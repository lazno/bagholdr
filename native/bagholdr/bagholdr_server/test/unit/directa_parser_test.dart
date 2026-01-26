import 'package:test/test.dart';
import 'package:bagholdr_server/src/import/directa_parser.dart';

void main() {
  group('convertItalianDate', () {
    test('converts DD-MM-YYYY to YYYY-MM-DD', () {
      expect(convertItalianDate('15-03-2024'), equals('2024-03-15'));
      expect(convertItalianDate('01-01-2020'), equals('2020-01-01'));
      expect(convertItalianDate('31-12-2023'), equals('2023-12-31'));
    });

    test('handles whitespace', () {
      expect(convertItalianDate('  15-03-2024  '), equals('2024-03-15'));
    });

    test('returns null for invalid format', () {
      expect(convertItalianDate('2024-03-15'), isNull); // Wrong format
      expect(convertItalianDate('15/03/2024'), isNull); // Wrong separator
      expect(convertItalianDate('15-3-2024'), isNull); // Missing leading zero
      expect(convertItalianDate('invalid'), isNull);
      expect(convertItalianDate(''), isNull);
    });
  });

  group('extractAccountName', () {
    test('extracts account ID from header line', () {
      expect(extractAccountName('ACCOUNT : C6766 Lazzeri Norbert'), equals('C6766'));
    });

    test('handles different formatting', () {
      expect(extractAccountName('ACCOUNT :  ABC123  Name'), equals('ABC123'));
    });

    test('returns null if pattern not found', () {
      expect(extractAccountName('No account here'), isNull);
      expect(extractAccountName(''), isNull);
    });
  });

  group('parseCSVLine', () {
    test('parses simple comma-separated values', () {
      expect(parseCSVLine('a,b,c'), equals(['a', 'b', 'c']));
    });

    test('handles quoted fields', () {
      expect(parseCSVLine('a,"b,c",d'), equals(['a', 'b,c', 'd']));
    });

    test('handles empty fields', () {
      expect(parseCSVLine('a,,c'), equals(['a', '', 'c']));
    });

    test('trims whitespace', () {
      expect(parseCSVLine(' a , b , c '), equals(['a', 'b', 'c']));
    });

    test('handles quoted fields with spaces', () {
      expect(parseCSVLine('"hello world",test'), equals(['hello world', 'test']));
    });
  });

  group('parseNumber', () {
    test('parses positive numbers', () {
      expect(parseNumber('123.45'), equals(123.45));
      expect(parseNumber('100'), equals(100.0));
    });

    test('parses negative numbers', () {
      expect(parseNumber('-123.45'), equals(-123.45));
    });

    test('handles whitespace', () {
      expect(parseNumber('  123.45  '), equals(123.45));
    });

    test('returns 0 for empty string', () {
      expect(parseNumber(''), equals(0.0));
      expect(parseNumber('   '), equals(0.0));
    });

    test('returns 0 for invalid input', () {
      expect(parseNumber('abc'), equals(0.0));
    });
  });

  group('isImportableTransaction', () {
    test('returns true for importable types', () {
      expect(isImportableTransaction('Buy'), isTrue);
      expect(isImportableTransaction('Sell'), isTrue);
      expect(isImportableTransaction('Commissions'), isTrue);
    });

    test('returns false for other types', () {
      expect(isImportableTransaction('Wire transfer payment'), isFalse);
      expect(isImportableTransaction('Cap.gain tax'), isFalse);
      expect(isImportableTransaction('Portfolio stamp duty*'), isFalse);
      expect(isImportableTransaction('Etf withholding tax'), isFalse);
      expect(isImportableTransaction('Bond accrd int wd'), isFalse);
      expect(isImportableTransaction('Bonds coupon pmt'), isFalse);
    });
  });

  group('mapTransactionType', () {
    test('maps Buy to buy', () {
      expect(mapTransactionType('Buy'), equals(DirectaTransactionType.buy));
    });

    test('maps Sell to sell', () {
      expect(mapTransactionType('Sell'), equals(DirectaTransactionType.sell));
    });

    test('maps Commissions to commission', () {
      expect(mapTransactionType('Commissions'), equals(DirectaTransactionType.commission));
    });

    test('returns null for unknown types', () {
      expect(mapTransactionType('Unknown'), isNull);
    });
  });

  group('parseDirectaCSV', () {
    test('returns error for file too short', () {
      final result = parseDirectaCSV('line1\nline2\nline3');
      expect(result.errors.length, equals(1));
      expect(result.errors.first.message, contains('too short'));
    });

    test('parses valid CSV with buy order', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,Vanguard FTSE All-World,10,1234.56,0,EUR,REF001',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.errors, isEmpty);
      expect(result.orders.length, equals(1));
      expect(result.accountName, equals('C6766'));

      final order = result.orders.first;
      expect(order.isin, equals('IE00BK5BQT80'));
      expect(order.ticker, equals('VWCE'));
      expect(order.name, equals('Vanguard FTSE All-World'));
      expect(order.transactionType, equals(DirectaTransactionType.buy));
      expect(order.quantity, equals(10.0));
      expect(order.amountEur, equals(1234.56));
      expect(order.currency, equals('EUR'));
      expect(order.orderReference, equals('REF001'));
    });

    test('parses sell order with negative quantity', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Sell,VWCE,IE00BK5BQT80,123456,Vanguard FTSE All-World,-10,1234.56,0,EUR,REF002',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders.length, equals(1));
      final order = result.orders.first;
      expect(order.transactionType, equals(DirectaTransactionType.sell));
      expect(order.quantity, equals(-10.0)); // Negative for sells
    });

    test('parses commission with zero quantity', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Commissions,VWCE,IE00BK5BQT80,123456,Commission,0,5.00,0,EUR,REF003',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders.length, equals(1));
      final order = result.orders.first;
      expect(order.transactionType, equals(DirectaTransactionType.commission));
      expect(order.quantity, equals(0.0));
      expect(order.amountEur, equals(5.0));
    });

    test('skips non-importable transaction types', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,Buy Order,10,1000.00,0,EUR,REF001',
        '15-03-2024,15-03-2024,Wire transfer payment,,,123456,Wire,0,500.00,0,EUR,',
        '15-03-2024,15-03-2024,Cap.gain tax,VWCE,IE00BK5BQT80,123456,Tax,0,10.00,0,EUR,',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders.length, equals(1));
      expect(result.skippedRows, equals(2));
    });

    test('handles currency amount for non-EUR trades', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,AAPL,US0378331005,123456,Apple Inc,5,450.00,500.00,USD,REF004',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders.length, equals(1));
      final order = result.orders.first;
      expect(order.amountEur, equals(450.0));
      expect(order.currencyAmount, equals(500.0));
      expect(order.currency, equals('USD'));
    });

    test('defaults currency to EUR if empty', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,ETF,10,1000.00,0,,REF005',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders.first.currency, equals('EUR'));
    });

    test('reports error for missing ISIN', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,VWCE,,123456,ETF,10,1000.00,0,EUR,REF006',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders, isEmpty);
      expect(result.errors.length, equals(1));
      expect(result.errors.first.message, contains('Missing ISIN'));
    });

    test('reports error for invalid date', () {
      final csv = _buildCSV([
        'invalid-date,15-03-2024,Buy,VWCE,IE00BK5BQT80,123456,ETF,10,1000.00,0,EUR,REF007',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders, isEmpty);
      expect(result.errors.length, equals(1));
      expect(result.errors.first.message, contains('Invalid date'));
    });

    test('reports error for invalid column count', () {
      final csv = _buildCSV([
        '15-03-2024,15-03-2024,Buy,VWCE,IE00BK5BQT80', // Only 5 columns
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.orders, isEmpty);
      expect(result.errors.length, equals(1));
      expect(result.errors.first.message, contains('Invalid column count'));
    });

    test('parses multiple orders', () {
      final csv = _buildCSV([
        '01-01-2024,01-01-2024,Buy,VWCE,IE00BK5BQT80,123,ETF1,10,1000.00,0,EUR,R1',
        '02-01-2024,02-01-2024,Buy,AAPL,US0378331005,124,Stock,5,500.00,550.00,USD,R2',
        '03-01-2024,03-01-2024,Commissions,VWCE,IE00BK5BQT80,125,Comm,0,2.50,0,EUR,R3',
        '04-01-2024,04-01-2024,Sell,VWCE,IE00BK5BQT80,126,ETF1,-3,300.00,0,EUR,R4',
      ]);

      final result = parseDirectaCSV(csv);

      expect(result.errors, isEmpty);
      expect(result.orders.length, equals(4));
      expect(result.orders[0].transactionType, equals(DirectaTransactionType.buy));
      expect(result.orders[1].transactionType, equals(DirectaTransactionType.buy));
      expect(result.orders[2].transactionType, equals(DirectaTransactionType.commission));
      expect(result.orders[3].transactionType, equals(DirectaTransactionType.sell));
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
