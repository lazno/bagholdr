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

/// Sleeve - Hierarchical grouping of assets with budget targets
/// Portfolio-specific - same global holdings can be organized differently per portfolio
abstract class Sleeve
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Sleeve._({
    this.id,
    required this.portfolioId,
    this.parentSleeveId,
    required this.name,
    required this.budgetPercent,
    required this.sortOrder,
    required this.isCash,
  });

  factory Sleeve({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    _i1.UuidValue? parentSleeveId,
    required String name,
    required double budgetPercent,
    required int sortOrder,
    required bool isCash,
  }) = _SleeveImpl;

  factory Sleeve.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sleeve(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      parentSleeveId: jsonSerialization['parentSleeveId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['parentSleeveId'],
            ),
      name: jsonSerialization['name'] as String,
      budgetPercent: (jsonSerialization['budgetPercent'] as num).toDouble(),
      sortOrder: jsonSerialization['sortOrder'] as int,
      isCash: jsonSerialization['isCash'] as bool,
    );
  }

  static final t = SleeveTable();

  static const db = SleeveRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to parent portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Self-reference for hierarchy (null = root/top-level sleeve)
  /// Cascade delete: when parent sleeve is deleted, children are also deleted
  _i1.UuidValue? parentSleeveId;

  /// Display name (e.g., "Core", "Equities", "Satellite")
  String name;

  /// Target allocation as percentage of portfolio (e.g., 75.0 = 75%)
  double budgetPercent;

  /// Display order within parent (for UI sorting)
  int sortOrder;

  /// Whether this sleeve represents the cash allocation
  bool isCash;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Sleeve]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Sleeve copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    _i1.UuidValue? parentSleeveId,
    String? name,
    double? budgetPercent,
    int? sortOrder,
    bool? isCash,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Sleeve',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      if (parentSleeveId != null) 'parentSleeveId': parentSleeveId?.toJson(),
      'name': name,
      'budgetPercent': budgetPercent,
      'sortOrder': sortOrder,
      'isCash': isCash,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Sleeve',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      if (parentSleeveId != null) 'parentSleeveId': parentSleeveId?.toJson(),
      'name': name,
      'budgetPercent': budgetPercent,
      'sortOrder': sortOrder,
      'isCash': isCash,
    };
  }

  static SleeveInclude include() {
    return SleeveInclude._();
  }

  static SleeveIncludeList includeList({
    _i1.WhereExpressionBuilder<SleeveTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveTable>? orderByList,
    SleeveInclude? include,
  }) {
    return SleeveIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sleeve.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Sleeve.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveImpl extends Sleeve {
  _SleeveImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    _i1.UuidValue? parentSleeveId,
    required String name,
    required double budgetPercent,
    required int sortOrder,
    required bool isCash,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         parentSleeveId: parentSleeveId,
         name: name,
         budgetPercent: budgetPercent,
         sortOrder: sortOrder,
         isCash: isCash,
       );

  /// Returns a shallow copy of this [Sleeve]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Sleeve copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    Object? parentSleeveId = _Undefined,
    String? name,
    double? budgetPercent,
    int? sortOrder,
    bool? isCash,
  }) {
    return Sleeve(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      parentSleeveId: parentSleeveId is _i1.UuidValue?
          ? parentSleeveId
          : this.parentSleeveId,
      name: name ?? this.name,
      budgetPercent: budgetPercent ?? this.budgetPercent,
      sortOrder: sortOrder ?? this.sortOrder,
      isCash: isCash ?? this.isCash,
    );
  }
}

class SleeveUpdateTable extends _i1.UpdateTable<SleeveTable> {
  SleeveUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> portfolioId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.portfolioId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> parentSleeveId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.parentSleeveId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<double, double> budgetPercent(double value) =>
      _i1.ColumnValue(
        table.budgetPercent,
        value,
      );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<bool, bool> isCash(bool value) => _i1.ColumnValue(
    table.isCash,
    value,
  );
}

