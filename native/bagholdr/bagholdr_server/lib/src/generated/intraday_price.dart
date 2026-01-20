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

/// IntradayPrice - 5-minute interval OHLCV data for detailed charting
/// Used for intraday charts (last 5 trading days)
abstract class IntradayPrice
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  IntradayPrice._({
    this.id,
    required this.ticker,
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.currency,
    required this.fetchedAt,
  });

  factory IntradayPrice({
    _i1.UuidValue? id,
    required String ticker,
    required int timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) = _IntradayPriceImpl;

  factory IntradayPrice.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntradayPrice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      timestamp: jsonSerialization['timestamp'] as int,
      open: (jsonSerialization['open'] as num).toDouble(),
      high: (jsonSerialization['high'] as num).toDouble(),
      low: (jsonSerialization['low'] as num).toDouble(),
      close: (jsonSerialization['close'] as num).toDouble(),
      volume: jsonSerialization['volume'] as int,
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  static final t = IntradayPriceTable();

  static const db = IntradayPriceRepository._();

  @override
  _i1.UuidValue? id;

  /// Yahoo Finance ticker symbol
  String ticker;

  /// Unix timestamp in seconds for this interval
  int timestamp;

  /// Open price for the interval
  double open;

  /// Highest price during the interval
  double high;

  /// Lowest price during the interval
  double low;

  /// Closing price for the interval
  double close;

  /// Trading volume during the interval
  int volume;

  /// Currency of the price data
  String currency;

  /// When this data was fetched
  DateTime fetchedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [IntradayPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IntradayPrice copyWith({
    _i1.UuidValue? id,
    String? ticker,
    int? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntradayPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IntradayPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'timestamp': timestamp,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  static IntradayPriceInclude include() {
    return IntradayPriceInclude._();
  }

  static IntradayPriceIncludeList includeList({
    _i1.WhereExpressionBuilder<IntradayPriceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntradayPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntradayPriceTable>? orderByList,
    IntradayPriceInclude? include,
  }) {
    return IntradayPriceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntradayPrice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(IntradayPrice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IntradayPriceImpl extends IntradayPrice {
  _IntradayPriceImpl({
    _i1.UuidValue? id,
    required String ticker,
    required int timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         timestamp: timestamp,
         open: open,
         high: high,
         low: low,
         close: close,
         volume: volume,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [IntradayPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IntradayPrice copyWith({
    Object? id = _Undefined,
    String? ticker,
    int? timestamp,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return IntradayPrice(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      timestamp: timestamp ?? this.timestamp,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

class IntradayPriceUpdateTable extends _i1.UpdateTable<IntradayPriceTable> {
  IntradayPriceUpdateTable(super.table);

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<int, int> timestamp(int value) => _i1.ColumnValue(
    table.timestamp,
    value,
  );

  _i1.ColumnValue<double, double> open(double value) => _i1.ColumnValue(
    table.open,
    value,
  );

  _i1.ColumnValue<double, double> high(double value) => _i1.ColumnValue(
    table.high,
    value,
  );

  _i1.ColumnValue<double, double> low(double value) => _i1.ColumnValue(
    table.low,
    value,
  );

  _i1.ColumnValue<double, double> close(double value) => _i1.ColumnValue(
    table.close,
    value,
  );

  _i1.ColumnValue<int, int> volume(int value) => _i1.ColumnValue(
    table.volume,
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

class IntradayPriceTable extends _i1.Table<_i1.UuidValue?> {
  IntradayPriceTable({super.tableRelation})
    : super(tableName: 'intraday_prices') {
    updateTable = IntradayPriceUpdateTable(this);
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    timestamp = _i1.ColumnInt(
      'timestamp',
      this,
    );
    open = _i1.ColumnDouble(
      'open',
      this,
    );
    high = _i1.ColumnDouble(
      'high',
      this,
    );
    low = _i1.ColumnDouble(
      'low',
      this,
    );
    close = _i1.ColumnDouble(
      'close',
      this,
    );
    volume = _i1.ColumnInt(
      'volume',
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

  late final IntradayPriceUpdateTable updateTable;

  /// Yahoo Finance ticker symbol
  late final _i1.ColumnString ticker;

  /// Unix timestamp in seconds for this interval
  late final _i1.ColumnInt timestamp;

  /// Open price for the interval
  late final _i1.ColumnDouble open;

  /// Highest price during the interval
  late final _i1.ColumnDouble high;

  /// Lowest price during the interval
  late final _i1.ColumnDouble low;

  /// Closing price for the interval
  late final _i1.ColumnDouble close;

  /// Trading volume during the interval
  late final _i1.ColumnInt volume;

  /// Currency of the price data
  late final _i1.ColumnString currency;

  /// When this data was fetched
  late final _i1.ColumnDateTime fetchedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    ticker,
    timestamp,
    open,
    high,
    low,
    close,
    volume,
    currency,
    fetchedAt,
  ];
}

class IntradayPriceInclude extends _i1.IncludeObject {
  IntradayPriceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => IntradayPrice.t;
}

class IntradayPriceIncludeList extends _i1.IncludeList {
  IntradayPriceIncludeList._({
    _i1.WhereExpressionBuilder<IntradayPriceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IntradayPrice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => IntradayPrice.t;
}

class IntradayPriceRepository {
  const IntradayPriceRepository._();

  /// Returns a list of [IntradayPrice]s matching the given query parameters.
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
  Future<List<IntradayPrice>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<IntradayPriceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntradayPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntradayPriceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<IntradayPrice>(
      where: where?.call(IntradayPrice.t),
      orderBy: orderBy?.call(IntradayPrice.t),
      orderByList: orderByList?.call(IntradayPrice.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [IntradayPrice] matching the given query parameters.
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
  Future<IntradayPrice?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<IntradayPriceTable>? where,
    int? offset,
    _i1.OrderByBuilder<IntradayPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntradayPriceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<IntradayPrice>(
      where: where?.call(IntradayPrice.t),
      orderBy: orderBy?.call(IntradayPrice.t),
      orderByList: orderByList?.call(IntradayPrice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [IntradayPrice] by its [id] or null if no such row exists.
  Future<IntradayPrice?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<IntradayPrice>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [IntradayPrice]s in the list and returns the inserted rows.
  ///
  /// The returned [IntradayPrice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<IntradayPrice>> insert(
    _i1.Session session,
    List<IntradayPrice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<IntradayPrice>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [IntradayPrice] and returns the inserted row.
  ///
  /// The returned [IntradayPrice] will have its `id` field set.
  Future<IntradayPrice> insertRow(
    _i1.Session session,
    IntradayPrice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<IntradayPrice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [IntradayPrice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<IntradayPrice>> update(
    _i1.Session session,
    List<IntradayPrice> rows, {
    _i1.ColumnSelections<IntradayPriceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<IntradayPrice>(
      rows,
      columns: columns?.call(IntradayPrice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IntradayPrice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IntradayPrice> updateRow(
    _i1.Session session,
    IntradayPrice row, {
    _i1.ColumnSelections<IntradayPriceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<IntradayPrice>(
      row,
      columns: columns?.call(IntradayPrice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IntradayPrice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IntradayPrice?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<IntradayPriceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<IntradayPrice>(
      id,
      columnValues: columnValues(IntradayPrice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IntradayPrice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<IntradayPrice>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<IntradayPriceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<IntradayPriceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntradayPriceTable>? orderBy,
    _i1.OrderByListBuilder<IntradayPriceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<IntradayPrice>(
      columnValues: columnValues(IntradayPrice.t.updateTable),
      where: where(IntradayPrice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntradayPrice.t),
      orderByList: orderByList?.call(IntradayPrice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [IntradayPrice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<IntradayPrice>> delete(
    _i1.Session session,
    List<IntradayPrice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<IntradayPrice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [IntradayPrice].
  Future<IntradayPrice> deleteRow(
    _i1.Session session,
    IntradayPrice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IntradayPrice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<IntradayPrice>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<IntradayPriceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<IntradayPrice>(
      where: where(IntradayPrice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<IntradayPriceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<IntradayPrice>(
      where: where?.call(IntradayPrice.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
