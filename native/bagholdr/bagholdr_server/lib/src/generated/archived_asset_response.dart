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

/// ArchivedAssetResponse - Summary of an archived asset
/// Used by the Manage Assets screen to display archived assets
abstract class ArchivedAssetResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ArchivedAssetResponse._({
    required this.id,
    required this.name,
    required this.isin,
    this.yahooSymbol,
    this.lastKnownValue,
  });

  factory ArchivedAssetResponse({
    required String id,
    required String name,
    required String isin,
    String? yahooSymbol,
    double? lastKnownValue,
  }) = _ArchivedAssetResponseImpl;

  factory ArchivedAssetResponse.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return ArchivedAssetResponse(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      isin: jsonSerialization['isin'] as String,
      yahooSymbol: jsonSerialization['yahooSymbol'] as String?,
      lastKnownValue: (jsonSerialization['lastKnownValue'] as num?)?.toDouble(),
    );
  }

  /// Asset ID (UUID string)
  String id;

  /// Asset name
  String name;

  /// ISIN
  String isin;

  /// Yahoo symbol (if set)
  String? yahooSymbol;

  /// Last known value in EUR (if holding exists)
  double? lastKnownValue;

  /// Returns a shallow copy of this [ArchivedAssetResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ArchivedAssetResponse copyWith({
    String? id,
    String? name,
    String? isin,
    String? yahooSymbol,
    double? lastKnownValue,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ArchivedAssetResponse',
      'id': id,
      'name': name,
      'isin': isin,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      if (lastKnownValue != null) 'lastKnownValue': lastKnownValue,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ArchivedAssetResponse',
      'id': id,
      'name': name,
      'isin': isin,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      if (lastKnownValue != null) 'lastKnownValue': lastKnownValue,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ArchivedAssetResponseImpl extends ArchivedAssetResponse {
  _ArchivedAssetResponseImpl({
    required String id,
    required String name,
    required String isin,
    String? yahooSymbol,
    double? lastKnownValue,
  }) : super._(
         id: id,
         name: name,
         isin: isin,
         yahooSymbol: yahooSymbol,
         lastKnownValue: lastKnownValue,
       );

  /// Returns a shallow copy of this [ArchivedAssetResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ArchivedAssetResponse copyWith({
    String? id,
    String? name,
    String? isin,
    Object? yahooSymbol = _Undefined,
    Object? lastKnownValue = _Undefined,
  }) {
    return ArchivedAssetResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      isin: isin ?? this.isin,
      yahooSymbol: yahooSymbol is String? ? yahooSymbol : this.yahooSymbol,
      lastKnownValue: lastKnownValue is double?
          ? lastKnownValue
          : this.lastKnownValue,
    );
  }
}
