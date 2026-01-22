import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'yahoo.dart';

/// Price cache TTL: 6 hours.
const int priceCacheTtlMs = 6 * 60 * 60 * 1000;

/// Check if a cached entry is still valid.
bool _isValid(DateTime fetchedAt) {
  final age = DateTime.now().difference(fetchedAt).inMilliseconds;
  return age < priceCacheTtlMs;
}

class CachedPriceResult {
  final String ticker;
  final double priceNative;
  final String currency;
  final double priceEur;
  final DateTime fetchedAt;
  final bool fromCache;

  CachedPriceResult({
    required this.ticker,
    required this.priceNative,
    required this.currency,
    required this.priceEur,
    required this.fetchedAt,
    required this.fromCache,
  });
}

class CachedFxRateResult {
  final String pair;
  final double rate;
  final DateTime fetchedAt;
  final bool fromCache;

  CachedFxRateResult({
    required this.pair,
    required this.rate,
    required this.fetchedAt,
    required this.fromCache,
  });
}

/// Get price from cache or fetch from Yahoo.
///
/// [isin] - Asset ISIN (used for symbol resolution if needed)
/// [yahooSymbol] - Yahoo Finance symbol (if known); if null, will throw
/// [forceRefresh] - If true, bypass cache and fetch fresh data
Future<CachedPriceResult> getPrice(
  Session session,
  String isin,
  String? yahooSymbol, {
  bool forceRefresh = false,
}) async {
  if (yahooSymbol == null) {
    throw Exception('No Yahoo symbol set for ISIN $isin. Resolve symbols first.');
  }

  // Check cache first (unless forcing refresh)
  if (!forceRefresh) {
    final cached = await PriceCache.db.findFirstRow(
      session,
      where: (t) => t.ticker.equals(yahooSymbol),
    );

    if (cached != null && _isValid(cached.fetchedAt)) {
      return CachedPriceResult(
        ticker: cached.ticker,
        priceNative: cached.priceNative,
        currency: cached.currency,
        priceEur: cached.priceEur,
        fetchedAt: cached.fetchedAt,
        fromCache: true,
      );
    }
  }

  // Fetch fresh data using Yahoo symbol
  final fresh = await fetchPriceInEur(isin, knownTicker: yahooSymbol);
  final now = DateTime.now();

  // Upsert cache
  final existing = await PriceCache.db.findFirstRow(
    session,
    where: (t) => t.ticker.equals(yahooSymbol),
  );

  if (existing != null) {
    existing.priceNative = fresh.priceNative;
    existing.currency = fresh.currency;
    existing.priceEur = fresh.priceEur;
    existing.fetchedAt = now;
    await PriceCache.db.updateRow(session, existing);
  } else {
    await PriceCache.db.insertRow(
      session,
      PriceCache(
        ticker: yahooSymbol,
        priceNative: fresh.priceNative,
        currency: fresh.currency,
        priceEur: fresh.priceEur,
        fetchedAt: now,
      ),
    );
  }

  return CachedPriceResult(
    ticker: yahooSymbol,
    priceNative: fresh.priceNative,
    currency: fresh.currency,
    priceEur: fresh.priceEur,
    fetchedAt: now,
    fromCache: false,
  );
}

/// Get FX rate from cache or fetch from Yahoo.
Future<CachedFxRateResult> getFxRate(
  Session session,
  String from,
  String to,
) async {
  final pair = '${from.toUpperCase()}${to.toUpperCase()}';

  // Same currency
  if (from.toUpperCase() == to.toUpperCase()) {
    return CachedFxRateResult(
      pair: pair,
      rate: 1.0,
      fetchedAt: DateTime.now(),
      fromCache: false,
    );
  }

  // Check cache
  final cached = await FxCache.db.findFirstRow(
    session,
    where: (t) => t.pair.equals(pair),
  );

  if (cached != null && _isValid(cached.fetchedAt)) {
    return CachedFxRateResult(
      pair: cached.pair,
      rate: cached.rate,
      fetchedAt: cached.fetchedAt,
      fromCache: true,
    );
  }

  // Fetch fresh rate
  final rate = await fetchFxRate(from, to);
  final now = DateTime.now();

  // Upsert cache
  if (cached != null) {
    cached.rate = rate;
    cached.fetchedAt = now;
    await FxCache.db.updateRow(session, cached);
  } else {
    await FxCache.db.insertRow(
      session,
      FxCache(
        pair: pair,
        rate: rate,
        fetchedAt: now,
      ),
    );
  }

  return CachedFxRateResult(
    pair: pair,
    rate: rate,
    fetchedAt: now,
    fromCache: false,
  );
}

/// Clear expired cache entries.
Future<({int pricesCleared, int fxCleared})> clearExpiredCache(
  Session session,
) async {
  final expiryDate = DateTime.now().subtract(
    Duration(milliseconds: priceCacheTtlMs),
  );

  final pricesDeleted = await PriceCache.db.deleteWhere(
    session,
    where: (t) => t.fetchedAt < expiryDate,
  );

  final fxDeleted = await FxCache.db.deleteWhere(
    session,
    where: (t) => t.fetchedAt < expiryDate,
  );

  return (pricesCleared: pricesDeleted.length, fxCleared: fxDeleted.length);
}

/// Clear all cache.
Future<void> clearAllCache(Session session) async {
  await PriceCache.db.deleteWhere(session, where: (t) => Constant.bool(true));
  await FxCache.db.deleteWhere(session, where: (t) => Constant.bool(true));
}
