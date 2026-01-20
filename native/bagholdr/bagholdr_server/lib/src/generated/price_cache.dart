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

/// PriceCache - Cached current price data from Yahoo Finance
/// Short-lived cache for real-time price display
abstract class PriceCache
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PriceCache._({
    this.id,
    required this.ticker,
    required this.priceNative,
    required this.currency,
    required this.priceEur,
    required this.fetchedAt,
  });

  factory PriceCache({
    _i1.UuidValue? id,
    required String ticker,
    required double priceNative,
    required String currency,
    required double priceEur,
    required DateTime fetchedAt,
  }) = _PriceCacheImpl;

  factory PriceCache.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceCache(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      priceNative: (jsonSerialization['priceNative'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      priceEur: (jsonSerialization['priceEur'] as num).toDouble(),
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  static final t = PriceCacheTable();

  static const db = PriceCacheRepository._();

  @override
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Price in the native currency of the instrument
  double priceNative;

  /// Currency of the price (e.g., USD, EUR, GBP)
  String currency;

  /// Price converted to EUR (using cached FX rate)
  double priceEur;

  /// When this price was fetched
  DateTime fetchedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PriceCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceCache copyWith({
    _i1.UuidValue? id,
    String? ticker,
    double? priceNative,
    String? currency,
    double? priceEur,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceCache',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'priceNative': priceNative,
      'currency': currency,
      'priceEur': priceEur,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PriceCache',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'priceNative': priceNative,
      'currency': currency,
      'priceEur': priceEur,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  static PriceCacheInclude include() {
    return PriceCacheInclude._();
  }

  static PriceCacheIncludeList includeList({
    _i1.WhereExpressionBuilder<PriceCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceCacheTable>? orderByList,
    PriceCacheInclude? include,
  }) {
    return PriceCacheIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceCache.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PriceCache.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PriceCacheImpl extends PriceCache {
  _PriceCacheImpl({
    _i1.UuidValue? id,
    required String ticker,
    required double priceNative,
    required String currency,
    required double priceEur,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         priceNative: priceNative,
         currency: currency,
         priceEur: priceEur,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [PriceCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceCache copyWith({
    Object? id = _Undefined,
    String? ticker,
    double? priceNative,
    String? currency,
    double? priceEur,
    DateTime? fetchedAt,
  }) {
    return PriceCache(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      priceNative: priceNative ?? this.priceNative,
      currency: currency ?? this.currency,
      priceEur: priceEur ?? this.priceEur,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

class PriceCacheUpdateTable extends _i1.UpdateTable<PriceCacheTable> {
  PriceCacheUpdateTable(super.table);

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<double, double> priceNative(double value) => _i1.ColumnValue(
    table.priceNative,
    value,
  );

  _i1.ColumnValue<String, String> currency(String value) => _i1.ColumnValue(
    table.currency,
    value,
  );

  _i1.ColumnValue<double, double> priceEur(double value) => _i1.ColumnValue(
    table.priceEur,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> fetchedAt(DateTime value) =>
      _i1.ColumnValue(
        table.fetchedAt,
        value,
      );
}

class PriceCacheTable extends _i1.Table<_i1.UuidValue?> {
  PriceCacheTable({super.tableRelation}) : super(tableName: 'price_cache') {
    updateTable = PriceCacheUpdateTable(this);
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    priceNative = _i1.ColumnDouble(
      'priceNative',
      this,
    );
    currency = _i1.ColumnString(
      'currency',
      this,
    );
    priceEur = _i1.ColumnDouble(
      'priceEur',
      this,
    );
    fetchedAt = _i1.ColumnDateTime(
      'fetchedAt',
      this,
    );
  }

  late final PriceCacheUpdateTable updateTable;

  /// Yahoo Finance ticker symbol
  late final _i1.ColumnString ticker;

  /// Price in the native currency of the instrument
  late final _i1.ColumnDouble priceNative;

  /// Currency of the price (e.g., USD, EUR, GBP)
  late final _i1.ColumnString currency;

  /// Price converted to EUR (using cached FX rate)
  late final _i1.ColumnDouble priceEur;

  /// When this price was fetched
  late final _i1.ColumnDateTime fetchedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    ticker,
    priceNative,
    currency,
    priceEur,
    fetchedAt,
  ];
}

class PriceCacheInclude extends _i1.IncludeObject {
  PriceCacheInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PriceCache.t;
}

class PriceCacheIncludeList extends _i1.IncludeList {
  PriceCacheIncludeList._({
    _i1.WhereExpressionBuilder<PriceCacheTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PriceCache.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PriceCache.t;
}

class PriceCacheRepository {
  const PriceCacheRepository._();

  /// Returns a list of [PriceCache]s matching the given query parameters.
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
  Future<List<PriceCache>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PriceCacheTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceCacheTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PriceCache>(
      where: where?.call(PriceCache.t),
      orderBy: orderBy?.call(PriceCache.t),
      orderByList: orderByList?.call(PriceCache.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PriceCache] matching the given query parameters.
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
  Future<PriceCache?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PriceCacheTable>? where,
    int? offset,
    _i1.OrderByBuilder<PriceCacheTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PriceCacheTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PriceCache>(
      where: where?.call(PriceCache.t),
      orderBy: orderBy?.call(PriceCache.t),
      orderByList: orderByList?.call(PriceCache.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PriceCache] by its [id] or null if no such row exists.
  Future<PriceCache?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PriceCache>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PriceCache]s in the list and returns the inserted rows.
  ///
  /// The returned [PriceCache]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PriceCache>> insert(
    _i1.Session session,
    List<PriceCache> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PriceCache>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PriceCache] and returns the inserted row.
  ///
  /// The returned [PriceCache] will have its `id` field set.
  Future<PriceCache> insertRow(
    _i1.Session session,
    PriceCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PriceCache>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PriceCache]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PriceCache>> update(
    _i1.Session session,
    List<PriceCache> rows, {
    _i1.ColumnSelections<PriceCacheTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PriceCache>(
      rows,
      columns: columns?.call(PriceCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PriceCache]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PriceCache> updateRow(
    _i1.Session session,
    PriceCache row, {
    _i1.ColumnSelections<PriceCacheTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PriceCache>(
      row,
      columns: columns?.call(PriceCache.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PriceCache] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PriceCache?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PriceCacheUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PriceCache>(
      id,
      columnValues: columnValues(PriceCache.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PriceCache]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PriceCache>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PriceCacheUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PriceCacheTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PriceCacheTable>? orderBy,
    _i1.OrderByListBuilder<PriceCacheTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PriceCache>(
      columnValues: columnValues(PriceCache.t.updateTable),
      where: where(PriceCache.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PriceCache.t),
      orderByList: orderByList?.call(PriceCache.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PriceCache]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PriceCache>> delete(
    _i1.Session session,
    List<PriceCache> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PriceCache>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PriceCache].
  Future<PriceCache> deleteRow(
    _i1.Session session,
    PriceCache row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PriceCache>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PriceCache>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PriceCacheTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PriceCache>(
      where: where(PriceCache.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PriceCacheTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PriceCache>(
      where: where?.call(PriceCache.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
