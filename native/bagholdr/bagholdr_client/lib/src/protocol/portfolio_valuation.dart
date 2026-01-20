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
import 'sleeve_allocation.dart' as _i2;
import 'asset_valuation.dart' as _i3;
import 'band_config.dart' as _i4;
import 'missing_symbol_asset.dart' as _i5;
import 'stale_price_asset.dart' as _i6;
import 'concentration_violation.dart' as _i7;
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i8;

/// PortfolioValuation - Full portfolio valuation response
abstract class PortfolioValuation implements _i1.SerializableModel {
  PortfolioValuation._({
    required this.portfolioId,
    required this.portfolioName,
    required this.cashEur,
    required this.totalHoldingsValueEur,
    required this.assignedHoldingsValueEur,
    required this.unassignedValueEur,
    required this.investedValueEur,
    required this.totalValueEur,
    required this.totalCostBasisEur,
    required this.sleeves,
    required this.unassignedAssets,
    required this.bandConfig,
    required this.violationCount,
    required this.hasAllPrices,
    required this.missingSymbolAssets,
    required this.stalePriceAssets,
    required this.stalePriceThresholdHours,
    required this.concentrationViolations,
    required this.concentrationViolationCount,
    required this.totalViolationCount,
    this.lastSyncAt,
  });

  factory PortfolioValuation({
    required String portfolioId,
    required String portfolioName,
    required double cashEur,
    required double totalHoldingsValueEur,
    required double assignedHoldingsValueEur,
    required double unassignedValueEur,
    required double investedValueEur,
    required double totalValueEur,
    required double totalCostBasisEur,
    required List<_i2.SleeveAllocation> sleeves,
    required List<_i3.AssetValuation> unassignedAssets,
    required _i4.BandConfig bandConfig,
    required int violationCount,
    required bool hasAllPrices,
    required List<_i5.MissingSymbolAsset> missingSymbolAssets,
    required List<_i6.StalePriceAsset> stalePriceAssets,
    required int stalePriceThresholdHours,
    required List<_i7.ConcentrationViolation> concentrationViolations,
    required int concentrationViolationCount,
    required int totalViolationCount,
    DateTime? lastSyncAt,
  }) = _PortfolioValuationImpl;

