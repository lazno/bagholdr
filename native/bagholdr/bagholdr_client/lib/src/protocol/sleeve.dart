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

/// Sleeve - Hierarchical grouping of assets with budget targets
/// Portfolio-specific - same global holdings can be organized differently per portfolio
abstract class Sleeve implements _i1.SerializableModel {
  Sleeve._({
    this.id,
    required this.portfolioId,
    this.parentSleeveId,
    required this.name,
    required this.budgetPercent,
    required this.sortOrder,
    required this.isCash,
  });

  factory Sleeve({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    _i1.UuidValue? parentSleeveId,
    required String name,
    required double budgetPercent,
    required int sortOrder,
    required bool isCash,
  }) = _SleeveImpl;

  factory Sleeve.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sleeve(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      parentSleeveId: jsonSerialization['parentSleeveId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['parentSleeveId'],
            ),
      name: jsonSerialization['name'] as String,
      budgetPercent: (jsonSerialization['budgetPercent'] as num).toDouble(),
      sortOrder: jsonSerialization['sortOrder'] as int,
      isCash: jsonSerialization['isCash'] as bool,
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to parent portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Self-reference for hierarchy (null = root/top-level sleeve)
  /// Cascade delete: when parent sleeve is deleted, children are also deleted
  _i1.UuidValue? parentSleeveId;

  /// Display name (e.g., "Core", "Equities", "Satellite")
  String name;

  /// Target allocation as percentage of portfolio (e.g., 75.0 = 75%)
  double budgetPercent;

  /// Display order within parent (for UI sorting)
  int sortOrder;

  /// Whether this sleeve represents the cash allocation
  bool isCash;

  /// Returns a shallow copy of this [Sleeve]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Sleeve copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? parentSleeveId,
    String? name,
    double? budgetPercent,
    int? sortOrder,
    bool? isCash,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Sleeve',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      if (parentSleeveId != null) 'parentSleeveId': parentSleeveId?.toJson(),
      'name': name,
      'budgetPercent': budgetPercent,
      'sortOrder': sortOrder,
      'isCash': isCash,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveImpl extends Sleeve {
  _SleeveImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    _i1.UuidValue? parentSleeveId,
    required String name,
    required double budgetPercent,
    required int sortOrder,
    required bool isCash,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         parentSleeveId: parentSleeveId,
         name: name,
         budgetPercent: budgetPercent,
         sortOrder: sortOrder,
         isCash: isCash,
       );

  /// Returns a shallow copy of this [Sleeve]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Sleeve copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    Object? parentSleeveId = _Undefined,
    String? name,
    double? budgetPercent,
    int? sortOrder,
    bool? isCash,
  }) {
    return Sleeve(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      parentSleeveId: parentSleeveId is _i1.UuidValue?
          ? parentSleeveId
          : this.parentSleeveId,
      name: name ?? this.name,
      budgetPercent: budgetPercent ?? this.budgetPercent,
      sortOrder: sortOrder ?? this.sortOrder,
      isCash: isCash ?? this.isCash,
    );
  }
}
