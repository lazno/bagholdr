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

/// AssignSleeveResult - Result of assigning an asset to a sleeve
abstract class AssignSleeveResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AssignSleeveResult._({
    required this.success,
    this.sleeveId,
    this.sleeveName,
  });

  factory AssignSleeveResult({
    required bool success,
    String? sleeveId,
    String? sleeveName,
  }) = _AssignSleeveResultImpl;

  factory AssignSleeveResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssignSleeveResult(
      success: jsonSerialization['success'] as bool,
      sleeveId: jsonSerialization['sleeveId'] as String?,
      sleeveName: jsonSerialization['sleeveName'] as String?,
    );
  }

  /// Whether the operation succeeded
  bool success;

  /// New sleeve ID (null if unassigned)
  String? sleeveId;

  /// New sleeve name (null if unassigned)
  String? sleeveName;

  /// Returns a shallow copy of this [AssignSleeveResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssignSleeveResult copyWith({
    bool? success,
    String? sleeveId,
    String? sleeveName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssignSleeveResult',
      'success': success,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AssignSleeveResult',
      'success': success,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssignSleeveResultImpl extends AssignSleeveResult {
  _AssignSleeveResultImpl({
    required bool success,
    String? sleeveId,
    String? sleeveName,
  }) : super._(
         success: success,
         sleeveId: sleeveId,
         sleeveName: sleeveName,
       );

  /// Returns a shallow copy of this [AssignSleeveResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AssignSleeveResult copyWith({
    bool? success,
    Object? sleeveId = _Undefined,
    Object? sleeveName = _Undefined,
  }) {
    return AssignSleeveResult(
      success: success ?? this.success,
      sleeveId: sleeveId is String? ? sleeveId : this.sleeveId,
      sleeveName: sleeveName is String? ? sleeveName : this.sleeveName,
    );
  }
}
