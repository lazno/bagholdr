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

/// Portfolio - Configuration/strategy container
/// Each portfolio organizes global holdings differently with its own band settings
abstract class Portfolio implements _i1.SerializableModel {
  Portfolio._({
    this.id,
    required this.name,
    required this.bandRelativeTolerance,
    required this.bandAbsoluteFloor,
    required this.bandAbsoluteCap,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio({
    _i1.UuidValue? id,
    required String name,
    required double bandRelativeTolerance,
    required double bandAbsoluteFloor,
    required double bandAbsoluteCap,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PortfolioImpl;

  factory Portfolio.fromJson(Map<String, dynamic> jsonSerialization) {
    return Portfolio(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      bandRelativeTolerance: (jsonSerialization['bandRelativeTolerance'] as num)
          .toDouble(),
      bandAbsoluteFloor: (jsonSerialization['bandAbsoluteFloor'] as num)
          .toDouble(),
      bandAbsoluteCap: (jsonSerialization['bandAbsoluteCap'] as num).toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Portfolio display name
  String name;

  /// Band configuration (applies to all sleeves in portfolio)
  /// Relative tolerance as percentage (e.g., 20 means +/-20% of target)
  double bandRelativeTolerance;

  /// Minimum band width in percentage points
  double bandAbsoluteFloor;

  /// Maximum band width in percentage points
  double bandAbsoluteCap;

  /// Timestamps
  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Portfolio]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Portfolio copyWith({
    _i1.UuidValue? id,
    String? name,
    double? bandRelativeTolerance,
    double? bandAbsoluteFloor,
    double? bandAbsoluteCap,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Portfolio',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'bandRelativeTolerance': bandRelativeTolerance,
      'bandAbsoluteFloor': bandAbsoluteFloor,
      'bandAbsoluteCap': bandAbsoluteCap,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioImpl extends Portfolio {
  _PortfolioImpl({
    _i1.UuidValue? id,
    required String name,
    required double bandRelativeTolerance,
    required double bandAbsoluteFloor,
    required double bandAbsoluteCap,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         bandRelativeTolerance: bandRelativeTolerance,
         bandAbsoluteFloor: bandAbsoluteFloor,
         bandAbsoluteCap: bandAbsoluteCap,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Portfolio]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Portfolio copyWith({
    Object? id = _Undefined,
    String? name,
    double? bandRelativeTolerance,
    double? bandAbsoluteFloor,
    double? bandAbsoluteCap,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Portfolio(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      bandRelativeTolerance:
          bandRelativeTolerance ?? this.bandRelativeTolerance,
      bandAbsoluteFloor: bandAbsoluteFloor ?? this.bandAbsoluteFloor,
      bandAbsoluteCap: bandAbsoluteCap ?? this.bandAbsoluteCap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
