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
import 'order_summary.dart' as _i2;
import 'package:bagholdr_client/src/protocol/protocol.dart' as _i3;

/// AssetDetailResponse - Full asset details with order history
/// Used by the asset detail screen
abstract class AssetDetailResponse implements _i1.SerializableModel {
  AssetDetailResponse._({
    required this.assetId,
    required this.isin,
    required this.ticker,
    required this.name,
    this.yahooSymbol,
    required this.assetType,
    required this.currency,
    required this.quantity,
    required this.value,
    required this.costBasis,
    required this.weight,
    required this.periodReturnAbs,
    this.periodReturnPct,
    required this.mwr,
    this.twr,
    this.sleeveId,
    this.sleeveName,
    required this.orders,
  });

  factory AssetDetailResponse({
    required String assetId,
    required String isin,
    required String ticker,
    required String name,
    String? yahooSymbol,
    required String assetType,
    required String currency,
    required double quantity,
    required double value,
    required double costBasis,
    required double weight,
    required double periodReturnAbs,
    double? periodReturnPct,
    required double mwr,
    double? twr,
    String? sleeveId,
    String? sleeveName,
    required List<_i2.OrderSummary> orders,
  }) = _AssetDetailResponseImpl;

  factory AssetDetailResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetDetailResponse(
      assetId: jsonSerialization['assetId'] as String,
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
      yahooSymbol: jsonSerialization['yahooSymbol'] as String?,
      assetType: jsonSerialization['assetType'] as String,
      currency: jsonSerialization['currency'] as String,
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      value: (jsonSerialization['value'] as num).toDouble(),
      costBasis: (jsonSerialization['costBasis'] as num).toDouble(),
      weight: (jsonSerialization['weight'] as num).toDouble(),
      periodReturnAbs: (jsonSerialization['periodReturnAbs'] as num).toDouble(),
      periodReturnPct: (jsonSerialization['periodReturnPct'] as num?)
          ?.toDouble(),
      mwr: (jsonSerialization['mwr'] as num).toDouble(),
      twr: (jsonSerialization['twr'] as num?)?.toDouble(),
      sleeveId: jsonSerialization['sleeveId'] as String?,
      sleeveName: jsonSerialization['sleeveName'] as String?,
      orders: _i3.Protocol().deserialize<List<_i2.OrderSummary>>(
        jsonSerialization['orders'],
      ),
    );
  }

  /// Asset identification
  String assetId;

  String isin;

  String ticker;

  String name;

  String? yahooSymbol;

  String assetType;

  String currency;

  /// Position info
  double quantity;

  double value;

  double costBasis;

  double weight;

  /// Returns (period-specific)
  double periodReturnAbs;

  double? periodReturnPct;

  double mwr;

  double? twr;

  /// Sleeve assignment
  String? sleeveId;

  String? sleeveName;

  /// Order history (most recent first)
  List<_i2.OrderSummary> orders;

  /// Returns a shallow copy of this [AssetDetailResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssetDetailResponse copyWith({
    String? assetId,
    String? isin,
    String? ticker,
    String? name,
    String? yahooSymbol,
    String? assetType,
    String? currency,
    double? quantity,
    double? value,
    double? costBasis,
    double? weight,
    double? periodReturnAbs,
    double? periodReturnPct,
    double? mwr,
    double? twr,
    String? sleeveId,
    String? sleeveName,
    List<_i2.OrderSummary>? orders,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetDetailResponse',
      'assetId': assetId,
      'isin': isin,
      'ticker': ticker,
      'name': name,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      'assetType': assetType,
      'currency': currency,
      'quantity': quantity,
      'value': value,
      'costBasis': costBasis,
      'weight': weight,
      'periodReturnAbs': periodReturnAbs,
      if (periodReturnPct != null) 'periodReturnPct': periodReturnPct,
      'mwr': mwr,
      if (twr != null) 'twr': twr,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
      'orders': orders.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetDetailResponseImpl extends AssetDetailResponse {
  _AssetDetailResponseImpl({
    required String assetId,
    required String isin,
    required String ticker,
    required String name,
    String? yahooSymbol,
    required String assetType,
    required String currency,
    required double quantity,
    required double value,
    required double costBasis,
    required double weight,
    required double periodReturnAbs,
    double? periodReturnPct,
    required double mwr,
    double? twr,
    String? sleeveId,
    String? sleeveName,
    required List<_i2.OrderSummary> orders,
  }) : super._(
         assetId: assetId,
         isin: isin,
         ticker: ticker,
         name: name,
         yahooSymbol: yahooSymbol,
         assetType: assetType,
         currency: currency,
         quantity: quantity,
         value: value,
         costBasis: costBasis,
         weight: weight,
         periodReturnAbs: periodReturnAbs,
         periodReturnPct: periodReturnPct,
         mwr: mwr,
         twr: twr,
         sleeveId: sleeveId,
         sleeveName: sleeveName,
         orders: orders,
       );

  /// Returns a shallow copy of this [AssetDetailResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AssetDetailResponse copyWith({
    String? assetId,
    String? isin,
    String? ticker,
    String? name,
    Object? yahooSymbol = _Undefined,
    String? assetType,
    String? currency,
    double? quantity,
    double? value,
    double? costBasis,
    double? weight,
    double? periodReturnAbs,
    Object? periodReturnPct = _Undefined,
    double? mwr,
    Object? twr = _Undefined,
    Object? sleeveId = _Undefined,
    Object? sleeveName = _Undefined,
    List<_i2.OrderSummary>? orders,
  }) {
    return AssetDetailResponse(
      assetId: assetId ?? this.assetId,
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      yahooSymbol: yahooSymbol is String? ? yahooSymbol : this.yahooSymbol,
      assetType: assetType ?? this.assetType,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      value: value ?? this.value,
      costBasis: costBasis ?? this.costBasis,
      weight: weight ?? this.weight,
      periodReturnAbs: periodReturnAbs ?? this.periodReturnAbs,
      periodReturnPct: periodReturnPct is double?
          ? periodReturnPct
          : this.periodReturnPct,
      mwr: mwr ?? this.mwr,
      twr: twr is double? ? twr : this.twr,
      sleeveId: sleeveId is String? ? sleeveId : this.sleeveId,
      sleeveName: sleeveName is String? ? sleeveName : this.sleeveName,
      orders: orders ?? this.orders.map((e0) => e0.copyWith()).toList(),
    );
  }
}
