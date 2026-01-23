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
import 'sleeve_node.dart' as _i2;
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i3;

/// SleeveNode - Sleeve in the hierarchy tree with allocation and return data
abstract class SleeveNode implements _i1.SerializableModel {
  SleeveNode._({
    required this.id,
    required this.name,
    this.parentId,
    required this.color,
    required this.targetPct,
    required this.currentPct,
    required this.driftPp,
    required this.driftStatus,
    required this.value,
    required this.mwr,
    this.twr,
    this.totalReturn,
    required this.assetCount,
    required this.childSleeveCount,
    this.children,
  });

  factory SleeveNode({
    required String id,
    required String name,
    String? parentId,
    required String color,
    required double targetPct,
    required double currentPct,
    required double driftPp,
    required String driftStatus,
    required double value,
    required double mwr,
    double? twr,
    double? totalReturn,
    required int assetCount,
    required int childSleeveCount,
    List<_i2.SleeveNode>? children,
  }) = _SleeveNodeImpl;

  factory SleeveNode.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveNode(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      parentId: jsonSerialization['parentId'] as String?,
      color: jsonSerialization['color'] as String,
      targetPct: (jsonSerialization['targetPct'] as num).toDouble(),
      currentPct: (jsonSerialization['currentPct'] as num).toDouble(),
      driftPp: (jsonSerialization['driftPp'] as num).toDouble(),
      driftStatus: jsonSerialization['driftStatus'] as String,
      value: (jsonSerialization['value'] as num).toDouble(),
      mwr: (jsonSerialization['mwr'] as num).toDouble(),
      twr: (jsonSerialization['twr'] as num?)?.toDouble(),
      totalReturn: (jsonSerialization['totalReturn'] as num?)?.toDouble(),
      assetCount: jsonSerialization['assetCount'] as int,
      childSleeveCount: jsonSerialization['childSleeveCount'] as int,
      children: jsonSerialization['children'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.SleeveNode>>(
              jsonSerialization['children'],
            ),
    );
  }

  /// Sleeve ID (UUID)
  String id;

  /// Sleeve display name
  String name;

  /// Parent sleeve ID (null for top-level sleeves)
  String? parentId;

  /// Hex color code (e.g., "#3b82f6")
  String color;

  /// Target allocation percentage
  double targetPct;

  /// Actual current allocation percentage
  double currentPct;

  /// Drift from target in percentage points
  double driftPp;

  /// Drift status: "ok", "over", or "under"
  String driftStatus;

  /// Total value in EUR (includes descendant sleeves)
  double value;

  /// MWR compounded return for period (big green/red number)
  double mwr;

  /// TWR return for period (grey, null if calculation failed)
  double? twr;

  /// Total return for period ((endValue + sells) / (startValue + buys + fees) - 1)
  double? totalReturn;

  /// Number of direct assets in this sleeve
  int assetCount;

  /// Number of direct child sleeves
  int childSleeveCount;

  /// Child sleeves (for tree rendering, null for leaves)
  List<_i2.SleeveNode>? children;

  /// Returns a shallow copy of this [SleeveNode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveNode copyWith({
    String? id,
    String? name,
    String? parentId,
    String? color,
    double? targetPct,
    double? currentPct,
    double? driftPp,
    String? driftStatus,
    double? value,
    double? mwr,
    double? twr,
    double? totalReturn,
    int? assetCount,
    int? childSleeveCount,
    List<_i2.SleeveNode>? children,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveNode',
      'id': id,
      'name': name,
      if (parentId != null) 'parentId': parentId,
      'color': color,
      'targetPct': targetPct,
      'currentPct': currentPct,
      'driftPp': driftPp,
      'driftStatus': driftStatus,
      'value': value,
      'mwr': mwr,
      if (twr != null) 'twr': twr,
      if (totalReturn != null) 'totalReturn': totalReturn,
      'assetCount': assetCount,
      'childSleeveCount': childSleeveCount,
      if (children != null)
        'children': children?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveNodeImpl extends SleeveNode {
  _SleeveNodeImpl({
    required String id,
    required String name,
    String? parentId,
    required String color,
    required double targetPct,
    required double currentPct,
    required double driftPp,
    required String driftStatus,
    required double value,
    required double mwr,
    double? twr,
    double? totalReturn,
    required int assetCount,
    required int childSleeveCount,
    List<_i2.SleeveNode>? children,
  }) : super._(
         id: id,
         name: name,
         parentId: parentId,
         color: color,
         targetPct: targetPct,
         currentPct: currentPct,
         driftPp: driftPp,
         driftStatus: driftStatus,
         value: value,
         mwr: mwr,
         twr: twr,
         totalReturn: totalReturn,
         assetCount: assetCount,
         childSleeveCount: childSleeveCount,
         children: children,
       );

  /// Returns a shallow copy of this [SleeveNode]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveNode copyWith({
    String? id,
    String? name,
    Object? parentId = _Undefined,
    String? color,
    double? targetPct,
    double? currentPct,
    double? driftPp,
    String? driftStatus,
    double? value,
    double? mwr,
    Object? twr = _Undefined,
    Object? totalReturn = _Undefined,
    int? assetCount,
    int? childSleeveCount,
    Object? children = _Undefined,
  }) {
    return SleeveNode(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId is String? ? parentId : this.parentId,
      color: color ?? this.color,
      targetPct: targetPct ?? this.targetPct,
      currentPct: currentPct ?? this.currentPct,
      driftPp: driftPp ?? this.driftPp,
      driftStatus: driftStatus ?? this.driftStatus,
      value: value ?? this.value,
      mwr: mwr ?? this.mwr,
      twr: twr is double? ? twr : this.twr,
      totalReturn: totalReturn is double? ? totalReturn : this.totalReturn,
      assetCount: assetCount ?? this.assetCount,
      childSleeveCount: childSleeveCount ?? this.childSleeveCount,
      children: children is List<_i2.SleeveNode>?
          ? children
          : this.children?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
