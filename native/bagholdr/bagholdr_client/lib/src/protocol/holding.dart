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

/// Holding - Current position derived from orders
/// Global table shared across all portfolios (like TypeScript schema)
abstract class Holding implements _i1.SerializableModel {
  Holding._({
    this.id,
    required this.assetId,
    required this.quantity,
    required this.totalCostEur,
  });

  factory Holding({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required double quantity,
    required double totalCostEur,
  }) = _HoldingImpl;

  factory Holding.fromJson(Map<String, dynamic> jsonSerialization) {
    return Holding(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      totalCostEur: (jsonSerialization['totalCostEur'] as num).toDouble(),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Current quantity held (positive value)
  double quantity;

  /// Total cost basis in EUR (sum of all purchase costs minus sales)
  double totalCostEur;

  /// Returns a shallow copy of this [Holding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Holding copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? assetId,
    double? quantity,
    double? totalCostEur,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Holding',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'quantity': quantity,
      'totalCostEur': totalCostEur,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HoldingImpl extends Holding {
  _HoldingImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required double quantity,
    required double totalCostEur,
  }) : super._(
         id: id,
         assetId: assetId,
         quantity: quantity,
         totalCostEur: totalCostEur,
       );

  /// Returns a shallow copy of this [Holding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Holding copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? assetId,
    double? quantity,
    double? totalCostEur,
  }) {
    return Holding(
      id: id is _i1.UuidValue? ? id : this.id,
      assetId: assetId ?? this.assetId,
      quantity: quantity ?? this.quantity,
      totalCostEur: totalCostEur ?? this.totalCostEur,
    );
  }
}
