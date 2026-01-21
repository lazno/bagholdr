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
import 'issue_type.dart' as _i2;
import 'issue_severity.dart' as _i3;

/// Issue - Portfolio issue/health indicator
abstract class Issue
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  Issue._({
    required this.type,
    required this.severity,
    required this.message,
    this.sleeveId,
    this.sleeveName,
    this.assetId,
    this.driftPp,
    this.color,
  });

  factory Issue({
    required _i2.IssueType type,
    required _i3.IssueSeverity severity,
    required String message,
    String? sleeveId,
    String? sleeveName,
    String? assetId,
    double? driftPp,
    String? color,
  }) = _IssueImpl;

  factory Issue.fromJson(Map<String, dynamic> jsonSerialization) {
    return Issue(
      type: _i2.IssueType.fromJson((jsonSerialization['type'] as String)),
      severity: _i3.IssueSeverity.fromJson(
        (jsonSerialization['severity'] as String),
      ),
      message: jsonSerialization['message'] as String,
      sleeveId: jsonSerialization['sleeveId'] as String?,
      sleeveName: jsonSerialization['sleeveName'] as String?,
      assetId: jsonSerialization['assetId'] as String?,
      driftPp: (jsonSerialization['driftPp'] as num?)?.toDouble(),
      color: jsonSerialization['color'] as String?,
    );
  }

  /// Issue type (overAllocation, underAllocation, stalePrice, syncStatus)
  _i2.IssueType type;

  /// Issue severity (warning, info)
  _i3.IssueSeverity severity;

  /// Human-readable message
  String message;

  /// Sleeve ID (for allocation issues)
  String? sleeveId;

  /// Sleeve name (for allocation issues)
  String? sleeveName;

  /// Asset ID (for stale price issues)
  String? assetId;

  /// Percentage points of drift (for allocation issues)
  double? driftPp;

  /// Color for the sleeve (for allocation issues)
  String? color;

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Issue copyWith({
    _i2.IssueType? type,
    _i3.IssueSeverity? severity,
    String? message,
    String? sleeveId,
    String? sleeveName,
    String? assetId,
    double? driftPp,
    String? color,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Issue',
      'type': type.toJson(),
      'severity': severity.toJson(),
      'message': message,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
      if (assetId != null) 'assetId': assetId,
      if (driftPp != null) 'driftPp': driftPp,
      if (color != null) 'color': color,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Issue',
      'type': type.toJson(),
      'severity': severity.toJson(),
      'message': message,
      if (sleeveId != null) 'sleeveId': sleeveId,
      if (sleeveName != null) 'sleeveName': sleeveName,
      if (assetId != null) 'assetId': assetId,
      if (driftPp != null) 'driftPp': driftPp,
      if (color != null) 'color': color,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IssueImpl extends Issue {
  _IssueImpl({
    required _i2.IssueType type,
    required _i3.IssueSeverity severity,
    required String message,
    String? sleeveId,
    String? sleeveName,
    String? assetId,
    double? driftPp,
    String? color,
  }) : super._(
         type: type,
         severity: severity,
         message: message,
         sleeveId: sleeveId,
         sleeveName: sleeveName,
         assetId: assetId,
         driftPp: driftPp,
         color: color,
       );

  /// Returns a shallow copy of this [Issue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Issue copyWith({
    _i2.IssueType? type,
    _i3.IssueSeverity? severity,
    String? message,
    Object? sleeveId = _Undefined,
    Object? sleeveName = _Undefined,
    Object? assetId = _Undefined,
    Object? driftPp = _Undefined,
    Object? color = _Undefined,
  }) {
    return Issue(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      sleeveId: sleeveId is String? ? sleeveId : this.sleeveId,
      sleeveName: sleeveName is String? ? sleeveName : this.sleeveName,
      assetId: assetId is String? ? assetId : this.assetId,
      driftPp: driftPp is double? ? driftPp : this.driftPp,
      color: color is String? ? color : this.color,
    );
  }
}
