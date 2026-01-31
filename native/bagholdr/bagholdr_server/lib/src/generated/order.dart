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

/// Order - Raw imported orders from broker CSV
/// Global table (audit trail), not per-portfolio
abstract class Order
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Order._({
    this.id,
    required this.accountId,
    required this.assetId,
    required this.orderDate,
    required this.quantity,
    required this.priceNative,
    required this.totalNative,
    required this.totalEur,
    required this.currency,
    this.orderReference,
    required this.importedAt,
  });

  factory Order({
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    required _i1.UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
    String? orderReference,
    required DateTime importedAt,
  }) = _OrderImpl;

  factory Order.fromJson(Map<String, dynamic> jsonSerialization) {
    return Order(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
      orderDate: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['orderDate'],
      ),
      quantity: (jsonSerialization['quantity'] as num).toDouble(),
      priceNative: (jsonSerialization['priceNative'] as num).toDouble(),
      totalNative: (jsonSerialization['totalNative'] as num).toDouble(),
      totalEur: (jsonSerialization['totalEur'] as num).toDouble(),
      currency: jsonSerialization['currency'] as String,
      orderReference: jsonSerialization['orderReference'] as String?,
      importedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['importedAt'],
      ),
    );
  }

  static final t = OrderTable();

  static const db = OrderRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the account this order belongs to (UUID)
  _i1.UuidValue accountId;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  /// Date the order was executed
  DateTime orderDate;

  /// Quantity bought (positive) or sold (negative)
  double quantity;

  /// Price per unit in the native currency
  double priceNative;

  /// Total value in native currency (quantity * priceNative)
  double totalNative;

  /// Total value in EUR (converted at order time)
  double totalEur;

  /// Currency of the order (e.g., EUR, USD)
  String currency;

  /// Optional broker order reference number
  String? orderReference;

  /// Timestamp when this order was imported into the system
  DateTime importedAt;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Order copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? accountId,
    _i1.UuidValue? assetId,
    DateTime? orderDate,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
    String? orderReference,
    DateTime? importedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Order',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'assetId': assetId.toJson(),
      'orderDate': orderDate.toJson(),
      'quantity': quantity,
      'priceNative': priceNative,
      'totalNative': totalNative,
      'totalEur': totalEur,
      'currency': currency,
      if (orderReference != null) 'orderReference': orderReference,
      'importedAt': importedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Order',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'assetId': assetId.toJson(),
      'orderDate': orderDate.toJson(),
      'quantity': quantity,
      'priceNative': priceNative,
      'totalNative': totalNative,
      'totalEur': totalEur,
      'currency': currency,
      if (orderReference != null) 'orderReference': orderReference,
      'importedAt': importedAt.toJson(),
    };
  }

  static OrderInclude include() {
    return OrderInclude._();
  }

  static OrderIncludeList includeList({
    _i1.WhereExpressionBuilder<OrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderTable>? orderByList,
    OrderInclude? include,
  }) {
    return OrderIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Order.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Order.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderImpl extends Order {
  _OrderImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue accountId,
    required _i1.UuidValue assetId,
    required DateTime orderDate,
    required double quantity,
    required double priceNative,
    required double totalNative,
    required double totalEur,
    required String currency,
    String? orderReference,
    required DateTime importedAt,
  }) : super._(
         id: id,
         accountId: accountId,
         assetId: assetId,
         orderDate: orderDate,
         quantity: quantity,
         priceNative: priceNative,
         totalNative: totalNative,
         totalEur: totalEur,
         currency: currency,
         orderReference: orderReference,
         importedAt: importedAt,
       );

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Order copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? accountId,
    _i1.UuidValue? assetId,
    DateTime? orderDate,
    double? quantity,
    double? priceNative,
    double? totalNative,
    double? totalEur,
    String? currency,
    Object? orderReference = _Undefined,
    DateTime? importedAt,
  }) {
    return Order(
      id: id is _i1.UuidValue? ? id : this.id,
      accountId: accountId ?? this.accountId,
      assetId: assetId ?? this.assetId,
      orderDate: orderDate ?? this.orderDate,
      quantity: quantity ?? this.quantity,
      priceNative: priceNative ?? this.priceNative,
      totalNative: totalNative ?? this.totalNative,
      totalEur: totalEur ?? this.totalEur,
      currency: currency ?? this.currency,
      orderReference: orderReference is String?
          ? orderReference
          : this.orderReference,
      importedAt: importedAt ?? this.importedAt,
    );
  }
}

class OrderUpdateTable extends _i1.UpdateTable<OrderTable> {
  OrderUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> accountId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.accountId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> assetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.assetId,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> orderDate(DateTime value) =>
      _i1.ColumnValue(
        table.orderDate,
        value,
      );

