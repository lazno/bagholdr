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

/// TickerMetadata - Sync state tracking per ticker
/// Tracks when price data was last fetched for each ticker
abstract class TickerMetadata implements _i1.SerializableModel {
  TickerMetadata._({
    this.id,
    required this.ticker,
    this.lastDailyDate,
    this.lastSyncedAt,
    this.lastIntradaySyncedAt,
    required this.isActive,
  });

  factory TickerMetadata({
    _i1.UuidValue? id,
    required String ticker,
    String? lastDailyDate,
    DateTime? lastSyncedAt,
    DateTime? lastIntradaySyncedAt,
    required bool isActive,
  }) = _TickerMetadataImpl;

  factory TickerMetadata.fromJson(Map<String, dynamic> jsonSerialization) {
    return TickerMetadata(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      lastDailyDate: jsonSerialization['lastDailyDate'] as String?,
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      lastIntradaySyncedAt: jsonSerialization['lastIntradaySyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastIntradaySyncedAt'],
            ),
      isActive: jsonSerialization['isActive'] as bool,
    );
  }

  /// UUID primary key (v7 for lexicographic sorting)
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Last date with daily price data (YYYY-MM-DD format)
  String? lastDailyDate;

  /// When daily data was last synced
  DateTime? lastSyncedAt;

  /// When intraday data was last synced
  DateTime? lastIntradaySyncedAt;

  /// Whether this ticker should be actively synced
  bool isActive;

  /// Returns a shallow copy of this [TickerMetadata]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TickerMetadata copyWith({
    _i1.UuidValue? id,
    String? ticker,
    String? lastDailyDate,
    DateTime? lastSyncedAt,
    DateTime? lastIntradaySyncedAt,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TickerMetadata',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      if (lastDailyDate != null) 'lastDailyDate': lastDailyDate,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastIntradaySyncedAt != null)
        'lastIntradaySyncedAt': lastIntradaySyncedAt?.toJson(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TickerMetadataImpl extends TickerMetadata {
  _TickerMetadataImpl({
    _i1.UuidValue? id,
    required String ticker,
    String? lastDailyDate,
    DateTime? lastSyncedAt,
    DateTime? lastIntradaySyncedAt,
    required bool isActive,
  }) : super._(
         id: id,
         ticker: ticker,
         lastDailyDate: lastDailyDate,
         lastSyncedAt: lastSyncedAt,
         lastIntradaySyncedAt: lastIntradaySyncedAt,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [TickerMetadata]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TickerMetadata copyWith({
    Object? id = _Undefined,
    String? ticker,
    Object? lastDailyDate = _Undefined,
    Object? lastSyncedAt = _Undefined,
    Object? lastIntradaySyncedAt = _Undefined,
    bool? isActive,
  }) {
    return TickerMetadata(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      lastDailyDate: lastDailyDate is String?
          ? lastDailyDate
          : this.lastDailyDate,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      lastIntradaySyncedAt: lastIntradaySyncedAt is DateTime?
          ? lastIntradaySyncedAt
          : this.lastIntradaySyncedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