  factory PortfolioValuation.fromJson(Map<String, dynamic> jsonSerialization) {
    return PortfolioValuation(
      portfolioId: jsonSerialization['portfolioId'] as String,
      portfolioName: jsonSerialization['portfolioName'] as String,
      cashEur: (jsonSerialization['cashEur'] as num).toDouble(),
      totalHoldingsValueEur: (jsonSerialization['totalHoldingsValueEur'] as num)
          .toDouble(),
      assignedHoldingsValueEur:
          (jsonSerialization['assignedHoldingsValueEur'] as num).toDouble(),
      unassignedValueEur: (jsonSerialization['unassignedValueEur'] as num)
          .toDouble(),
      investedValueEur: (jsonSerialization['investedValueEur'] as num)
          .toDouble(),
      totalValueEur: (jsonSerialization['totalValueEur'] as num).toDouble(),
      totalCostBasisEur: (jsonSerialization['totalCostBasisEur'] as num)
          .toDouble(),
      sleeves: _i8.Protocol().deserialize<List<_i2.SleeveAllocation>>(
        jsonSerialization['sleeves'],
      ),
      unassignedAssets: _i8.Protocol().deserialize<List<_i3.AssetValuation>>(
        jsonSerialization['unassignedAssets'],
      ),
      bandConfig: _i8.Protocol().deserialize<_i4.BandConfig>(
        jsonSerialization['bandConfig'],
      ),
      violationCount: jsonSerialization['violationCount'] as int,
      hasAllPrices: jsonSerialization['hasAllPrices'] as bool,
      missingSymbolAssets: _i8.Protocol()
          .deserialize<List<_i5.MissingSymbolAsset>>(
            jsonSerialization['missingSymbolAssets'],
          ),
      stalePriceAssets: _i8.Protocol().deserialize<List<_i6.StalePriceAsset>>(
        jsonSerialization['stalePriceAssets'],
      ),
      stalePriceThresholdHours:
          jsonSerialization['stalePriceThresholdHours'] as int,
      concentrationViolations: _i8.Protocol()
          .deserialize<List<_i7.ConcentrationViolation>>(
            jsonSerialization['concentrationViolations'],
          ),
      concentrationViolationCount:
          jsonSerialization['concentrationViolationCount'] as int,
      totalViolationCount: jsonSerialization['totalViolationCount'] as int,
      lastSyncAt: jsonSerialization['lastSyncAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSyncAt']),
    );
  }

  /// Portfolio ID (UUID)
  String portfolioId;

  /// Portfolio display name
  String portfolioName;

  /// Cash balance in EUR
  double cashEur;

  /// Total holdings value in EUR (all holdings)
  double totalHoldingsValueEur;

  /// Assigned holdings value in EUR (holdings in sleeves)
  double assignedHoldingsValueEur;

  /// Unassigned holdings value in EUR
  double unassignedValueEur;

  /// Invested value in EUR (= assignedHoldingsValueEur, the "100%" for invested view)
  double investedValueEur;

  /// Total portfolio value in EUR (holdings + cash)
  double totalValueEur;

  /// Total cost basis in EUR (for return calculation)
  double totalCostBasisEur;

  /// Sleeves with allocation info (excluding cash sleeves)
  List<_i2.SleeveAllocation> sleeves;

  /// Assets not assigned to any sleeve
  List<_i3.AssetValuation> unassignedAssets;

  /// Band configuration used for this portfolio
  _i4.BandConfig bandConfig;

  /// Number of sleeves with band violations
  int violationCount;

  /// Whether all assets have current prices
  bool hasAllPrices;

  /// Assets missing Yahoo symbols
  List<_i5.MissingSymbolAsset> missingSymbolAssets;

  /// Assets with stale prices
  List<_i6.StalePriceAsset> stalePriceAssets;

  /// Threshold for stale prices in hours
  int stalePriceThresholdHours;

  /// Concentration rule violations
  List<_i7.ConcentrationViolation> concentrationViolations;

  /// Number of concentration rule violations
  int concentrationViolationCount;

  /// Total violations (sleeves + concentration)
  int totalViolationCount;

  /// Most recent price sync time (null if no prices)
  DateTime? lastSyncAt;

  /// Returns a shallow copy of this [PortfolioValuation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PortfolioValuation copyWith({
    String? portfolioId,
    String? portfolioName,
    double? cashEur,
    double? totalHoldingsValueEur,
    double? assignedHoldingsValueEur,
    double? unassignedValueEur,
    double? investedValueEur,
    double? totalValueEur,
    double? totalCostBasisEur,
    List<_i2.SleeveAllocation>? sleeves,
    List<_i3.AssetValuation>? unassignedAssets,
    _i4.BandConfig? bandConfig,
    int? violationCount,
    bool? hasAllPrices,
    List<_i5.MissingSymbolAsset>? missingSymbolAssets,
    List<_i6.StalePriceAsset>? stalePriceAssets,
    int? stalePriceThresholdHours,
    List<_i7.ConcentrationViolation>? concentrationViolations,
    int? concentrationViolationCount,
    int? totalViolationCount,
    DateTime? lastSyncAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PortfolioValuation',
      'portfolioId': portfolioId,
      'portfolioName': portfolioName,
      'cashEur': cashEur,
      'totalHoldingsValueEur': totalHoldingsValueEur,
      'assignedHoldingsValueEur': assignedHoldingsValueEur,
      'unassignedValueEur': unassignedValueEur,
      'investedValueEur': investedValueEur,
      'totalValueEur': totalValueEur,
      'totalCostBasisEur': totalCostBasisEur,
      'sleeves': sleeves.toJson(valueToJson: (v) => v.toJson()),
      'unassignedAssets': unassignedAssets.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'bandConfig': bandConfig.toJson(),
      'violationCount': violationCount,
      'hasAllPrices': hasAllPrices,
      'missingSymbolAssets': missingSymbolAssets.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'stalePriceAssets': stalePriceAssets.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'stalePriceThresholdHours': stalePriceThresholdHours,
      'concentrationViolations': concentrationViolations.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'concentrationViolationCount': concentrationViolationCount,
      'totalViolationCount': totalViolationCount,
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioValuationImpl extends PortfolioValuation {
  _PortfolioValuationImpl({
    required String portfolioId,
    required String portfolioName,
    required double cashEur,
    required double totalHoldingsValueEur,
    required double assignedHoldingsValueEur,
    required double unassignedValueEur,
    required double investedValueEur,
    required double totalValueEur,
    required double totalCostBasisEur,
    required List<_i2.SleeveAllocation> sleeves,
    required List<_i3.AssetValuation> unassignedAssets,
    required _i4.BandConfig bandConfig,
    required int violationCount,
    required bool hasAllPrices,
    required List<_i5.MissingSymbolAsset> missingSymbolAssets,
    required List<_i6.StalePriceAsset> stalePriceAssets,
    required int stalePriceThresholdHours,
    required List<_i7.ConcentrationViolation> concentrationViolations,
    required int concentrationViolationCount,
    required int totalViolationCount,
    DateTime? lastSyncAt,
  }) : super._(
         portfolioId: portfolioId,
         portfolioName: portfolioName,
         cashEur: cashEur,
         totalHoldingsValueEur: totalHoldingsValueEur,
         assignedHoldingsValueEur: assignedHoldingsValueEur,
         unassignedValueEur: unassignedValueEur,
         investedValueEur: investedValueEur,
         totalValueEur: totalValueEur,
         totalCostBasisEur: totalCostBasisEur,
         sleeves: sleeves,
         unassignedAssets: unassignedAssets,
         bandConfig: bandConfig,
         violationCount: violationCount,
         hasAllPrices: hasAllPrices,
         missingSymbolAssets: missingSymbolAssets,
         stalePriceAssets: stalePriceAssets,
         stalePriceThresholdHours: stalePriceThresholdHours,
         concentrationViolations: concentrationViolations,
         concentrationViolationCount: concentrationViolationCount,
         totalViolationCount: totalViolationCount,
         lastSyncAt: lastSyncAt,
       );

  /// Returns a shallow copy of this [PortfolioValuation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PortfolioValuation copyWith({
    String? portfolioId,
    String? portfolioName,
    double? cashEur,
    double? totalHoldingsValueEur,
    double? assignedHoldingsValueEur,
    double? unassignedValueEur,
    double? investedValueEur,
    double? totalValueEur,
    double? totalCostBasisEur,
    List<_i2.SleeveAllocation>? sleeves,
    List<_i3.AssetValuation>? unassignedAssets,
    _i4.BandConfig? bandConfig,
    int? violationCount,
    bool? hasAllPrices,
    List<_i5.MissingSymbolAsset>? missingSymbolAssets,
    List<_i6.StalePriceAsset>? stalePriceAssets,
    int? stalePriceThresholdHours,
    List<_i7.ConcentrationViolation>? concentrationViolations,
    int? concentrationViolationCount,
    int? totalViolationCount,
    Object? lastSyncAt = _Undefined,
  }) {
    return PortfolioValuation(
      portfolioId: portfolioId ?? this.portfolioId,
      portfolioName: portfolioName ?? this.portfolioName,
      cashEur: cashEur ?? this.cashEur,
      totalHoldingsValueEur:
          totalHoldingsValueEur ?? this.totalHoldingsValueEur,
      assignedHoldingsValueEur:
          assignedHoldingsValueEur ?? this.assignedHoldingsValueEur,
      unassignedValueEur: unassignedValueEur ?? this.unassignedValueEur,
      investedValueEur: investedValueEur ?? this.investedValueEur,
      totalValueEur: totalValueEur ?? this.totalValueEur,
      totalCostBasisEur: totalCostBasisEur ?? this.totalCostBasisEur,
      sleeves: sleeves ?? this.sleeves.map((e0) => e0.copyWith()).toList(),
      unassignedAssets:
          unassignedAssets ??
          this.unassignedAssets.map((e0) => e0.copyWith()).toList(),
      bandConfig: bandConfig ?? this.bandConfig.copyWith(),
      violationCount: violationCount ?? this.violationCount,
      hasAllPrices: hasAllPrices ?? this.hasAllPrices,
      missingSymbolAssets:
          missingSymbolAssets ??
          this.missingSymbolAssets.map((e0) => e0.copyWith()).toList(),
      stalePriceAssets:
          stalePriceAssets ??
          this.stalePriceAssets.map((e0) => e0.copyWith()).toList(),
      stalePriceThresholdHours:
          stalePriceThresholdHours ?? this.stalePriceThresholdHours,
      concentrationViolations:
          concentrationViolations ??
          this.concentrationViolations.map((e0) => e0.copyWith()).toList(),
      concentrationViolationCount:
          concentrationViolationCount ?? this.concentrationViolationCount,
      totalViolationCount: totalViolationCount ?? this.totalViolationCount,
      lastSyncAt: lastSyncAt is DateTime? ? lastSyncAt : this.lastSyncAt,
    );
  }
}
