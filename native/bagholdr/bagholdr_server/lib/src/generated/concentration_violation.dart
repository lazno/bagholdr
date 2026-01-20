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
import 'asset_type.dart' as _i2;

/// ConcentrationViolation - Single asset concentration rule violation
abstract class ConcentrationViolation
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ConcentrationViolation._({
    required this.ruleId,
    required this.ruleName,
    required this.assetIsin,
    required this.assetName,
    required this.assetTicker,
    required this.assetType,
    required this.actualPercent,
    required this.maxPercent,
  });

  factory ConcentrationViolation({
    required String ruleId,
    required String ruleName,
    required String assetIsin,
    required String assetName,
    required String assetTicker,
    required _i2.AssetType assetType,
    required double actualPercent,
    required double maxPercent,
  }) = _ConcentrationViolationImpl;

  factory ConcentrationViolation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ConcentrationViolation(
      ruleId: jsonSerialization['ruleId'] as String,
      ruleName: jsonSerialization['ruleName'] as String,
      assetIsin: jsonSerialization['assetIsin'] as String,
      assetName: jsonSerialization['assetName'] as String,
      assetTicker: jsonSerialization['assetTicker'] as String,
      assetType: _i2.AssetType.fromJson(
        (jsonSerialization['assetType'] as String),
      ),
      actualPercent: (jsonSerialization['actualPercent'] as num).toDouble(),
      maxPercent: (jsonSerialization['maxPercent'] as num).toDouble(),
    );
  }

  /// Rule ID
  String ruleId;

  /// Rule display name
  String ruleName;

  /// ISIN of the violating asset
  String assetIsin;

  /// Name of the violating asset
  String assetName;

  /// Ticker of the violating asset
  String assetTicker;

  /// Asset type
  _i2.AssetType assetType;

  /// Actual percentage of portfolio
  double actualPercent;

  /// Maximum allowed percentage
  double maxPercent;

  /// Returns a shallow copy of this [ConcentrationViolation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ConcentrationViolation copyWith({
    String? ruleId,
    String? ruleName,
    String? assetIsin,
    String? assetName,
    String? assetTicker,
    _i2.AssetType? assetType,
    double? actualPercent,
    double? maxPercent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConcentrationViolation',
      'ruleId': ruleId,
      'ruleName': ruleName,
      'assetIsin': assetIsin,
      'assetName': assetName,
      'assetTicker': assetTicker,
      'assetType': assetType.toJson(),
      'actualPercent': actualPercent,
      'maxPercent': maxPercent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConcentrationViolation',
      'ruleId': ruleId,
      'ruleName': ruleName,
      'assetIsin': assetIsin,
      'assetName': assetName,
      'assetTicker': assetTicker,
      'assetType': assetType.toJson(),
      'actualPercent': actualPercent,
      'maxPercent': maxPercent,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ConcentrationViolationImpl extends ConcentrationViolation {
  _ConcentrationViolationImpl({
    required String ruleId,
    required String ruleName,
    required String assetIsin,
    required String assetName,
    required String assetTicker,
    required _i2.AssetType assetType,
    required double actualPercent,
    required double maxPercent,
  }) : super._(
         ruleId: ruleId,
         ruleName: ruleName,
         assetIsin: assetIsin,
         assetName: assetName,
         assetTicker: assetTicker,
         assetType: assetType,
         actualPercent: actualPercent,
         maxPercent: maxPercent,
       );

  /// Returns a shallow copy of this [ConcentrationViolation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ConcentrationViolation copyWith({
    String? ruleId,
    String? ruleName,
    String? assetIsin,
    String? assetName,
    String? assetTicker,
    _i2.AssetType? assetType,
    double? actualPercent,
    double? maxPercent,
  }) {
    return ConcentrationViolation(
      ruleId: ruleId ?? this.ruleId,
      ruleName: ruleName ?? this.ruleName,
      assetIsin: assetIsin ?? this.assetIsin,
      assetName: assetName ?? this.assetName,
      assetTicker: assetTicker ?? this.assetTicker,
      assetType: assetType ?? this.assetType,
      actualPercent: actualPercent ?? this.actualPercent,
      maxPercent: maxPercent ?? this.maxPercent,
    );
  }
}
