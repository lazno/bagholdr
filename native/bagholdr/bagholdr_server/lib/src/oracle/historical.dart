import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'yahoo.dart';

// =============================================================================
// Types
// =============================================================================

class SyncResult {
  final String ticker;
  final int candlesUpserted;
  final int dividendsUpserted;
  final String? latestDate;
  final String? error;

  SyncResult({
    required this.ticker,
    required this.candlesUpserted,
    required this.dividendsUpserted,
    this.latestDate,
    this.error,
  });
}

class IntradaySyncResult {
  final String ticker;
  final int candlesUpserted;
  final int candlesPurged;
  final String? error;

  IntradaySyncResult({
    required this.ticker,
    required this.candlesUpserted,
    required this.candlesPurged,
    this.error,
  });
}

// =============================================================================
// Sync Functions
// =============================================================================

/// Sync historical data for a ticker from Yahoo Finance.
/// Fetches all available data (range=10y) and upserts to database.
/// Also updates ticker_metadata with sync timestamp.
Future<SyncResult> syncHistoricalData(
  Session session,
  String ticker,
) async {
  final now = DateTime.now();

  try {
    // Fetch from Yahoo (10y range ensures daily granularity)
    final data = await fetchHistoricalData(ticker, range: '10y');

    String? latestDate;
    for (final candle in data.candles) {
      if (latestDate == null || candle.date.compareTo(latestDate) > 0) {
        latestDate = candle.date;
      }
    }

    // Delete existing daily prices for this ticker and re-insert
    // This is simpler than upsert-per-row and works well for bulk sync
    await DailyPrice.db.deleteWhere(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    // Batch insert candles
    if (data.candles.isNotEmpty) {
      final rows = data.candles.map((candle) => DailyPrice(
        ticker: ticker,
        date: candle.date,
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close,
        adjClose: candle.adjClose,
        volume: candle.volume,
        currency: data.currency,
        fetchedAt: now,
      )).toList();

      // Insert in batches of 100
      const batchSize = 100;
      for (var i = 0; i < rows.length; i += batchSize) {
        final batch = rows.sublist(
          i,
          i + batchSize > rows.length ? rows.length : i + batchSize,
        );
        await DailyPrice.db.insert(session, batch);
      }
    }

    // Delete existing dividends for this ticker and re-insert
    await DividendEvent.db.deleteWhere(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    if (data.dividends.isNotEmpty) {
      final divRows = data.dividends.map((dividend) => DividendEvent(
        ticker: ticker,
        exDate: dividend.exDate,
        amount: dividend.amount,
        currency: data.currency,
        fetchedAt: now,
      )).toList();

      const batchSize = 100;
      for (var i = 0; i < divRows.length; i += batchSize) {
        final batch = divRows.sublist(
          i,
          i + batchSize > divRows.length ? divRows.length : i + batchSize,
        );
        await DividendEvent.db.insert(session, batch);
      }
    }

    // Upsert ticker metadata
    await _upsertTickerMetadata(session, ticker, (meta) {
      meta.lastDailyDate = latestDate;
      meta.lastSyncedAt = now;
      meta.isActive = true;
    });

    return SyncResult(
      ticker: ticker,
      candlesUpserted: data.candles.length,
      dividendsUpserted: data.dividends.length,
      latestDate: latestDate,
    );
  } catch (err) {
    // Mark ticker as inactive if not found
    if (err is YahooFinanceError && err.code == 'NOT_FOUND') {
      await _upsertTickerMetadata(session, ticker, (meta) {
        meta.isActive = false;
        meta.lastSyncedAt = now;
      });
    }

    return SyncResult(
      ticker: ticker,
      candlesUpserted: 0,
      dividendsUpserted: 0,
      error: err is Exception ? err.toString() : 'Unknown error',
    );
  }
}

/// Check if a ticker needs historical sync.
/// Returns true if never synced before or last sync was before today.
Future<bool> needsHistoricalSync(Session session, String ticker) async {
  final meta = await TickerMetadata.db.findFirstRow(
    session,
    where: (t) => t.ticker.equals(ticker),
  );

  if (meta == null || meta.lastSyncedAt == null) return true;

  final today = _todayString();
  final lastSyncDate = _dateString(meta.lastSyncedAt!);

  return lastSyncDate.compareTo(today) < 0;
}

/// Get list of tickers that need historical sync.
/// Only includes active tickers that haven't been synced today.
Future<List<String>> getTickersNeedingSync(
  Session session,
  List<String> tickers,
) async {
  final today = _todayString();
  final needsSync = <String>[];

  for (final ticker in tickers) {
    final meta = await TickerMetadata.db.findFirstRow(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    if (meta == null) {
      needsSync.add(ticker);
    } else if (meta.isActive) {
      final lastSyncDate =
          meta.lastSyncedAt != null ? _dateString(meta.lastSyncedAt!) : null;
      if (lastSyncDate == null || lastSyncDate.compareTo(today) < 0) {
        needsSync.add(ticker);
      }
    }
  }

  return needsSync;
}

/// Ensure ticker_metadata entries exist for all given tickers.
Future<int> ensureTickerMetadata(
  Session session,
  List<String> tickers,
) async {
  var created = 0;

  for (final ticker in tickers) {
    final existing = await TickerMetadata.db.findFirstRow(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    if (existing == null) {
      await TickerMetadata.db.insertRow(
        session,
        TickerMetadata(
          ticker: ticker,
          isActive: true,
        ),
      );
      created++;
    }
  }

  return created;
}

// =============================================================================
// Intraday Functions
// =============================================================================

/// Sync intraday data for a ticker from Yahoo Finance.
/// Fetches 5-day data with 5-minute intervals and upserts to database.
/// Also purges data older than 5 days.
Future<IntradaySyncResult> syncIntradayData(
  Session session,
  String ticker,
) async {
  final now = DateTime.now();

  try {
    // Fetch 5-day intraday data from Yahoo
    final data = await fetchIntradayData(ticker, range: '5d');

    // Delete existing intraday for this ticker and re-insert
    await IntradayPrice.db.deleteWhere(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    // Batch insert candles
    if (data.candles.isNotEmpty) {
      final rows = data.candles.map((candle) => IntradayPrice(
        ticker: ticker,
        timestamp: candle.timestamp,
        open: candle.open,
        high: candle.high,
        low: candle.low,
        close: candle.close,
        volume: candle.volume,
        currency: data.currency,
        fetchedAt: now,
      )).toList();

      const batchSize = 100;
      for (var i = 0; i < rows.length; i += batchSize) {
        final batch = rows.sublist(
          i,
          i + batchSize > rows.length ? rows.length : i + batchSize,
        );
        await IntradayPrice.db.insert(session, batch);
      }
    }

    // Purge data older than 5 days
    final fiveDaysAgo = now.subtract(const Duration(days: 5));
    final fiveDaysAgoTimestamp = fiveDaysAgo.millisecondsSinceEpoch ~/ 1000;
    final purged = await IntradayPrice.db.deleteWhere(
      session,
      where: (t) =>
          t.ticker.equals(ticker) & (t.timestamp < fiveDaysAgoTimestamp),
    );

    // Update ticker metadata
    await _upsertTickerMetadata(session, ticker, (meta) {
      meta.lastIntradaySyncedAt = now;
      meta.isActive = true;
    });

    return IntradaySyncResult(
      ticker: ticker,
      candlesUpserted: data.candles.length,
      candlesPurged: purged.length,
    );
  } catch (err) {
    return IntradaySyncResult(
      ticker: ticker,
      candlesUpserted: 0,
      candlesPurged: 0,
      error: err is Exception ? err.toString() : 'Unknown error',
    );
  }
}

/// Check if a ticker needs intraday sync.
/// Returns true if never synced or last sync was more than 5 minutes ago.
Future<bool> needsIntradaySync(Session session, String ticker) async {
  final meta = await TickerMetadata.db.findFirstRow(
    session,
    where: (t) => t.ticker.equals(ticker),
  );

  if (meta == null || meta.lastIntradaySyncedAt == null) return true;

  final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
  return meta.lastIntradaySyncedAt!.isBefore(fiveMinutesAgo);
}

/// Get list of tickers that need intraday sync.
Future<List<String>> getTickersNeedingIntradaySync(
  Session session,
  List<String> tickers,
) async {
  final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
  final needsSync = <String>[];

  for (final ticker in tickers) {
    final meta = await TickerMetadata.db.findFirstRow(
      session,
      where: (t) => t.ticker.equals(ticker),
    );

    if (meta == null) {
      needsSync.add(ticker);
    } else if (meta.isActive) {
      if (meta.lastIntradaySyncedAt == null ||
          meta.lastIntradaySyncedAt!.isBefore(fiveMinutesAgo)) {
        needsSync.add(ticker);
      }
    }
  }

  return needsSync;
}

// =============================================================================
// Query Functions
// =============================================================================

/// Get historical prices for a ticker from the database.
Future<List<DailyPrice>> getHistoricalPrices(
  Session session,
  String ticker, {
  String? startDate,
  String? endDate,
}) async {
  final end = endDate ?? _todayString();
  final start = startDate ?? _oneYearAgoString();

  return DailyPrice.db.find(
    session,
    where: (t) =>
        t.ticker.equals(ticker) & (t.date >= start) & (t.date <= end),
    orderBy: (t) => t.date,
  );
}

/// Get dividend events for a ticker from the database.
Future<List<DividendEvent>> getDividendEvents(
  Session session,
  String ticker, {
  String? startDate,
}) async {
  if (startDate != null) {
    return DividendEvent.db.find(
      session,
      where: (t) => t.ticker.equals(ticker) & (t.exDate >= startDate),
      orderBy: (t) => t.exDate,
      orderDescending: true,
    );
  }

  return DividendEvent.db.find(
    session,
    where: (t) => t.ticker.equals(ticker),
    orderBy: (t) => t.exDate,
    orderDescending: true,
  );
}

/// Get ticker metadata (sync status).
Future<TickerMetadata?> getTickerMetadata(
  Session session,
  String ticker,
) async {
  return TickerMetadata.db.findFirstRow(
    session,
    where: (t) => t.ticker.equals(ticker),
  );
}

// =============================================================================
// Helpers
// =============================================================================

String _todayString() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

String _oneYearAgoString() {
  final d = DateTime.now().subtract(const Duration(days: 365));
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _dateString(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

/// Helper to upsert ticker metadata.
Future<void> _upsertTickerMetadata(
  Session session,
  String ticker,
  void Function(TickerMetadata) update,
) async {
  final existing = await TickerMetadata.db.findFirstRow(
    session,
    where: (t) => t.ticker.equals(ticker),
  );

  if (existing != null) {
    update(existing);
    await TickerMetadata.db.updateRow(session, existing);
  } else {
    final meta = TickerMetadata(ticker: ticker, isActive: true);
    update(meta);
    await TickerMetadata.db.insertRow(session, meta);
  }
}
