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

/// SleeveOption - Simplified sleeve info for picker dialogs
abstract class SleeveOption
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SleeveOption._({
    required this.id,
    required this.name,
    required this.depth,
  });

  factory SleeveOption({
    required String id,
    required String name,
    required int depth,
  }) = _SleeveOptionImpl;

  factory SleeveOption.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveOption(
      id: jsonSerialization['id'] as String,
      name: jsonSerialization['name'] as String,
      depth: jsonSerialization['depth'] as int,
    );
  }

  /// Sleeve UUID
  String id;

  /// Display name (e.g., "Core > Equities")
  String name;

  /// Hierarchy depth (0 = root, 1 = child, etc.)
  int depth;

  /// Returns a shallow copy of this [SleeveOption]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveOption copyWith({
    String? id,
    String? name,
    int? depth,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveOption',
      'id': id,
      'name': name,
      'depth': depth,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SleeveOption',
      'id': id,
      'name': name,
      'depth': depth,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SleeveOptionImpl extends SleeveOption {
  _SleeveOptionImpl({
    required String id,
    required String name,
    required int depth,
  }) : super._(
         id: id,
         name: name,
         depth: depth,
       );

  /// Returns a shallow copy of this [SleeveOption]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveOption copyWith({
    String? id,
    String? name,
    int? depth,
  }) {
    return SleeveOption(
      id: id ?? this.id,
      name: name ?? this.name,
      depth: depth ?? this.depth,
    );
  }
}
