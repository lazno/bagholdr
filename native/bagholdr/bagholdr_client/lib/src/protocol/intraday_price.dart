/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// IntradayPrice - 5-minute interval OHLCV data for detailed charting
/// Used for intraday charts (last 5 trading days)
abstract class IntradayPrice implements _i1.SerializableModel {
  IntradayPrice._({
    this.id,
    required this.ticker,
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.currency,
    required this.fetchedAt,
  });

  factory IntradayPrice({
    _i1.UuidValue? id,
    required String ticker,
    required int timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) = _IntradayPriceImpl;

  factory IntradayPrice.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntradayPrice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      timestamp: jsonSerialization['timestamp'] as int,
      open: (jsonSerialization['open'] as num).toDouble(),
      high: (jsonSerialization['high'] as num).toDouble(),
      low: (jsonSerialization['low'] as num).toDouble(),
      close: (jsonSerialization['close'] as num).toDouble(),
      volume: jsonSerialization['volume'] as int,
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Unix timestamp in seconds for this interval
  int timestamp;

  /// Open price for the interval
  double open;

  /// Highest price during the interval
  double high;

  /// Lowest price during the interval
  double low;

  /// Closing price for the interval
  double close;

  /// Trading volume during the interval
  int volume;

  /// Currency of the price data
  String currency;

  /// When this data was fetched
  DateTime fetchedAt;

  /// Returns a shallow copy of this [IntradayPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IntradayPrice copyWith({
    _i1.UuidValue? id,
    String? ticker,
    int? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntradayPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IntradayPriceImpl extends IntradayPrice {
  _IntradayPriceImpl({
    _i1.UuidValue? id,
    required String ticker,
    required int timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         timestamp: timestamp,
         open: open,
         high: high,
         low: low,
         close: close,
         volume: volume,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [IntradayPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IntradayPrice copyWith({
    Object? id = _Undefined,
    String? ticker,
    int? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return IntradayPrice(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
