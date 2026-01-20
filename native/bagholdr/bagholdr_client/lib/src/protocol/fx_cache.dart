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

/// FxCache - Cached foreign exchange rates
/// Used for currency conversion (e.g., USD/EUR, GBP/EUR)
abstract class FxCache implements _i1.SerializableModel {
  FxCache._({
    this.id,
    required this.pair,
    required this.rate,
    required this.fetchedAt,
  });

  factory FxCache({
    _i1.UuidValue? id,
    required String pair,
    required double rate,
    required DateTime fetchedAt,
  }) = _FxCacheImpl;

  factory FxCache.fromJson(Map<String, dynamic> jsonSerialization) {
    return FxCache(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      pair: jsonSerialization['pair'] as String,
      rate: (jsonSerialization['rate'] as num).toDouble(),
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Currency pair identifier (e.g., "USDEUR", "GBPEUR")
  String pair;

  /// Exchange rate (e.g., 0.92 for USD/EUR)
  double rate;

  /// When this rate was fetched
  DateTime fetchedAt;

  /// Returns a shallow copy of this [FxCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FxCache copyWith({
    _i1.UuidValue? id,
    String? pair,
    double? rate,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FxCache',
      if (id != null) 'id': id?.toJson(),
      'pair': pair,
      'rate': rate,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FxCacheImpl extends FxCache {
  _FxCacheImpl({
    _i1.UuidValue? id,
    required String pair,
    required double rate,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         pair: pair,
         rate: rate,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [FxCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FxCache copyWith({
    Object? id = _Undefined,
    String? pair,
    double? rate,
    DateTime? fetchedAt,
  }) {
    return FxCache(
      id: id is _i1.UuidValue? ? id : this.id,
      pair: pair ?? this.pair,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
