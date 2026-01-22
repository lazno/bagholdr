/// Integration test for Oracle - tests real Yahoo Finance API calls.
/// Run manually: dart test test/integration/oracle_integration_test.dart
///
/// Note: This test makes real HTTP requests to Yahoo Finance.
/// It may fail if Yahoo is down or rate limiting.
import 'package:test/test.dart';
import 'package:bagholdr_server/src/oracle/yahoo.dart';

void main() {
  group('Yahoo Finance API (live)', () {
    test('fetchPriceData returns price for AAPL', () async {
      final result = await fetchPriceData('AAPL');

      expect(result.price, greaterThan(0));
      expect(result.currency, equals('USD'));
      expect(result.instrumentType, isNotEmpty);
    });

    test('fetchAllSymbolsFromIsin resolves known ISIN', () async {
      // Apple Inc. ISIN
      final results = await fetchAllSymbolsFromIsin('US0378331005');

      expect(results, isNotEmpty);
      expect(results.first.symbol, equals('AAPL'));
    });

    test('fetchHistoricalData returns candles for AAPL', () async {
      final data = await fetchHistoricalData('AAPL', range: '1y');

      expect(data.candles, isNotEmpty);
      expect(data.currency, equals('USD'));
      expect(data.candles.first.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(data.candles.first.close, greaterThan(0));
    });

    test('fetchFxRate returns valid rate for USD/EUR', () async {
      final rate = await fetchFxRate('USD', 'EUR');

      expect(rate, greaterThan(0));
      expect(rate, lessThan(2)); // Sanity check
    });

    test('fetchPriceData throws NOT_FOUND for invalid symbol', () async {
      expect(
        () => fetchPriceData('INVALIDTICKER12345'),
        throwsA(isA<YahooFinanceError>()),
      );
    });

    test('fetchPriceInEur converts USD price to EUR', () async {
      final result = await fetchPriceInEur(
        'US0378331005',
        knownTicker: 'AAPL',
      );

      expect(result.ticker, equals('AAPL'));
      expect(result.priceNative, greaterThan(0));
      expect(result.currency, equals('USD'));
      expect(result.priceEur, greaterThan(0));
      // EUR price should be different from USD (unless rates are 1:1)
      expect(result.priceEur, isNot(equals(result.priceNative)));
    });
  });
}
