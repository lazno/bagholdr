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

/// Portfolio - Configuration/strategy container
/// Each portfolio organizes global holdings differently with its own band settings
abstract class Portfolio
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Portfolio._({
    this.id,
    required this.name,
    required this.bandRelativeTolerance,
    required this.bandAbsoluteFloor,
    required this.bandAbsoluteCap,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Portfolio({
    _i1.UuidValue? id,
    required String name,
    required double bandRelativeTolerance,
    required double bandAbsoluteFloor,
    required double bandAbsoluteCap,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PortfolioImpl;

  factory Portfolio.fromJson(Map<String, dynamic> jsonSerialization) {
    return Portfolio(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      bandRelativeTolerance: (jsonSerialization['bandRelativeTolerance'] as num)
          .toDouble(),
      bandAbsoluteFloor: (jsonSerialization['bandAbsoluteFloor'] as num)
          .toDouble(),
      bandAbsoluteCap: (jsonSerialization['bandAbsoluteCap'] as num).toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = PortfolioTable();

  static const db = PortfolioRepository._();

  @override
  _i1.UuidValue? id;

  /// Portfolio display name
  String name;

  /// Band configuration (applies to all sleeves in portfolio)
  /// Relative tolerance as percentage (e.g., 20 means +/-20% of target)
  double bandRelativeTolerance;

  /// Minimum band width in percentage points
  double bandAbsoluteFloor;

  /// Maximum band width in percentage points
  double bandAbsoluteCap;

  /// Timestamps
  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Portfolio]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Portfolio copyWith({
    _i1.UuidValue? id,
    String? name,
    double? bandRelativeTolerance,
    double? bandAbsoluteFloor,
    double? bandAbsoluteCap,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Portfolio',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'bandRelativeTolerance': bandRelativeTolerance,
      'bandAbsoluteFloor': bandAbsoluteFloor,
      'bandAbsoluteCap': bandAbsoluteCap,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Portfolio',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'bandRelativeTolerance': bandRelativeTolerance,
      'bandAbsoluteFloor': bandAbsoluteFloor,
      'bandAbsoluteCap': bandAbsoluteCap,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static PortfolioInclude include() {
    return PortfolioInclude._();
  }

  static PortfolioIncludeList includeList({
    _i1.WhereExpressionBuilder<PortfolioTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioTable>? orderByList,
    PortfolioInclude? include,
  }) {
    return PortfolioIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Portfolio.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Portfolio.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioImpl extends Portfolio {
  _PortfolioImpl({
    _i1.UuidValue? id,
    required String name,
    required double bandRelativeTolerance,
    required double bandAbsoluteFloor,
    required double bandAbsoluteCap,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         name: name,
         bandRelativeTolerance: bandRelativeTolerance,
         bandAbsoluteFloor: bandAbsoluteFloor,
         bandAbsoluteCap: bandAbsoluteCap,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Portfolio]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Portfolio copyWith({
    Object? id = _Undefined,
    String? name,
    double? bandRelativeTolerance,
    double? bandAbsoluteFloor,
    double? bandAbsoluteCap,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Portfolio(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      bandRelativeTolerance:
          bandRelativeTolerance ?? this.bandRelativeTolerance,
      bandAbsoluteFloor: bandAbsoluteFloor ?? this.bandAbsoluteFloor,
      bandAbsoluteCap: bandAbsoluteCap ?? this.bandAbsoluteCap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PortfolioUpdateTable extends _i1.UpdateTable<PortfolioTable> {
  PortfolioUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<double, double> bandRelativeTolerance(double value) =>
      _i1.ColumnValue(
        table.bandRelativeTolerance,
        value,
      );

  _i1.ColumnValue<double, double> bandAbsoluteFloor(double value) =>
      _i1.ColumnValue(
        table.bandAbsoluteFloor,
        value,
      );

  _i1.ColumnValue<double, double> bandAbsoluteCap(double value) =>
      _i1.ColumnValue(
        table.bandAbsoluteCap,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class PortfolioTable extends _i1.Table<_i1.UuidValue?> {
  PortfolioTable({super.tableRelation}) : super(tableName: 'portfolios') {
    updateTable = PortfolioUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    bandRelativeTolerance = _i1.ColumnDouble(
      'bandRelativeTolerance',
      this,
    );
    bandAbsoluteFloor = _i1.ColumnDouble(
      'bandAbsoluteFloor',
      this,
    );
    bandAbsoluteCap = _i1.ColumnDouble(
      'bandAbsoluteCap',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final PortfolioUpdateTable updateTable;

  /// Portfolio display name
  late final _i1.ColumnString name;

  /// Band configuration (applies to all sleeves in portfolio)
  /// Relative tolerance as percentage (e.g., 20 means +/-20% of target)
  late final _i1.ColumnDouble bandRelativeTolerance;

  /// Minimum band width in percentage points
  late final _i1.ColumnDouble bandAbsoluteFloor;

  /// Maximum band width in percentage points
  late final _i1.ColumnDouble bandAbsoluteCap;

  /// Timestamps
  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    bandRelativeTolerance,
    bandAbsoluteFloor,
    bandAbsoluteCap,
    createdAt,
    updatedAt,
  ];
}

class PortfolioInclude extends _i1.IncludeObject {
  PortfolioInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Portfolio.t;
}

class PortfolioIncludeList extends _i1.IncludeList {
  PortfolioIncludeList._({
    _i1.WhereExpressionBuilder<PortfolioTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Portfolio.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Portfolio.t;
}

class PortfolioRepository {
  const PortfolioRepository._();

  /// Returns a list of [Portfolio]s matching the given query parameters.
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
  Future<List<Portfolio>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Portfolio>(
      where: where?.call(Portfolio.t),
      orderBy: orderBy?.call(Portfolio.t),
      orderByList: orderByList?.call(Portfolio.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Portfolio] matching the given query parameters.
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
  Future<Portfolio?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioTable>? where,
    int? offset,
    _i1.OrderByBuilder<PortfolioTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Portfolio>(
      where: where?.call(Portfolio.t),
      orderBy: orderBy?.call(Portfolio.t),
      orderByList: orderByList?.call(Portfolio.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Portfolio] by its [id] or null if no such row exists.
  Future<Portfolio?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Portfolio>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Portfolio]s in the list and returns the inserted rows.
  ///
  /// The returned [Portfolio]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Portfolio>> insert(
    _i1.Session session,
    List<Portfolio> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Portfolio>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Portfolio] and returns the inserted row.
  ///
  /// The returned [Portfolio] will have its `id` field set.
  Future<Portfolio> insertRow(
    _i1.Session session,
    Portfolio row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Portfolio>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Portfolio]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Portfolio>> update(
    _i1.Session session,
    List<Portfolio> rows, {
    _i1.ColumnSelections<PortfolioTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Portfolio>(
      rows,
      columns: columns?.call(Portfolio.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Portfolio]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Portfolio> updateRow(
    _i1.Session session,
    Portfolio row, {
    _i1.ColumnSelections<PortfolioTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Portfolio>(
      row,
      columns: columns?.call(Portfolio.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Portfolio] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Portfolio?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PortfolioUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Portfolio>(
      id,
      columnValues: columnValues(Portfolio.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Portfolio]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Portfolio>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PortfolioUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PortfolioTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioTable>? orderBy,
    _i1.OrderByListBuilder<PortfolioTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Portfolio>(
      columnValues: columnValues(Portfolio.t.updateTable),
      where: where(Portfolio.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Portfolio.t),
      orderByList: orderByList?.call(Portfolio.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Portfolio]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Portfolio>> delete(
    _i1.Session session,
    List<Portfolio> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Portfolio>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Portfolio].
  Future<Portfolio> deleteRow(
    _i1.Session session,
    Portfolio row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Portfolio>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Portfolio>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PortfolioTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Portfolio>(
      where: where(Portfolio.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Portfolio>(
      where: where?.call(Portfolio.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
