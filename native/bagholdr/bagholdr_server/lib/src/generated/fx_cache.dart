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

/// FxCache - Cached foreign exchange rates
/// Used for currency conversion (e.g., USD/EUR, GBP/EUR)
abstract class FxCache
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = FxCacheTable();

  static const db = FxCacheRepository._();

  @override
  _i1.UuidValue? id;

  /// Currency pair identifier (e.g., "USDEUR", "GBPEUR")
  String pair;

  /// Exchange rate (e.g., 0.92 for USD/EUR)
  double rate;

  /// When this rate was fetched
  DateTime fetchedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FxCache',
      if (id != null) 'id': id?.toJson(),
      'pair': pair,
      'rate': rate,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  static FxCacheInclude include() {
    return FxCacheInclude._();
  }

  static FxCacheIncludeList includeList({
    _i1.WhereExpressionBuilder<FxCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxCacheTable>? orderByList,
    FxCacheInclude? include,
  }) {
    return FxCacheIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxCache.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FxCache.t),
      include: include,
    );
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

class FxCacheUpdateTable extends _i1.UpdateTable<FxCacheTable> {
  FxCacheUpdateTable(super.table);

  _i1.ColumnValue<String, String> pair(String value) => _i1.ColumnValue(
    table.pair,
    value,
  );

  _i1.ColumnValue<double, double> rate(double value) => _i1.ColumnValue(
    table.rate,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _i1.ColumnValue(
        table.fetchedAt,
        value,
      );
}

class FxCacheTable extends _i1.Table<_i1.UuidValue?> {
  FxCacheTable({super.tableRelation}) : super(tableName: 'fx_cache') {
    updateTable = FxCacheUpdateTable(this);
    pair = _i1.ColumnString(
      'pair',
      this,
    );
    rate = _i1.ColumnDouble(
      'rate',
      this,
    );
    fetchedAt = _i1.ColumnDateTime(
      'fetchedAt',
      this,
    );
  }

  late final FxCacheUpdateTable updateTable;

  /// Currency pair identifier (e.g., "USDEUR", "GBPEUR")
  late final _i1.ColumnString pair;

  /// Exchange rate (e.g., 0.92 for USD/EUR)
  late final _i1.ColumnDouble rate;

  /// When this rate was fetched
  late final _i1.ColumnDateTime fetchedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    pair,
    rate,
    fetchedAt,
  ];
}

class FxCacheInclude extends _i1.IncludeObject {
  FxCacheInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxCache.t;
}

class FxCacheIncludeList extends _i1.IncludeList {
  FxCacheIncludeList._({
    _i1.WhereExpressionBuilder<FxCacheTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FxCache.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => FxCache.t;
}

class FxCacheRepository {
  const FxCacheRepository._();

  /// Returns a list of [FxCache]s matching the given query parameters.
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
  Future<List<FxCache>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FxCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxCacheTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<FxCache>(
      where: where?.call(FxCache.t),
      orderBy: orderBy?.call(FxCache.t),
      orderByList: orderByList?.call(FxCache.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [FxCache] matching the given query parameters.
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
  Future<FxCache?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FxCacheTable>? where,
    int? offset,
    _i1.OrderByBuilder<FxCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FxCacheTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<FxCache>(
      where: where?.call(FxCache.t),
      orderBy: orderBy?.call(FxCache.t),
      orderByList: orderByList?.call(FxCache.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [FxCache] by its [id] or null if no such row exists.
  Future<FxCache?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<FxCache>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [FxCache]s in the list and returns the inserted rows.
  ///
  /// The returned [FxCache]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FxCache>> insert(
    _i1.Session session,
    List<FxCache> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FxCache>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FxCache] and returns the inserted row.
  ///
  /// The returned [FxCache] will have its `id` field set.
  Future<FxCache> insertRow(
    _i1.Session session,
    FxCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FxCache>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FxCache]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FxCache>> update(
    _i1.Session session,
    List<FxCache> rows, {
    _i1.ColumnSelections<FxCacheTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FxCache>(
      rows,
      columns: columns?.call(FxCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxCache]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FxCache> updateRow(
    _i1.Session session,
    FxCache row, {
    _i1.ColumnSelections<FxCacheTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FxCache>(
      row,
      columns: columns?.call(FxCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FxCache] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FxCache?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<FxCacheUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FxCache>(
      id,
      columnValues: columnValues(FxCache.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FxCache]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FxCache>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<FxCacheUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FxCacheTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FxCacheTable>? orderBy,
    _i1.OrderByListBuilder<FxCacheTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FxCache>(
      columnValues: columnValues(FxCache.t.updateTable),
      where: where(FxCache.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FxCache.t),
      orderByList: orderByList?.call(FxCache.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FxCache]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FxCache>> delete(
    _i1.Session session,
    List<FxCache> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FxCache>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FxCache].
  Future<FxCache> deleteRow(
    _i1.Session session,
    FxCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FxCache>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FxCache>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FxCacheTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FxCache>(
      where: where(FxCache.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FxCacheTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FxCache>(
      where: where?.call(FxCache.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
