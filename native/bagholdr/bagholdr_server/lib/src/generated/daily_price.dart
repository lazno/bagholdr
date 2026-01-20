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

/// DailyPrice - Historical daily OHLCV data from Yahoo Finance
/// Used for charting and performance calculations
abstract class DailyPrice
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  DailyPrice._({
    this.id,
    required this.ticker,
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.adjClose,
    required this.volume,
    required this.currency,
    required this.fetchedAt,
  });

  factory DailyPrice({
    _i1.UuidValue? id,
    required String ticker,
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    required double adjClose,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) = _DailyPriceImpl;

  factory DailyPrice.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPrice(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      ticker: jsonSerialization['ticker'] as String,
      date: jsonSerialization['date'] as String,
      open: (jsonSerialization['open'] as num).toDouble(),
      high: (jsonSerialization['high'] as num).toDouble(),
      low: (jsonSerialization['low'] as num).toDouble(),
      close: (jsonSerialization['close'] as num).toDouble(),
      adjClose: (jsonSerialization['adjClose'] as num).toDouble(),
      volume: jsonSerialization['volume'] as int,
      currency: jsonSerialization['currency'] as String,
      fetchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['fetchedAt'],
      ),
    );
  }

  static final t = DailyPriceTable();

  static const db = DailyPriceRepository._();

  @override
  _i1.UuidValue? id;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT")
  String ticker;

  /// Date in YYYY-MM-DD format
  String date;

  /// Open price for the day
  double open;

  /// Highest price during the day
  double high;

  /// Lowest price during the day
  double low;

  /// Closing price for the day
  double close;

  /// Adjusted close (accounts for splits/dividends)
  double adjClose;

  /// Trading volume
  int volume;

  /// Currency of the price data (e.g., EUR, USD)
  String currency;

  /// When this price data was fetched from Yahoo
  DateTime fetchedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [DailyPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPrice copyWith({
    _i1.UuidValue? id,
    String? ticker,
    String? date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? adjClose,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'adjClose': adjClose,
      'volume': volume,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyPrice',
      if (id != null) 'id': id?.toJson(),
      'ticker': ticker,
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'adjClose': adjClose,
      'volume': volume,
      'currency': currency,
      'fetchedAt': fetchedAt.toJson(),
    };
  }

  static DailyPriceInclude include() {
    return DailyPriceInclude._();
  }

  static DailyPriceIncludeList includeList({
    _i1.WhereExpressionBuilder<DailyPriceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPriceTable>? orderByList,
    DailyPriceInclude? include,
  }) {
    return DailyPriceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPrice.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DailyPrice.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyPriceImpl extends DailyPrice {
  _DailyPriceImpl({
    _i1.UuidValue? id,
    required String ticker,
    required String date,
    required double open,
    required double high,
    required double low,
    required double close,
    required double adjClose,
    required int volume,
    required String currency,
    required DateTime fetchedAt,
  }) : super._(
         id: id,
         ticker: ticker,
         date: date,
         open: open,
         high: high,
         low: low,
         close: close,
         adjClose: adjClose,
         volume: volume,
         currency: currency,
         fetchedAt: fetchedAt,
       );

  /// Returns a shallow copy of this [DailyPrice]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPrice copyWith({
    Object? id = _Undefined,
    String? ticker,
    String? date,
    double? open,
    double? high,
    double? low,
    double? close,
    double? adjClose,
    int? volume,
    String? currency,
    DateTime? fetchedAt,
  }) {
    return DailyPrice(
      id: id is _i1.UuidValue? ? id : this.id,
      ticker: ticker ?? this.ticker,
      date: date ?? this.date,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      adjClose: adjClose ?? this.adjClose,
      volume: volume ?? this.volume,
      currency: currency ?? this.currency,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

class DailyPriceUpdateTable extends _i1.UpdateTable<DailyPriceTable> {
  DailyPriceUpdateTable(super.table);

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<String, String> date(String value) => _i1.ColumnValue(
    table.date,
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

  _i1.ColumnValue<double, double> adjClose(double value) => _i1.ColumnValue(
    table.adjClose,
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

class DailyPriceTable extends _i1.Table<_i1.UuidValue?> {
  DailyPriceTable({super.tableRelation}) : super(tableName: 'daily_prices') {
    updateTable = DailyPriceUpdateTable(this);
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    date = _i1.ColumnString(
      'date',
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
    adjClose = _i1.ColumnDouble(
      'adjClose',
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

  late final DailyPriceUpdateTable updateTable;

  /// Yahoo Finance symbol (e.g., "AAPL", "MSFT")
  late final _i1.ColumnString ticker;

  /// Date in YYYY-MM-DD format
  late final _i1.ColumnString date;

  /// Open price for the day
  late final _i1.ColumnDouble open;

  /// Highest price during the day
  late final _i1.ColumnDouble high;

  /// Lowest price during the day
  late final _i1.ColumnDouble low;

  /// Closing price for the day
  late final _i1.ColumnDouble close;

  /// Adjusted close (accounts for splits/dividends)
  late final _i1.ColumnDouble adjClose;

  /// Trading volume
  late final _i1.ColumnInt volume;

  /// Currency of the price data (e.g., EUR, USD)
  late final _i1.ColumnString currency;

  /// When this price data was fetched from Yahoo
  late final _i1.ColumnDateTime fetchedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    ticker,
    date,
    open,
    high,
    low,
    close,
    adjClose,
    volume,
    currency,
    fetchedAt,
  ];
}

class DailyPriceInclude extends _i1.IncludeObject {
  DailyPriceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DailyPrice.t;
}

class DailyPriceIncludeList extends _i1.IncludeList {
  DailyPriceIncludeList._({
    _i1.WhereExpressionBuilder<DailyPriceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyPrice.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => DailyPrice.t;
}

class DailyPriceRepository {
  const DailyPriceRepository._();

  /// Returns a list of [DailyPrice]s matching the given query parameters.
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
  Future<List<DailyPrice>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPriceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPriceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DailyPrice>(
      where: where?.call(DailyPrice.t),
      orderBy: orderBy?.call(DailyPrice.t),
      orderByList: orderByList?.call(DailyPrice.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DailyPrice] matching the given query parameters.
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
  Future<DailyPrice?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPriceTable>? where,
    int? offset,
    _i1.OrderByBuilder<DailyPriceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPriceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DailyPrice>(
      where: where?.call(DailyPrice.t),
      orderBy: orderBy?.call(DailyPrice.t),
      orderByList: orderByList?.call(DailyPrice.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DailyPrice] by its [id] or null if no such row exists.
  Future<DailyPrice?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DailyPrice>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DailyPrice]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyPrice]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DailyPrice>> insert(
    _i1.Session session,
    List<DailyPrice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DailyPrice>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DailyPrice] and returns the inserted row.
  ///
  /// The returned [DailyPrice] will have its `id` field set.
  Future<DailyPrice> insertRow(
    _i1.Session session,
    DailyPrice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyPrice>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DailyPrice]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DailyPrice>> update(
    _i1.Session session,
    List<DailyPrice> rows, {
    _i1.ColumnSelections<DailyPriceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DailyPrice>(
      rows,
      columns: columns?.call(DailyPrice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPrice]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyPrice> updateRow(
    _i1.Session session,
    DailyPrice row, {
    _i1.ColumnSelections<DailyPriceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyPrice>(
      row,
      columns: columns?.call(DailyPrice.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPrice] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyPrice?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<DailyPriceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyPrice>(
      id,
      columnValues: columnValues(DailyPrice.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyPrice]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DailyPrice>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DailyPriceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DailyPriceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPriceTable>? orderBy,
    _i1.OrderByListBuilder<DailyPriceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DailyPrice>(
      columnValues: columnValues(DailyPrice.t.updateTable),
      where: where(DailyPrice.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPrice.t),
      orderByList: orderByList?.call(DailyPrice.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DailyPrice]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DailyPrice>> delete(
    _i1.Session session,
    List<DailyPrice> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DailyPrice>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DailyPrice].
  Future<DailyPrice> deleteRow(
    _i1.Session session,
    DailyPrice row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyPrice>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DailyPrice>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DailyPriceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DailyPrice>(
      where: where(DailyPrice.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPriceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DailyPrice>(
      where: where?.call(DailyPrice.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
