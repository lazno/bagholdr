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

/// DailyPrice - Historical daily OHLCV data from Yahoo Finance
/// Used for charting and performance calculations
abstract class DailyPrice implements _i1.SerializableModel {
  DailyPrice._({
    this.id,
    required this.ticker,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.adjClose,
    required this.volume,
    required this.currency,
    required this.fetchedAt,
  });

  factory DailyPrice({
    _i1.UuidValue? id,
    required String ticker,
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    required double adjClose,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) = _DailyPriceImpl;

  factory DailyPrice.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPrice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      date: jsonSerialization['date'] as String,
      open: (jsonSerialization['open'] as num).toDouble(),
      high: (jsonSerialization['high'] as num).toDouble(),
      low: (jsonSerialization['low'] as num).toDouble(),
      close: (jsonSerialization['close'] as num).toDouble(),
      adjClose: (jsonSerialization['adjClose'] as num).toDouble(),
      volume: jsonSerialization['volume'] as int,
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT")
  String ticker;

  /// Date in YYYY-MM-DD format
  String date;

  /// Open price for the day
  double open;

  /// Highest price during the day
  double high;

  /// Lowest price during the day
  double low;

  /// Closing price for the day
  double close;

  /// Adjusted close (accounts for splits/dividends)
  double adjClose;

  /// Trading volume
  int volume;

  /// Currency of the price data (e.g., EUR, USD)
  String currency;

  /// When this price data was fetched from Yahoo
  DateTime fetchedAt;

  /// Returns a shallow copy of this [DailyPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPrice copyWith({
    _i1.UuidValue? id,
    String? ticker,
    String? date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? adjClose,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'adjClose': adjClose,
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

class _DailyPriceImpl extends DailyPrice {
  _DailyPriceImpl({
    _i1.UuidValue? id,
    required String ticker,
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    required double adjClose,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         date: date,
         open: open,
         high: high,
         low: low,
         close: close,
         adjClose: adjClose,
         volume: volume,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [DailyPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPrice copyWith({
    Object? id = _Undefined,
    String? ticker,
    String? date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? adjClose,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return DailyPrice(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      date: date ?? this.date,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      adjClose: adjClose ?? this.adjClose,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
