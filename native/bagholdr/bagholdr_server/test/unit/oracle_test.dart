import 'package:test/test.dart';
import 'package:bagholdr_server/src/oracle/rate_limiter.dart';
import 'package:bagholdr_server/src/oracle/yahoo.dart';

void main() {
  group('YahooRateLimiter', () {
    test('processes requests sequentially', () async {
      final limiter = YahooRateLimiter(minDelayMs: 0);
      final order = <int>[];

      final futures = [
        limiter.enqueue(() async {
          order.add(1);
          return 'a';
        }),
        limiter.enqueue(() async {
          order.add(2);
          return 'b';
        }),
        limiter.enqueue(() async {
          order.add(3);
          return 'c';
        }),
      ];

      final results = await Future.wait(futures);
      expect(results, equals(['a', 'b', 'c']));
      expect(order, equals([1, 2, 3]));
    });

    test('enforces minimum delay between requests', () async {
      final limiter = YahooRateLimiter(minDelayMs: 50);
      final timestamps = <int>[];

      await limiter.enqueue(() async {
        timestamps.add(DateTime.now().millisecondsSinceEpoch);
        return null;
      });
      await limiter.enqueue(() async {
        timestamps.add(DateTime.now().millisecondsSinceEpoch);
        return null;
      });
      await limiter.enqueue(() async {
        timestamps.add(DateTime.now().millisecondsSinceEpoch);
        return null;
      });

      // Verify delays between requests
      expect(timestamps[1] - timestamps[0], greaterThanOrEqualTo(45));
      expect(timestamps[2] - timestamps[1], greaterThanOrEqualTo(45));
    });

    test('propagates errors without breaking the queue', () async {
      final limiter = YahooRateLimiter(minDelayMs: 0);

      final future1 = limiter.enqueue(() async => 'first');
      final future2 = limiter.enqueue(() async => throw Exception('fail'));
      final future3 = limiter.enqueue(() async => 'third');

      expect(await future1, equals('first'));
      expect(future2, throwsA(isA<Exception>()));
      expect(await future3, equals('third'));
    });

    test('tracks total request count', () async {
      final limiter = YahooRateLimiter(minDelayMs: 0);

      expect(limiter.totalRequests, equals(0));

      await limiter.enqueue(() async => null);
      await limiter.enqueue(() async => null);

      expect(limiter.totalRequests, equals(2));
    });

    test('reports queue length', () async {
      final limiter = YahooRateLimiter(minDelayMs: 100);

      // Enqueue several requests without awaiting
      limiter.enqueue(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return null;
      });
      limiter.enqueue(() async => null);
      limiter.enqueue(() async => null);

      // Queue should have items (first is processing, rest queued)
      // Allow a small window for processing to start
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(limiter.queueLength, greaterThanOrEqualTo(1));
    });
  });

  group('adjustConversionRate', () {
    test('divides by 100 for GBp (pence)', () {
      expect(adjustConversionRate('GBp', 0.85), closeTo(0.0085, 0.0001));
    });

    test('returns rate unchanged for EUR', () {
      expect(adjustConversionRate('EUR', 1.0), equals(1.0));
    });

    test('returns rate unchanged for USD', () {
      expect(adjustConversionRate('USD', 0.92), equals(0.92));
    });

    test('returns rate unchanged for GBP (uppercase, not pence)', () {
      expect(adjustConversionRate('GBP', 0.85), equals(0.85));
    });
  });

  group('YahooFinanceError', () {
    test('stores message and code', () {
      final error = YahooFinanceError('Rate limited', 'RATE_LIMITED');
      expect(error.message, equals('Rate limited'));
      expect(error.code, equals('RATE_LIMITED'));
    });

    test('toString includes code and message', () {
      final error = YahooFinanceError('Not found', 'NOT_FOUND');
      expect(error.toString(), contains('NOT_FOUND'));
      expect(error.toString(), contains('Not found'));
    });
  });

  group('YahooPriceInfo', () {
    test('stores all fields', () {
      final now = DateTime.now();
      final info = YahooPriceInfo(
        price: 150.25,
        currency: 'USD',
        instrumentType: 'EQUITY',
        timestamp: now,
      );
      expect(info.price, equals(150.25));
      expect(info.currency, equals('USD'));
      expect(info.instrumentType, equals('EQUITY'));
      expect(info.timestamp, equals(now));
    });
  });

  group('YahooSearchResult', () {
    test('stores required and optional fields', () {
      final result = YahooSearchResult(
        symbol: 'AAPL',
        exchange: 'NMS',
        exchangeDisplay: 'NASDAQ',
        quoteType: 'EQUITY',
        shortname: 'Apple Inc.',
      );
      expect(result.symbol, equals('AAPL'));
      expect(result.exchange, equals('NMS'));
      expect(result.exchangeDisplay, equals('NASDAQ'));
    });

    test('optional fields default to null', () {
      final result = YahooSearchResult(symbol: 'AAPL');
      expect(result.exchange, isNull);
      expect(result.exchangeDisplay, isNull);
      expect(result.quoteType, isNull);
      expect(result.shortname, isNull);
    });
  });

  group('PriceInEurResult', () {
    test('stores all conversion data', () {
      final result = PriceInEurResult(
        ticker: 'AAPL',
        priceNative: 150.0,
        currency: 'USD',
        priceEur: 138.0,
        instrumentType: 'EQUITY',
      );
      expect(result.ticker, equals('AAPL'));
      expect(result.priceNative, equals(150.0));
      expect(result.currency, equals('USD'));
      expect(result.priceEur, equals(138.0));
      expect(result.instrumentType, equals('EQUITY'));
    });
  });

  group('YahooCandle', () {
    test('stores OHLCV data', () {
      final candle = YahooCandle(
        date: '2024-01-15',
        open: 100.0,
        high: 105.0,
        low: 99.0,
        close: 103.0,
        adjClose: 102.5,
        volume: 1000000,
      );
      expect(candle.date, equals('2024-01-15'));
      expect(candle.open, equals(100.0));
      expect(candle.high, equals(105.0));
      expect(candle.low, equals(99.0));
      expect(candle.close, equals(103.0));
      expect(candle.adjClose, equals(102.5));
      expect(candle.volume, equals(1000000));
    });
  });

  group('YahooHistoricalData', () {
    test('stores candles, dividends, and currency', () {
      final data = YahooHistoricalData(
        candles: [
          YahooCandle(
            date: '2024-01-15',
            open: 100.0,
            high: 105.0,
            low: 99.0,
            close: 103.0,
            adjClose: 102.5,
            volume: 1000000,
          ),
        ],
        dividends: [
          YahooDividend(exDate: '2024-03-01', amount: 0.25),
        ],
        currency: 'USD',
      );
      expect(data.candles.length, equals(1));
      expect(data.dividends.length, equals(1));
      expect(data.currency, equals('USD'));
      expect(data.dividends.first.amount, equals(0.25));
    });
  });
}
