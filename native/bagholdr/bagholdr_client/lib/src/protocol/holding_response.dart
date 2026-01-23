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
    required this.pl,
    required this.weight,
    required this.mwr,
    this.twr,
    this.totalReturn,
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
    required double pl,
    required double weight,
    required double mwr,
    double? twr,
    double? totalReturn,
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
      pl: (jsonSerialization['pl'] as num).toDouble(),
      weight: (jsonSerialization['weight'] as num).toDouble(),
      mwr: (jsonSerialization['mwr'] as num).toDouble(),
      twr: (jsonSerialization['twr'] as num?)?.toDouble(),
      totalReturn: (jsonSerialization['totalReturn'] as num?)?.toDouble(),
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

  /// Profit/Loss (value - costBasis)
  double pl;

  /// Portfolio weight % (value / total * 100)
  double weight;

  /// MWR compounded return % for period (big green/red number)
  double mwr;

  /// TWR return % for period (grey, null if calculation failed)
  double? twr;

  /// Total return % for period ((endValue + sells) / (startValue + buys + fees) - 1)
  double? totalReturn;

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
    double? pl,
    double? weight,
    double? mwr,
    double? twr,
    double? totalReturn,
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
      'pl': pl,
      'weight': weight,
      'mwr': mwr,
      if (twr != null) 'twr': twr,
      if (totalReturn != null) 'totalReturn': totalReturn,
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
    required double pl,
    required double weight,
    required double mwr,
    double? twr,
    double? totalReturn,
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
         pl: pl,
         weight: weight,
         mwr: mwr,
         twr: twr,
         totalReturn: totalReturn,
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
    double? pl,
    double? weight,
    double? mwr,
    Object? twr = _Undefined,
    Object? totalReturn = _Undefined,
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
      pl: pl ?? this.pl,
      weight: weight ?? this.weight,
      mwr: mwr ?? this.mwr,
      twr: twr is double? ? twr : this.twr,
      totalReturn: totalReturn is double? ? totalReturn : this.totalReturn,
      sleeveId: sleeveId is String? ? sleeveId : this.sleeveId,
      sleeveName: sleeveName is String? ? sleeveName : this.sleeveName,
      assetId: assetId ?? this.assetId,
      quantity: quantity ?? this.quantity,
    );
  }
}
