import 'dart:async';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../oracle/cache.dart';
import '../oracle/historical.dart';

/// Background service that periodically fetches prices for held assets
/// and broadcasts updates to connected streaming clients.
class PriceSyncService {
  static final PriceSyncService instance = PriceSyncService._();
  PriceSyncService._();

  /// Creates a fresh instance for testing (not the singleton).
  factory PriceSyncService.testInstance() => PriceSyncService._();

  /// Broadcast controller - streaming endpoints listen to this.
  final StreamController<PriceUpdate> _controller =
      StreamController<PriceUpdate>.broadcast();

  /// Stream of price updates for subscribers.
  Stream<PriceUpdate> get priceUpdates => _controller.stream;

  Timer? _timer;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  int _lastSuccessCount = 0;
  int _lastErrorCount = 0;

  /// Current sync status.
  SyncStatus get status => SyncStatus(
        isSyncing: _isSyncing,
        lastSyncAt: _lastSyncAt,
        lastSuccessCount: _lastSuccessCount,
        lastErrorCount: _lastErrorCount,
      );

  /// Start the periodic sync timer. Call from server.dart after pod.start().
  void start(
    Serverpod pod, {
    Duration interval = const Duration(minutes: 5),
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _runSync(pod));
    print('[PriceSync] Service started (interval: ${interval.inMinutes}min, '
        'first sync in 10s)');
    // Run first sync after a short delay to let the server fully initialize.
    Future.delayed(const Duration(seconds: 10), () => _runSync(pod));
  }

  /// Stop the periodic sync timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Trigger a manual sync (returns immediately, sync runs in background).
  void triggerSync(Serverpod pod) {
    if (!_isSyncing) {
      _runSync(pod);
    }
  }

  Future<void> _runSync(Serverpod pod) async {
    if (_isSyncing) return;
    _isSyncing = true;

    final session = await pod.createSession();
    final stopwatch = Stopwatch()..start();
    try {
      // Get all held assets with Yahoo symbols.
      final holdings = await Holding.db.find(
        session,
        where: (t) => t.quantity > 0.0,
      );

      final assets = await Asset.db.find(
        session,
        where: (t) => t.archived.equals(false),
      );

      final assetById = <String, Asset>{};
      for (final asset in assets) {
        if (asset.id != null) {
          assetById[asset.id!.toString()] = asset;
        }
      }

      // Build list of syncable tickers.
      final syncItems = <({String isin, String ticker})>[];
      for (final holding in holdings) {
        final asset = assetById[holding.assetId.toString()];
        if (asset != null && asset.yahooSymbol != null) {
          syncItems.add((isin: asset.isin, ticker: asset.yahooSymbol!));
        }
      }

      if (syncItems.isEmpty) {
        print('[PriceSync] No assets to sync');
        _isSyncing = false;
        await session.close();
        return;
      }

      final tickers = syncItems.map((i) => i.ticker).toList();

      // Ensure ticker metadata exists.
      await ensureTickerMetadata(session, tickers);

      // Determine which tickers need historical/intraday sync.
      final needsHistorical = await getTickersNeedingSync(session, tickers);
      final needsIntraday =
          await getTickersNeedingIntradaySync(session, tickers);

      print('[PriceSync] Starting sync for ${syncItems.length} assets '
          '(${needsHistorical.length} need historical, '
          '${needsIntraday.length} need intraday)...');

      int priceOk = 0, priceErr = 0;
      int histOk = 0, histErr = 0;
      int intradayOk = 0, intradayErr = 0;

      for (final item in syncItems) {
        // 1. Current price.
        try {
          final result = await getPrice(
            session,
            item.isin,
            item.ticker,
            forceRefresh: true,
          );

          publishUpdate(PriceUpdate(
            isin: item.isin,
            ticker: result.ticker,
            priceEur: result.priceEur,
            currency: result.currency,
            fetchedAt: result.fetchedAt,
          ));

          priceOk++;
          print('[PriceSync]   ${result.ticker}: '
              '€${result.priceEur.toStringAsFixed(2)} '
              '(${result.currency})');
        } catch (e) {
          priceErr++;
          print('[PriceSync]   ERROR price ${item.ticker}: $e');
        }

        // 2. Historical daily data (if needed).
        if (needsHistorical.contains(item.ticker)) {
          try {
            final result = await syncHistoricalData(session, item.ticker);
            if (result.error != null) {
              histErr++;
              print('[PriceSync]   ERROR historical ${item.ticker}: '
                  '${result.error}');
            } else {
              histOk++;
              print('[PriceSync]   ${item.ticker} historical: '
                  '${result.candlesUpserted} candles, '
                  '${result.dividendsUpserted} dividends');
            }
          } catch (e) {
            histErr++;
            print('[PriceSync]   ERROR historical ${item.ticker}: $e');
          }
        }

        // 3. Intraday data (if needed).
        if (needsIntraday.contains(item.ticker)) {
          try {
            final result = await syncIntradayData(session, item.ticker);
            if (result.error != null) {
              intradayErr++;
              print('[PriceSync]   ERROR intraday ${item.ticker}: '
                  '${result.error}');
            } else {
              intradayOk++;
              print('[PriceSync]   ${item.ticker} intraday: '
                  '${result.candlesUpserted} candles');
            }
          } catch (e) {
            intradayErr++;
            print('[PriceSync]   ERROR intraday ${item.ticker}: $e');
          }
        }
      }

      // 4. Sync historical FX rates for non-EUR currencies.
      final nonEurCurrencies = <String>{};
      final cachedPrices = await PriceCache.db.find(session);
      for (final p in cachedPrices) {
        if (p.currency != 'EUR') {
          nonEurCurrencies.add(p.currency);
        }
      }

      int fxOk = 0, fxErr = 0;
      if (nonEurCurrencies.isNotEmpty) {
        final fxTickers =
            nonEurCurrencies.map((c) => '${c}EUR=X').toList();
        await ensureTickerMetadata(session, fxTickers);
        final needsFxHistorical =
            await getTickersNeedingSync(session, fxTickers);

        if (needsFxHistorical.isNotEmpty) {
          print('[PriceSync] Syncing ${needsFxHistorical.length} FX pairs: '
              '${needsFxHistorical.join(', ')}');
        }

        for (final fxTicker in needsFxHistorical) {
          try {
            final result = await syncHistoricalData(session, fxTicker);
            if (result.error != null) {
              fxErr++;
              print('[PriceSync]   ERROR FX $fxTicker: ${result.error}');
            } else {
              fxOk++;
              print('[PriceSync]   $fxTicker: ${result.candlesUpserted} rates');
            }
          } catch (e) {
            fxErr++;
            print('[PriceSync]   ERROR FX $fxTicker: $e');
          }
        }
      }

      _lastSuccessCount = priceOk;
      _lastErrorCount = priceErr;
      _lastSyncAt = DateTime.now();
      stopwatch.stop();

      print('[PriceSync] Done in '
          '${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)}s - '
          'Prices: $priceOk ok/$priceErr err, '
          'Historical: $histOk ok/$histErr err, '
          'Intraday: $intradayOk ok/$intradayErr err, '
          'FX: $fxOk ok/$fxErr err');
    } catch (e) {
      stopwatch.stop();
      print('[PriceSync] Job failed: $e');
    } finally {
      _isSyncing = false;
      await session.close();
    }
  }

  /// Publish a price update to the broadcast stream.
  /// Used by the sync job internally and exposed for testing.
  void publishUpdate(PriceUpdate update) {
    _controller.add(update);
  }

  /// Clean up resources.
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
