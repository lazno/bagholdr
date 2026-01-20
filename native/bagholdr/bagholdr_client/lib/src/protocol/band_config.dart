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

/// BandConfig - Portfolio-level band configuration
abstract class BandConfig implements _i1.SerializableModel {
  BandConfig._({
    required this.relativeTolerance,
    required this.absoluteFloor,
    required this.absoluteCap,
  });

  factory BandConfig({
    required double relativeTolerance,
    required double absoluteFloor,
    required double absoluteCap,
  }) = _BandConfigImpl;

  factory BandConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return BandConfig(
      relativeTolerance: (jsonSerialization['relativeTolerance'] as num)
          .toDouble(),
      absoluteFloor: (jsonSerialization['absoluteFloor'] as num).toDouble(),
      absoluteCap: (jsonSerialization['absoluteCap'] as num).toDouble(),
    );
  }

  /// Relative tolerance as percentage of target (e.g., 20 means ±20% of target)
  double relativeTolerance;

  /// Minimum half-width in percentage points (e.g., 2 means at least ±2pp)
  double absoluteFloor;

  /// Maximum half-width in percentage points (e.g., 10 means at most ±10pp)
  double absoluteCap;

  /// Returns a shallow copy of this [BandConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BandConfig copyWith({
    double? relativeTolerance,
    double? absoluteFloor,
    double? absoluteCap,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BandConfig',
      'relativeTolerance': relativeTolerance,
      'absoluteFloor': absoluteFloor,
      'absoluteCap': absoluteCap,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _BandConfigImpl extends BandConfig {
  _BandConfigImpl({
    required double relativeTolerance,
    required double absoluteFloor,
    required double absoluteCap,
  }) : super._(
         relativeTolerance: relativeTolerance,
         absoluteFloor: absoluteFloor,
         absoluteCap: absoluteCap,
       );

  /// Returns a shallow copy of this [BandConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BandConfig copyWith({
    double? relativeTolerance,
    double? absoluteFloor,
    double? absoluteCap,
  }) {
    return BandConfig(
      relativeTolerance: relativeTolerance ?? this.relativeTolerance,
      absoluteFloor: absoluteFloor ?? this.absoluteFloor,
      absoluteCap: absoluteCap ?? this.absoluteCap,
    );
  }
}
