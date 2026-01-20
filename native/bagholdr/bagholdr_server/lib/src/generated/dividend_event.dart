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

/// DividendEvent - Dividend payout history from Yahoo Finance
/// Tracks ex-dates and amounts for dividend-paying assets
abstract class DividendEvent
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  DividendEvent._({
    this.id,
    required this.ticker,
    required this.exDate,
    required this.amount,
    required this.currency,
    required this.fetchedAt,
  });

  factory DividendEvent({
    _i1.UuidValue? id,
    required String ticker,
    required String exDate,
    required double amount,
    required String currency,
    required DateTime fetchedAt,
  }) = _DividendEventImpl;

  factory DividendEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DividendEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      exDate: jsonSerialization['exDate'] as String,
      amount: (jsonSerialization['amount'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  static final t = DividendEventTable();

  static const db = DividendEventRepository._();

  @override
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Ex-dividend date in YYYY-MM-DD format
  String exDate;

  /// Dividend amount per share
  double amount;

  /// Currency of the dividend
  String currency;

  /// When this dividend data was fetched
  DateTime fetchedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [DividendEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DividendEvent copyWith({
    _i1.UuidValue? id,
    String? ticker,
    String? exDate,
    double? amount,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DividendEvent',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'exDate': exDate,
      'amount': amount,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DividendEvent',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'exDate': exDate,
      'amount': amount,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  static DividendEventInclude include() {
    return DividendEventInclude._();
  }

  static DividendEventIncludeList includeList({
    _i1.WhereExpressionBuilder<DividendEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DividendEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DividendEventTable>? orderByList,
    DividendEventInclude? include,
  }) {
    return DividendEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DividendEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DividendEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DividendEventImpl extends DividendEvent {
  _DividendEventImpl({
    _i1.UuidValue? id,
    required String ticker,
    required String exDate,
    required double amount,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         exDate: exDate,
         amount: amount,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [DividendEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DividendEvent copyWith({
    Object? id = _Undefined,
    String? ticker,
    String? exDate,
    double? amount,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return DividendEvent(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      exDate: exDate ?? this.exDate,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

class DividendEventUpdateTable extends _i1.UpdateTable<DividendEventTable> {
  DividendEventUpdateTable(super.table);

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<String, String> exDate(String value) => _i1.ColumnValue(
    table.exDate,
    value,
  );

  _i1.ColumnValue<double, double> amount(double value) => _i1.ColumnValue(
    table.amount,
    value,
  );

  _i1.ColumnValue<String, String> currency(String value) => _i1.ColumnValue(
    table.currency,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _i1.ColumnValue(
        table.fetchedAt,
        value,
      );
}

class DividendEventTable extends _i1.Table<_i1.UuidValue?> {
  DividendEventTable({super.tableRelation})
    : super(tableName: 'dividend_events') {
    updateTable = DividendEventUpdateTable(this);
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    exDate = _i1.ColumnString(
      'exDate',
      this,
    );
    amount = _i1.ColumnDouble(
      'amount',
      this,
    );
    currency = _i1.ColumnString(
      'currency',
      this,
    );
    fetchedAt = _i1.ColumnDateTime(
      'fetchedAt',
      this,
    );
  }

  late final DividendEventUpdateTable updateTable;

  /// Yahoo Finance ticker symbol
  late final _i1.ColumnString ticker;

  /// Ex-dividend date in YYYY-MM-DD format
  late final _i1.ColumnString exDate;

  /// Dividend amount per share
  late final _i1.ColumnDouble amount;

  /// Currency of the dividend
  late final _i1.ColumnString currency;

  /// When this dividend data was fetched
  late final _i1.ColumnDateTime fetchedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    ticker,
    exDate,
    amount,
    currency,
    fetchedAt,
  ];
}

class DividendEventInclude extends _i1.IncludeObject {
  DividendEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DividendEvent.t;
}

class DividendEventIncludeList extends _i1.IncludeList {
  DividendEventIncludeList._({
    _i1.WhereExpressionBuilder<DividendEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DividendEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DividendEvent.t;
}

class DividendEventRepository {
  const DividendEventRepository._();

  /// Returns a list of [DividendEvent]s matching the given query parameters.
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
  Future<List<DividendEvent>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DividendEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DividendEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DividendEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DividendEvent>(
      where: where?.call(DividendEvent.t),
      orderBy: orderBy?.call(DividendEvent.t),
      orderByList: orderByList?.call(DividendEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DividendEvent] matching the given query parameters.
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
  Future<DividendEvent?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DividendEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<DividendEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DividendEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DividendEvent>(
      where: where?.call(DividendEvent.t),
      orderBy: orderBy?.call(DividendEvent.t),
      orderByList: orderByList?.call(DividendEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DividendEvent] by its [id] or null if no such row exists.
  Future<DividendEvent?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DividendEvent>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DividendEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [DividendEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DividendEvent>> insert(
    _i1.Session session,
    List<DividendEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DividendEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DividendEvent] and returns the inserted row.
  ///
  /// The returned [DividendEvent] will have its `id` field set.
  Future<DividendEvent> insertRow(
    _i1.Session session,
    DividendEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DividendEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DividendEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DividendEvent>> update(
    _i1.Session session,
    List<DividendEvent> rows, {
    _i1.ColumnSelections<DividendEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DividendEvent>(
      rows,
      columns: columns?.call(DividendEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DividendEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DividendEvent> updateRow(
    _i1.Session session,
    DividendEvent row, {
    _i1.ColumnSelections<DividendEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DividendEvent>(
      row,
      columns: columns?.call(DividendEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DividendEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DividendEvent?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<DividendEventUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DividendEvent>(
      id,
      columnValues: columnValues(DividendEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DividendEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DividendEvent>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DividendEventUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DividendEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DividendEventTable>? orderBy,
    _i1.OrderByListBuilder<DividendEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DividendEvent>(
      columnValues: columnValues(DividendEvent.t.updateTable),
      where: where(DividendEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DividendEvent.t),
      orderByList: orderByList?.call(DividendEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DividendEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DividendEvent>> delete(
    _i1.Session session,
    List<DividendEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DividendEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DividendEvent].
  Future<DividendEvent> deleteRow(
    _i1.Session session,
    DividendEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DividendEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DividendEvent>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DividendEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DividendEvent>(
      where: where(DividendEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DividendEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DividendEvent>(
      where: where?.call(DividendEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
