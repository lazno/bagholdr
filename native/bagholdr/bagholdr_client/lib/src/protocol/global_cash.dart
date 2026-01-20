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

/// GlobalCash - Single-row table storing portfolio cash balance
/// Tracks cash held outside of invested positions
abstract class GlobalCash implements _i1.SerializableModel {
  GlobalCash._({
    this.id,
    required this.cashId,
    required this.amountEur,
    required this.updatedAt,
  });

  factory GlobalCash({
    _i1.UuidValue? id,
    required String cashId,
    required double amountEur,
    required DateTime updatedAt,
  }) = _GlobalCashImpl;

  factory GlobalCash.fromJson(Map<String, dynamic> jsonSerialization) {
    return GlobalCash(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      cashId: jsonSerialization['cashId'] as String,
      amountEur: (jsonSerialization['amountEur'] as num).toDouble(),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Logical identifier for the cash record (e.g., "default")
  /// Allows multiple cash accounts if needed in future
  String cashId;

  /// Cash balance in EUR
  double amountEur;

  /// Last update timestamp
  DateTime updatedAt;

  /// Returns a shallow copy of this [GlobalCash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GlobalCash copyWith({
    _i1.UuidValue? id,
    String? cashId,
    double? amountEur,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GlobalCash',
      if (id != null) 'id': id?.toJson(),
      'cashId': cashId,
      'amountEur': amountEur,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GlobalCashImpl extends GlobalCash {
  _GlobalCashImpl({
    _i1.UuidValue? id,
    required String cashId,
    required double amountEur,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         cashId: cashId,
         amountEur: amountEur,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [GlobalCash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GlobalCash copyWith({
    Object? id = _Undefined,
    String? cashId,
    double? amountEur,
    DateTime? updatedAt,
  }) {
    return GlobalCash(
      id: id is _i1.UuidValue? ? id : this.id,
      cashId: cashId ?? this.cashId,
      amountEur: amountEur ?? this.amountEur,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