  _i1.ColumnValue<double, double> quantity(double value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<double, double> priceNative(double value) => _i1.ColumnValue(
    table.priceNative,
    value,
  );

  _i1.ColumnValue<double, double> totalNative(double value) => _i1.ColumnValue(
    table.totalNative,
    value,
  );

  _i1.ColumnValue<double, double> totalEur(double value) => _i1.ColumnValue(
    table.totalEur,
    value,
  );

  _i1.ColumnValue<String, String> currency(String value) => _i1.ColumnValue(
    table.currency,
    value,
  );

  _i1.ColumnValue<String, String> orderReference(String? value) =>
      _i1.ColumnValue(
        table.orderReference,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> importedAt(DateTime value) =>
      _i1.ColumnValue(
        table.importedAt,
        value,
      );
}

class OrderTable extends _i1.Table<_i1.UuidValue?> {
  OrderTable({super.tableRelation}) : super(tableName: 'orders') {
    updateTable = OrderUpdateTable(this);
    accountId = _i1.ColumnUuid(
      'accountId',
      this,
    );
    assetId = _i1.ColumnUuid(
      'assetId',
      this,
    );
    orderDate = _i1.ColumnDateTime(
      'orderDate',
      this,
    );
    quantity = _i1.ColumnDouble(
      'quantity',
      this,
    );
    priceNative = _i1.ColumnDouble(
      'priceNative',
      this,
    );
    totalNative = _i1.ColumnDouble(
      'totalNative',
      this,
    );
    totalEur = _i1.ColumnDouble(
      'totalEur',
      this,
    );
    currency = _i1.ColumnString(
      'currency',
      this,
    );
    orderReference = _i1.ColumnString(
      'orderReference',
      this,
    );
    importedAt = _i1.ColumnDateTime(
      'importedAt',
      this,
    );
  }

  late final OrderUpdateTable updateTable;

  /// Reference to the account this order belongs to (UUID)
  late final _i1.ColumnUuid accountId;

  /// Reference to the asset (UUID)
  late final _i1.ColumnUuid assetId;

  /// Date the order was executed
  late final _i1.ColumnDateTime orderDate;

  /// Quantity bought (positive) or sold (negative)
  late final _i1.ColumnDouble quantity;

  /// Price per unit in the native currency
  late final _i1.ColumnDouble priceNative;

  /// Total value in native currency (quantity * priceNative)
  late final _i1.ColumnDouble totalNative;

  /// Total value in EUR (converted at order time)
  late final _i1.ColumnDouble totalEur;

  /// Currency of the order (e.g., EUR, USD)
  late final _i1.ColumnString currency;

  /// Optional broker order reference number
  late final _i1.ColumnString orderReference;

  /// Timestamp when this order was imported into the system
  late final _i1.ColumnDateTime importedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    accountId,
    assetId,
    orderDate,
    quantity,
    priceNative,
    totalNative,
    totalEur,
    currency,
    orderReference,
    importedAt,
  ];
}

class OrderInclude extends _i1.IncludeObject {
  OrderInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Order.t;
}

class OrderIncludeList extends _i1.IncludeList {
  OrderIncludeList._({
    _i1.WhereExpressionBuilder<OrderTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Order.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Order.t;
}

class OrderRepository {
  const OrderRepository._();

  /// Returns a list of [Order]s matching the given query parameters.
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
  Future<List<Order>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Order>(
      where: where?.call(Order.t),
      orderBy: orderBy?.call(Order.t),
      orderByList: orderByList?.call(Order.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Order] matching the given query parameters.
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
  Future<Order?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderTable>? where,
    int? offset,
    _i1.OrderByBuilder<OrderTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Order>(
      where: where?.call(Order.t),
      orderBy: orderBy?.call(Order.t),
      orderByList: orderByList?.call(Order.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Order] by its [id] or null if no such row exists.
  Future<Order?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Order>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Order]s in the list and returns the inserted rows.
  ///
  /// The returned [Order]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Order>> insert(
    _i1.Session session,
    List<Order> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Order>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Order] and returns the inserted row.
  ///
  /// The returned [Order] will have its `id` field set.
  Future<Order> insertRow(
    _i1.Session session,
    Order row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Order>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Order]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Order>> update(
    _i1.Session session,
    List<Order> rows, {
    _i1.ColumnSelections<OrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Order>(
      rows,
      columns: columns?.call(Order.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Order]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Order> updateRow(
    _i1.Session session,
    Order row, {
    _i1.ColumnSelections<OrderTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Order>(
      row,
      columns: columns?.call(Order.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Order] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Order?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<OrderUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Order>(
      id,
      columnValues: columnValues(Order.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Order]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Order>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<OrderUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<OrderTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderTable>? orderBy,
    _i1.OrderByListBuilder<OrderTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Order>(
      columnValues: columnValues(Order.t.updateTable),
      where: where(Order.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Order.t),
      orderByList: orderByList?.call(Order.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Order]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Order>> delete(
    _i1.Session session,
    List<Order> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Order>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Order].
  Future<Order> deleteRow(
    _i1.Session session,
    Order row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Order>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Order>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<OrderTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Order>(
      where: where(Order.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Order>(
      where: where?.call(Order.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
