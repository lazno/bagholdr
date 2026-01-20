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

/// PriceCache - Cached current price data from Yahoo Finance
/// Short-lived cache for real-time price display
abstract class PriceCache implements _i1.SerializableModel {
  PriceCache._({
    this.id,
    required this.ticker,
    required this.priceNative,
    required this.currency,
    required this.priceEur,
    required this.fetchedAt,
  });

  factory PriceCache({
    _i1.UuidValue? id,
    required String ticker,
    required double priceNative,
    required String currency,
    required double priceEur,
    required DateTime fetchedAt,
  }) = _PriceCacheImpl;

  factory PriceCache.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceCache(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      priceNative: (jsonSerialization['priceNative'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      priceEur: (jsonSerialization['priceEur'] as num).toDouble(),
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Price in the native currency of the instrument
  double priceNative;

  /// Currency of the price (e.g., USD, EUR, GBP)
  String currency;

  /// Price converted to EUR (using cached FX rate)
  double priceEur;

  /// When this price was fetched
  DateTime fetchedAt;

  /// Returns a shallow copy of this [PriceCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceCache copyWith({
    _i1.UuidValue? id,
    String? ticker,
    double? priceNative,
    String? currency,
    double? priceEur,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceCache',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'priceNative': priceNative,
      'currency': currency,
      'priceEur': priceEur,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PriceCacheImpl extends PriceCache {
  _PriceCacheImpl({
    _i1.UuidValue? id,
    required String ticker,
    required double priceNative,
    required String currency,
    required double priceEur,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         priceNative: priceNative,
         currency: currency,
         priceEur: priceEur,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [PriceCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceCache copyWith({
    Object? id = _Undefined,
    String? ticker,
    double? priceNative,
    String? currency,
    double? priceEur,
    DateTime? fetchedAt,
  }) {
    return PriceCache(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      priceNative: priceNative ?? this.priceNative,
      currency: currency ?? this.currency,
      priceEur: priceEur ?? this.priceEur,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
