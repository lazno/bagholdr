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

/// PortfolioRule - Flexible rule system for portfolio constraints
/// Stores concentration limits, exposure rules, and other constraints
abstract class PortfolioRule
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PortfolioRule._({
    this.id,
    required this.portfolioId,
    required this.ruleType,
    required this.name,
    this.config,
    required this.enabled,
    required this.createdAt,
  });

  factory PortfolioRule({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required String ruleType,
    required String name,
    String? config,
    required bool enabled,
    required DateTime createdAt,
  }) = _PortfolioRuleImpl;

  factory PortfolioRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return PortfolioRule(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      portfolioId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['portfolioId'],
      ),
      ruleType: jsonSerialization['ruleType'] as String,
      name: jsonSerialization['name'] as String,
      config: jsonSerialization['config'] as String?,
      enabled: jsonSerialization['enabled'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PortfolioRuleTable();

  static const db = PortfolioRuleRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the portfolio (UUID)
  _i1.UuidValue portfolioId;

  /// Type of rule (e.g., "concentration", "exposure", "custom")
  String ruleType;

  /// Human-readable rule name
  String name;

  /// JSON configuration for rule-specific parameters
  /// e.g., {"maxPercent": 10, "asset": "AAPL"} for concentration
  String? config;

  /// Whether the rule is currently active
  bool enabled;

  /// When the rule was created
  DateTime createdAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PortfolioRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PortfolioRule copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? portfolioId,
    String? ruleType,
    String? name,
    String? config,
    bool? enabled,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PortfolioRule',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'ruleType': ruleType,
      'name': name,
      if (config != null) 'config': config,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PortfolioRule',
      if (id != null) 'id': id?.toJson(),
      'portfolioId': portfolioId.toJson(),
      'ruleType': ruleType,
      'name': name,
      if (config != null) 'config': config,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
    };
  }

  static PortfolioRuleInclude include() {
    return PortfolioRuleInclude._();
  }

  static PortfolioRuleIncludeList includeList({
    _i1.WhereExpressionBuilder<PortfolioRuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioRuleTable>? orderByList,
    PortfolioRuleInclude? include,
  }) {
    return PortfolioRuleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PortfolioRule.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PortfolioRule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PortfolioRuleImpl extends PortfolioRule {
  _PortfolioRuleImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue portfolioId,
    required String ruleType,
    required String name,
    String? config,
    required bool enabled,
    required DateTime createdAt,
  }) : super._(
         id: id,
         portfolioId: portfolioId,
         ruleType: ruleType,
         name: name,
         config: config,
         enabled: enabled,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PortfolioRule]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PortfolioRule copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? portfolioId,
    String? ruleType,
    String? name,
    Object? config = _Undefined,
    bool? enabled,
    DateTime? createdAt,
  }) {
    return PortfolioRule(
      id: id is _i1.UuidValue? ? id : this.id,
      portfolioId: portfolioId ?? this.portfolioId,
      ruleType: ruleType ?? this.ruleType,
      name: name ?? this.name,
      config: config is String? ? config : this.config,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PortfolioRuleUpdateTable extends _i1.UpdateTable<PortfolioRuleTable> {
  PortfolioRuleUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> portfolioId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.portfolioId,
    value,
  );

  _i1.ColumnValue<String, String> ruleType(String value) => _i1.ColumnValue(
    table.ruleType,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> config(String? value) => _i1.ColumnValue(
    table.config,
    value,
  );

  _i1.ColumnValue<bool, bool> enabled(bool value) => _i1.ColumnValue(
    table.enabled,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PortfolioRuleTable extends _i1.Table<_i1.UuidValue?> {
  PortfolioRuleTable({super.tableRelation})
    : super(tableName: 'portfolio_rules') {
    updateTable = PortfolioRuleUpdateTable(this);
    portfolioId = _i1.ColumnUuid(
      'portfolioId',
      this,
    );
    ruleType = _i1.ColumnString(
      'ruleType',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    config = _i1.ColumnString(
      'config',
      this,
    );
    enabled = _i1.ColumnBool(
      'enabled',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PortfolioRuleUpdateTable updateTable;

  /// Reference to the portfolio (UUID)
  late final _i1.ColumnUuid portfolioId;

  /// Type of rule (e.g., "concentration", "exposure", "custom")
  late final _i1.ColumnString ruleType;

  /// Human-readable rule name
  late final _i1.ColumnString name;

  /// JSON configuration for rule-specific parameters
  /// e.g., {"maxPercent": 10, "asset": "AAPL"} for concentration
  late final _i1.ColumnString config;

  /// Whether the rule is currently active
  late final _i1.ColumnBool enabled;

  /// When the rule was created
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    portfolioId,
    ruleType,
    name,
    config,
    enabled,
    createdAt,
  ];
}

class PortfolioRuleInclude extends _i1.IncludeObject {
  PortfolioRuleInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PortfolioRule.t;
}

class PortfolioRuleIncludeList extends _i1.IncludeList {
  PortfolioRuleIncludeList._({
    _i1.WhereExpressionBuilder<PortfolioRuleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PortfolioRule.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PortfolioRule.t;
}

class PortfolioRuleRepository {
  const PortfolioRuleRepository._();

  /// Returns a list of [PortfolioRule]s matching the given query parameters.
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
  Future<List<PortfolioRule>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioRuleTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioRuleTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PortfolioRule>(
      where: where?.call(PortfolioRule.t),
      orderBy: orderBy?.call(PortfolioRule.t),
      orderByList: orderByList?.call(PortfolioRule.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PortfolioRule] matching the given query parameters.
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
  Future<PortfolioRule?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioRuleTable>? where,
    int? offset,
    _i1.OrderByBuilder<PortfolioRuleTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PortfolioRuleTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PortfolioRule>(
      where: where?.call(PortfolioRule.t),
      orderBy: orderBy?.call(PortfolioRule.t),
      orderByList: orderByList?.call(PortfolioRule.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PortfolioRule] by its [id] or null if no such row exists.
  Future<PortfolioRule?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PortfolioRule>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PortfolioRule]s in the list and returns the inserted rows.
  ///
  /// The returned [PortfolioRule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PortfolioRule>> insert(
    _i1.Session session,
    List<PortfolioRule> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PortfolioRule>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PortfolioRule] and returns the inserted row.
  ///
  /// The returned [PortfolioRule] will have its `id` field set.
  Future<PortfolioRule> insertRow(
    _i1.Session session,
    PortfolioRule row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PortfolioRule>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PortfolioRule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PortfolioRule>> update(
    _i1.Session session,
    List<PortfolioRule> rows, {
    _i1.ColumnSelections<PortfolioRuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PortfolioRule>(
      rows,
      columns: columns?.call(PortfolioRule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PortfolioRule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PortfolioRule> updateRow(
    _i1.Session session,
    PortfolioRule row, {
    _i1.ColumnSelections<PortfolioRuleTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PortfolioRule>(
      row,
      columns: columns?.call(PortfolioRule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PortfolioRule] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PortfolioRule?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PortfolioRuleUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PortfolioRule>(
      id,
      columnValues: columnValues(PortfolioRule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PortfolioRule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PortfolioRule>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PortfolioRuleUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PortfolioRuleTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PortfolioRuleTable>? orderBy,
    _i1.OrderByListBuilder<PortfolioRuleTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PortfolioRule>(
      columnValues: columnValues(PortfolioRule.t.updateTable),
      where: where(PortfolioRule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PortfolioRule.t),
      orderByList: orderByList?.call(PortfolioRule.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PortfolioRule]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PortfolioRule>> delete(
    _i1.Session session,
    List<PortfolioRule> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PortfolioRule>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PortfolioRule].
  Future<PortfolioRule> deleteRow(
    _i1.Session session,
    PortfolioRule row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PortfolioRule>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PortfolioRule>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PortfolioRuleTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PortfolioRule>(
      where: where(PortfolioRule.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PortfolioRuleTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PortfolioRule>(
      where: where?.call(PortfolioRule.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
