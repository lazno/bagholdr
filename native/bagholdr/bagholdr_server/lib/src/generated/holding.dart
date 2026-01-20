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

/// Holding - Current position derived from orders
/// Global table shared across all portfolios (like TypeScript schema)
abstract class Holding
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Holding._({
    this.id,
    required this.assetId,
    required this.quantity,
    required this.totalCostEur,
  });

  factory Holding({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required double quantity,
    required double totalCostEur,
  }) = _HoldingImpl;

  factory Holding.fromJson(Map<String, dynamic> jsonSerialization) {
    return Holding(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      totalCostEur: (jsonSerialization['totalCostEur'] as num).toDouble(),
    );
  }

  static final t = HoldingTable();

  static const db = HoldingRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Current quantity held (positive value)
  double quantity;

  /// Total cost basis in EUR (sum of all purchase costs minus sales)
  double totalCostEur;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Holding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Holding copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? assetId,
    double? quantity,
    double? totalCostEur,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Holding',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'quantity': quantity,
      'totalCostEur': totalCostEur,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Holding',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'quantity': quantity,
      'totalCostEur': totalCostEur,
    };
  }

  static HoldingInclude include() {
    return HoldingInclude._();
  }

  static HoldingIncludeList includeList({
    _i1.WhereExpressionBuilder<HoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HoldingTable>? orderByList,
    HoldingInclude? include,
  }) {
    return HoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Holding.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Holding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HoldingImpl extends Holding {
  _HoldingImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required double quantity,
    required double totalCostEur,
  }) : super._(
         id: id,
         assetId: assetId,
         quantity: quantity,
         totalCostEur: totalCostEur,
       );

  /// Returns a shallow copy of this [Holding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Holding copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? assetId,
    double? quantity,
    double? totalCostEur,
  }) {
    return Holding(
      id: id is _i1.UuidValue? ? id : this.id,
      assetId: assetId ?? this.assetId,
      quantity: quantity ?? this.quantity,
      totalCostEur: totalCostEur ?? this.totalCostEur,
    );
  }
}

class HoldingUpdateTable extends _i1.UpdateTable<HoldingTable> {
  HoldingUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> assetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.assetId,
        value,
      );

  _i1.ColumnValue<double, double> quantity(double value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<double, double> totalCostEur(double value) => _i1.ColumnValue(
    table.totalCostEur,
    value,
  );
}

class HoldingTable extends _i1.Table<_i1.UuidValue?> {
  HoldingTable({super.tableRelation}) : super(tableName: 'holdings') {
    updateTable = HoldingUpdateTable(this);
    assetId = _i1.ColumnUuid(
      'assetId',
      this,
    );
    quantity = _i1.ColumnDouble(
      'quantity',
      this,
    );
    totalCostEur = _i1.ColumnDouble(
      'totalCostEur',
      this,
    );
  }

  late final HoldingUpdateTable updateTable;

  /// Reference to the asset (UUID)
  late final _i1.ColumnUuid assetId;

  /// Current quantity held (positive value)
  late final _i1.ColumnDouble quantity;

  /// Total cost basis in EUR (sum of all purchase costs minus sales)
  late final _i1.ColumnDouble totalCostEur;

  @override
  List<_i1.Column> get columns => [
    id,
    assetId,
    quantity,
    totalCostEur,
  ];
}

class HoldingInclude extends _i1.IncludeObject {
  HoldingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Holding.t;
}

class HoldingIncludeList extends _i1.IncludeList {
  HoldingIncludeList._({
    _i1.WhereExpressionBuilder<HoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Holding.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Holding.t;
}

class HoldingRepository {
  const HoldingRepository._();

  /// Returns a list of [Holding]s matching the given query parameters.
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
  Future<List<Holding>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HoldingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Holding>(
      where: where?.call(Holding.t),
      orderBy: orderBy?.call(Holding.t),
      orderByList: orderByList?.call(Holding.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Holding] matching the given query parameters.
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
  Future<Holding?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HoldingTable>? where,
    int? offset,
    _i1.OrderByBuilder<HoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HoldingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Holding>(
      where: where?.call(Holding.t),
      orderBy: orderBy?.call(Holding.t),
      orderByList: orderByList?.call(Holding.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Holding] by its [id] or null if no such row exists.
  Future<Holding?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Holding>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Holding]s in the list and returns the inserted rows.
  ///
  /// The returned [Holding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Holding>> insert(
    _i1.Session session,
    List<Holding> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Holding>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Holding] and returns the inserted row.
  ///
  /// The returned [Holding] will have its `id` field set.
  Future<Holding> insertRow(
    _i1.Session session,
    Holding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Holding>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Holding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Holding>> update(
    _i1.Session session,
    List<Holding> rows, {
    _i1.ColumnSelections<HoldingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Holding>(
      rows,
      columns: columns?.call(Holding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Holding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Holding> updateRow(
    _i1.Session session,
    Holding row, {
    _i1.ColumnSelections<HoldingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Holding>(
      row,
      columns: columns?.call(Holding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Holding] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Holding?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<HoldingUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Holding>(
      id,
      columnValues: columnValues(Holding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Holding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Holding>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<HoldingUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<HoldingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HoldingTable>? orderBy,
    _i1.OrderByListBuilder<HoldingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Holding>(
      columnValues: columnValues(Holding.t.updateTable),
      where: where(Holding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Holding.t),
      orderByList: orderByList?.call(Holding.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Holding]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Holding>> delete(
    _i1.Session session,
    List<Holding> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Holding>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Holding].
  Future<Holding> deleteRow(
    _i1.Session session,
    Holding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Holding>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Holding>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<HoldingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Holding>(
      where: where(Holding.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HoldingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Holding>(
      where: where?.call(Holding.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
