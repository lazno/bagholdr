import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'clearPriceHistory endpoint',
    (sessionBuilder, endpoints) {
      test('clears price history for asset with Yahoo symbol', () async {
        // Insert test data
        final session = await sessionBuilder.build();

        // Create a test asset with Yahoo symbol using proper UUID v7
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'TEST123456789',
          ticker: 'TEST',
          yahooSymbol: 'TEST.MI',
          assetType: AssetType.etf,
          currency: 'EUR',
          name: 'Test Asset',
          archived: false,
        );
        await Asset.db.insert(session, [testAsset]);

        // Insert some price data for the symbol
        final dailyPrice = DailyPrice(
          ticker: 'TEST.MI',
          date: '2024-01-15',
          open: 100.0,
          high: 105.0,
          low: 99.0,
          close: 103.0,
          adjClose: 103.0,
          volume: 1000,
          currency: 'EUR',
          fetchedAt: DateTime.now(),
        );
        await DailyPrice.db.insert(session, [dailyPrice]);

        final intradayPrice = IntradayPrice(
          ticker: 'TEST.MI',
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          open: 102.0,
          high: 104.0,
          low: 101.0,
          close: 103.5,
          volume: 500,
          currency: 'EUR',
          fetchedAt: DateTime.now(),
        );
        await IntradayPrice.db.insert(session, [intradayPrice]);

        final priceCache = PriceCache(
          ticker: 'TEST.MI',
          priceNative: 103.5,
          currency: 'EUR',
          priceEur: 103.5,
          fetchedAt: DateTime.now(),
        );
        await PriceCache.db.insert(session, [priceCache]);

        // Call the endpoint
        final result = await endpoints.holdings.clearPriceHistory(
          sessionBuilder,
          assetId: assetId,
        );

        // Verify result
        expect(result.success, isTrue);
        expect(result.dailyPricesCleared, equals(1));
        expect(result.intradayPricesCleared, equals(1));
        expect(result.priceCacheCleared, isTrue);

        // Verify data was actually deleted
        final remainingDaily = await DailyPrice.db.find(
          session,
          where: (t) => t.ticker.equals('TEST.MI'),
        );
        expect(remainingDaily, isEmpty);

        final remainingIntraday = await IntradayPrice.db.find(
          session,
          where: (t) => t.ticker.equals('TEST.MI'),
        );
        expect(remainingIntraday, isEmpty);

        final remainingCache = await PriceCache.db.find(
          session,
          where: (t) => t.ticker.equals('TEST.MI'),
        );
        expect(remainingCache, isEmpty);
      });

      test('returns zero counts when asset has no Yahoo symbol', () async {
        final session = await sessionBuilder.build();

        // Create a test asset without Yahoo symbol
        final assetId = UuidValue.fromString(const Uuid().v7());
        final testAsset = Asset(
          id: assetId,
          isin: 'NOSY123456789',
          ticker: 'NOSY',
          yahooSymbol: null,  // No Yahoo symbol
          assetType: AssetType.stock,
          currency: 'EUR',
          name: 'No Symbol Asset',
          archived: false,
        );
        await Asset.db.insert(session, [testAsset]);

        // Call the endpoint
        final result = await endpoints.holdings.clearPriceHistory(
          sessionBuilder,
          assetId: assetId,
        );

        // Verify result - should succeed but with zero counts
        expect(result.success, isTrue);
        expect(result.dailyPricesCleared, equals(0));
        expect(result.intradayPricesCleared, equals(0));
        expect(result.dividendsCleared, equals(0));
        expect(result.priceCacheCleared, isFalse);
      });

      test('throws exception for non-existent asset', () async {
        final nonExistentId = UuidValue.fromString(const Uuid().v7());

        expect(
          () => endpoints.holdings.clearPriceHistory(
            sessionBuilder,
            assetId: nonExistentId,
          ),
          throwsException,
        );
      });
    },
    rollbackDatabase: RollbackDatabase.afterEach,
  );
}
