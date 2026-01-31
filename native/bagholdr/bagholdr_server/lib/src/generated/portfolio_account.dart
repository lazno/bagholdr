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

/// PortfolioAccount - Junction table linking portfolios to accounts
/// Enables portfolios to aggregate multiple accounts for multi-broker views
abstract class PortfolioAccount
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PortfolioAccount._({
    this.id,
    required this.portfolioId,
    required this.accountId,
  });

  factory PortfolioAccount({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required _i1.UuidValue accountId,
  }) = _PortfolioAccountImpl;

  factory PortfolioAccount.fromJson(Map<String, dynamic> jsonSerialization) {
    return PortfolioAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      accountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
    );
  }

  static final t = PortfolioAccountTable();

  static const db = PortfolioAccountRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Reference to the account (UUID)
  _i1.UuidValue accountId;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PortfolioAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PortfolioAccount copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? accountId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PortfolioAccount',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'accountId': accountId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PortfolioAccount',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'accountId': accountId.toJson(),
    };
  }

  static PortfolioAccountInclude include() {
    return PortfolioAccountInclude._();
  }

  static PortfolioAccountIncludeList includeList({
    _i1.WhereExpressionBuilder<PortfolioAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioAccountTable>? orderByList,
    PortfolioAccountInclude? include,
  }) {
    return PortfolioAccountIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PortfolioAccount.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PortfolioAccount.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioAccountImpl extends PortfolioAccount {
  _PortfolioAccountImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required _i1.UuidValue accountId,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         accountId: accountId,
       );

  /// Returns a shallow copy of this [PortfolioAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PortfolioAccount copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? accountId,
  }) {
    return PortfolioAccount(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      accountId: accountId ?? this.accountId,
    );
  }
}

class PortfolioAccountUpdateTable
    extends _i1.UpdateTable<PortfolioAccountTable> {
  PortfolioAccountUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> portfolioId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.portfolioId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.accountId,
    value,
  );
}

class PortfolioAccountTable extends _i1.Table<_i1.UuidValue?> {
  PortfolioAccountTable({super.tableRelation})
    : super(tableName: 'portfolio_accounts') {
    updateTable = PortfolioAccountUpdateTable(this);
    portfolioId = _i1.ColumnUuid(
      'portfolioId',
      this,
    );
    accountId = _i1.ColumnUuid(
      'accountId',
      this,
    );
  }

  late final PortfolioAccountUpdateTable updateTable;

  /// Reference to the portfolio (UUID)
  late final _i1.ColumnUuid portfolioId;

  /// Reference to the account (UUID)
  late final _i1.ColumnUuid accountId;

  @override
  List<_i1.Column> get columns => [
    id,
    portfolioId,
    accountId,
  ];
}

class PortfolioAccountInclude extends _i1.IncludeObject {
  PortfolioAccountInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PortfolioAccount.t;
}

class PortfolioAccountIncludeList extends _i1.IncludeList {
  PortfolioAccountIncludeList._({
    _i1.WhereExpressionBuilder<PortfolioAccountTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PortfolioAccount.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PortfolioAccount.t;
}

class PortfolioAccountRepository {
  const PortfolioAccountRepository._();

  /// Returns a list of [PortfolioAccount]s matching the given query parameters.
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
  Future<List<PortfolioAccount>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioAccountTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PortfolioAccount>(
      where: where?.call(PortfolioAccount.t),
      orderBy: orderBy?.call(PortfolioAccount.t),
      orderByList: orderByList?.call(PortfolioAccount.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PortfolioAccount] matching the given query parameters.
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
  Future<PortfolioAccount?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioAccountTable>? where,
    int? offset,
    _i1.OrderByBuilder<PortfolioAccountTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioAccountTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PortfolioAccount>(
      where: where?.call(PortfolioAccount.t),
      orderBy: orderBy?.call(PortfolioAccount.t),
      orderByList: orderByList?.call(PortfolioAccount.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PortfolioAccount] by its [id] or null if no such row exists.
  Future<PortfolioAccount?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PortfolioAccount>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PortfolioAccount]s in the list and returns the inserted rows.
  ///
  /// The returned [PortfolioAccount]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PortfolioAccount>> insert(
    _i1.Session session,
    List<PortfolioAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PortfolioAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PortfolioAccount] and returns the inserted row.
  ///
  /// The returned [PortfolioAccount] will have its `id` field set.
  Future<PortfolioAccount> insertRow(
    _i1.Session session,
    PortfolioAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PortfolioAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PortfolioAccount]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PortfolioAccount>> update(
    _i1.Session session,
    List<PortfolioAccount> rows, {
    _i1.ColumnSelections<PortfolioAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PortfolioAccount>(
      rows,
      columns: columns?.call(PortfolioAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PortfolioAccount]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PortfolioAccount> updateRow(
    _i1.Session session,
    PortfolioAccount row, {
    _i1.ColumnSelections<PortfolioAccountTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PortfolioAccount>(
      row,
      columns: columns?.call(PortfolioAccount.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PortfolioAccount] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PortfolioAccount?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PortfolioAccountUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PortfolioAccount>(
      id,
      columnValues: columnValues(PortfolioAccount.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PortfolioAccount]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PortfolioAccount>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PortfolioAccountUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PortfolioAccountTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioAccountTable>? orderBy,
    _i1.OrderByListBuilder<PortfolioAccountTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PortfolioAccount>(
      columnValues: columnValues(PortfolioAccount.t.updateTable),
      where: where(PortfolioAccount.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PortfolioAccount.t),
      orderByList: orderByList?.call(PortfolioAccount.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PortfolioAccount]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PortfolioAccount>> delete(
    _i1.Session session,
    List<PortfolioAccount> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PortfolioAccount>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PortfolioAccount].
  Future<PortfolioAccount> deleteRow(
    _i1.Session session,
    PortfolioAccount row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PortfolioAccount>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PortfolioAccount>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PortfolioAccountTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PortfolioAccount>(
      where: where(PortfolioAccount.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioAccountTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PortfolioAccount>(
      where: where?.call(PortfolioAccount.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
