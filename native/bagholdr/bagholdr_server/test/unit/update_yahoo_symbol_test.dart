import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('UpdateYahooSymbolResult', () {
    test('creates result with all fields', () {
      final result = UpdateYahooSymbolResult(
        success: true,
        newSymbol: 'SWDA.MI',
        dailyPricesCleared: 100,
        intradayPricesCleared: 50,
        dividendsCleared: 5,
      );

      expect(result.success, isTrue);
      expect(result.newSymbol, equals('SWDA.MI'));
      expect(result.dailyPricesCleared, equals(100));
      expect(result.intradayPricesCleared, equals(50));
      expect(result.dividendsCleared, equals(5));
    });

    test('allows null newSymbol for clearing symbol', () {
      final result = UpdateYahooSymbolResult(
        success: true,
        newSymbol: null,
        dailyPricesCleared: 100,
        intradayPricesCleared: 50,
        dividendsCleared: 5,
      );

      expect(result.success, isTrue);
      expect(result.newSymbol, isNull);
      expect(result.dailyPricesCleared, equals(100));
    });

    test('handles zero cleared counts for same symbol update', () {
      final result = UpdateYahooSymbolResult(
        success: true,
        newSymbol: 'SWDA.MI',
        dailyPricesCleared: 0,
        intradayPricesCleared: 0,
        dividendsCleared: 0,
      );

      expect(result.success, isTrue);
      expect(result.dailyPricesCleared, equals(0));
      expect(result.intradayPricesCleared, equals(0));
      expect(result.dividendsCleared, equals(0));
    });

    test('serializes to JSON correctly', () {
      final result = UpdateYahooSymbolResult(
        success: true,
        newSymbol: 'AAPL',
        dailyPricesCleared: 200,
        intradayPricesCleared: 100,
        dividendsCleared: 10,
      );

      final json = result.toJson();
      expect(json['success'], isTrue);
      expect(json['newSymbol'], equals('AAPL'));
      expect(json['dailyPricesCleared'], equals(200));
      expect(json['intradayPricesCleared'], equals(100));
      expect(json['dividendsCleared'], equals(10));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'success': true,
        'newSymbol': 'MSFT',
        'dailyPricesCleared': 150,
        'intradayPricesCleared': 75,
        'dividendsCleared': 8,
      };

      final result = UpdateYahooSymbolResult.fromJson(json);
      expect(result.success, isTrue);
      expect(result.newSymbol, equals('MSFT'));
      expect(result.dailyPricesCleared, equals(150));
      expect(result.intradayPricesCleared, equals(75));
      expect(result.dividendsCleared, equals(8));
    });

    test('deserializes null newSymbol from JSON', () {
      final json = {
        'success': true,
        'newSymbol': null,
        'dailyPricesCleared': 50,
        'intradayPricesCleared': 25,
        'dividendsCleared': 2,
      };

      final result = UpdateYahooSymbolResult.fromJson(json);
      expect(result.success, isTrue);
      expect(result.newSymbol, isNull);
    });
  });
}
