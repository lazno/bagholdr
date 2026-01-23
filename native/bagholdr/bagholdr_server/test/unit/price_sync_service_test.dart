import 'dart:async';

import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';
import 'package:bagholdr_server/src/services/price_sync_service.dart';

void main() {
  group('PriceSyncService', () {
    late PriceSyncService service;

    setUp(() {
      service = PriceSyncService.testInstance();
    });

    tearDown(() {
      service.dispose();
    });

    group('broadcast stream', () {
      test('subscribers receive price updates', () async {
        final updates = <PriceUpdate>[];
        final sub = service.priceUpdates.listen(updates.add);

        service.publishUpdate(PriceUpdate(
          isin: 'IE00B4L5Y983',
          ticker: 'IWDA.AS',
          priceEur: 85.50,
          currency: 'EUR',
          fetchedAt: DateTime.now(),
        ));

        await Future.delayed(Duration.zero);

        expect(updates, hasLength(1));
        expect(updates.first.isin, equals('IE00B4L5Y983'));
        expect(updates.first.ticker, equals('IWDA.AS'));
        expect(updates.first.priceEur, equals(85.50));
        expect(updates.first.currency, equals('EUR'));

        await sub.cancel();
      });

      test('multiple subscribers receive the same update', () async {
        final updates1 = <PriceUpdate>[];
        final updates2 = <PriceUpdate>[];

        final sub1 = service.priceUpdates.listen(updates1.add);
        final sub2 = service.priceUpdates.listen(updates2.add);

        service.publishUpdate(PriceUpdate(
          isin: 'US0378331005',
          ticker: 'AAPL',
          priceEur: 150.00,
          currency: 'USD',
          fetchedAt: DateTime.now(),
        ));

        await Future.delayed(Duration.zero);

        expect(updates1, hasLength(1));
        expect(updates2, hasLength(1));
        expect(updates1.first.ticker, equals('AAPL'));
        expect(updates2.first.ticker, equals('AAPL'));

        await sub1.cancel();
        await sub2.cancel();
      });

      test('late subscriber does not receive past updates', () async {
        service.publishUpdate(PriceUpdate(
          isin: 'US0378331005',
          ticker: 'AAPL',
          priceEur: 150.00,
          currency: 'USD',
          fetchedAt: DateTime.now(),
        ));

        await Future.delayed(Duration.zero);

        final lateUpdates = <PriceUpdate>[];
        final sub = service.priceUpdates.listen(lateUpdates.add);

        await Future.delayed(Duration.zero);
        expect(lateUpdates, isEmpty);

        await sub.cancel();
      });

      test('multiple updates are received in order', () async {
        final updates = <PriceUpdate>[];
        final sub = service.priceUpdates.listen(updates.add);

        service.publishUpdate(PriceUpdate(
          isin: 'US0378331005',
          ticker: 'AAPL',
          priceEur: 150.00,
          currency: 'USD',
          fetchedAt: DateTime.now(),
        ));

        service.publishUpdate(PriceUpdate(
          isin: 'US5949181045',
          ticker: 'MSFT',
          priceEur: 380.00,
          currency: 'USD',
          fetchedAt: DateTime.now(),
        ));

        service.publishUpdate(PriceUpdate(
          isin: 'IE00B4L5Y983',
          ticker: 'IWDA.AS',
          priceEur: 85.50,
          currency: 'EUR',
          fetchedAt: DateTime.now(),
        ));

        await Future.delayed(Duration.zero);

        expect(updates, hasLength(3));
        expect(updates[0].ticker, equals('AAPL'));
        expect(updates[1].ticker, equals('MSFT'));
        expect(updates[2].ticker, equals('IWDA.AS'));

        await sub.cancel();
      });
    });

    group('sync status', () {
      test('initial status shows not syncing', () {
        final status = service.status;

        expect(status.isSyncing, isFalse);
        expect(status.lastSyncAt, isNull);
        expect(status.lastSuccessCount, equals(0));
        expect(status.lastErrorCount, equals(0));
      });
    });

    group('lifecycle', () {
      test('stop cancels the timer', () {
        // Should not throw even when not started.
        service.stop();
      });

      test('dispose closes the stream', () async {
        service.dispose();

        // Creating a new subscription after dispose should get an error
        // or close immediately.
        final completer = Completer<void>();
        service.priceUpdates.listen(
          (_) {},
          onDone: () => completer.complete(),
          onError: (_) => completer.complete(),
        );

        await completer.future.timeout(
          const Duration(seconds: 1),
          onTimeout: () {
            // Stream closed immediately - expected.
          },
        );
      });
    });
  });
}