class SleeveTable extends _i1.Table<_i1.UuidValue?> {
  SleeveTable({super.tableRelation}) : super(tableName: 'sleeves') {
    updateTable = SleeveUpdateTable(this);
    portfolioId = _i1.ColumnUuid(
      'portfolioId',
      this,
    );
    parentSleeveId = _i1.ColumnUuid(
      'parentSleeveId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    budgetPercent = _i1.ColumnDouble(
      'budgetPercent',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    isCash = _i1.ColumnBool(
      'isCash',
      this,
    );
  }

  late final SleeveUpdateTable updateTable;

  /// Reference to parent portfolio (UUID)
  late final _i1.ColumnUuid portfolioId;

  /// Self-reference for hierarchy (null = root/top-level sleeve)
  /// Cascade delete: when parent sleeve is deleted, children are also deleted
  late final _i1.ColumnUuid parentSleeveId;

  /// Display name (e.g., "Core", "Equities", "Satellite")
  late final _i1.ColumnString name;

  /// Target allocation as percentage of portfolio (e.g., 75.0 = 75%)
  late final _i1.ColumnDouble budgetPercent;

  /// Display order within parent (for UI sorting)
  late final _i1.ColumnInt sortOrder;

  /// Whether this sleeve represents the cash allocation
  late final _i1.ColumnBool isCash;

  @override
  List<_i1.Column> get columns => [
    id,
    portfolioId,
    parentSleeveId,
    name,
    budgetPercent,
    sortOrder,
    isCash,
  ];
}

class SleeveInclude extends _i1.IncludeObject {
  SleeveInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Sleeve.t;
}

class SleeveIncludeList extends _i1.IncludeList {
  SleeveIncludeList._({
    _i1.WhereExpressionBuilder<SleeveTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Sleeve.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Sleeve.t;
}

class SleeveRepository {
  const SleeveRepository._();

  /// Returns a list of [Sleeve]s matching the given query parameters.
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
  Future<List<Sleeve>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Sleeve>(
      where: where?.call(Sleeve.t),
      orderBy: orderBy?.call(Sleeve.t),
      orderByList: orderByList?.call(Sleeve.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Sleeve] matching the given query parameters.
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
  Future<Sleeve?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveTable>? where,
    int? offset,
    _i1.OrderByBuilder<SleeveTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Sleeve>(
      where: where?.call(Sleeve.t),
      orderBy: orderBy?.call(Sleeve.t),
      orderByList: orderByList?.call(Sleeve.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Sleeve] by its [id] or null if no such row exists.
  Future<Sleeve?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Sleeve>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Sleeve]s in the list and returns the inserted rows.
  ///
  /// The returned [Sleeve]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Sleeve>> insert(
    _i1.Session session,
    List<Sleeve> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Sleeve>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Sleeve] and returns the inserted row.
  ///
  /// The returned [Sleeve] will have its `id` field set.
  Future<Sleeve> insertRow(
    _i1.Session session,
    Sleeve row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Sleeve>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Sleeve]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Sleeve>> update(
    _i1.Session session,
    List<Sleeve> rows, {
    _i1.ColumnSelections<SleeveTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Sleeve>(
      rows,
      columns: columns?.call(Sleeve.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Sleeve]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Sleeve> updateRow(
    _i1.Session session,
    Sleeve row, {
    _i1.ColumnSelections<SleeveTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Sleeve>(
      row,
      columns: columns?.call(Sleeve.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Sleeve] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Sleeve?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SleeveUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Sleeve>(
      id,
      columnValues: columnValues(Sleeve.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Sleeve]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Sleeve>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SleeveUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SleeveTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveTable>? orderBy,
    _i1.OrderByListBuilder<SleeveTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Sleeve>(
      columnValues: columnValues(Sleeve.t.updateTable),
      where: where(Sleeve.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sleeve.t),
      orderByList: orderByList?.call(Sleeve.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Sleeve]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Sleeve>> delete(
    _i1.Session session,
    List<Sleeve> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Sleeve>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Sleeve].
  Future<Sleeve> deleteRow(
    _i1.Session session,
    Sleeve row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Sleeve>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Sleeve>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SleeveTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Sleeve>(
      where: where(Sleeve.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Sleeve>(
      where: where?.call(Sleeve.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
