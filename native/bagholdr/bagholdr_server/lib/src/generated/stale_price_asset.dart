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

/// StalePriceAsset - Asset with stale price data (health issue)
abstract class StalePriceAsset
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  StalePriceAsset._({
    required this.isin,
    required this.ticker,
    required this.name,
    required this.lastFetchedAt,
    required this.hoursStale,
  });

  factory StalePriceAsset({
    required String isin,
    required String ticker,
    required String name,
    required DateTime lastFetchedAt,
    required int hoursStale,
  }) = _StalePriceAssetImpl;

  factory StalePriceAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return StalePriceAsset(
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
      lastFetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastFetchedAt'],
      ),
      hoursStale: jsonSerialization['hoursStale'] as int,
    );
  }

  /// ISIN identifier
  String isin;

  /// Broker ticker symbol
  String ticker;

  /// Human-readable name
  String name;

  /// When the price was last fetched
  DateTime lastFetchedAt;

  /// How many hours stale
  int hoursStale;

  /// Returns a shallow copy of this [StalePriceAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StalePriceAsset copyWith({
    String? isin,
    String? ticker,
    String? name,
    DateTime? lastFetchedAt,
    int? hoursStale,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StalePriceAsset',
      'isin': isin,
      'ticker': ticker,
      'name': name,
      'lastFetchedAt': lastFetchedAt.toJson(),
      'hoursStale': hoursStale,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StalePriceAsset',
      'isin': isin,
      'ticker': ticker,
      'name': name,
      'lastFetchedAt': lastFetchedAt.toJson(),
      'hoursStale': hoursStale,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _StalePriceAssetImpl extends StalePriceAsset {
  _StalePriceAssetImpl({
    required String isin,
    required String ticker,
    required String name,
    required DateTime lastFetchedAt,
    required int hoursStale,
  }) : super._(
         isin: isin,
         ticker: ticker,
         name: name,
         lastFetchedAt: lastFetchedAt,
         hoursStale: hoursStale,
       );

  /// Returns a shallow copy of this [StalePriceAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StalePriceAsset copyWith({
    String? isin,
    String? ticker,
    String? name,
    DateTime? lastFetchedAt,
    int? hoursStale,
  }) {
    return StalePriceAsset(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      hoursStale: hoursStale ?? this.hoursStale,
    );
  }
}
