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

/// PortfolioRule - Flexible rule system for portfolio constraints
/// Stores concentration limits, exposure rules, and other constraints
abstract class PortfolioRule implements _i1.SerializableModel {
  PortfolioRule._({
    this.id,
    required this.portfolioId,
    required this.ruleType,
    required this.name,
    this.config,
    required this.enabled,
    required this.createdAt,
  });

  factory PortfolioRule({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required String ruleType,
    required String name,
    String? config,
    required bool enabled,
    required DateTime createdAt,
  }) = _PortfolioRuleImpl;

  factory PortfolioRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return PortfolioRule(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      ruleType: jsonSerialization['ruleType'] as String,
      name: jsonSerialization['name'] as String,
      config: jsonSerialization['config'] as String?,
      enabled: jsonSerialization['enabled'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Reference to the portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Type of rule (e.g., "concentration", "exposure", "custom")
  String ruleType;

  /// Human-readable rule name
  String name;

  /// JSON configuration for rule-specific parameters
  /// e.g., {"maxPercent": 10, "asset": "AAPL"} for concentration
  String? config;

  /// Whether the rule is currently active
  bool enabled;

  /// When the rule was created
  DateTime createdAt;

  /// Returns a shallow copy of this [PortfolioRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PortfolioRule copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    String? ruleType,
    String? name,
    String? config,
    bool? enabled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PortfolioRule',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'ruleType': ruleType,
      'name': name,
      if (config != null) 'config': config,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioRuleImpl extends PortfolioRule {
  _PortfolioRuleImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required String ruleType,
    required String name,
    String? config,
    required bool enabled,
    required DateTime createdAt,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         ruleType: ruleType,
         name: name,
         config: config,
         enabled: enabled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PortfolioRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PortfolioRule copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    String? ruleType,
    String? name,
    Object? config = _Undefined,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return PortfolioRule(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      ruleType: ruleType ?? this.ruleType,
      name: name ?? this.name,
      config: config is String? ? config : this.config,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
