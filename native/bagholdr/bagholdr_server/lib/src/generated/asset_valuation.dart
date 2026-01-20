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

/// AssetValuation - Valuation details for a single asset
abstract class AssetValuation
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AssetValuation._({
    required this.isin,
    required this.ticker,
    required this.name,
    required this.assetType,
    required this.quantity,
    this.priceEur,
    required this.costBasisEur,
    required this.valueEur,
    required this.usingCostBasis,
    required this.percentOfInvested,
    required this.currency,
    this.priceNative,
    required this.costBasisNative,
    this.impliedHistoricalFxRate,
  });

  factory AssetValuation({
    required String isin,
    required String ticker,
    required String name,
    required _i2.AssetType assetType,
    required double quantity,
    double? priceEur,
    required double costBasisEur,
    required double valueEur,
    required bool usingCostBasis,
    required double percentOfInvested,
    required String currency,
    double? priceNative,
    required double costBasisNative,
    double? impliedHistoricalFxRate,
  }) = _AssetValuationImpl;

  factory AssetValuation.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetValuation(
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
      assetType: _i2.AssetType.fromJson(
        (jsonSerialization['assetType'] as String),
      ),
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      priceEur: (jsonSerialization['priceEur'] as num?)?.toDouble(),
      costBasisEur: (jsonSerialization['costBasisEur'] as num).toDouble(),
      valueEur: (jsonSerialization['valueEur'] as num).toDouble(),
      usingCostBasis: jsonSerialization['usingCostBasis'] as bool,
      percentOfInvested: (jsonSerialization['percentOfInvested'] as num)
          .toDouble(),
      currency: jsonSerialization['currency'] as String,
      priceNative: (jsonSerialization['priceNative'] as num?)?.toDouble(),
      costBasisNative: (jsonSerialization['costBasisNative'] as num).toDouble(),
      impliedHistoricalFxRate:
          (jsonSerialization['impliedHistoricalFxRate'] as num?)?.toDouble(),
    );
  }

  /// ISIN identifier
  String isin;

  /// Broker ticker symbol
  String ticker;

  /// Human-readable name
  String name;

  /// Asset classification
  _i2.AssetType assetType;

  /// Current quantity held
  double quantity;

  /// Current price in EUR (null if no cached price)
  double? priceEur;

  /// Total cost basis in EUR
  double costBasisEur;

  /// Current value in EUR (uses price if available, else cost basis)
  double valueEur;

  /// Whether this valuation is using cost basis instead of market price
  bool usingCostBasis;

  /// Percentage of invested portfolio
  double percentOfInvested;

  /// Asset's base currency (e.g., EUR, USD)
  String currency;

  /// Price in native currency (null if not available)
  double? priceNative;

  /// Cost basis in native currency (from orders)
  double costBasisNative;

  /// Implied FX rate at time of purchase (EUR per 1 unit of native)
  double? impliedHistoricalFxRate;

  /// Returns a shallow copy of this [AssetValuation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssetValuation copyWith({
    String? isin,
    String? ticker,
    String? name,
    _i2.AssetType? assetType,
    double? quantity,
    double? priceEur,
    double? costBasisEur,
    double? valueEur,
    bool? usingCostBasis,
    double? percentOfInvested,
    String? currency,
    double? priceNative,
    double? costBasisNative,
    double? impliedHistoricalFxRate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetValuation',
      'isin': isin,
      'ticker': ticker,
      'name': name,
      'assetType': assetType.toJson(),
      'quantity': quantity,
      if (priceEur != null) 'priceEur': priceEur,
      'costBasisEur': costBasisEur,
      'valueEur': valueEur,
      'usingCostBasis': usingCostBasis,
      'percentOfInvested': percentOfInvested,
      'currency': currency,
      if (priceNative != null) 'priceNative': priceNative,
      'costBasisNative': costBasisNative,
      if (impliedHistoricalFxRate != null)
        'impliedHistoricalFxRate': impliedHistoricalFxRate,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssetValuation',
      'isin': isin,
      'ticker': ticker,
      'name': name,
      'assetType': assetType.toJson(),
      'quantity': quantity,
      if (priceEur != null) 'priceEur': priceEur,
      'costBasisEur': costBasisEur,
      'valueEur': valueEur,
      'usingCostBasis': usingCostBasis,
      'percentOfInvested': percentOfInvested,
      'currency': currency,
      if (priceNative != null) 'priceNative': priceNative,
      'costBasisNative': costBasisNative,
      if (impliedHistoricalFxRate != null)
        'impliedHistoricalFxRate': impliedHistoricalFxRate,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetValuationImpl extends AssetValuation {
  _AssetValuationImpl({
    required String isin,
    required String ticker,
    required String name,
    required _i2.AssetType assetType,
    required double quantity,
    double? priceEur,
    required double costBasisEur,
    required double valueEur,
    required bool usingCostBasis,
    required double percentOfInvested,
    required String currency,
    double? priceNative,
    required double costBasisNative,
    double? impliedHistoricalFxRate,
  }) : super._(
         isin: isin,
         ticker: ticker,
         name: name,
         assetType: assetType,
         quantity: quantity,
         priceEur: priceEur,
         costBasisEur: costBasisEur,
         valueEur: valueEur,
         usingCostBasis: usingCostBasis,
         percentOfInvested: percentOfInvested,
         currency: currency,
         priceNative: priceNative,
         costBasisNative: costBasisNative,
         impliedHistoricalFxRate: impliedHistoricalFxRate,
       );

  /// Returns a shallow copy of this [AssetValuation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AssetValuation copyWith({
    String? isin,
    String? ticker,
    String? name,
    _i2.AssetType? assetType,
    double? quantity,
    Object? priceEur = _Undefined,
    double? costBasisEur,
    double? valueEur,
    bool? usingCostBasis,
    double? percentOfInvested,
    String? currency,
    Object? priceNative = _Undefined,
    double? costBasisNative,
    Object? impliedHistoricalFxRate = _Undefined,
  }) {
    return AssetValuation(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      assetType: assetType ?? this.assetType,
      quantity: quantity ?? this.quantity,
      priceEur: priceEur is double? ? priceEur : this.priceEur,
      costBasisEur: costBasisEur ?? this.costBasisEur,
      valueEur: valueEur ?? this.valueEur,
      usingCostBasis: usingCostBasis ?? this.usingCostBasis,
      percentOfInvested: percentOfInvested ?? this.percentOfInvested,
      currency: currency ?? this.currency,
      priceNative: priceNative is double? ? priceNative : this.priceNative,
      costBasisNative: costBasisNative ?? this.costBasisNative,
      impliedHistoricalFxRate: impliedHistoricalFxRate is double?
          ? impliedHistoricalFxRate
          : this.impliedHistoricalFxRate,
    );
  }
}
