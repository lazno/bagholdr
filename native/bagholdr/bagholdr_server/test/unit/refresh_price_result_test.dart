import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('RefreshPriceResult', () {
    test('creates successful result with all fields', () {
      final now = DateTime.now();
      final result = RefreshPriceResult(
        success: true,
        ticker: 'SWDA.MI',
        priceEur: 89.42,
        currency: 'EUR',
        fetchedAt: now,
      );

      expect(result.success, isTrue);
      expect(result.ticker, equals('SWDA.MI'));
      expect(result.priceEur, equals(89.42));
      expect(result.currency, equals('EUR'));
      expect(result.fetchedAt, equals(now));
      expect(result.errorMessage, isNull);
    });

    test('creates error result for asset not found', () {
      final result = RefreshPriceResult(
        success: false,
        errorMessage: 'Asset not found: 123e4567-e89b-12d3-a456-426614174000',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Asset not found'));
      expect(result.ticker, isNull);
      expect(result.priceEur, isNull);
      expect(result.currency, isNull);
      expect(result.fetchedAt, isNull);
    });

    test('creates error result for missing Yahoo symbol', () {
      final result = RefreshPriceResult(
        success: false,
        errorMessage: 'No Yahoo symbol set for SWDA. Set a symbol first.',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('No Yahoo symbol'));
      expect(result.ticker, isNull);
    });

    test('creates error result for fetch failure', () {
      final result = RefreshPriceResult(
        success: false,
        errorMessage: 'Failed to fetch price: Connection timeout',
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Failed to fetch price'));
    });

    test('serializes to JSON correctly', () {
      final now = DateTime.utc(2024, 1, 15, 10, 30, 0);
      final result = RefreshPriceResult(
        success: true,
        ticker: 'AAPL',
        priceEur: 185.50,
        currency: 'USD',
        fetchedAt: now,
      );

      final json = result.toJson();
      expect(json['success'], isTrue);
      expect(json['ticker'], equals('AAPL'));
      expect(json['priceEur'], equals(185.50));
      expect(json['currency'], equals('USD'));
      expect(json['fetchedAt'], equals('2024-01-15T10:30:00.000Z'));
      expect(json['errorMessage'], isNull);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'success': true,
        'ticker': 'MSFT',
        'priceEur': 395.25,
        'currency': 'USD',
        'fetchedAt': '2024-01-15T10:30:00.000Z',
        'errorMessage': null,
      };

      final result = RefreshPriceResult.fromJson(json);
      expect(result.success, isTrue);
      expect(result.ticker, equals('MSFT'));
      expect(result.priceEur, equals(395.25));
      expect(result.currency, equals('USD'));
      expect(result.fetchedAt, isNotNull);
      expect(result.fetchedAt!.year, equals(2024));
    });

    test('deserializes error result from JSON', () {
      final json = {
        'success': false,
        'ticker': null,
        'priceEur': null,
        'currency': null,
        'fetchedAt': null,
        'errorMessage': 'Asset not found',
      };

      final result = RefreshPriceResult.fromJson(json);
      expect(result.success, isFalse);
      expect(result.errorMessage, equals('Asset not found'));
      expect(result.ticker, isNull);
      expect(result.priceEur, isNull);
    });
  });
}
