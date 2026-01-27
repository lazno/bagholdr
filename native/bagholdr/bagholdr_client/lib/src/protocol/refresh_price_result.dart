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

/// RefreshPriceResult - Result of refreshing an asset's price
/// Contains success status and the new price data (or error message on failure)
abstract class RefreshPriceResult implements _i1.SerializableModel {
  RefreshPriceResult._({
    required this.success,
    this.ticker,
    this.priceEur,
    this.currency,
    this.fetchedAt,
    this.errorMessage,
  });

  factory RefreshPriceResult({
    required bool success,
    String? ticker,
    double? priceEur,
    String? currency,
    DateTime? fetchedAt,
    String? errorMessage,
  }) = _RefreshPriceResultImpl;

  factory RefreshPriceResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return RefreshPriceResult(
      success: jsonSerialization['success'] as bool,
      ticker: jsonSerialization['ticker'] as String?,
      priceEur: (jsonSerialization['priceEur'] as num?)?.toDouble(),
      currency: jsonSerialization['currency'] as String?,
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      errorMessage: jsonSerialization['errorMessage'] as String?,
    );
  }

  bool success;

  String? ticker;

  double? priceEur;

  String? currency;

  DateTime? fetchedAt;

  String? errorMessage;

  /// Returns a shallow copy of this [RefreshPriceResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RefreshPriceResult copyWith({
    bool? success,
    String? ticker,
    double? priceEur,
    String? currency,
    DateTime? fetchedAt,
    String? errorMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RefreshPriceResult',
      'success': success,
      if (ticker != null) 'ticker': ticker,
      if (priceEur != null) 'priceEur': priceEur,
      if (currency != null) 'currency': currency,
      if (fetchedAt != null) 'fetchedAt': fetchedAt?.toJson(),
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RefreshPriceResultImpl extends RefreshPriceResult {
  _RefreshPriceResultImpl({
    required bool success,
    String? ticker,
    double? priceEur,
    String? currency,
    DateTime? fetchedAt,
    String? errorMessage,
  }) : super._(
         success: success,
         ticker: ticker,
         priceEur: priceEur,
         currency: currency,
         fetchedAt: fetchedAt,
         errorMessage: errorMessage,
       );

  /// Returns a shallow copy of this [RefreshPriceResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RefreshPriceResult copyWith({
    bool? success,
    Object? ticker = _Undefined,
    Object? priceEur = _Undefined,
    Object? currency = _Undefined,
    Object? fetchedAt = _Undefined,
    Object? errorMessage = _Undefined,
  }) {
    return RefreshPriceResult(
      success: success ?? this.success,
      ticker: ticker is String? ? ticker : this.ticker,
      priceEur: priceEur is double? ? priceEur : this.priceEur,
      currency: currency is String? ? currency : this.currency,
      fetchedAt: fetchedAt is DateTime? ? fetchedAt : this.fetchedAt,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
    );
  }
}
