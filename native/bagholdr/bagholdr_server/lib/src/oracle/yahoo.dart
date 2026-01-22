import 'dart:convert';
import 'dart:io';

import 'rate_limiter.dart';

// =============================================================================
// Constants
// =============================================================================

const String yahooSearchUrl =
    'https://query1.finance.yahoo.com/v1/finance/search';
const String yahooChartUrl =
    'https://query1.finance.yahoo.com/v8/finance/chart';

// =============================================================================
// Types
// =============================================================================

class YahooPriceInfo {
  final double price;
  final String currency;
  final String instrumentType;
  final DateTime timestamp;

  YahooPriceInfo({
    required this.price,
    required this.currency,
    required this.instrumentType,
    required this.timestamp,
  });
}

class YahooSearchResult {
  final String symbol;
  final String? exchange;
  final String? exchangeDisplay;
  final String? quoteType;
  final String? shortname;

  YahooSearchResult({
    required this.symbol,
    this.exchange,
    this.exchangeDisplay,
    this.quoteType,
    this.shortname,
  });
}

class YahooCandle {
  final String date; // YYYY-MM-DD
  final double open;
  final double high;
  final double low;
  final double close;
  final double adjClose;
  final int volume;

  YahooCandle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.adjClose,
    required this.volume,
  });
}

class YahooDividend {
  final String exDate; // YYYY-MM-DD
  final double amount;

  YahooDividend({required this.exDate, required this.amount});
}

class YahooHistoricalData {
  final List<YahooCandle> candles;
  final List<YahooDividend> dividends;
  final String currency;

  YahooHistoricalData({
    required this.candles,
    required this.dividends,
    required this.currency,
  });
}

class YahooIntradayCandle {
  final int timestamp; // Unix timestamp in seconds
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  YahooIntradayCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class YahooIntradayData {
  final List<YahooIntradayCandle> candles;
  final String currency;

  YahooIntradayData({required this.candles, required this.currency});
}

class YahooFinanceError implements Exception {
  final String message;
  final String code;

  YahooFinanceError(this.message, this.code);

