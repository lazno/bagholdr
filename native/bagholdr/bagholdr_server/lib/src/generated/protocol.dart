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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'allocation_status.dart' as _i5;
import 'asset.dart' as _i6;
import 'asset_period_return.dart' as _i7;
import 'asset_type.dart' as _i8;
import 'asset_valuation.dart' as _i9;
import 'band.dart' as _i10;
import 'band_config.dart' as _i11;
import 'chart_data_point.dart' as _i12;
import 'chart_data_result.dart' as _i13;
import 'chart_range.dart' as _i14;
import 'concentration_violation.dart' as _i15;
import 'daily_price.dart' as _i16;
import 'dividend_event.dart' as _i17;
import 'fx_cache.dart' as _i18;
import 'global_cash.dart' as _i19;
import 'historical_returns_result.dart' as _i20;
import 'holding.dart' as _i21;
import 'holding_response.dart' as _i22;
import 'holdings_list_response.dart' as _i23;
import 'intraday_price.dart' as _i24;
import 'issue.dart' as _i25;
import 'issue_severity.dart' as _i26;
import 'issue_type.dart' as _i27;
import 'issues_response.dart' as _i28;
import 'missing_symbol_asset.dart' as _i29;
import 'order.dart' as _i30;
import 'period_return.dart' as _i31;
import 'portfolio.dart' as _i32;
import 'portfolio_rule.dart' as _i33;
import 'portfolio_valuation.dart' as _i34;
import 'price_cache.dart' as _i35;
import 'return_period.dart' as _i36;
import 'sleeve.dart' as _i37;
import 'sleeve_allocation.dart' as _i38;
import 'sleeve_asset.dart' as _i39;
import 'sleeve_node.dart' as _i40;
import 'sleeve_tree_response.dart' as _i41;
import 'stale_price_asset.dart' as _i42;
import 'ticker_metadata.dart' as _i43;
import 'yahoo_symbol.dart' as _i44;
import 'package:bagholdr_server/src/generated/portfolio.dart' as _i45;
export 'allocation_status.dart';
export 'asset.dart';
export 'asset_period_return.dart';
export 'asset_type.dart';
export 'asset_valuation.dart';
export 'band.dart';
export 'band_config.dart';
export 'chart_data_point.dart';
export 'chart_data_result.dart';
export 'chart_range.dart';
export 'concentration_violation.dart';
export 'daily_price.dart';
export 'dividend_event.dart';
export 'fx_cache.dart';
export 'global_cash.dart';
export 'historical_returns_result.dart';
export 'holding.dart';
export 'holding_response.dart';
export 'holdings_list_response.dart';
export 'intraday_price.dart';
export 'issue.dart';
export 'issue_severity.dart';
export 'issue_type.dart';
export 'issues_response.dart';
export 'missing_symbol_asset.dart';
export 'order.dart';
export 'period_return.dart';
export 'portfolio.dart';
export 'portfolio_rule.dart';
export 'portfolio_valuation.dart';
export 'price_cache.dart';
export 'return_period.dart';
export 'sleeve.dart';
export 'sleeve_allocation.dart';
export 'sleeve_asset.dart';
export 'sleeve_node.dart';
export 'sleeve_tree_response.dart';
export 'stale_price_asset.dart';
export 'ticker_metadata.dart';
export 'yahoo_symbol.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'assets',
      dartName: 'Asset',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'isin',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'assetType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:AssetType',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'yahooSymbol',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'metadata',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'archived',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'assets_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'asset_isin_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'isin',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'daily_prices',
      dartName: 'DailyPrice',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'date',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'open',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'high',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'low',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'close',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'adjClose',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'volume',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'daily_prices_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'daily_price_ticker_date_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'date',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'daily_price_ticker_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'dividend_events',
      dartName: 'DividendEvent',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'exDate',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'amount',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'dividend_events_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'dividend_event_ticker_date_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'exDate',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'dividend_event_ticker_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'fx_cache',
      dartName: 'FxCache',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'pair',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'rate',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'fx_cache_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'fx_cache_pair_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'pair',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'global_cash',
      dartName: 'GlobalCash',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'cashId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'amountEur',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'global_cash_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'global_cash_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'cashId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'holdings',
      dartName: 'Holding',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'assetId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'quantity',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'totalCostEur',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'holdings_fk_0',
          columns: ['assetId'],
          referenceTable: 'assets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'holdings_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'holding_asset_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'intraday_prices',
      dartName: 'IntradayPrice',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'timestamp',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'open',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'high',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'low',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'close',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'volume',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'intraday_prices_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'intraday_price_ticker_ts_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'timestamp',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'intraday_price_ticker_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'orders',
      dartName: 'Order',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'assetId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'orderDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'quantity',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'priceNative',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'totalNative',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'totalEur',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'orderReference',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'importedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'orders_fk_0',
          columns: ['assetId'],
          referenceTable: 'assets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'orders_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'order_asset_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'portfolio_rules',
      dartName: 'PortfolioRule',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'portfolioId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'ruleType',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'config',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'enabled',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'portfolio_rules_fk_0',
          columns: ['portfolioId'],
          referenceTable: 'portfolios',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'portfolio_rules_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'portfolio_rule_portfolio_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'portfolioId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'portfolios',
      dartName: 'Portfolio',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'bandRelativeTolerance',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'bandAbsoluteFloor',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'bandAbsoluteCap',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'portfolios_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'price_cache',
      dartName: 'PriceCache',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'priceNative',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'currency',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'priceEur',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'fetchedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'price_cache_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'price_cache_ticker_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'sleeve_assets',
      dartName: 'SleeveAsset',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'sleeveId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'assetId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'sleeve_assets_fk_0',
          columns: ['sleeveId'],
          referenceTable: 'sleeves',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'sleeve_assets_fk_1',
          columns: ['assetId'],
          referenceTable: 'assets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'sleeve_assets_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'sleeve_asset_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sleeveId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'sleeve_asset_sleeve_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sleeveId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'sleeve_asset_asset_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'sleeves',
      dartName: 'Sleeve',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'portfolioId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'parentSleeveId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'budgetPercent',
          columnType: _i2.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'isCash',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'sleeves_fk_0',
          columns: ['portfolioId'],
          referenceTable: 'portfolios',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'sleeves_fk_1',
          columns: ['parentSleeveId'],
          referenceTable: 'sleeves',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'sleeves_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'sleeve_portfolio_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'portfolioId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'ticker_metadata',
      dartName: 'TickerMetadata',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'ticker',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'lastDailyDate',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'lastSyncedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'lastIntradaySyncedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'isActive',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'ticker_metadata_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'ticker_metadata_ticker_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'ticker',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'yahoo_symbols',
      dartName: 'YahooSymbol',
      schema: 'public',
      module: 'bagholdr',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'assetId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'symbol',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'exchange',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'exchangeDisplay',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'quoteType',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'resolvedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'yahoo_symbols_fk_0',
          columns: ['assetId'],
          referenceTable: 'assets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'yahoo_symbols_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'yahoo_symbol_asset_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'assetId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'yahoo_symbol_symbol_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'symbol',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.AllocationStatus) {
      return _i5.AllocationStatus.fromJson(data) as T;
    }
    if (t == _i6.Asset) {
      return _i6.Asset.fromJson(data) as T;
    }
    if (t == _i7.AssetPeriodReturn) {
      return _i7.AssetPeriodReturn.fromJson(data) as T;
    }
    if (t == _i8.AssetType) {
      return _i8.AssetType.fromJson(data) as T;
    }
    if (t == _i9.AssetValuation) {
      return _i9.AssetValuation.fromJson(data) as T;
    }
    if (t == _i10.Band) {
      return _i10.Band.fromJson(data) as T;
    }
    if (t == _i11.BandConfig) {
      return _i11.BandConfig.fromJson(data) as T;
    }
    if (t == _i12.ChartDataPoint) {
      return _i12.ChartDataPoint.fromJson(data) as T;
    }
    if (t == _i13.ChartDataResult) {
      return _i13.ChartDataResult.fromJson(data) as T;
    }
    if (t == _i14.ChartRange) {
      return _i14.ChartRange.fromJson(data) as T;
    }
    if (t == _i15.ConcentrationViolation) {
      return _i15.ConcentrationViolation.fromJson(data) as T;
    }
    if (t == _i16.DailyPrice) {
      return _i16.DailyPrice.fromJson(data) as T;
    }
    if (t == _i17.DividendEvent) {
      return _i17.DividendEvent.fromJson(data) as T;
    }
    if (t == _i18.FxCache) {
      return _i18.FxCache.fromJson(data) as T;
    }
    if (t == _i19.GlobalCash) {
      return _i19.GlobalCash.fromJson(data) as T;
    }
    if (t == _i20.HistoricalReturnsResult) {
      return _i20.HistoricalReturnsResult.fromJson(data) as T;
    }
    if (t == _i21.Holding) {
      return _i21.Holding.fromJson(data) as T;
    }
    if (t == _i22.HoldingResponse) {
      return _i22.HoldingResponse.fromJson(data) as T;
    }
    if (t == _i23.HoldingsListResponse) {
      return _i23.HoldingsListResponse.fromJson(data) as T;
    }
    if (t == _i24.IntradayPrice) {
      return _i24.IntradayPrice.fromJson(data) as T;
    }
    if (t == _i25.Issue) {
      return _i25.Issue.fromJson(data) as T;
    }
    if (t == _i26.IssueSeverity) {
      return _i26.IssueSeverity.fromJson(data) as T;
    }
    if (t == _i27.IssueType) {
      return _i27.IssueType.fromJson(data) as T;
    }
    if (t == _i28.IssuesResponse) {
      return _i28.IssuesResponse.fromJson(data) as T;
    }
    if (t == _i29.MissingSymbolAsset) {
      return _i29.MissingSymbolAsset.fromJson(data) as T;
    }
    if (t == _i30.Order) {
      return _i30.Order.fromJson(data) as T;
    }
    if (t == _i31.PeriodReturn) {
      return _i31.PeriodReturn.fromJson(data) as T;
    }
    if (t == _i32.Portfolio) {
      return _i32.Portfolio.fromJson(data) as T;
    }
    if (t == _i33.PortfolioRule) {
      return _i33.PortfolioRule.fromJson(data) as T;
    }
    if (t == _i34.PortfolioValuation) {
      return _i34.PortfolioValuation.fromJson(data) as T;
    }
    if (t == _i35.PriceCache) {
      return _i35.PriceCache.fromJson(data) as T;
    }
    if (t == _i36.ReturnPeriod) {
      return _i36.ReturnPeriod.fromJson(data) as T;
    }
    if (t == _i37.Sleeve) {
      return _i37.Sleeve.fromJson(data) as T;
    }
    if (t == _i38.SleeveAllocation) {
      return _i38.SleeveAllocation.fromJson(data) as T;
    }
    if (t == _i39.SleeveAsset) {
      return _i39.SleeveAsset.fromJson(data) as T;
    }
    if (t == _i40.SleeveNode) {
      return _i40.SleeveNode.fromJson(data) as T;
    }
    if (t == _i41.SleeveTreeResponse) {
      return _i41.SleeveTreeResponse.fromJson(data) as T;
    }
    if (t == _i42.StalePriceAsset) {
      return _i42.StalePriceAsset.fromJson(data) as T;
    }
    if (t == _i43.TickerMetadata) {
      return _i43.TickerMetadata.fromJson(data) as T;
    }
    if (t == _i44.YahooSymbol) {
      return _i44.YahooSymbol.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AllocationStatus?>()) {
      return (data != null ? _i5.AllocationStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Asset?>()) {
      return (data != null ? _i6.Asset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.AssetPeriodReturn?>()) {
      return (data != null ? _i7.AssetPeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.AssetType?>()) {
      return (data != null ? _i8.AssetType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.AssetValuation?>()) {
      return (data != null ? _i9.AssetValuation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Band?>()) {
      return (data != null ? _i10.Band.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.BandConfig?>()) {
      return (data != null ? _i11.BandConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ChartDataPoint?>()) {
      return (data != null ? _i12.ChartDataPoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ChartDataResult?>()) {
      return (data != null ? _i13.ChartDataResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ChartRange?>()) {
      return (data != null ? _i14.ChartRange.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ConcentrationViolation?>()) {
      return (data != null ? _i15.ConcentrationViolation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DailyPrice?>()) {
      return (data != null ? _i16.DailyPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.DividendEvent?>()) {
      return (data != null ? _i17.DividendEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.FxCache?>()) {
      return (data != null ? _i18.FxCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.GlobalCash?>()) {
      return (data != null ? _i19.GlobalCash.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.HistoricalReturnsResult?>()) {
      return (data != null ? _i20.HistoricalReturnsResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i21.Holding?>()) {
      return (data != null ? _i21.Holding.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.HoldingResponse?>()) {
      return (data != null ? _i22.HoldingResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.HoldingsListResponse?>()) {
      return (data != null ? _i23.HoldingsListResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.IntradayPrice?>()) {
      return (data != null ? _i24.IntradayPrice.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.Issue?>()) {
      return (data != null ? _i25.Issue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.IssueSeverity?>()) {
      return (data != null ? _i26.IssueSeverity.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.IssueType?>()) {
      return (data != null ? _i27.IssueType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.IssuesResponse?>()) {
      return (data != null ? _i28.IssuesResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.MissingSymbolAsset?>()) {
      return (data != null ? _i29.MissingSymbolAsset.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.Order?>()) {
      return (data != null ? _i30.Order.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.PeriodReturn?>()) {
      return (data != null ? _i31.PeriodReturn.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.Portfolio?>()) {
      return (data != null ? _i32.Portfolio.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.PortfolioRule?>()) {
      return (data != null ? _i33.PortfolioRule.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.PortfolioValuation?>()) {
      return (data != null ? _i34.PortfolioValuation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.PriceCache?>()) {
      return (data != null ? _i35.PriceCache.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.ReturnPeriod?>()) {
      return (data != null ? _i36.ReturnPeriod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.Sleeve?>()) {
      return (data != null ? _i37.Sleeve.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.SleeveAllocation?>()) {
      return (data != null ? _i38.SleeveAllocation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.SleeveAsset?>()) {
      return (data != null ? _i39.SleeveAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.SleeveNode?>()) {
      return (data != null ? _i40.SleeveNode.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.SleeveTreeResponse?>()) {
      return (data != null ? _i41.SleeveTreeResponse.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i42.StalePriceAsset?>()) {
      return (data != null ? _i42.StalePriceAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.TickerMetadata?>()) {
      return (data != null ? _i43.TickerMetadata.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.YahooSymbol?>()) {
      return (data != null ? _i44.YahooSymbol.fromJson(data) : null) as T;
    }
    if (t == List<_i12.ChartDataPoint>) {
      return (data as List)
              .map((e) => deserialize<_i12.ChartDataPoint>(e))
              .toList()
          as T;
    }
    if (t == Map<String, _i31.PeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i31.PeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, Map<String, _i7.AssetPeriodReturn>>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<Map<String, _i7.AssetPeriodReturn>>(v),
            ),
          )
          as T;
    }
    if (t == Map<String, _i7.AssetPeriodReturn>) {
      return (data as Map).map(
            (k, v) => MapEntry(
              deserialize<String>(k),
              deserialize<_i7.AssetPeriodReturn>(v),
            ),
          )
          as T;
    }
    if (t == List<_i22.HoldingResponse>) {
      return (data as List)
              .map((e) => deserialize<_i22.HoldingResponse>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.Issue>) {
      return (data as List).map((e) => deserialize<_i25.Issue>(e)).toList()
          as T;
    }
    if (t == List<_i38.SleeveAllocation>) {
      return (data as List)
              .map((e) => deserialize<_i38.SleeveAllocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i9.AssetValuation>) {
      return (data as List)
              .map((e) => deserialize<_i9.AssetValuation>(e))
              .toList()
          as T;
    }
    if (t == List<_i29.MissingSymbolAsset>) {
      return (data as List)
              .map((e) => deserialize<_i29.MissingSymbolAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i42.StalePriceAsset>) {
      return (data as List)
              .map((e) => deserialize<_i42.StalePriceAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.ConcentrationViolation>) {
      return (data as List)
              .map((e) => deserialize<_i15.ConcentrationViolation>(e))
              .toList()
          as T;
    }
    if (t == List<_i40.SleeveNode>) {
      return (data as List).map((e) => deserialize<_i40.SleeveNode>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<_i40.SleeveNode>?>()) {
      return (data != null
              ? (data as List)
                    .map((e) => deserialize<_i40.SleeveNode>(e))
                    .toList()
              : null)
          as T;
    }
    if (t == List<_i45.Portfolio>) {
      return (data as List).map((e) => deserialize<_i45.Portfolio>(e)).toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AllocationStatus => 'AllocationStatus',
      _i6.Asset => 'Asset',
      _i7.AssetPeriodReturn => 'AssetPeriodReturn',
      _i8.AssetType => 'AssetType',
      _i9.AssetValuation => 'AssetValuation',
      _i10.Band => 'Band',
      _i11.BandConfig => 'BandConfig',
      _i12.ChartDataPoint => 'ChartDataPoint',
      _i13.ChartDataResult => 'ChartDataResult',
      _i14.ChartRange => 'ChartRange',
      _i15.ConcentrationViolation => 'ConcentrationViolation',
      _i16.DailyPrice => 'DailyPrice',
      _i17.DividendEvent => 'DividendEvent',
      _i18.FxCache => 'FxCache',
      _i19.GlobalCash => 'GlobalCash',
      _i20.HistoricalReturnsResult => 'HistoricalReturnsResult',
      _i21.Holding => 'Holding',
      _i22.HoldingResponse => 'HoldingResponse',
      _i23.HoldingsListResponse => 'HoldingsListResponse',
      _i24.IntradayPrice => 'IntradayPrice',
      _i25.Issue => 'Issue',
      _i26.IssueSeverity => 'IssueSeverity',
      _i27.IssueType => 'IssueType',
      _i28.IssuesResponse => 'IssuesResponse',
      _i29.MissingSymbolAsset => 'MissingSymbolAsset',
      _i30.Order => 'Order',
      _i31.PeriodReturn => 'PeriodReturn',
      _i32.Portfolio => 'Portfolio',
      _i33.PortfolioRule => 'PortfolioRule',
      _i34.PortfolioValuation => 'PortfolioValuation',
      _i35.PriceCache => 'PriceCache',
      _i36.ReturnPeriod => 'ReturnPeriod',
      _i37.Sleeve => 'Sleeve',
      _i38.SleeveAllocation => 'SleeveAllocation',
      _i39.SleeveAsset => 'SleeveAsset',
      _i40.SleeveNode => 'SleeveNode',
      _i41.SleeveTreeResponse => 'SleeveTreeResponse',
      _i42.StalePriceAsset => 'StalePriceAsset',
      _i43.TickerMetadata => 'TickerMetadata',
      _i44.YahooSymbol => 'YahooSymbol',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('bagholdr.', '');
    }

    switch (data) {
      case _i5.AllocationStatus():
        return 'AllocationStatus';
      case _i6.Asset():
        return 'Asset';
      case _i7.AssetPeriodReturn():
        return 'AssetPeriodReturn';
      case _i8.AssetType():
        return 'AssetType';
      case _i9.AssetValuation():
        return 'AssetValuation';
      case _i10.Band():
        return 'Band';
      case _i11.BandConfig():
        return 'BandConfig';
      case _i12.ChartDataPoint():
        return 'ChartDataPoint';
      case _i13.ChartDataResult():
        return 'ChartDataResult';
      case _i14.ChartRange():
        return 'ChartRange';
      case _i15.ConcentrationViolation():
        return 'ConcentrationViolation';
      case _i16.DailyPrice():
        return 'DailyPrice';
      case _i17.DividendEvent():
        return 'DividendEvent';
      case _i18.FxCache():
        return 'FxCache';
      case _i19.GlobalCash():
        return 'GlobalCash';
      case _i20.HistoricalReturnsResult():
        return 'HistoricalReturnsResult';
      case _i21.Holding():
        return 'Holding';
      case _i22.HoldingResponse():
        return 'HoldingResponse';
      case _i23.HoldingsListResponse():
        return 'HoldingsListResponse';
      case _i24.IntradayPrice():
        return 'IntradayPrice';
      case _i25.Issue():
        return 'Issue';
      case _i26.IssueSeverity():
        return 'IssueSeverity';
      case _i27.IssueType():
        return 'IssueType';
      case _i28.IssuesResponse():
        return 'IssuesResponse';
      case _i29.MissingSymbolAsset():
        return 'MissingSymbolAsset';
      case _i30.Order():
        return 'Order';
      case _i31.PeriodReturn():
        return 'PeriodReturn';
      case _i32.Portfolio():
        return 'Portfolio';
      case _i33.PortfolioRule():
        return 'PortfolioRule';
      case _i34.PortfolioValuation():
        return 'PortfolioValuation';
      case _i35.PriceCache():
        return 'PriceCache';
      case _i36.ReturnPeriod():
        return 'ReturnPeriod';
      case _i37.Sleeve():
        return 'Sleeve';
      case _i38.SleeveAllocation():
        return 'SleeveAllocation';
      case _i39.SleeveAsset():
        return 'SleeveAsset';
      case _i40.SleeveNode():
        return 'SleeveNode';
      case _i41.SleeveTreeResponse():
        return 'SleeveTreeResponse';
      case _i42.StalePriceAsset():
        return 'StalePriceAsset';
      case _i43.TickerMetadata():
        return 'TickerMetadata';
      case _i44.YahooSymbol():
        return 'YahooSymbol';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AllocationStatus') {
      return deserialize<_i5.AllocationStatus>(data['data']);
    }
    if (dataClassName == 'Asset') {
      return deserialize<_i6.Asset>(data['data']);
    }
    if (dataClassName == 'AssetPeriodReturn') {
      return deserialize<_i7.AssetPeriodReturn>(data['data']);
    }
    if (dataClassName == 'AssetType') {
      return deserialize<_i8.AssetType>(data['data']);
    }
    if (dataClassName == 'AssetValuation') {
      return deserialize<_i9.AssetValuation>(data['data']);
    }
    if (dataClassName == 'Band') {
      return deserialize<_i10.Band>(data['data']);
    }
    if (dataClassName == 'BandConfig') {
      return deserialize<_i11.BandConfig>(data['data']);
    }
    if (dataClassName == 'ChartDataPoint') {
      return deserialize<_i12.ChartDataPoint>(data['data']);
    }
    if (dataClassName == 'ChartDataResult') {
      return deserialize<_i13.ChartDataResult>(data['data']);
    }
    if (dataClassName == 'ChartRange') {
      return deserialize<_i14.ChartRange>(data['data']);
    }
    if (dataClassName == 'ConcentrationViolation') {
      return deserialize<_i15.ConcentrationViolation>(data['data']);
    }
    if (dataClassName == 'DailyPrice') {
      return deserialize<_i16.DailyPrice>(data['data']);
    }
    if (dataClassName == 'DividendEvent') {
      return deserialize<_i17.DividendEvent>(data['data']);
    }
    if (dataClassName == 'FxCache') {
      return deserialize<_i18.FxCache>(data['data']);
    }
    if (dataClassName == 'GlobalCash') {
      return deserialize<_i19.GlobalCash>(data['data']);
    }
    if (dataClassName == 'HistoricalReturnsResult') {
      return deserialize<_i20.HistoricalReturnsResult>(data['data']);
    }
    if (dataClassName == 'Holding') {
      return deserialize<_i21.Holding>(data['data']);
    }
    if (dataClassName == 'HoldingResponse') {
      return deserialize<_i22.HoldingResponse>(data['data']);
    }
    if (dataClassName == 'HoldingsListResponse') {
      return deserialize<_i23.HoldingsListResponse>(data['data']);
    }
    if (dataClassName == 'IntradayPrice') {
      return deserialize<_i24.IntradayPrice>(data['data']);
    }
    if (dataClassName == 'Issue') {
      return deserialize<_i25.Issue>(data['data']);
    }
    if (dataClassName == 'IssueSeverity') {
      return deserialize<_i26.IssueSeverity>(data['data']);
    }
    if (dataClassName == 'IssueType') {
      return deserialize<_i27.IssueType>(data['data']);
    }
    if (dataClassName == 'IssuesResponse') {
      return deserialize<_i28.IssuesResponse>(data['data']);
    }
    if (dataClassName == 'MissingSymbolAsset') {
      return deserialize<_i29.MissingSymbolAsset>(data['data']);
    }
    if (dataClassName == 'Order') {
      return deserialize<_i30.Order>(data['data']);
    }
    if (dataClassName == 'PeriodReturn') {
      return deserialize<_i31.PeriodReturn>(data['data']);
    }
    if (dataClassName == 'Portfolio') {
      return deserialize<_i32.Portfolio>(data['data']);
    }
    if (dataClassName == 'PortfolioRule') {
      return deserialize<_i33.PortfolioRule>(data['data']);
    }
    if (dataClassName == 'PortfolioValuation') {
      return deserialize<_i34.PortfolioValuation>(data['data']);
    }
    if (dataClassName == 'PriceCache') {
      return deserialize<_i35.PriceCache>(data['data']);
    }
    if (dataClassName == 'ReturnPeriod') {
      return deserialize<_i36.ReturnPeriod>(data['data']);
    }
    if (dataClassName == 'Sleeve') {
      return deserialize<_i37.Sleeve>(data['data']);
    }
    if (dataClassName == 'SleeveAllocation') {
      return deserialize<_i38.SleeveAllocation>(data['data']);
    }
    if (dataClassName == 'SleeveAsset') {
      return deserialize<_i39.SleeveAsset>(data['data']);
    }
    if (dataClassName == 'SleeveNode') {
      return deserialize<_i40.SleeveNode>(data['data']);
    }
    if (dataClassName == 'SleeveTreeResponse') {
      return deserialize<_i41.SleeveTreeResponse>(data['data']);
    }
    if (dataClassName == 'StalePriceAsset') {
      return deserialize<_i42.StalePriceAsset>(data['data']);
    }
    if (dataClassName == 'TickerMetadata') {
      return deserialize<_i43.TickerMetadata>(data['data']);
    }
    if (dataClassName == 'YahooSymbol') {
      return deserialize<_i44.YahooSymbol>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6.Asset:
        return _i6.Asset.t;
      case _i16.DailyPrice:
        return _i16.DailyPrice.t;
      case _i17.DividendEvent:
        return _i17.DividendEvent.t;
      case _i18.FxCache:
        return _i18.FxCache.t;
      case _i19.GlobalCash:
        return _i19.GlobalCash.t;
      case _i21.Holding:
        return _i21.Holding.t;
      case _i24.IntradayPrice:
        return _i24.IntradayPrice.t;
      case _i30.Order:
        return _i30.Order.t;
      case _i32.Portfolio:
        return _i32.Portfolio.t;
      case _i33.PortfolioRule:
        return _i33.PortfolioRule.t;
      case _i35.PriceCache:
        return _i35.PriceCache.t;
      case _i37.Sleeve:
        return _i37.Sleeve.t;
      case _i39.SleeveAsset:
        return _i39.SleeveAsset.t;
      case _i43.TickerMetadata:
        return _i43.TickerMetadata.t;
      case _i44.YahooSymbol:
        return _i44.YahooSymbol.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'bagholdr';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
