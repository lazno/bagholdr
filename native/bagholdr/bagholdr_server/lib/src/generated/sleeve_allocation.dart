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
import 'asset_valuation.dart' as _i2;
import 'band.dart' as _i3;
import 'allocation_status.dart' as _i4;
import 'package:bagholdr_server/src/generated/protocol.dart' as _i5;

/// SleeveAllocation - Sleeve with allocation and band info
abstract class SleeveAllocation
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SleeveAllocation._({
    required this.sleeveId,
    required this.sleeveName,
    this.parentSleeveId,
    required this.budgetPercent,
    required this.directAssets,
    required this.directValueEur,
    required this.totalValueEur,
    required this.actualPercentInvested,
    required this.actualPercentTotal,
    required this.band,
    required this.status,
    required this.deltaPercent,
  });

  factory SleeveAllocation({
    required String sleeveId,
    required String sleeveName,
    String? parentSleeveId,
    required double budgetPercent,
    required List<_i2.AssetValuation> directAssets,
    required double directValueEur,
    required double totalValueEur,
    required double actualPercentInvested,
    required double actualPercentTotal,
    required _i3.Band band,
    required _i4.AllocationStatus status,
    required double deltaPercent,
  }) = _SleeveAllocationImpl;

  factory SleeveAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveAllocation(
      sleeveId: jsonSerialization['sleeveId'] as String,
      sleeveName: jsonSerialization['sleeveName'] as String,
      parentSleeveId: jsonSerialization['parentSleeveId'] as String?,
      budgetPercent: (jsonSerialization['budgetPercent'] as num).toDouble(),
      directAssets: _i5.Protocol().deserialize<List<_i2.AssetValuation>>(
        jsonSerialization['directAssets'],
      ),
      directValueEur: (jsonSerialization['directValueEur'] as num).toDouble(),
      totalValueEur: (jsonSerialization['totalValueEur'] as num).toDouble(),
      actualPercentInvested: (jsonSerialization['actualPercentInvested'] as num)
          .toDouble(),
      actualPercentTotal: (jsonSerialization['actualPercentTotal'] as num)
          .toDouble(),
      band: _i5.Protocol().deserialize<_i3.Band>(jsonSerialization['band']),
      status: _i4.AllocationStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      deltaPercent: (jsonSerialization['deltaPercent'] as num).toDouble(),
    );
  }

  /// Sleeve ID (UUID)
  String sleeveId;

  /// Sleeve display name
  String sleeveName;

  /// Parent sleeve ID (null for top-level)
  String? parentSleeveId;

  /// Target allocation percentage
  double budgetPercent;

  /// Direct assets assigned to this sleeve
  List<_i2.AssetValuation> directAssets;

  /// Value of direct assets in EUR
  double directValueEur;

  /// Total value including all descendants in EUR
  double totalValueEur;

  /// Percentage of invested holdings (primary)
  double actualPercentInvested;

  /// Percentage of total including cash (informational)
  double actualPercentTotal;

  /// Calculated band bounds
  _i3.Band band;

  /// Band evaluation status
  _i4.AllocationStatus status;

  /// Deviation from target (percentage points)
  double deltaPercent;

  /// Returns a shallow copy of this [SleeveAllocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveAllocation copyWith({
    String? sleeveId,
    String? sleeveName,
    String? parentSleeveId,
    double? budgetPercent,
    List<_i2.AssetValuation>? directAssets,
    double? directValueEur,
    double? totalValueEur,
    double? actualPercentInvested,
    double? actualPercentTotal,
    _i3.Band? band,
    _i4.AllocationStatus? status,
    double? deltaPercent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveAllocation',
      'sleeveId': sleeveId,
      'sleeveName': sleeveName,
      if (parentSleeveId != null) 'parentSleeveId': parentSleeveId,
      'budgetPercent': budgetPercent,
      'directAssets': directAssets.toJson(valueToJson: (v) => v.toJson()),
      'directValueEur': directValueEur,
      'totalValueEur': totalValueEur,
      'actualPercentInvested': actualPercentInvested,
      'actualPercentTotal': actualPercentTotal,
      'band': band.toJson(),
      'status': status.toJson(),
      'deltaPercent': deltaPercent,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SleeveAllocation',
      'sleeveId': sleeveId,
      'sleeveName': sleeveName,
      if (parentSleeveId != null) 'parentSleeveId': parentSleeveId,
      'budgetPercent': budgetPercent,
      'directAssets': directAssets.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'directValueEur': directValueEur,
      'totalValueEur': totalValueEur,
      'actualPercentInvested': actualPercentInvested,
      'actualPercentTotal': actualPercentTotal,
      'band': band.toJsonForProtocol(),
      'status': status.toJson(),
      'deltaPercent': deltaPercent,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveAllocationImpl extends SleeveAllocation {
  _SleeveAllocationImpl({
    required String sleeveId,
    required String sleeveName,
    String? parentSleeveId,
    required double budgetPercent,
    required List<_i2.AssetValuation> directAssets,
    required double directValueEur,
    required double totalValueEur,
    required double actualPercentInvested,
    required double actualPercentTotal,
    required _i3.Band band,
    required _i4.AllocationStatus status,
    required double deltaPercent,
  }) : super._(
         sleeveId: sleeveId,
         sleeveName: sleeveName,
         parentSleeveId: parentSleeveId,
         budgetPercent: budgetPercent,
         directAssets: directAssets,
         directValueEur: directValueEur,
         totalValueEur: totalValueEur,
         actualPercentInvested: actualPercentInvested,
         actualPercentTotal: actualPercentTotal,
         band: band,
         status: status,
         deltaPercent: deltaPercent,
       );

  /// Returns a shallow copy of this [SleeveAllocation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveAllocation copyWith({
    String? sleeveId,
    String? sleeveName,
    Object? parentSleeveId = _Undefined,
    double? budgetPercent,
    List<_i2.AssetValuation>? directAssets,
    double? directValueEur,
    double? totalValueEur,
    double? actualPercentInvested,
    double? actualPercentTotal,
    _i3.Band? band,
    _i4.AllocationStatus? status,
    double? deltaPercent,
  }) {
    return SleeveAllocation(
      sleeveId: sleeveId ?? this.sleeveId,
      sleeveName: sleeveName ?? this.sleeveName,
      parentSleeveId: parentSleeveId is String?
          ? parentSleeveId
          : this.parentSleeveId,
      budgetPercent: budgetPercent ?? this.budgetPercent,
      directAssets:
          directAssets ?? this.directAssets.map((e0) => e0.copyWith()).toList(),
      directValueEur: directValueEur ?? this.directValueEur,
      totalValueEur: totalValueEur ?? this.totalValueEur,
      actualPercentInvested:
          actualPercentInvested ?? this.actualPercentInvested,
      actualPercentTotal: actualPercentTotal ?? this.actualPercentTotal,
      band: band ?? this.band.copyWith(),
      status: status ?? this.status,
      deltaPercent: deltaPercent ?? this.deltaPercent,
    );
  }
}
