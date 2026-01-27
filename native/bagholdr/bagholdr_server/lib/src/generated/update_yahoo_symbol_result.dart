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
import 'package:serverpod/serverpod.dart' as _i1;

/// UpdateYahooSymbolResult - Result of updating an asset's Yahoo symbol
/// Contains info about what was cleared when the symbol changed
abstract class UpdateYahooSymbolResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UpdateYahooSymbolResult._({
    required this.success,
    this.newSymbol,
    required this.dailyPricesCleared,
    required this.intradayPricesCleared,
    required this.dividendsCleared,
  });

  factory UpdateYahooSymbolResult({
    required bool success,
    String? newSymbol,
    required int dailyPricesCleared,
    required int intradayPricesCleared,
    required int dividendsCleared,
  }) = _UpdateYahooSymbolResultImpl;

  factory UpdateYahooSymbolResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UpdateYahooSymbolResult(
      success: jsonSerialization['success'] as bool,
      newSymbol: jsonSerialization['newSymbol'] as String?,
      dailyPricesCleared: jsonSerialization['dailyPricesCleared'] as int,
      intradayPricesCleared: jsonSerialization['intradayPricesCleared'] as int,
      dividendsCleared: jsonSerialization['dividendsCleared'] as int,
    );
  }

  bool success;

  String? newSymbol;

  int dailyPricesCleared;

  int intradayPricesCleared;

  int dividendsCleared;

  /// Returns a shallow copy of this [UpdateYahooSymbolResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UpdateYahooSymbolResult copyWith({
    bool? success,
    String? newSymbol,
    int? dailyPricesCleared,
    int? intradayPricesCleared,
    int? dividendsCleared,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UpdateYahooSymbolResult',
      'success': success,
      if (newSymbol != null) 'newSymbol': newSymbol,
      'dailyPricesCleared': dailyPricesCleared,
      'intradayPricesCleared': intradayPricesCleared,
      'dividendsCleared': dividendsCleared,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UpdateYahooSymbolResult',
      'success': success,
      if (newSymbol != null) 'newSymbol': newSymbol,
      'dailyPricesCleared': dailyPricesCleared,
      'intradayPricesCleared': intradayPricesCleared,
      'dividendsCleared': dividendsCleared,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UpdateYahooSymbolResultImpl extends UpdateYahooSymbolResult {
  _UpdateYahooSymbolResultImpl({
    required bool success,
    String? newSymbol,
    required int dailyPricesCleared,
    required int intradayPricesCleared,
    required int dividendsCleared,
  }) : super._(
         success: success,
         newSymbol: newSymbol,
         dailyPricesCleared: dailyPricesCleared,
         intradayPricesCleared: intradayPricesCleared,
         dividendsCleared: dividendsCleared,
       );

  /// Returns a shallow copy of this [UpdateYahooSymbolResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UpdateYahooSymbolResult copyWith({
    bool? success,
    Object? newSymbol = _Undefined,
    int? dailyPricesCleared,
    int? intradayPricesCleared,
    int? dividendsCleared,
  }) {
    return UpdateYahooSymbolResult(
      success: success ?? this.success,
      newSymbol: newSymbol is String? ? newSymbol : this.newSymbol,
      dailyPricesCleared: dailyPricesCleared ?? this.dailyPricesCleared,
      intradayPricesCleared:
          intradayPricesCleared ?? this.intradayPricesCleared,
      dividendsCleared: dividendsCleared ?? this.dividendsCleared,
    );
  }
}
