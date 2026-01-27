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

/// ClearPriceHistoryResult - Result of clearing price history for an asset
/// Contains counts of records cleared from each table
abstract class ClearPriceHistoryResult implements _i1.SerializableModel {
  ClearPriceHistoryResult._({
    required this.success,
    required this.dailyPricesCleared,
    required this.intradayPricesCleared,
    required this.dividendsCleared,
    required this.priceCacheCleared,
  });

  factory ClearPriceHistoryResult({
    required bool success,
    required int dailyPricesCleared,
    required int intradayPricesCleared,
    required int dividendsCleared,
    required bool priceCacheCleared,
  }) = _ClearPriceHistoryResultImpl;

  factory ClearPriceHistoryResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ClearPriceHistoryResult(
      success: jsonSerialization['success'] as bool,
      dailyPricesCleared: jsonSerialization['dailyPricesCleared'] as int,
      intradayPricesCleared: jsonSerialization['intradayPricesCleared'] as int,
      dividendsCleared: jsonSerialization['dividendsCleared'] as int,
      priceCacheCleared: jsonSerialization['priceCacheCleared'] as bool,
    );
  }

  bool success;

  int dailyPricesCleared;

  int intradayPricesCleared;

  int dividendsCleared;

  bool priceCacheCleared;

  /// Returns a shallow copy of this [ClearPriceHistoryResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClearPriceHistoryResult copyWith({
    bool? success,
    int? dailyPricesCleared,
    int? intradayPricesCleared,
    int? dividendsCleared,
    bool? priceCacheCleared,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClearPriceHistoryResult',
      'success': success,
      'dailyPricesCleared': dailyPricesCleared,
      'intradayPricesCleared': intradayPricesCleared,
      'dividendsCleared': dividendsCleared,
      'priceCacheCleared': priceCacheCleared,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ClearPriceHistoryResultImpl extends ClearPriceHistoryResult {
  _ClearPriceHistoryResultImpl({
    required bool success,
    required int dailyPricesCleared,
    required int intradayPricesCleared,
    required int dividendsCleared,
    required bool priceCacheCleared,
  }) : super._(
         success: success,
         dailyPricesCleared: dailyPricesCleared,
         intradayPricesCleared: intradayPricesCleared,
         dividendsCleared: dividendsCleared,
         priceCacheCleared: priceCacheCleared,
       );

  /// Returns a shallow copy of this [ClearPriceHistoryResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClearPriceHistoryResult copyWith({
    bool? success,
    int? dailyPricesCleared,
    int? intradayPricesCleared,
    int? dividendsCleared,
    bool? priceCacheCleared,
  }) {
    return ClearPriceHistoryResult(
      success: success ?? this.success,
      dailyPricesCleared: dailyPricesCleared ?? this.dailyPricesCleared,
      intradayPricesCleared:
          intradayPricesCleared ?? this.intradayPricesCleared,
      dividendsCleared: dividendsCleared ?? this.dividendsCleared,
      priceCacheCleared: priceCacheCleared ?? this.priceCacheCleared,
    );
  }
}
