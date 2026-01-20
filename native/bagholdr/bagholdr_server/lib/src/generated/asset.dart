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
import 'asset_type.dart' as _i2;

/// Asset - Financial instruments identified by ISIN
/// Global table shared across all portfolios
abstract class Asset
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  Asset._({
    this.id,
    required this.isin,
    required this.ticker,
    required this.name,
    this.description,
    required this.assetType,
    required this.currency,
    this.yahooSymbol,
    this.metadata,
    required this.archived,
  });

  factory Asset({
    _i1.UuidValue? id,
    required String isin,
    required String ticker,
    required String name,
    String? description,
    required _i2.AssetType assetType,
    required String currency,
    String? yahooSymbol,
    String? metadata,
    required bool archived,
  }) = _AssetImpl;

  factory Asset.fromJson(Map<String, dynamic> jsonSerialization) {
    return Asset(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      isin: jsonSerialization['isin'] as String,
      ticker: jsonSerialization['ticker'] as String,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      assetType: _i2.AssetType.fromJson(
        (jsonSerialization['assetType'] as String),
      ),
      currency: jsonSerialization['currency'] as String,
      yahooSymbol: jsonSerialization['yahooSymbol'] as String?,
      metadata: jsonSerialization['metadata'] as String?,
      archived: jsonSerialization['archived'] as bool,
    );
  }

  static final t = AssetTable();

  static const db = AssetRepository._();

  @override
  _i1.UuidValue? id;

  /// ISIN (International Securities Identification Number) - unique business identifier
  String isin;

  /// Broker's ticker symbol (from import)
  String ticker;

  /// Human-readable name
  String name;

  /// Optional description
  String? description;

  /// Classification: stock, etf, bond, fund, commodity, other
  _i2.AssetType assetType;

  /// Trading currency (e.g., EUR, USD)
  String currency;

  /// Yahoo Finance symbol - resolved from ISIN, used for price fetching
  String? yahooSymbol;

  /// JSON metadata for ETF look-through (holdings, sectors, factors)
  /// e.g., {"holdings": [{"name": "Apple", "weight": 5.2}], "sectors": [{"name": "Tech", "weight": 30}]}
  String? metadata;

  /// Whether asset is excluded from calculations and dashboard views
  bool archived;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Asset copyWith({
    _i1.UuidValue? id,
    String? isin,
    String? ticker,
    String? name,
    String? description,
    _i2.AssetType? assetType,
    String? currency,
    String? yahooSymbol,
    String? metadata,
    bool? archived,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id?.toJson(),
      'isin': isin,
      'ticker': ticker,
      'name': name,
      if (description != null) 'description': description,
      'assetType': assetType.toJson(),
      'currency': currency,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      if (metadata != null) 'metadata': metadata,
      'archived': archived,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Asset',
      if (id != null) 'id': id?.toJson(),
      'isin': isin,
      'ticker': ticker,
      'name': name,
      if (description != null) 'description': description,
      'assetType': assetType.toJson(),
      'currency': currency,
      if (yahooSymbol != null) 'yahooSymbol': yahooSymbol,
      if (metadata != null) 'metadata': metadata,
      'archived': archived,
    };
  }

  static AssetInclude include() {
    return AssetInclude._();
  }

  static AssetIncludeList includeList({
    _i1.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetTable>? orderByList,
    AssetInclude? include,
  }) {
    return AssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Asset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetImpl extends Asset {
  _AssetImpl({
    _i1.UuidValue? id,
    required String isin,
    required String ticker,
    required String name,
    String? description,
    required _i2.AssetType assetType,
    required String currency,
    String? yahooSymbol,
    String? metadata,
    required bool archived,
  }) : super._(
         id: id,
         isin: isin,
         ticker: ticker,
         name: name,
         description: description,
         assetType: assetType,
         currency: currency,
         yahooSymbol: yahooSymbol,
         metadata: metadata,
         archived: archived,
       );

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Asset copyWith({
    Object? id = _Undefined,
    String? isin,
    String? ticker,
    String? name,
    Object? description = _Undefined,
    _i2.AssetType? assetType,
    String? currency,
    Object? yahooSymbol = _Undefined,
    Object? metadata = _Undefined,
    bool? archived,
  }) {
    return Asset(
      id: id is _i1.UuidValue? ? id : this.id,
      isin: isin ?? this.isin,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      assetType: assetType ?? this.assetType,
      currency: currency ?? this.currency,
      yahooSymbol: yahooSymbol is String? ? yahooSymbol : this.yahooSymbol,
      metadata: metadata is String? ? metadata : this.metadata,
      archived: archived ?? this.archived,
    );
  }
}

class AssetUpdateTable extends _i1.UpdateTable<AssetTable> {
  AssetUpdateTable(super.table);

  _i1.ColumnValue<String, String> isin(String value) => _i1.ColumnValue(
    table.isin,
    value,
  );

  _i1.ColumnValue<String, String> ticker(String value) => _i1.ColumnValue(
    table.ticker,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<_i2.AssetType, _i2.AssetType> assetType(
    _i2.AssetType value,
  ) => _i1.ColumnValue(
    table.assetType,
    value,
  );

  _i1.ColumnValue<String, String> currency(String value) => _i1.ColumnValue(
    table.currency,
    value,
  );

  _i1.ColumnValue<String, String> yahooSymbol(String? value) => _i1.ColumnValue(
    table.yahooSymbol,
    value,
  );

  _i1.ColumnValue<String, String> metadata(String? value) => _i1.ColumnValue(
    table.metadata,
    value,
  );

  _i1.ColumnValue<bool, bool> archived(bool value) => _i1.ColumnValue(
    table.archived,
    value,
  );
}

class AssetTable extends _i1.Table<_i1.UuidValue?> {
  AssetTable({super.tableRelation}) : super(tableName: 'assets') {
    updateTable = AssetUpdateTable(this);
    isin = _i1.ColumnString(
      'isin',
      this,
    );
    ticker = _i1.ColumnString(
      'ticker',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    assetType = _i1.ColumnEnum(
      'assetType',
      this,
      _i1.EnumSerialization.byName,
    );
    currency = _i1.ColumnString(
      'currency',
      this,
    );
    yahooSymbol = _i1.ColumnString(
      'yahooSymbol',
      this,
    );
    metadata = _i1.ColumnString(
      'metadata',
      this,
    );
    archived = _i1.ColumnBool(
      'archived',
      this,
    );
  }

  late final AssetUpdateTable updateTable;

  /// ISIN (International Securities Identification Number) - unique business identifier
  late final _i1.ColumnString isin;

  /// Broker's ticker symbol (from import)
  late final _i1.ColumnString ticker;

  /// Human-readable name
  late final _i1.ColumnString name;

  /// Optional description
  late final _i1.ColumnString description;

  /// Classification: stock, etf, bond, fund, commodity, other
  late final _i1.ColumnEnum<_i2.AssetType> assetType;

  /// Trading currency (e.g., EUR, USD)
  late final _i1.ColumnString currency;

  /// Yahoo Finance symbol - resolved from ISIN, used for price fetching
  late final _i1.ColumnString yahooSymbol;

  /// JSON metadata for ETF look-through (holdings, sectors, factors)
  /// e.g., {"holdings": [{"name": "Apple", "weight": 5.2}], "sectors": [{"name": "Tech", "weight": 30}]}
  late final _i1.ColumnString metadata;

  /// Whether asset is excluded from calculations and dashboard views
  late final _i1.ColumnBool archived;

  @override
  List<_i1.Column> get columns => [
    id,
    isin,
    ticker,
    name,
    description,
    assetType,
    currency,
    yahooSymbol,
    metadata,
    archived,
  ];
}

class AssetInclude extends _i1.IncludeObject {
  AssetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Asset.t;
}

class AssetIncludeList extends _i1.IncludeList {
  AssetIncludeList._({
    _i1.WhereExpressionBuilder<AssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Asset.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => Asset.t;
}

class AssetRepository {
  const AssetRepository._();

  /// Returns a list of [Asset]s matching the given query parameters.
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
  Future<List<Asset>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Asset] matching the given query parameters.
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
  Future<Asset?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AssetTable>? where,
    int? offset,
    _i1.OrderByBuilder<AssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AssetTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Asset] by its [id] or null if no such row exists.
  Future<Asset?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Asset>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Asset]s in the list and returns the inserted rows.
  ///
  /// The returned [Asset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Asset>> insert(
    _i1.Session session,
    List<Asset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Asset>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Asset] and returns the inserted row.
  ///
  /// The returned [Asset] will have its `id` field set.
  Future<Asset> insertRow(
    _i1.Session session,
    Asset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Asset>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Asset>> update(
    _i1.Session session,
    List<Asset> rows, {
    _i1.ColumnSelections<AssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Asset>(
      rows,
      columns: columns?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Asset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Asset> updateRow(
    _i1.Session session,
    Asset row, {
    _i1.ColumnSelections<AssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Asset>(
      row,
      columns: columns?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Asset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Asset?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Asset>(
      id,
      columnValues: columnValues(Asset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Asset>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AssetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AssetTable>? orderBy,
    _i1.OrderByListBuilder<AssetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Asset>(
      columnValues: columnValues(Asset.t.updateTable),
      where: where(Asset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Asset]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Asset>> delete(
    _i1.Session session,
    List<Asset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Asset>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Asset].
  Future<Asset> deleteRow(
    _i1.Session session,
    Asset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Asset>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Asset>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<AssetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Asset>(
      where: where(Asset.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Asset>(
      where: where?.call(Asset.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
