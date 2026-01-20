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

/// MissingSymbolAsset - Asset without Yahoo symbol (health issue)
abstract class MissingSymbolAsset
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MissingSymbolAsset._({
    required this.isin,
    required this.ticker,
    required this.name,
  });

  factory MissingSymbolAsset({
    required String isin,
    required String ticker,
    required String name,
  }) = _MissingSymbolAssetImpl;

  factory MissingSymbolAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return MissingSymbolAsset(
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
    );
  }

  /// ISIN identifier
  String isin;

  /// Broker ticker symbol
  String ticker;

  /// Human-readable name
  String name;

  /// Returns a shallow copy of this [MissingSymbolAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MissingSymbolAsset copyWith({
    String? isin,
    String? ticker,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MissingSymbolAsset',
      'isin': isin,
      'ticker': ticker,
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MissingSymbolAsset',
      'isin': isin,
      'ticker': ticker,
      'name': name,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MissingSymbolAssetImpl extends MissingSymbolAsset {
  _MissingSymbolAssetImpl({
    required String isin,
    required String ticker,
    required String name,
  }) : super._(
         isin: isin,
         ticker: ticker,
         name: name,
       );

  /// Returns a shallow copy of this [MissingSymbolAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MissingSymbolAsset copyWith({
    String? isin,
    String? ticker,
    String? name,
  }) {
    return MissingSymbolAsset(
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
    );
  }
}
