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

/// Band - Calculated band bounds for a target allocation
abstract class Band
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Band._({
    required this.lower,
    required this.upper,
    required this.halfWidth,
  });

  factory Band({
    required double lower,
    required double upper,
    required double halfWidth,
  }) = _BandImpl;

  factory Band.fromJson(Map<String, dynamic> jsonSerialization) {
    return Band(
      lower: (jsonSerialization['lower'] as num).toDouble(),
      upper: (jsonSerialization['upper'] as num).toDouble(),
      halfWidth: (jsonSerialization['halfWidth'] as num).toDouble(),
    );
  }

  /// Lower bound in percentage points
  double lower;

  /// Upper bound in percentage points
  double upper;

  /// Half-width used (for display purposes)
  double halfWidth;

  /// Returns a shallow copy of this [Band]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Band copyWith({
    double? lower,
    double? upper,
    double? halfWidth,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Band',
      'lower': lower,
      'upper': upper,
      'halfWidth': halfWidth,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Band',
      'lower': lower,
      'upper': upper,
      'halfWidth': halfWidth,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _BandImpl extends Band {
  _BandImpl({
    required double lower,
    required double upper,
    required double halfWidth,
  }) : super._(
         lower: lower,
         upper: upper,
         halfWidth: halfWidth,
       );

  /// Returns a shallow copy of this [Band]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Band copyWith({
    double? lower,
    double? upper,
    double? halfWidth,
  }) {
    return Band(
      lower: lower ?? this.lower,
      upper: upper ?? this.upper,
      halfWidth: halfWidth ?? this.halfWidth,
    );
  }
}
