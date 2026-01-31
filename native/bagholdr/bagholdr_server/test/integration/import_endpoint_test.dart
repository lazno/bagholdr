import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Import Endpoint', (sessionBuilder, endpoints) {
    // Create a test account ID that will be used across tests
    late UuidValue testAccountId;

    setUp(() async {
      // Create a test account before each test
      final account = await endpoints.account.createAccount(
        sessionBuilder,
        name: 'Test Account',
        accountType: 'real',
      );
      testAccountId = account.id!;
    });

    group('importDirectaCsv', () {
      test('imports orders and creates assets', () async {
        final csv = _buildCSV([
          '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,Vanguard FTSE All-World,10,1234.56,0,EUR,REF001',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(1));
        expect(result.assetsCreated, equals(1));
        expect(result.holdingsUpdated, equals(1));
        expect(result.errors, isEmpty);
      });

      test('reuses existing asset by ISIN', () async {
        // First import
        final csv1 = _buildCSV([
          '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,Vanguard FTSE All-World,10,1000.00,0,EUR,REF001',
        ]);

        await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv1,
          accountId: testAccountId,
        );

        // Second import with same ISIN
        final csv2 = _buildCSV([
          '16-03-2024,16-03-2024,Buy,VWCE,IE00BK5BQT80,123457,Vanguard FTSE All-World,5,500.00,0,EUR,REF002',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv2,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(1));
        expect(result.assetsCreated, equals(0)); // No new assets
        expect(result.holdingsUpdated, equals(1));
      });

      test('replaces duplicate orders by reference', () async {
        final csv = _buildCSV([
          '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,ETF,10,1000.00,0,EUR,REF001',
        ]);

        // First import
        await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        // Same CSV again
        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        // Orders with same reference are replaced, not skipped
        expect(result.ordersImported, equals(1));
        expect(result.warnings.length, equals(1));
        expect(result.warnings.first, contains('Replaced'));
      });

      test('derives holdings correctly with buys and sells', () async {
        final csv = _buildCSV([
          '01-01-2024,01-01-2024,Buy,VWCE,IE00BK5BQT80,101,ETF,100,10000.00,0,EUR,REF101',
          '02-01-2024,02-01-2024,Buy,VWCE,IE00BK5BQT80,102,ETF,50,5500.00,0,EUR,REF102',
          '03-01-2024,03-01-2024,Commissions,VWCE,IE00BK5BQT80,103,Comm,0,10.00,0,EUR,REF103',
          '04-01-2024,04-01-2024,Sell,VWCE,IE00BK5BQT80,104,ETF,-30,3300.00,0,EUR,REF104',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(4));
        expect(result.holdingsUpdated, equals(1));
        expect(result.errors, isEmpty);

        // Verify holdings via direct DB query would require session access
        // The derive_holdings logic is tested separately in derive_holdings_test.dart
      });

      test('handles multiple assets in same import', () async {
        final csv = _buildCSV([
          '01-01-2024,01-01-2024,Buy,VWCE,IE00BK5BQT80,101,Vanguard,10,1000.00,0,EUR,REF201',
          '01-01-2024,01-01-2024,Buy,AAPL,US0378331005,102,Apple,5,900.00,1000.00,USD,REF202',
          '02-01-2024,02-01-2024,Buy,MSFT,US5949181045,103,Microsoft,3,750.00,800.00,USD,REF203',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(3));
        expect(result.assetsCreated, equals(3));
        expect(result.holdingsUpdated, equals(3));
      });

      test('returns parse errors for invalid CSV', () async {
        final csv = _buildCSV([
          'invalid-date,15-03-2024,Buy,VWCE,IE00BK5BQT80,123,ETF,10,1000.00,0,EUR,REF301',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(0));
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('Invalid date'));
      });

      test('returns error for file too short', () async {
        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: 'line1\nline2\nline3',
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(0));
        expect(result.errors.length, equals(1));
        expect(result.errors.first, contains('too short'));
      });

      test('handles non-EUR currency with currency amount', () async {
        final csv = _buildCSV([
          '15-03-2024,15-03-2024,Buy,AAPL,US0378331005,123,Apple Inc,10,920.00,1000.00,USD,REF401',
        ]);

        final result = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv,
          accountId: testAccountId,
        );

        expect(result.ordersImported, equals(1));
        expect(result.assetsCreated, equals(1));
        expect(result.errors, isEmpty);
      });

      test('removes holdings when position is sold completely', () async {
        // First import: buy 10 shares
        final csv1 = _buildCSV([
          '01-01-2024,01-01-2024,Buy,VWCE,IE00BK5BQT80,101,ETF,10,1000.00,0,EUR,REF501',
        ]);

        final result1 = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv1,
          accountId: testAccountId,
        );
        expect(result1.holdingsUpdated, equals(1));

        // Second import: sell all 10 shares
        final csv2 = _buildCSV([
          '02-01-2024,02-01-2024,Sell,VWCE,IE00BK5BQT80,102,ETF,-10,1100.00,0,EUR,REF502',
        ]);

        final result2 = await endpoints.import.importDirectaCsv(
          sessionBuilder,
          csvContent: csv2,
          accountId: testAccountId,
        );

        // Holdings should be 0 (deleted) after selling everything
        expect(result2.ordersImported, equals(1));
        expect(result2.holdingsUpdated, equals(0)); // No holdings left
      });
    });
  });
}

/// Build a valid Directa CSV with header lines
String _buildCSV(List<String> dataLines) {
  final header = [
    'ACCOUNT : C6766 Lazzeri Norbert',
    'Line 2',
    'Line 3',
    'Line 4',
    'Line 5',
    'Line 6',
    'Line 7',
    'Line 8',
    'Line 9',
    'Date,Value Date,Type,Ticker,ISIN,Protocol,Description,Quantity,Amount EUR,Currency Amount,Currency,Order Ref',
  ];

  return [...header, ...dataLines].join('\n');
}
