import 'dart:async';

import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/services/price_stream_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceStreamProvider', () {
    late StreamController<PriceUpdate> controller;
    late PriceStreamProvider provider;

    setUp(() {
      controller = StreamController<PriceUpdate>.broadcast();
      provider = PriceStreamProvider(
        streamFactory: () => controller.stream,
      );
    });

    tearDown(() {
      provider.dispose();
      controller.close();
    });

    test('initial state is disconnected', () {
      expect(provider.connectionStatus, equals(ConnectionStatus.disconnected));
      expect(provider.lastUpdateAt, isNull);
      expect(provider.prices, isEmpty);
    });

    test('connect transitions to connected', () {
      provider.connect();
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));
    });

    test('connect while already connected does nothing', () {
      provider.connect();
      provider.connect(); // should not throw or create duplicate subscriptions
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));
    });

    test('price updates are stored by ISIN', () async {
      provider.connect();

      controller.add(PriceUpdate(
        isin: 'IE00B4L5Y983',
        ticker: 'IWDA.AS',
        priceEur: 85.50,
        currency: 'EUR',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);

      expect(provider.prices, hasLength(1));
      expect(provider.getPrice('IE00B4L5Y983'), isNotNull);
      expect(provider.getPrice('IE00B4L5Y983')!.priceEur, equals(85.50));
    });

    test('multiple updates for same ISIN replaces value', () async {
      provider.connect();

      controller.add(PriceUpdate(
        isin: 'IE00B4L5Y983',
        ticker: 'IWDA.AS',
        priceEur: 85.50,
        currency: 'EUR',
        fetchedAt: DateTime.now(),
      ));

      controller.add(PriceUpdate(
        isin: 'IE00B4L5Y983',
        ticker: 'IWDA.AS',
        priceEur: 86.00,
        currency: 'EUR',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);

      expect(provider.prices, hasLength(1));
      expect(provider.getPrice('IE00B4L5Y983')!.priceEur, equals(86.00));
    });

    test('updates lastUpdateAt on new price', () async {
      provider.connect();

      expect(provider.lastUpdateAt, isNull);

      controller.add(PriceUpdate(
        isin: 'US0378331005',
        ticker: 'AAPL',
        priceEur: 150.00,
        currency: 'USD',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);

      expect(provider.lastUpdateAt, isNotNull);
    });

    test('isRecentlyUpdated returns true after update', () async {
      provider.connect();

      controller.add(PriceUpdate(
        isin: 'US0378331005',
        ticker: 'AAPL',
        priceEur: 150.00,
        currency: 'USD',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);

      expect(provider.isRecentlyUpdated('US0378331005'), isTrue);
      expect(provider.isRecentlyUpdated('UNKNOWN'), isFalse);
    });

    test('isRecentlyUpdated clears after 5 seconds', () {
      fakeAsync((async) {
        provider.connect();

        controller.add(PriceUpdate(
          isin: 'US0378331005',
          ticker: 'AAPL',
          priceEur: 150.00,
          currency: 'USD',
          fetchedAt: DateTime.now(),
        ));

        async.elapse(const Duration(milliseconds: 100));
        expect(provider.isRecentlyUpdated('US0378331005'), isTrue);

        async.elapse(const Duration(seconds: 5));
        expect(provider.isRecentlyUpdated('US0378331005'), isFalse);
      });
    });

    test('disconnect cancels subscription', () async {
      provider.connect();
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));

      provider.disconnect();
      expect(provider.connectionStatus, equals(ConnectionStatus.disconnected));

      // Updates after disconnect should not be received.
      controller.add(PriceUpdate(
        isin: 'US0378331005',
        ticker: 'AAPL',
        priceEur: 150.00,
        currency: 'USD',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);
      expect(provider.prices, isEmpty);
    });

    test('stream error transitions to disconnected', () async {
      provider.connect();
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));

      controller.addError('Connection lost');
      await Future.delayed(Duration.zero);

      expect(provider.connectionStatus, equals(ConnectionStatus.disconnected));
    });

    test('stream done transitions to disconnected', () async {
      provider.connect();
      expect(provider.connectionStatus, equals(ConnectionStatus.connected));

      await controller.close();
      await Future.delayed(Duration.zero);

      expect(provider.connectionStatus, equals(ConnectionStatus.disconnected));
    });

    test('reconnects after error with delay', () {
      fakeAsync((async) {
        // Use a controller that errors but then a new stream works.
        var callCount = 0;
        final errorController = StreamController<PriceUpdate>.broadcast();
        final successController = StreamController<PriceUpdate>.broadcast();

        final reconnectProvider = PriceStreamProvider(
          streamFactory: () {
            callCount++;
            if (callCount == 1) {
              return errorController.stream;
            }
            return successController.stream;
          },
        );

        reconnectProvider.connect();
        expect(reconnectProvider.connectionStatus,
            equals(ConnectionStatus.connected));
        expect(callCount, equals(1));

        // Trigger error.
        errorController.addError('Network error');
        async.elapse(const Duration(milliseconds: 100));
        expect(reconnectProvider.connectionStatus,
            equals(ConnectionStatus.disconnected));

        // Wait for reconnect timer (10 seconds).
        async.elapse(const Duration(seconds: 10));
        expect(callCount, equals(2));
        expect(reconnectProvider.connectionStatus,
            equals(ConnectionStatus.connected));

        reconnectProvider.dispose();
        errorController.close();
        successController.close();
      });
    });

    test('notifies listeners on price update', () async {
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.connect();

      controller.add(PriceUpdate(
        isin: 'US0378331005',
        ticker: 'AAPL',
        priceEur: 150.00,
        currency: 'USD',
        fetchedAt: DateTime.now(),
      ));

      await Future.delayed(Duration.zero);

      // At least 1 notification for the update (may be more for connection
      // status change).
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('getPrice returns null for unknown ISIN', () {
      expect(provider.getPrice('UNKNOWN'), isNull);
    });
  });
}
