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

/// TickerMetadata - Sync state tracking per ticker
/// Tracks when price data was last fetched for each ticker
abstract class TickerMetadata
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = TickerMetadataTable();

  static const db = TickerMetadataRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static TickerMetadataInclude include() {
    return TickerMetadataInclude._();
  }

  static TickerMetadataIncludeList includeList({
    _i1.WhereExpressionBuilder<TickerMetadataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TickerMetadataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TickerMetadataTable>? orderByList,
    TickerMetadataInclude? include,
  }) {
    return TickerMetadataIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TickerMetadata.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TickerMetadata.t),
      include: include,
    );
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

class TickerMetadataUpdateTable extends _i1.UpdateTable<TickerMetadataTable> {
  TickerMetadataUpdateTable(super.table);

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<String, String> lastDailyDate(String? value) =>
      _i1.ColumnValue(
        table.lastDailyDate,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastIntradaySyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastIntradaySyncedAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );
}

class TickerMetadataTable extends _i1.Table<_i1.UuidValue?> {
  TickerMetadataTable({super.tableRelation})
    : super(tableName: 'ticker_metadata') {
    updateTable = TickerMetadataUpdateTable(this);
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    lastDailyDate = _i1.ColumnString(
      'lastDailyDate',
      this,
    );
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    lastIntradaySyncedAt = _i1.ColumnDateTime(
      'lastIntradaySyncedAt',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
  }

  late final TickerMetadataUpdateTable updateTable;

  /// Yahoo Finance ticker symbol
  late final _i1.ColumnString ticker;

  /// Last date with daily price data (YYYY-MM-DD format)
  late final _i1.ColumnString lastDailyDate;

  /// When daily data was last synced
  late final _i1.ColumnDateTime lastSyncedAt;

  /// When intraday data was last synced
  late final _i1.ColumnDateTime lastIntradaySyncedAt;

  /// Whether this ticker should be actively synced
  late final _i1.ColumnBool isActive;

  @override
  List<_i1.Column> get columns => [
    id,
    ticker,
    lastDailyDate,
    lastSyncedAt,
    lastIntradaySyncedAt,
    isActive,
  ];
}

class TickerMetadataInclude extends _i1.IncludeObject {
  TickerMetadataInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => TickerMetadata.t;
}

class TickerMetadataIncludeList extends _i1.IncludeList {
  TickerMetadataIncludeList._({
    _i1.WhereExpressionBuilder<TickerMetadataTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TickerMetadata.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => TickerMetadata.t;
}

class TickerMetadataRepository {
  const TickerMetadataRepository._();

  /// Returns a list of [TickerMetadata]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<TickerMetadata>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TickerMetadataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TickerMetadataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TickerMetadataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TickerMetadata>(
      where: where?.call(TickerMetadata.t),
      orderBy: orderBy?.call(TickerMetadata.t),
      orderByList: orderByList?.call(TickerMetadata.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TickerMetadata] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<TickerMetadata?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TickerMetadataTable>? where,
    int? offset,
    _i1.OrderByBuilder<TickerMetadataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TickerMetadataTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TickerMetadata>(
      where: where?.call(TickerMetadata.t),
      orderBy: orderBy?.call(TickerMetadata.t),
      orderByList: orderByList?.call(TickerMetadata.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TickerMetadata] by its [id] or null if no such row exists.
  Future<TickerMetadata?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TickerMetadata>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TickerMetadata]s in the list and returns the inserted rows.
  ///
  /// The returned [TickerMetadata]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TickerMetadata>> insert(
    _i1.Session session,
    List<TickerMetadata> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TickerMetadata>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TickerMetadata] and returns the inserted row.
  ///
  /// The returned [TickerMetadata] will have its `id` field set.
  Future<TickerMetadata> insertRow(
    _i1.Session session,
    TickerMetadata row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TickerMetadata>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TickerMetadata]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TickerMetadata>> update(
    _i1.Session session,
    List<TickerMetadata> rows, {
    _i1.ColumnSelections<TickerMetadataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TickerMetadata>(
      rows,
      columns: columns?.call(TickerMetadata.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TickerMetadata]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TickerMetadata> updateRow(
    _i1.Session session,
    TickerMetadata row, {
    _i1.ColumnSelections<TickerMetadataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TickerMetadata>(
      row,
      columns: columns?.call(TickerMetadata.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TickerMetadata] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TickerMetadata?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<TickerMetadataUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<TickerMetadata>(
      id,
      columnValues: columnValues(TickerMetadata.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TickerMetadata]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<TickerMetadata>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<TickerMetadataUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TickerMetadataTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TickerMetadataTable>? orderBy,
    _i1.OrderByListBuilder<TickerMetadataTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<TickerMetadata>(
      columnValues: columnValues(TickerMetadata.t.updateTable),
      where: where(TickerMetadata.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TickerMetadata.t),
      orderByList: orderByList?.call(TickerMetadata.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [TickerMetadata]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TickerMetadata>> delete(
    _i1.Session session,
    List<TickerMetadata> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TickerMetadata>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TickerMetadata].
  Future<TickerMetadata> deleteRow(
    _i1.Session session,
    TickerMetadata row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TickerMetadata>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TickerMetadata>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TickerMetadataTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TickerMetadata>(
      where: where(TickerMetadata.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TickerMetadataTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TickerMetadata>(
      where: where?.call(TickerMetadata.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
