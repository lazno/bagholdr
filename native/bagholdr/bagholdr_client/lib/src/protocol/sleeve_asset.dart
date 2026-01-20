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

/// SleeveAsset - Junction table linking sleeves to assets
/// Enables many-to-many relationship between sleeves and assets
abstract class SleeveAsset implements _i1.SerializableModel {
  SleeveAsset._({
    this.id,
    required this.sleeveId,
    required this.assetId,
  });

  factory SleeveAsset({
    _i1.UuidValue? id,
    required _i1.UuidValue sleeveId,
    required _i1.UuidValue assetId,
  }) = _SleeveAssetImpl;

  factory SleeveAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveAsset(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      sleeveId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['sleeveId'],
      ),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the sleeve (UUID)
  _i1.UuidValue sleeveId;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Returns a shallow copy of this [SleeveAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveAsset copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? sleeveId,
    _i1.UuidValue? assetId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveAsset',
      if (id != null) 'id': id?.toJson(),
      'sleeveId': sleeveId.toJson(),
      'assetId': assetId.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveAssetImpl extends SleeveAsset {
  _SleeveAssetImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue sleeveId,
    required _i1.UuidValue assetId,
  }) : super._(
         id: id,
         sleeveId: sleeveId,
         assetId: assetId,
       );

  /// Returns a shallow copy of this [SleeveAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveAsset copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? sleeveId,
    _i1.UuidValue? assetId,
  }) {
    return SleeveAsset(
      id: id is _i1.UuidValue? ? id : this.id,
      sleeveId: sleeveId ?? this.sleeveId,
      assetId: assetId ?? this.assetId,
    );
  }
}
