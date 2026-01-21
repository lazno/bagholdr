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
import 'sleeve_node.dart' as _i2;
import 'package:bagholdr_server/src/generated/protocol.dart' as _i3;

/// SleeveTreeResponse - Sleeve hierarchy with allocation data for the Strategy section
abstract class SleeveTreeResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SleeveTreeResponse._({
    required this.sleeves,
    required this.totalValue,
    required this.totalMwr,
    this.totalTwr,
    required this.totalAssetCount,
  });

  factory SleeveTreeResponse({
    required List<_i2.SleeveNode> sleeves,
    required double totalValue,
    required double totalMwr,
    double? totalTwr,
    required int totalAssetCount,
  }) = _SleeveTreeResponseImpl;

  factory SleeveTreeResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveTreeResponse(
      sleeves: _i3.Protocol().deserialize<List<_i2.SleeveNode>>(
        jsonSerialization['sleeves'],
      ),
      totalValue: (jsonSerialization['totalValue'] as num).toDouble(),
      totalMwr: (jsonSerialization['totalMwr'] as num).toDouble(),
      totalTwr: (jsonSerialization['totalTwr'] as num?)?.toDouble(),
      totalAssetCount: jsonSerialization['totalAssetCount'] as int,
    );
  }

  /// Root-level sleeves (non-cash sleeves with no parent)
  List<_i2.SleeveNode> sleeves;

  /// Total portfolio value in EUR (invested holdings, excludes cash)
  double totalValue;

  /// Portfolio MWR compounded return for period (big green/red number)
  double totalMwr;

  /// Portfolio TWR return for period (grey, null if calculation failed)
  double? totalTwr;

  /// Total assets across all sleeves
  int totalAssetCount;

  /// Returns a shallow copy of this [SleeveTreeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveTreeResponse copyWith({
    List<_i2.SleeveNode>? sleeves,
    double? totalValue,
    double? totalMwr,
    double? totalTwr,
    int? totalAssetCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveTreeResponse',
      'sleeves': sleeves.toJson(valueToJson: (v) => v.toJson()),
      'totalValue': totalValue,
      'totalMwr': totalMwr,
      if (totalTwr != null) 'totalTwr': totalTwr,
      'totalAssetCount': totalAssetCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SleeveTreeResponse',
      'sleeves': sleeves.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalValue': totalValue,
      'totalMwr': totalMwr,
      if (totalTwr != null) 'totalTwr': totalTwr,
      'totalAssetCount': totalAssetCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveTreeResponseImpl extends SleeveTreeResponse {
  _SleeveTreeResponseImpl({
    required List<_i2.SleeveNode> sleeves,
    required double totalValue,
    required double totalMwr,
    double? totalTwr,
    required int totalAssetCount,
  }) : super._(
         sleeves: sleeves,
         totalValue: totalValue,
         totalMwr: totalMwr,
         totalTwr: totalTwr,
         totalAssetCount: totalAssetCount,
       );

  /// Returns a shallow copy of this [SleeveTreeResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveTreeResponse copyWith({
    List<_i2.SleeveNode>? sleeves,
    double? totalValue,
    double? totalMwr,
    Object? totalTwr = _Undefined,
    int? totalAssetCount,
  }) {
    return SleeveTreeResponse(
      sleeves: sleeves ?? this.sleeves.map((e0) => e0.copyWith()).toList(),
      totalValue: totalValue ?? this.totalValue,
      totalMwr: totalMwr ?? this.totalMwr,
      totalTwr: totalTwr is double? ? totalTwr : this.totalTwr,
      totalAssetCount: totalAssetCount ?? this.totalAssetCount,
    );
  }
}
