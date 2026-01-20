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
import 'asset_type.dart' as _i2;

/// Asset - Financial instruments identified by ISIN
/// Global table shared across all portfolios
abstract class Asset implements _i1.SerializableModel {
  Asset._({
    this.id,
    required this.isin,
    required this.ticker,
    required this.name,
    this.description,
    required this.assetType,
    required this.currency,
    this.yahooSymbol,
    this.metadata,
    required this.archived,
  });

  factory Asset({
    _i1.UuidValue? id,
    required String isin,
    required String ticker,
    required String name,
    String? description,
    required _i2.AssetType assetType,
    required String currency,
    String? yahooSymbol,
    String? metadata,
    required bool archived,
  }) = _AssetImpl;

  factory Asset.fromJson(Map<String, dynamic> jsonSerialization) {
    return Asset(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      assetType: _i2.AssetType.fromJson(
        (jsonSerialization['assetType'] as String),
      ),
      currency: jsonSerialization['currency'] as String,
      yahooSymbol: jsonSerialization['yahooSymbol'] as String?,
      metadata: jsonSerialization['metadata'] as String?,
      archived: jsonSerialization['archived'] as bool,
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// ISIN (International Securities Identification Number) - unique business identifier
  String isin;

  /// Broker's ticker symbol (from import)
  String ticker;

  /// Human-readable name
  String name;

  /// Optional description
  String? description;

  /// Classification: stock, etf, bond, fund, commodity, other
  _i2.AssetType assetType;

  /// Trading currency (e.g., EUR, USD)
  String currency;

  /// Yahoo Finance symbol - resolved from ISIN, used for price fetching
  String? yahooSymbol;

  /// JSON metadata for ETF look-through (holdings, sectors, factors)
  /// e.g., {"holdings": [{"name": "Apple", "weight": 5.2}], "sectors": [{"name": "Tech", "weight": 30}]}
  String? metadata;

  /// Whether asset is excluded from calculations and dashboard views
  bool archived;

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Asset copyWith({
    _i1.UuidValue? id,
    String? isin,
    String? ticker,
    String? name,
    String? description,
    _i2.AssetType? assetType,
    String? currency,
    String? yahooSymbol,
    String? metadata,
    bool? archived,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id?.toJson(),
      'isin': isin,
      'ticker': ticker,
      'name': name,
      if (description != null) 'description': description,
      'assetType': assetType.toJson(),
      'currency': currency,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      if (metadata != null) 'metadata': metadata,
      'archived': archived,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetImpl extends Asset {
  _AssetImpl({
    _i1.UuidValue? id,
    required String isin,
    required String ticker,
    required String name,
    String? description,
    required _i2.AssetType assetType,
    required String currency,
    String? yahooSymbol,
    String? metadata,
    required bool archived,
  }) : super._(
         id: id,
         isin: isin,
         ticker: ticker,
         name: name,
         description: description,
         assetType: assetType,
         currency: currency,
         yahooSymbol: yahooSymbol,
         metadata: metadata,
         archived: archived,
       );

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Asset copyWith({
    Object? id = _Undefined,
    String? isin,
    String? ticker,
    String? name,
    Object? description = _Undefined,
    _i2.AssetType? assetType,
    String? currency,
    Object? yahooSymbol = _Undefined,
    Object? metadata = _Undefined,
    bool? archived,
  }) {
    return Asset(
      id: id is _i1.UuidValue? ? id : this.id,
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      assetType: assetType ?? this.assetType,
      currency: currency ?? this.currency,
      yahooSymbol: yahooSymbol is String? ? yahooSymbol : this.yahooSymbol,
      metadata: metadata is String? ? metadata : this.metadata,
      archived: archived ?? this.archived,
    );
  }
}
