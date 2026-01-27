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

/// HoldingResponse - Individual holding data for the assets section
abstract class HoldingResponse implements _i1.SerializableModel {
  HoldingResponse._({
    required this.symbol,
    required this.name,
    required this.isin,
    required this.value,
    required this.costBasis,
    required this.unrealizedPL,
    this.unrealizedPLPct,
    required this.weight,
    this.sleeveId,
    this.sleeveName,
    required this.assetId,
    required this.quantity,
  });

  factory HoldingResponse({
    required String symbol,
    required String name,
    required String isin,
    required double value,
    required double costBasis,
    required double unrealizedPL,
    double? unrealizedPLPct,
    required double weight,
    String? sleeveId,
    String? sleeveName,
    required String assetId,
    required double quantity,
  }) = _HoldingResponseImpl;

  factory HoldingResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return HoldingResponse(
      symbol: jsonSerialization['symbol'] as String,
      name: jsonSerialization['name'] as String,
      isin: jsonSerialization['isin'] as String,
      value: (jsonSerialization['value'] as num).toDouble(),
      costBasis: (jsonSerialization['costBasis'] as num).toDouble(),
      unrealizedPL: (jsonSerialization['unrealizedPL'] as num).toDouble(),
      unrealizedPLPct: (jsonSerialization['unrealizedPLPct'] as num?)
          ?.toDouble(),
      weight: (jsonSerialization['weight'] as num).toDouble(),
      sleeveId: jsonSerialization['sleeveId'] as String?,
      sleeveName: jsonSerialization['sleeveName'] as String?,
      assetId: jsonSerialization['assetId'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
    );
  }

  /// Asset symbol (e.g., "X.IUSQ")
  String symbol;

  /// Asset name
  String name;

  /// Asset ISIN
  String isin;

  /// Current market value (quantity * price)
  double value;

  /// Total cost basis in EUR
  double costBasis;

  /// Unrealized P/L (paper gain) for the period
  /// ALL period: value - costBasis
  /// Sub-periods: value - referenceValue (based on historical price)
  double unrealizedPL;

  /// Unrealized P/L as percentage (relative to reference value)
  double? unrealizedPLPct;

  /// Portfolio weight % (value / total * 100)
  double weight;

  /// Sleeve ID (UUID string)
  String? sleeveId;

  /// Sleeve name for display
  String? sleeveName;

  /// Asset ID (UUID string)
  String assetId;

  /// Quantity held
  double quantity;

  /// Returns a shallow copy of this [HoldingResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HoldingResponse copyWith({
    String? symbol,
    String? name,
    String? isin,
    double? value,
    double? costBasis,
    double? unrealizedPL,
    double? unrealizedPLPct,
    double? weight,
    String? sleeveId,
    String? sleeveName,
    String? assetId,
    double? quantity,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HoldingResponse',
      'symbol': symbol,
      'name': name,
      'isin': isin,
      'value': value,
      'costBasis': costBasis,
      'unrealizedPL': unrealizedPL,
      if (unrealizedPLPct != null) 'unrealizedPLPct': unrealizedPLPct,
      'weight': weight,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
      'assetId': assetId,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HoldingResponseImpl extends HoldingResponse {
  _HoldingResponseImpl({
    required String symbol,
    required String name,
    required String isin,
    required double value,
    required double costBasis,
    required double unrealizedPL,
    double? unrealizedPLPct,
    required double weight,
    String? sleeveId,
    String? sleeveName,
    required String assetId,
    required double quantity,
  }) : super._(
         symbol: symbol,
         name: name,
         isin: isin,
         value: value,
         costBasis: costBasis,
         unrealizedPL: unrealizedPL,
         unrealizedPLPct: unrealizedPLPct,
         weight: weight,
         sleeveId: sleeveId,
         sleeveName: sleeveName,
         assetId: assetId,
         quantity: quantity,
       );

  /// Returns a shallow copy of this [HoldingResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HoldingResponse copyWith({
    String? symbol,
    String? name,
    String? isin,
    double? value,
    double? costBasis,
    double? unrealizedPL,
    Object? unrealizedPLPct = _Undefined,
    double? weight,
    Object? sleeveId = _Undefined,
    Object? sleeveName = _Undefined,
    String? assetId,
    double? quantity,
  }) {
    return HoldingResponse(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      isin: isin ?? this.isin,
      value: value ?? this.value,
      costBasis: costBasis ?? this.costBasis,
      unrealizedPL: unrealizedPL ?? this.unrealizedPL,
      unrealizedPLPct: unrealizedPLPct is double?
          ? unrealizedPLPct
          : this.unrealizedPLPct,
      weight: weight ?? this.weight,
      sleeveId: sleeveId is String? ? sleeveId : this.sleeveId,
      sleeveName: sleeveName is String? ? sleeveName : this.sleeveName,
      assetId: assetId ?? this.assetId,
      quantity: quantity ?? this.quantity,
    );
  }
}
