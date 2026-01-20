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

/// GlobalCash - Single-row table storing portfolio cash balance
/// Tracks cash held outside of invested positions
abstract class GlobalCash
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = GlobalCashTable();

  static const db = GlobalCashRepository._();

  @override
  _i1.UuidValue? id;

  /// Logical identifier for the cash record (e.g., "default")
  /// Allows multiple cash accounts if needed in future
  String cashId;

  /// Cash balance in EUR
  double amountEur;

  /// Last update timestamp
  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GlobalCash',
      if (id != null) 'id': id?.toJson(),
      'cashId': cashId,
      'amountEur': amountEur,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static GlobalCashInclude include() {
    return GlobalCashInclude._();
  }

  static GlobalCashIncludeList includeList({
    _i1.WhereExpressionBuilder<GlobalCashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GlobalCashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GlobalCashTable>? orderByList,
    GlobalCashInclude? include,
  }) {
    return GlobalCashIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GlobalCash.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(GlobalCash.t),
      include: include,
    );
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

class GlobalCashUpdateTable extends _i1.UpdateTable<GlobalCashTable> {
  GlobalCashUpdateTable(super.table);

  _i1.ColumnValue<String, String> cashId(String value) => _i1.ColumnValue(
    table.cashId,
    value,
  );

  _i1.ColumnValue<double, double> amountEur(double value) => _i1.ColumnValue(
    table.amountEur,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class GlobalCashTable extends _i1.Table<_i1.UuidValue?> {
  GlobalCashTable({super.tableRelation}) : super(tableName: 'global_cash') {
    updateTable = GlobalCashUpdateTable(this);
    cashId = _i1.ColumnString(
      'cashId',
      this,
    );
    amountEur = _i1.ColumnDouble(
      'amountEur',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final GlobalCashUpdateTable updateTable;

  /// Logical identifier for the cash record (e.g., "default")
  /// Allows multiple cash accounts if needed in future
  late final _i1.ColumnString cashId;

  /// Cash balance in EUR
  late final _i1.ColumnDouble amountEur;

  /// Last update timestamp
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    cashId,
    amountEur,
    updatedAt,
  ];
}

class GlobalCashInclude extends _i1.IncludeObject {
  GlobalCashInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => GlobalCash.t;
}

class GlobalCashIncludeList extends _i1.IncludeList {
  GlobalCashIncludeList._({
    _i1.WhereExpressionBuilder<GlobalCashTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GlobalCash.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => GlobalCash.t;
}

class GlobalCashRepository {
  const GlobalCashRepository._();

  /// Returns a list of [GlobalCash]s matching the given query parameters.
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
  Future<List<GlobalCash>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GlobalCashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GlobalCashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GlobalCashTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<GlobalCash>(
      where: where?.call(GlobalCash.t),
      orderBy: orderBy?.call(GlobalCash.t),
      orderByList: orderByList?.call(GlobalCash.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [GlobalCash] matching the given query parameters.
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
  Future<GlobalCash?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GlobalCashTable>? where,
    int? offset,
    _i1.OrderByBuilder<GlobalCashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<GlobalCashTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<GlobalCash>(
      where: where?.call(GlobalCash.t),
      orderBy: orderBy?.call(GlobalCash.t),
      orderByList: orderByList?.call(GlobalCash.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [GlobalCash] by its [id] or null if no such row exists.
  Future<GlobalCash?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<GlobalCash>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [GlobalCash]s in the list and returns the inserted rows.
  ///
  /// The returned [GlobalCash]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<GlobalCash>> insert(
    _i1.Session session,
    List<GlobalCash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<GlobalCash>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [GlobalCash] and returns the inserted row.
  ///
  /// The returned [GlobalCash] will have its `id` field set.
  Future<GlobalCash> insertRow(
    _i1.Session session,
    GlobalCash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<GlobalCash>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [GlobalCash]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<GlobalCash>> update(
    _i1.Session session,
    List<GlobalCash> rows, {
    _i1.ColumnSelections<GlobalCashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<GlobalCash>(
      rows,
      columns: columns?.call(GlobalCash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GlobalCash]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GlobalCash> updateRow(
    _i1.Session session,
    GlobalCash row, {
    _i1.ColumnSelections<GlobalCashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<GlobalCash>(
      row,
      columns: columns?.call(GlobalCash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GlobalCash] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GlobalCash?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<GlobalCashUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<GlobalCash>(
      id,
      columnValues: columnValues(GlobalCash.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GlobalCash]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<GlobalCash>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<GlobalCashUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<GlobalCashTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<GlobalCashTable>? orderBy,
    _i1.OrderByListBuilder<GlobalCashTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<GlobalCash>(
      columnValues: columnValues(GlobalCash.t.updateTable),
      where: where(GlobalCash.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GlobalCash.t),
      orderByList: orderByList?.call(GlobalCash.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [GlobalCash]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<GlobalCash>> delete(
    _i1.Session session,
    List<GlobalCash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<GlobalCash>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [GlobalCash].
  Future<GlobalCash> deleteRow(
    _i1.Session session,
    GlobalCash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GlobalCash>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<GlobalCash>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<GlobalCashTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<GlobalCash>(
      where: where(GlobalCash.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<GlobalCashTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<GlobalCash>(
      where: where?.call(GlobalCash.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