  @override
  String toString() => 'YahooFinanceError($code): $message';
}

// =============================================================================
// Internal Helpers
// =============================================================================

final _httpClient = HttpClient()
  ..userAgent = 'Bagholdr/1.0';

/// Rate-limited fetch wrapper. Returns decoded JSON.
Future<Map<String, dynamic>> _rateLimitedFetch(String url) {
  return yahooRateLimiter.enqueue(() async {
    final uri = Uri.parse(url);
    final request = await _httpClient.getUrl(uri);
    request.headers.set('Accept', 'application/json');
    final response = await request.close();

    if (response.statusCode == 403) {
      await response.drain<void>();
      throw YahooFinanceError(
        'Rate limited by Yahoo Finance',
        'RATE_LIMITED',
      );
    }

    if (response.statusCode == 404) {
      await response.drain<void>();
      throw YahooFinanceError(
        'Not found: $url',
        'NOT_FOUND',
      );
    }

    if (response.statusCode != 200) {
      await response.drain<void>();
      throw YahooFinanceError(
        'HTTP error: ${response.statusCode}',
        'HTTP_ERROR',
      );
    }

    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  });
}

/// Convert Unix timestamp (seconds) to YYYY-MM-DD string.
String _timestampToDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

// =============================================================================
// Symbol Resolution
// =============================================================================

/// Resolve ISIN to all available Yahoo Finance symbols.
/// Returns all exchanges where this ISIN is available.
Future<List<YahooSearchResult>> fetchAllSymbolsFromIsin(String isin) async {
  final url = '$yahooSearchUrl?q=${Uri.encodeComponent(isin)}'
      '&newsCount=0&listsCount=0&quotesCount=20'
      '&quotesQueryId=tss_match_phrase_query';

  final data = await _rateLimitedFetch(url);

  final quotes = data['quotes'] as List<dynamic>?;
  if (quotes == null || quotes.isEmpty) {
    throw YahooFinanceError('No symbol found for ISIN: $isin', 'NOT_FOUND');
  }

  return quotes.map((q) {
    final map = q as Map<String, dynamic>;
    return YahooSearchResult(
      symbol: map['symbol'] as String,
      exchange: map['exchange'] as String?,
      exchangeDisplay: map['exchDisp'] as String?,
      quoteType: map['quoteType'] as String?,
      shortname: map['shortname'] as String?,
    );
  }).toList();
}

/// Resolve ISIN to Yahoo Finance ticker symbol (first/best match).
Future<String> fetchSymbolFromIsin(String isin) async {
  final symbols = await fetchAllSymbolsFromIsin(isin);
  return symbols.first.symbol;
}

// =============================================================================
// Current Price
// =============================================================================

/// Fetch current price data for a ticker symbol.
Future<YahooPriceInfo> fetchPriceData(String symbol) async {
  final url = '$yahooChartUrl/${Uri.encodeComponent(symbol)}';

  final data = await _rateLimitedFetch(url);

  final chart = data['chart'] as Map<String, dynamic>?;
  final results = chart?['result'] as List<dynamic>?;
  if (results == null || results.isEmpty) {
    throw YahooFinanceError('No price data found for: $symbol', 'NOT_FOUND');
  }

  final result = results[0] as Map<String, dynamic>;
  final meta = result['meta'] as Map<String, dynamic>?;
  if (meta == null) {
    throw YahooFinanceError('No price data found for: $symbol', 'NOT_FOUND');
  }

  return YahooPriceInfo(
    price: (meta['regularMarketPrice'] as num).toDouble(),
    currency: meta['currency'] as String? ?? 'USD',
    instrumentType: meta['instrumentType'] as String? ?? 'unknown',
    timestamp: DateTime.now(),
  );
}

// =============================================================================
// Historical Data
// =============================================================================

/// Fetch historical daily price data for a ticker symbol.
///
/// [range] - Time range: '1y', '5y', '10y', or 'max' (default: '10y')
///
/// Note: Yahoo automatically downsamples to monthly data for very long ranges.
/// Using '10y' instead of 'max' ensures we get daily granularity for most instruments.
Future<YahooHistoricalData> fetchHistoricalData(
  String symbol, {
  String range = '10y',
}) async {
  final url = '$yahooChartUrl/${Uri.encodeComponent(symbol)}'
      '?interval=1d&range=$range&events=div';

  final data = await _rateLimitedFetch(url);

  final chart = data['chart'] as Map<String, dynamic>?;
  final results = chart?['result'] as List<dynamic>?;
  if (results == null || results.isEmpty) {
    throw YahooFinanceError(
      'No historical data found for: $symbol',
      'NOT_FOUND',
    );
  }

  final result = results[0] as Map<String, dynamic>;
  final meta = result['meta'] as Map<String, dynamic>? ?? {};
  final timestamps = (result['timestamp'] as List<dynamic>?)
          ?.map((t) => (t as num).toInt())
          .toList() ??
      [];

  final indicators = result['indicators'] as Map<String, dynamic>? ?? {};
  final quoteList = indicators['quote'] as List<dynamic>?;
  final quote = quoteList != null && quoteList.isNotEmpty
      ? quoteList[0] as Map<String, dynamic>
      : <String, dynamic>{};
  final adjCloseList = indicators['adjclose'] as List<dynamic>?;
  final adjCloseArr = adjCloseList != null && adjCloseList.isNotEmpty
      ? (adjCloseList[0] as Map<String, dynamic>)['adjclose'] as List<dynamic>?
      : null;

  final events = result['events'] as Map<String, dynamic>? ?? {};

  // Parse candles
  final candles = <YahooCandle>[];
  final openArr = quote['open'] as List<dynamic>?;
  final highArr = quote['high'] as List<dynamic>?;
  final lowArr = quote['low'] as List<dynamic>?;
  final closeArr = quote['close'] as List<dynamic>?;
  final volumeArr = quote['volume'] as List<dynamic>?;

  for (var i = 0; i < timestamps.length; i++) {
    final open = openArr?[i];
    final high = highArr?[i];
    final low = lowArr?[i];
    final close = closeArr?[i];
    final adjClose = adjCloseArr?[i];

    // Skip if any required value is null
    if (open == null || high == null || low == null || close == null || adjClose == null) {
      continue;
    }

    candles.add(YahooCandle(
      date: _timestampToDate(timestamps[i]),
      open: (open as num).toDouble(),
      high: (high as num).toDouble(),
      low: (low as num).toDouble(),
      close: (close as num).toDouble(),
      adjClose: (adjClose as num).toDouble(),
      volume: (volumeArr?[i] as num?)?.toInt() ?? 0,
    ));
  }

  // Parse dividends
  final dividends = <YahooDividend>[];
  final dividendEvents = events['dividends'] as Map<String, dynamic>?;
  if (dividendEvents != null) {
    for (final entry in dividendEvents.entries) {
      final div = entry.value as Map<String, dynamic>;
      final amount = div['amount'] as num?;
      if (amount != null) {
        dividends.add(YahooDividend(
          exDate: _timestampToDate(int.parse(entry.key)),
          amount: amount.toDouble(),
        ));
      }
    }
  }

  // Sort dividends by date
  dividends.sort((a, b) => a.exDate.compareTo(b.exDate));

  return YahooHistoricalData(
    candles: candles,
    dividends: dividends,
    currency: meta['currency'] as String? ?? 'USD',
  );
}

/// Fetch intraday price data (5-minute intervals) for a ticker symbol.
///
/// [range] - Time range: '1d', '5d' (default: '5d' for 5 days of data)
Future<YahooIntradayData> fetchIntradayData(
  String symbol, {
  String range = '5d',
}) async {
  final url = '$yahooChartUrl/${Uri.encodeComponent(symbol)}'
      '?interval=5m&range=$range&includePrePost=false';

  final data = await _rateLimitedFetch(url);

  final chart = data['chart'] as Map<String, dynamic>?;
  final results = chart?['result'] as List<dynamic>?;
  if (results == null || results.isEmpty) {
    throw YahooFinanceError(
      'No intraday data found for: $symbol',
      'NOT_FOUND',
    );
  }

  final result = results[0] as Map<String, dynamic>;
  final meta = result['meta'] as Map<String, dynamic>? ?? {};
  final timestamps = (result['timestamp'] as List<dynamic>?)
          ?.map((t) => (t as num).toInt())
          .toList() ??
      [];

  final indicators = result['indicators'] as Map<String, dynamic>? ?? {};
  final quoteList = indicators['quote'] as List<dynamic>?;
  final quote = quoteList != null && quoteList.isNotEmpty
      ? quoteList[0] as Map<String, dynamic>
      : <String, dynamic>{};

  // Parse candles
  final candles = <YahooIntradayCandle>[];
  final openArr = quote['open'] as List<dynamic>?;
  final highArr = quote['high'] as List<dynamic>?;
  final lowArr = quote['low'] as List<dynamic>?;
  final closeArr = quote['close'] as List<dynamic>?;
  final volumeArr = quote['volume'] as List<dynamic>?;

  for (var i = 0; i < timestamps.length; i++) {
    final open = openArr?[i];
    final high = highArr?[i];
    final low = lowArr?[i];
    final close = closeArr?[i];

    if (open == null || high == null || low == null || close == null) {
      continue;
    }

    candles.add(YahooIntradayCandle(
      timestamp: timestamps[i],
      open: (open as num).toDouble(),
      high: (high as num).toDouble(),
      low: (low as num).toDouble(),
      close: (close as num).toDouble(),
      volume: (volumeArr?[i] as num?)?.toInt() ?? 0,
    ));
  }

  return YahooIntradayData(
    candles: candles,
    currency: meta['currency'] as String? ?? 'USD',
  );
}

// =============================================================================
// FX Rates
// =============================================================================

/// Fetch FX rate from one currency to another.
/// Uses Yahoo Finance forex pairs (e.g., USDEUR=X).
Future<double> fetchFxRate(String from, String to) async {
  final fromUpper = from.toUpperCase();
  final toUpper = to.toUpperCase();

  // Same currency
  if (fromUpper == toUpper) return 1.0;

  // Handle GBp (pence) -> GBP conversion
  final actualFrom = fromUpper == 'GBP' ? 'GBP' : fromUpper;

  final symbol = '$actualFrom$toUpper=X';
  final priceInfo = await fetchPriceData(symbol);

  var rate = priceInfo.price;

  // Special handling for GBp (British pence)
  // Yahoo returns the rate for GBP, but prices might be in pence
  if (from.toLowerCase() == 'gbp' && from != 'GBP') {
    rate = rate / 100;
  }

  return rate;
}

/// Adjust conversion rate for special cases like GBp (pence).
double adjustConversionRate(String currency, double rate) {
  if (currency == 'GBp') {
    return rate / 100;
  }
  return rate;
}

// =============================================================================
// Convenience Functions
// =============================================================================

class PriceInEurResult {
  final String ticker;
  final double priceNative;
  final String currency;
  final double priceEur;
  final String instrumentType;

  PriceInEurResult({
    required this.ticker,
    required this.priceNative,
    required this.currency,
    required this.priceEur,
    required this.instrumentType,
  });
}

/// Fetch price in EUR for an asset.
/// Handles ISIN resolution and FX conversion.
Future<PriceInEurResult> fetchPriceInEur(
  String isin, {
  String? knownTicker,
}) async {
  // Resolve ISIN to ticker if not provided
  final ticker = knownTicker ?? await fetchSymbolFromIsin(isin);

  // Fetch price in native currency
  final priceInfo = await fetchPriceData(ticker);

  // Convert to EUR if needed
  double priceEur;
  if (priceInfo.currency == 'EUR') {
    priceEur = priceInfo.price;
  } else {
    final fxRate = await fetchFxRate(priceInfo.currency, 'EUR');
    final adjustedRate = adjustConversionRate(priceInfo.currency, fxRate);
    priceEur = priceInfo.price * adjustedRate;
  }

  return PriceInEurResult(
    ticker: ticker,
    priceNative: priceInfo.price,
    currency: priceInfo.currency,
    priceEur: priceEur,
    instrumentType: priceInfo.instrumentType,
  );
}
