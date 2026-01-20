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
import 'period_return.dart' as _i2;
import 'asset_period_return.dart' as _i3;
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i4;

/// HistoricalReturnsResult - Historical returns response
abstract class HistoricalReturnsResult implements _i1.SerializableModel {
  HistoricalReturnsResult._({
    required this.currentValue,
    required this.returns,
    required this.assetReturns,
  });

  factory HistoricalReturnsResult({
    required double currentValue,
    required Map<String, _i2.PeriodReturn> returns,
    required Map<String, Map<String, _i3.AssetPeriodReturn>> assetReturns,
  }) = _HistoricalReturnsResultImpl;

  factory HistoricalReturnsResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HistoricalReturnsResult(
      currentValue: (jsonSerialization['currentValue'] as num).toDouble(),
      returns: _i4.Protocol().deserialize<Map<String, _i2.PeriodReturn>>(
        jsonSerialization['returns'],
      ),
      assetReturns: _i4.Protocol()
          .deserialize<Map<String, Map<String, _i3.AssetPeriodReturn>>>(
            jsonSerialization['assetReturns'],
          ),
    );
  }

  /// Current portfolio value
  double currentValue;

  /// Returns by period (today, 1w, 1m, etc.)
  Map<String, _i2.PeriodReturn> returns;

  /// Per-asset returns keyed by period, then by ISIN
  Map<String, Map<String, _i3.AssetPeriodReturn>> assetReturns;

  /// Returns a shallow copy of this [HistoricalReturnsResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HistoricalReturnsResult copyWith({
    double? currentValue,
    Map<String, _i2.PeriodReturn>? returns,
    Map<String, Map<String, _i3.AssetPeriodReturn>>? assetReturns,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HistoricalReturnsResult',
      'currentValue': currentValue,
      'returns': returns.toJson(valueToJson: (v) => v.toJson()),
      'assetReturns': assetReturns.toJson(
        valueToJson: (v) => v.toJson(valueToJson: (v) => v.toJson()),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _HistoricalReturnsResultImpl extends HistoricalReturnsResult {
  _HistoricalReturnsResultImpl({
    required double currentValue,
    required Map<String, _i2.PeriodReturn> returns,
    required Map<String, Map<String, _i3.AssetPeriodReturn>> assetReturns,
  }) : super._(
         currentValue: currentValue,
         returns: returns,
         assetReturns: assetReturns,
       );

  /// Returns a shallow copy of this [HistoricalReturnsResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HistoricalReturnsResult copyWith({
    double? currentValue,
    Map<String, _i2.PeriodReturn>? returns,
    Map<String, Map<String, _i3.AssetPeriodReturn>>? assetReturns,
  }) {
    return HistoricalReturnsResult(
      currentValue: currentValue ?? this.currentValue,
      returns:
          returns ??
          this.returns.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0.copyWith(),
            ),
          ),
      assetReturns:
          assetReturns ??
          this.assetReturns.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0.map(
                (
                  key1,
                  value1,
                ) => MapEntry(
                  key1,
                  value1.copyWith(),
                ),
              ),
            ),
          ),
    );
  }
}
