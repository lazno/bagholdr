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

/// UpdateAssetTypeResult - Response from updating an asset's type
abstract class UpdateAssetTypeResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UpdateAssetTypeResult._({
    required this.success,
    this.newType,
  });

  factory UpdateAssetTypeResult({
    required bool success,
    String? newType,
  }) = _UpdateAssetTypeResultImpl;

  factory UpdateAssetTypeResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UpdateAssetTypeResult(
      success: jsonSerialization['success'] as bool,
      newType: jsonSerialization['newType'] as String?,
    );
  }

  /// Whether the update succeeded
  bool success;

  /// The new asset type (as string for display)
  String? newType;

  /// Returns a shallow copy of this [UpdateAssetTypeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UpdateAssetTypeResult copyWith({
    bool? success,
    String? newType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UpdateAssetTypeResult',
      'success': success,
      if (newType != null) 'newType': newType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UpdateAssetTypeResult',
      'success': success,
      if (newType != null) 'newType': newType,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UpdateAssetTypeResultImpl extends UpdateAssetTypeResult {
  _UpdateAssetTypeResultImpl({
    required bool success,
    String? newType,
  }) : super._(
         success: success,
         newType: newType,
       );

  /// Returns a shallow copy of this [UpdateAssetTypeResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UpdateAssetTypeResult copyWith({
    bool? success,
    Object? newType = _Undefined,
  }) {
    return UpdateAssetTypeResult(
      success: success ?? this.success,
      newType: newType is String? ? newType : this.newType,
    );
  }
}
