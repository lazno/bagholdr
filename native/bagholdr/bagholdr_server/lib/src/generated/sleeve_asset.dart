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

/// SleeveAsset - Junction table linking sleeves to assets
/// Enables many-to-many relationship between sleeves and assets
abstract class SleeveAsset
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SleeveAsset._({
    this.id,
    required this.sleeveId,
    required this.assetId,
  });

  factory SleeveAsset({
    _i1.UuidValue? id,
    required _i1.UuidValue sleeveId,
    required _i1.UuidValue assetId,
  }) = _SleeveAssetImpl;

  factory SleeveAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return SleeveAsset(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      sleeveId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['sleeveId'],
      ),
      assetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['assetId'],
      ),
    );
  }

  static final t = SleeveAssetTable();

  static const db = SleeveAssetRepository._();

  @override
  _i1.UuidValue? id;

  /// Reference to the sleeve (UUID)
  _i1.UuidValue sleeveId;

  /// Reference to the asset (UUID)
  _i1.UuidValue assetId;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SleeveAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SleeveAsset copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? sleeveId,
    _i1.UuidValue? assetId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SleeveAsset',
      if (id != null) 'id': id?.toJson(),
      'sleeveId': sleeveId.toJson(),
      'assetId': assetId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SleeveAsset',
      if (id != null) 'id': id?.toJson(),
      'sleeveId': sleeveId.toJson(),
      'assetId': assetId.toJson(),
    };
  }

  static SleeveAssetInclude include() {
    return SleeveAssetInclude._();
  }

  static SleeveAssetIncludeList includeList({
    _i1.WhereExpressionBuilder<SleeveAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveAssetTable>? orderByList,
    SleeveAssetInclude? include,
  }) {
    return SleeveAssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleeveAsset.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SleeveAsset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SleeveAssetImpl extends SleeveAsset {
  _SleeveAssetImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue sleeveId,
    required _i1.UuidValue assetId,
  }) : super._(
         id: id,
         sleeveId: sleeveId,
         assetId: assetId,
       );

  /// Returns a shallow copy of this [SleeveAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SleeveAsset copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? sleeveId,
    _i1.UuidValue? assetId,
  }) {
    return SleeveAsset(
      id: id is _i1.UuidValue? ? id : this.id,
      sleeveId: sleeveId ?? this.sleeveId,
      assetId: assetId ?? this.assetId,
    );
  }
}

class SleeveAssetUpdateTable extends _i1.UpdateTable<SleeveAssetTable> {
  SleeveAssetUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> sleeveId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.sleeveId,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> assetId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.assetId,
        value,
      );
}

class SleeveAssetTable extends _i1.Table<_i1.UuidValue?> {
  SleeveAssetTable({super.tableRelation}) : super(tableName: 'sleeve_assets') {
    updateTable = SleeveAssetUpdateTable(this);
    sleeveId = _i1.ColumnUuid(
      'sleeveId',
      this,
    );
    assetId = _i1.ColumnUuid(
      'assetId',
      this,
    );
  }

  late final SleeveAssetUpdateTable updateTable;

  /// Reference to the sleeve (UUID)
  late final _i1.ColumnUuid sleeveId;

  /// Reference to the asset (UUID)
  late final _i1.ColumnUuid assetId;

  @override
  List<_i1.Column> get columns => [
    id,
    sleeveId,
    assetId,
  ];
}

class SleeveAssetInclude extends _i1.IncludeObject {
  SleeveAssetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SleeveAsset.t;
}

class SleeveAssetIncludeList extends _i1.IncludeList {
  SleeveAssetIncludeList._({
    _i1.WhereExpressionBuilder<SleeveAssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SleeveAsset.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SleeveAsset.t;
}

class SleeveAssetRepository {
  const SleeveAssetRepository._();

  /// Returns a list of [SleeveAsset]s matching the given query parameters.
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
  Future<List<SleeveAsset>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveAssetTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<SleeveAsset>(
      where: where?.call(SleeveAsset.t),
      orderBy: orderBy?.call(SleeveAsset.t),
      orderByList: orderByList?.call(SleeveAsset.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [SleeveAsset] matching the given query parameters.
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
  Future<SleeveAsset?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveAssetTable>? where,
    int? offset,
    _i1.OrderByBuilder<SleeveAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SleeveAssetTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<SleeveAsset>(
      where: where?.call(SleeveAsset.t),
      orderBy: orderBy?.call(SleeveAsset.t),
      orderByList: orderByList?.call(SleeveAsset.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [SleeveAsset] by its [id] or null if no such row exists.
  Future<SleeveAsset?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<SleeveAsset>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [SleeveAsset]s in the list and returns the inserted rows.
  ///
  /// The returned [SleeveAsset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<SleeveAsset>> insert(
    _i1.Session session,
    List<SleeveAsset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<SleeveAsset>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [SleeveAsset] and returns the inserted row.
  ///
  /// The returned [SleeveAsset] will have its `id` field set.
  Future<SleeveAsset> insertRow(
    _i1.Session session,
    SleeveAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SleeveAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SleeveAsset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SleeveAsset>> update(
    _i1.Session session,
    List<SleeveAsset> rows, {
    _i1.ColumnSelections<SleeveAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SleeveAsset>(
      rows,
      columns: columns?.call(SleeveAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleeveAsset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SleeveAsset> updateRow(
    _i1.Session session,
    SleeveAsset row, {
    _i1.ColumnSelections<SleeveAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SleeveAsset>(
      row,
      columns: columns?.call(SleeveAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SleeveAsset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SleeveAsset?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SleeveAssetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SleeveAsset>(
      id,
      columnValues: columnValues(SleeveAsset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SleeveAsset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SleeveAsset>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<SleeveAssetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SleeveAssetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SleeveAssetTable>? orderBy,
    _i1.OrderByListBuilder<SleeveAssetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SleeveAsset>(
      columnValues: columnValues(SleeveAsset.t.updateTable),
      where: where(SleeveAsset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SleeveAsset.t),
      orderByList: orderByList?.call(SleeveAsset.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SleeveAsset]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SleeveAsset>> delete(
    _i1.Session session,
    List<SleeveAsset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SleeveAsset>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SleeveAsset].
  Future<SleeveAsset> deleteRow(
    _i1.Session session,
    SleeveAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SleeveAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SleeveAsset>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<SleeveAssetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SleeveAsset>(
      where: where(SleeveAsset.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<SleeveAssetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SleeveAsset>(
      where: where?.call(SleeveAsset.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
