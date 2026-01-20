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

/// YahooSymbol - Available Yahoo Finance symbols for an ISIN
/// Stores all available symbols (multiple exchanges) for price lookups
abstract class YahooSymbol
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  YahooSymbol._({
    this.id,
    required this.assetId,
    required this.symbol,
    this.exchange,
    this.exchangeDisplay,
    this.quoteType,
    required this.resolvedAt,
  });

  factory YahooSymbol({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required String symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    required DateTime resolvedAt,
  }) = _YahooSymbolImpl;

  factory YahooSymbol.fromJson(Map<String, dynamic> jsonSerialization) {
    return YahooSymbol(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      symbol: jsonSerialization['symbol'] as String,
      exchange: jsonSerialization['exchange'] as String?,
      exchangeDisplay: jsonSerialization['exchangeDisplay'] as String?,
      quoteType: jsonSerialization['quoteType'] as String?,
      resolvedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['resolvedAt'],
      ),
    );
  }

  static final t = YahooSymbolTable();

  static const db = YahooSymbolRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT.L", "IUSQ.DE")
  String symbol;

  /// Exchange code (e.g., "NMS", "LSE", "GER")
  String? exchange;

  /// Human-readable exchange name (e.g., "NASDAQ", "London Stock Exchange")
  String? exchangeDisplay;

  /// Quote type (e.g., "EQUITY", "ETF", "MUTUALFUND")
  String? quoteType;

  /// When this symbol was resolved/discovered
  DateTime resolvedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [YahooSymbol]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  YahooSymbol copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? assetId,
    String? symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    DateTime? resolvedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'YahooSymbol',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'symbol': symbol,
      if (exchange != null) 'exchange': exchange,
      if (exchangeDisplay != null) 'exchangeDisplay': exchangeDisplay,
      if (quoteType != null) 'quoteType': quoteType,
      'resolvedAt': resolvedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'YahooSymbol',
      if (id != null) 'id': id?.toJson(),
      'assetId': assetId.toJson(),
      'symbol': symbol,
      if (exchange != null) 'exchange': exchange,
      if (exchangeDisplay != null) 'exchangeDisplay': exchangeDisplay,
      if (quoteType != null) 'quoteType': quoteType,
      'resolvedAt': resolvedAt.toJson(),
    };
  }

  static YahooSymbolInclude include() {
    return YahooSymbolInclude._();
  }

  static YahooSymbolIncludeList includeList({
    _i1.WhereExpressionBuilder<YahooSymbolTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<YahooSymbolTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<YahooSymbolTable>? orderByList,
    YahooSymbolInclude? include,
  }) {
    return YahooSymbolIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(YahooSymbol.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(YahooSymbol.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _YahooSymbolImpl extends YahooSymbol {
  _YahooSymbolImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue assetId,
    required String symbol,
    String? exchange,
    String? exchangeDisplay,
    String? quoteType,
    required DateTime resolvedAt,
  }) : super._(
         id: id,
         assetId: assetId,
         symbol: symbol,
         exchange: exchange,
         exchangeDisplay: exchangeDisplay,
         quoteType: quoteType,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [YahooSymbol]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  YahooSymbol copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? assetId,
    String? symbol,
    Object? exchange = _Undefined,
    Object? exchangeDisplay = _Undefined,
    Object? quoteType = _Undefined,
    DateTime? resolvedAt,
  }) {
    return YahooSymbol(
      id: id is _i1.UuidValue? ? id : this.id,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      exchange: exchange is String? ? exchange : this.exchange,
      exchangeDisplay: exchangeDisplay is String?
          ? exchangeDisplay
          : this.exchangeDisplay,
      quoteType: quoteType is String? ? quoteType : this.quoteType,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class YahooSymbolUpdateTable extends _i1.UpdateTable<YahooSymbolTable> {
  YahooSymbolUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> assetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.assetId,
        value,
      );

  _i1.ColumnValue<String, String> symbol(String value) => _i1.ColumnValue(
    table.symbol,
    value,
  );

  _i1.ColumnValue<String, String> exchange(String? value) => _i1.ColumnValue(
    table.exchange,
    value,
  );

  _i1.ColumnValue<String, String> exchangeDisplay(String? value) =>
      _i1.ColumnValue(
        table.exchangeDisplay,
        value,
      );

  _i1.ColumnValue<String, String> quoteType(String? value) => _i1.ColumnValue(
    table.quoteType,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> resolvedAt(DateTime value) =>
      _i1.ColumnValue(
        table.resolvedAt,
        value,
      );
}

class YahooSymbolTable extends _i1.Table<_i1.UuidValue?> {
  YahooSymbolTable({super.tableRelation}) : super(tableName: 'yahoo_symbols') {
    updateTable = YahooSymbolUpdateTable(this);
    assetId = _i1.ColumnUuid(
      'assetId',
      this,
    );
    symbol = _i1.ColumnString(
      'symbol',
      this,
    );
    exchange = _i1.ColumnString(
      'exchange',
      this,
    );
    exchangeDisplay = _i1.ColumnString(
      'exchangeDisplay',
      this,
    );
    quoteType = _i1.ColumnString(
      'quoteType',
      this,
    );
    resolvedAt = _i1.ColumnDateTime(
      'resolvedAt',
      this,
    );
  }

  late final YahooSymbolUpdateTable updateTable;

  /// Reference to the asset (UUID)
  late final _i1.ColumnUuid assetId;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT.L", "IUSQ.DE")
  late final _i1.ColumnString symbol;

  /// Exchange code (e.g., "NMS", "LSE", "GER")
  late final _i1.ColumnString exchange;

  /// Human-readable exchange name (e.g., "NASDAQ", "London Stock Exchange")
  late final _i1.ColumnString exchangeDisplay;

  /// Quote type (e.g., "EQUITY", "ETF", "MUTUALFUND")
  late final _i1.ColumnString quoteType;

  /// When this symbol was resolved/discovered
  late final _i1.ColumnDateTime resolvedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    assetId,
    symbol,
    exchange,
    exchangeDisplay,
    quoteType,
    resolvedAt,
  ];
}

class YahooSymbolInclude extends _i1.IncludeObject {
  YahooSymbolInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => YahooSymbol.t;
}

class YahooSymbolIncludeList extends _i1.IncludeList {
  YahooSymbolIncludeList._({
    _i1.WhereExpressionBuilder<YahooSymbolTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(YahooSymbol.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => YahooSymbol.t;
}

class YahooSymbolRepository {
  const YahooSymbolRepository._();

  /// Returns a list of [YahooSymbol]s matching the given query parameters.
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
  Future<List<YahooSymbol>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<YahooSymbolTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<YahooSymbolTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<YahooSymbolTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<YahooSymbol>(
      where: where?.call(YahooSymbol.t),
      orderBy: orderBy?.call(YahooSymbol.t),
      orderByList: orderByList?.call(YahooSymbol.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [YahooSymbol] matching the given query parameters.
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
  Future<YahooSymbol?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<YahooSymbolTable>? where,
    int? offset,
    _i1.OrderByBuilder<YahooSymbolTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<YahooSymbolTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<YahooSymbol>(
      where: where?.call(YahooSymbol.t),
      orderBy: orderBy?.call(YahooSymbol.t),
      orderByList: orderByList?.call(YahooSymbol.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [YahooSymbol] by its [id] or null if no such row exists.
  Future<YahooSymbol?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<YahooSymbol>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [YahooSymbol]s in the list and returns the inserted rows.
  ///
  /// The returned [YahooSymbol]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<YahooSymbol>> insert(
    _i1.Session session,
    List<YahooSymbol> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<YahooSymbol>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [YahooSymbol] and returns the inserted row.
  ///
  /// The returned [YahooSymbol] will have its `id` field set.
  Future<YahooSymbol> insertRow(
    _i1.Session session,
    YahooSymbol row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<YahooSymbol>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [YahooSymbol]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<YahooSymbol>> update(
    _i1.Session session,
    List<YahooSymbol> rows, {
    _i1.ColumnSelections<YahooSymbolTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<YahooSymbol>(
      rows,
      columns: columns?.call(YahooSymbol.t),
      transaction: transaction,
    );
  }

  /// Updates a single [YahooSymbol]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<YahooSymbol> updateRow(
    _i1.Session session,
    YahooSymbol row, {
    _i1.ColumnSelections<YahooSymbolTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<YahooSymbol>(
      row,
      columns: columns?.call(YahooSymbol.t),
      transaction: transaction,
    );
  }

  /// Updates a single [YahooSymbol] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<YahooSymbol?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<YahooSymbolUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<YahooSymbol>(
      id,
      columnValues: columnValues(YahooSymbol.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [YahooSymbol]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<YahooSymbol>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<YahooSymbolUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<YahooSymbolTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<YahooSymbolTable>? orderBy,
    _i1.OrderByListBuilder<YahooSymbolTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<YahooSymbol>(
      columnValues: columnValues(YahooSymbol.t.updateTable),
      where: where(YahooSymbol.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(YahooSymbol.t),
      orderByList: orderByList?.call(YahooSymbol.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [YahooSymbol]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<YahooSymbol>> delete(
    _i1.Session session,
    List<YahooSymbol> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<YahooSymbol>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [YahooSymbol].
  Future<YahooSymbol> deleteRow(
    _i1.Session session,
    YahooSymbol row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<YahooSymbol>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<YahooSymbol>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<YahooSymbolTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<YahooSymbol>(
      where: where(YahooSymbol.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<YahooSymbolTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<YahooSymbol>(
      where: where?.call(YahooSymbol.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
