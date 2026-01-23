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

/// SyncStatus - Current state of the price sync job
/// Not persisted to database (no table directive)
abstract class SyncStatus
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SyncStatus._({
    required this.isSyncing,
    this.lastSyncAt,
    required this.lastSuccessCount,
    required this.lastErrorCount,
  });

  factory SyncStatus({
    required bool isSyncing,
    DateTime? lastSyncAt,
    required int lastSuccessCount,
    required int lastErrorCount,
  }) = _SyncStatusImpl;

  factory SyncStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncStatus(
      isSyncing: jsonSerialization['isSyncing'] as bool,
      lastSyncAt: jsonSerialization['lastSyncAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSyncAt']),
      lastSuccessCount: jsonSerialization['lastSuccessCount'] as int,
      lastErrorCount: jsonSerialization['lastErrorCount'] as int,
    );
  }

  /// Whether a sync is currently in progress
  bool isSyncing;

  /// When the last sync completed (null if never)
  DateTime? lastSyncAt;

  /// Number of assets successfully synced in last run
  int lastSuccessCount;

  /// Number of errors in last run
  int lastErrorCount;

  /// Returns a shallow copy of this [SyncStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncStatus copyWith({
    bool? isSyncing,
    DateTime? lastSyncAt,
    int? lastSuccessCount,
    int? lastErrorCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncStatus',
      'isSyncing': isSyncing,
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
      'lastSuccessCount': lastSuccessCount,
      'lastErrorCount': lastErrorCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncStatus',
      'isSyncing': isSyncing,
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt?.toJson(),
      'lastSuccessCount': lastSuccessCount,
      'lastErrorCount': lastErrorCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncStatusImpl extends SyncStatus {
  _SyncStatusImpl({
    required bool isSyncing,
    DateTime? lastSyncAt,
    required int lastSuccessCount,
    required int lastErrorCount,
  }) : super._(
         isSyncing: isSyncing,
         lastSyncAt: lastSyncAt,
         lastSuccessCount: lastSuccessCount,
         lastErrorCount: lastErrorCount,
       );

  /// Returns a shallow copy of this [SyncStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncStatus copyWith({
    bool? isSyncing,
    Object? lastSyncAt = _Undefined,
    int? lastSuccessCount,
    int? lastErrorCount,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncAt: lastSyncAt is DateTime? ? lastSyncAt : this.lastSyncAt,
      lastSuccessCount: lastSuccessCount ?? this.lastSuccessCount,
      lastErrorCount: lastErrorCount ?? this.lastErrorCount,
    );
  }
}
