import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('ClearPriceHistoryResult', () {
    test('creates result with all fields', () {
      final result = ClearPriceHistoryResult(
        success: true,
        dailyPricesCleared: 100,
        intradayPricesCleared: 50,
        dividendsCleared: 5,
        priceCacheCleared: true,
      );

      expect(result.success, isTrue);
      expect(result.dailyPricesCleared, equals(100));
      expect(result.intradayPricesCleared, equals(50));
      expect(result.dividendsCleared, equals(5));
      expect(result.priceCacheCleared, isTrue);
    });

    test('handles zero cleared counts when no data exists', () {
      final result = ClearPriceHistoryResult(
        success: true,
        dailyPricesCleared: 0,
        intradayPricesCleared: 0,
        dividendsCleared: 0,
        priceCacheCleared: false,
      );

      expect(result.success, isTrue);
      expect(result.dailyPricesCleared, equals(0));
      expect(result.intradayPricesCleared, equals(0));
      expect(result.dividendsCleared, equals(0));
      expect(result.priceCacheCleared, isFalse);
    });

    test('serializes to JSON correctly', () {
      final result = ClearPriceHistoryResult(
        success: true,
        dailyPricesCleared: 200,
        intradayPricesCleared: 100,
        dividendsCleared: 10,
        priceCacheCleared: true,
      );

      final json = result.toJson();
      expect(json['success'], isTrue);
      expect(json['dailyPricesCleared'], equals(200));
      expect(json['intradayPricesCleared'], equals(100));
      expect(json['dividendsCleared'], equals(10));
      expect(json['priceCacheCleared'], isTrue);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'success': true,
        'dailyPricesCleared': 150,
        'intradayPricesCleared': 75,
        'dividendsCleared': 8,
        'priceCacheCleared': false,
      };

      final result = ClearPriceHistoryResult.fromJson(json);
      expect(result.success, isTrue);
      expect(result.dailyPricesCleared, equals(150));
      expect(result.intradayPricesCleared, equals(75));
      expect(result.dividendsCleared, equals(8));
      expect(result.priceCacheCleared, isFalse);
    });
  });
}
