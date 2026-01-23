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

/// PriceUpdate - Real-time price update event pushed to clients
/// Not persisted to database (no table directive)
abstract class PriceUpdate implements _i1.SerializableModel {
  PriceUpdate._({
    required this.isin,
    required this.ticker,
    required this.priceEur,
    required this.currency,
    required this.fetchedAt,
  });

  factory PriceUpdate({
    required String isin,
    required String ticker,
    required double priceEur,
    required String currency,
    required DateTime fetchedAt,
  }) = _PriceUpdateImpl;

  factory PriceUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceUpdate(
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      priceEur: (jsonSerialization['priceEur'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// Asset ISIN
  String isin;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Price in EUR
  double priceEur;

  /// Native currency code
  String currency;

  /// When this price was fetched
  DateTime fetchedAt;

  /// Returns a shallow copy of this [PriceUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceUpdate copyWith({
    String? isin,
    String? ticker,
    double? priceEur,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceUpdate',
      'isin': isin,
      'ticker': ticker,
      'priceEur': priceEur,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PriceUpdateImpl extends PriceUpdate {
  _PriceUpdateImpl({
    required String isin,
    required String ticker,
    required double priceEur,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         isin: isin,
         ticker: ticker,
         priceEur: priceEur,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [PriceUpdate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceUpdate copyWith({
    String? isin,
    String? ticker,
    double? priceEur,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return PriceUpdate(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      priceEur: priceEur ?? this.priceEur,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
