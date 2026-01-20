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

/// YahooSymbol - Available Yahoo Finance symbols for an ISIN
/// Stores all available symbols (multiple exchanges) for price lookups
abstract class YahooSymbol implements _i1.SerializableModel {
  YahooSymbol._({
    this.id,
    required this.assetId,
    required this.symbol,
    this.exchange,
    this.exchangeDisplay,
    this.quoteType,
    required this.resolvedAt,
  });

  factory YahooSymbol({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required String symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    required DateTime resolvedAt,
  }) = _YahooSymbolImpl;

  factory YahooSymbol.fromJson(Map<String, dynamic> jsonSerialization) {
    return YahooSymbol(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      symbol: jsonSerialization['symbol'] as String,
      exchange: jsonSerialization['exchange'] as String?,
      exchangeDisplay: jsonSerialization['exchangeDisplay'] as String?,
      quoteType: jsonSerialization['quoteType'] as String?,
      resolvedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['resolvedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT.L", "IUSQ.DE")
  String symbol;

  /// Exchange code (e.g., "NMS", "LSE", "GER")
  String? exchange;

  /// Human-readable exchange name (e.g., "NASDAQ", "London Stock Exchange")
  String? exchangeDisplay;

  /// Quote type (e.g., "EQUITY", "ETF", "MUTUALFUND")
  String? quoteType;

  /// When this symbol was resolved/discovered
  DateTime resolvedAt;

  /// Returns a shallow copy of this [YahooSymbol]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  YahooSymbol copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? assetId,
    String? symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    DateTime? resolvedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'YahooSymbol',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'symbol': symbol,
      if (exchange != null) 'exchange': exchange,
      if (exchangeDisplay != null) 'exchangeDisplay': exchangeDisplay,
      if (quoteType != null) 'quoteType': quoteType,
      'resolvedAt': resolvedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _YahooSymbolImpl extends YahooSymbol {
  _YahooSymbolImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required String symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    required DateTime resolvedAt,
  }) : super._(
         id: id,
         assetId: assetId,
         symbol: symbol,
         exchange: exchange,
         exchangeDisplay: exchangeDisplay,
         quoteType: quoteType,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [YahooSymbol]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  YahooSymbol copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? assetId,
    String? symbol,
    Object? exchange = _Undefined,
    Object? exchangeDisplay = _Undefined,
    Object? quoteType = _Undefined,
    DateTime? resolvedAt,
  }) {
    return YahooSymbol(
      id: id is _i1.UuidValue? ? id : this.id,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      exchange: exchange is String? ? exchange : this.exchange,
      exchangeDisplay: exchangeDisplay is String?
          ? exchangeDisplay
          : this.exchangeDisplay,
      quoteType: quoteType is String? ? quoteType : this.quoteType,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
