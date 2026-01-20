/// Import migration data from SQLite export JSON into Serverpod/PostgreSQL
///
/// Run: dart bin/import_migration.dart ../../../server/migration-export.json
///
/// Prerequisites:
/// 1. Run the TypeScript export: cd server && npx tsx src/migration/export-to-json.ts
/// 2. Start the Serverpod server with migrations: dart bin/main.dart --apply-migrations
/// 3. Then run this script to import the data

import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:bagholdr_server/src/generated/endpoints.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';
// Import Order with prefix to avoid collision with Serverpod's Order
import 'package:bagholdr_server/src/generated/order.dart' as bagholdr;

// ID mapping tables
final Map<String, UuidValue> portfolioIdMap = {};
final Map<String, UuidValue> assetIsinToIdMap = {};
final Map<String, UuidValue> sleeveIdMap = {};

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart bin/import_migration.dart <path-to-migration-export.json>');
    exit(1);
  }

  final jsonPath = args[0];
  final file = File(jsonPath);

  if (!file.existsSync()) {
    print('Error: File not found: $jsonPath');
    exit(1);
  }

  print('Reading migration data from: $jsonPath');
  final jsonString = file.readAsStringSync();
  final data = jsonDecode(jsonString) as Map<String, dynamic>;

  print('Export date: ${data['exportedAt']}');
  print('');

  // Initialize Serverpod
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  await pod.start(runInGuardedZone: false);
  final session = await pod.createSession();

  try {
    // Check if data already exists
    final existingPortfolios = await Portfolio.db.count(session);
    if (existingPortfolios > 0) {
      print('WARNING: Database already contains $existingPortfolios portfolios.');
      print('Do you want to continue? This may create duplicates. (y/N)');
      final answer = stdin.readLineSync()?.toLowerCase();
      if (answer != 'y') {
        print('Aborted.');
        exit(0);
      }
    }

    final tables = data['tables'] as Map<String, dynamic>;

    // Import in dependency order
    await _importPortfolios(session, tables['portfolios'] as List<dynamic>);
    await _importAssets(session, tables['assets'] as List<dynamic>);
    await _importSleeves(session, tables['sleeves'] as List<dynamic>);
    await _importHoldings(session, tables['holdings'] as List<dynamic>);
    await _importOrders(session, tables['orders'] as List<dynamic>);
    await _importSleeveAssets(session, tables['sleeveAssets'] as List<dynamic>);
    await _importGlobalCash(session, tables['globalCash'] as List<dynamic>);
    await _importDailyPrices(session, tables['dailyPrices'] as List<dynamic>);
    await _importYahooSymbols(session, tables['yahooSymbols'] as List<dynamic>);
    await _importPortfolioRules(session, tables['portfolioRules'] as List<dynamic>);
    await _importPriceCache(session, tables['priceCache'] as List<dynamic>);
    await _importFxCache(session, tables['fxCache'] as List<dynamic>);
    await _importTickerMetadata(session, tables['tickerMetadata'] as List<dynamic>);
    await _importDividendEvents(session, tables['dividendEvents'] as List<dynamic>);
    await _importIntradayPrices(session, tables['intradayPrices'] as List<dynamic>);

    print('');
    print('Migration complete!');
  } catch (e, stack) {
    print('Error during migration: $e');
    print(stack);
    exit(1);
  } finally {
    await session.close();
    await pod.shutdown();
  }
}

DateTime _unixToDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  final seconds = value as int;
  return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
}

Future<void> _importPortfolios(Session session, List<dynamic> rows) async {
  print('Importing portfolios: ${rows.length} rows');

  for (final row in rows) {
    final portfolio = Portfolio(
      name: row['name'] as String,
      bandRelativeTolerance: (row['band_relative_tolerance'] as num).toDouble(),
      bandAbsoluteFloor: (row['band_absolute_floor'] as num).toDouble(),
      bandAbsoluteCap: (row['band_absolute_cap'] as num).toDouble(),
      createdAt: _unixToDateTime(row['created_at']),
      updatedAt: _unixToDateTime(row['updated_at']),
    );

    final inserted = await Portfolio.db.insertRow(session, portfolio);
    portfolioIdMap[row['id'] as String] = inserted.id!;
    print('  - ${inserted.name} -> ${inserted.id}');
  }
}

Future<void> _importAssets(Session session, List<dynamic> rows) async {
  print('Importing assets: ${rows.length} rows');

  for (final row in rows) {
    final assetTypeStr = row['asset_type'] as String;
    final assetType = AssetType.values.firstWhere(
      (e) => e.name == assetTypeStr,
      orElse: () => AssetType.other,
    );

    final asset = Asset(
      isin: row['isin'] as String,
      ticker: row['ticker'] as String,
      name: row['name'] as String,
      description: row['description'] as String?,
      assetType: assetType,
      currency: row['currency'] as String,
      yahooSymbol: row['yahoo_symbol'] as String?,
      metadata: row['metadata'] as String?,
      archived: (row['archived'] as int? ?? 0) == 1,
    );

    final inserted = await Asset.db.insertRow(session, asset);
    assetIsinToIdMap[row['isin'] as String] = inserted.id!;
  }

  print('  Done');
}

Future<void> _importSleeves(Session session, List<dynamic> rows) async {
  print('Importing sleeves: ${rows.length} rows');

  // First pass: insert all sleeves without parent references
  // Second pass: update parent references
  final toUpdate = <String, String>{};

  for (final row in rows) {
    final oldPortfolioId = row['portfolio_id'] as String;
    final newPortfolioId = portfolioIdMap[oldPortfolioId];

    if (newPortfolioId == null) {
      print('  WARNING: Portfolio not found for sleeve ${row['name']}');
      continue;
    }

    final sleeve = Sleeve(
      portfolioId: newPortfolioId,
      parentSleeveId: null, // Set in second pass
      name: row['name'] as String,
      budgetPercent: (row['budget_percent'] as num).toDouble(),
      sortOrder: row['sort_order'] as int,
      isCash: (row['is_cash'] as int? ?? 0) == 1,
    );

    final inserted = await Sleeve.db.insertRow(session, sleeve);
    sleeveIdMap[row['id'] as String] = inserted.id!;

    final oldParentId = row['parent_sleeve_id'] as String?;
    if (oldParentId != null) {
      toUpdate[row['id'] as String] = oldParentId;
    }
  }

  // Second pass: update parent references
  for (final entry in toUpdate.entries) {
    final sleeveId = sleeveIdMap[entry.key]!;
    final parentId = sleeveIdMap[entry.value];

    if (parentId != null) {
      await Sleeve.db.updateById(
        session,
        sleeveId,
        columnValues: (t) => [t.parentSleeveId(parentId)],
      );
    }
  }

  print('  Done');
}

Future<void> _importHoldings(Session session, List<dynamic> rows) async {
  print('Importing holdings: ${rows.length} rows');

  for (final row in rows) {
    final assetIsin = row['asset_isin'] as String;
    final assetId = assetIsinToIdMap[assetIsin];

    if (assetId == null) {
      print('  WARNING: Asset not found for holding: $assetIsin');
      continue;
    }

    final holding = Holding(
      assetId: assetId,
      quantity: (row['quantity'] as num).toDouble(),
      totalCostEur: (row['total_cost_eur'] as num).toDouble(),
    );

    await Holding.db.insertRow(session, holding);
  }

  print('  Done');
}

Future<void> _importOrders(Session session, List<dynamic> rows) async {
  print('Importing orders: ${rows.length} rows');

  for (final row in rows) {
    final assetIsin = row['asset_isin'] as String;
    final assetId = assetIsinToIdMap[assetIsin];

    if (assetId == null) {
      print('  WARNING: Asset not found for order: $assetIsin');
      continue;
    }

    final order = bagholdr.Order(
      assetId: assetId,
      orderDate: _unixToDateTime(row['order_date']),
      quantity: (row['quantity'] as num?)?.toDouble() ?? 0.0,
      priceNative: (row['price_native'] as num?)?.toDouble() ?? 0.0,
      totalNative: (row['total_native'] as num?)?.toDouble() ?? 0.0,
      totalEur: (row['total_eur'] as num?)?.toDouble() ?? 0.0,
      currency: row['currency'] as String,
      orderReference: row['order_reference'] as String?,
      importedAt: _unixToDateTime(row['imported_at']),
    );

    await bagholdr.Order.db.insertRow(session, order);
  }

  print('  Done');
}

Future<void> _importSleeveAssets(Session session, List<dynamic> rows) async {
  print('Importing sleeve_assets: ${rows.length} rows');

  for (final row in rows) {
    final oldSleeveId = row['sleeve_id'] as String;
    final assetIsin = row['asset_isin'] as String;

    final sleeveId = sleeveIdMap[oldSleeveId];
    final assetId = assetIsinToIdMap[assetIsin];

    if (sleeveId == null) {
      print('  WARNING: Sleeve not found: $oldSleeveId');
      continue;
    }
    if (assetId == null) {
      print('  WARNING: Asset not found: $assetIsin');
      continue;
    }

    final sleeveAsset = SleeveAsset(
      sleeveId: sleeveId,
      assetId: assetId,
    );

    await SleeveAsset.db.insertRow(session, sleeveAsset);
  }

  print('  Done');
}

Future<void> _importGlobalCash(Session session, List<dynamic> rows) async {
  print('Importing global_cash: ${rows.length} rows');

  for (final row in rows) {
    final globalCash = GlobalCash(
      cashId: row['id'] as String,
      amountEur: (row['amount_eur'] as num).toDouble(),
      updatedAt: _unixToDateTime(row['updated_at']),
    );

    await GlobalCash.db.insertRow(session, globalCash);
  }

  print('  Done');
}

Future<void> _importDailyPrices(Session session, List<dynamic> rows) async {
  print('Importing daily_prices: ${rows.length} rows');

  // Batch insert for performance
  const batchSize = 500;
  var count = 0;

  for (var i = 0; i < rows.length; i += batchSize) {
    final batch = rows.skip(i).take(batchSize).map((row) {
      return DailyPrice(
        ticker: row['ticker'] as String,
        date: row['date'] as String,
        open: (row['open'] as num).toDouble(),
        high: (row['high'] as num).toDouble(),
        low: (row['low'] as num).toDouble(),
        close: (row['close'] as num).toDouble(),
        adjClose: (row['adj_close'] as num).toDouble(),
        volume: row['volume'] as int,
        currency: row['currency'] as String,
        fetchedAt: _unixToDateTime(row['fetched_at']),
      );
    }).toList();

    await DailyPrice.db.insert(session, batch);
    count += batch.length;

    // Progress indicator
    if (count % 5000 == 0 || count == rows.length) {
      print('  Progress: $count/${rows.length}');
    }
  }

  print('  Done');
}

Future<void> _importYahooSymbols(Session session, List<dynamic> rows) async {
  print('Importing yahoo_symbols: ${rows.length} rows');

  for (final row in rows) {
    final assetIsin = row['asset_isin'] as String;
    final assetId = assetIsinToIdMap[assetIsin];

    if (assetId == null) {
      print('  WARNING: Asset not found for yahoo_symbol: $assetIsin');
      continue;
    }

    final yahooSymbol = YahooSymbol(
      assetId: assetId,
      symbol: row['symbol'] as String,
      exchange: row['exchange'] as String?,
      exchangeDisplay: row['exchange_display'] as String?,
      quoteType: row['quote_type'] as String?,
      resolvedAt: _unixToDateTime(row['resolved_at']),
    );

    await YahooSymbol.db.insertRow(session, yahooSymbol);
  }

  print('  Done');
}

Future<void> _importPortfolioRules(Session session, List<dynamic> rows) async {
  print('Importing portfolio_rules: ${rows.length} rows');

  for (final row in rows) {
    final oldPortfolioId = row['portfolio_id'] as String;
    final portfolioId = portfolioIdMap[oldPortfolioId];

    if (portfolioId == null) {
      print('  WARNING: Portfolio not found for rule');
      continue;
    }

    final rule = PortfolioRule(
      portfolioId: portfolioId,
      ruleType: row['rule_type'] as String,
      name: row['name'] as String,
      config: row['config'] as String?,
      enabled: (row['enabled'] as int? ?? 1) == 1,
      createdAt: _unixToDateTime(row['created_at']),
    );

    await PortfolioRule.db.insertRow(session, rule);
  }

  print('  Done');
}

Future<void> _importPriceCache(Session session, List<dynamic> rows) async {
  print('Importing price_cache: ${rows.length} rows');

  for (final row in rows) {
    final priceCache = PriceCache(
      ticker: row['ticker'] as String,
      priceNative: (row['price_native'] as num).toDouble(),
      currency: row['currency'] as String,
      priceEur: (row['price_eur'] as num).toDouble(),
      fetchedAt: _unixToDateTime(row['fetched_at']),
    );

    await PriceCache.db.insertRow(session, priceCache);
  }

  print('  Done');
}

Future<void> _importFxCache(Session session, List<dynamic> rows) async {
  print('Importing fx_cache: ${rows.length} rows');

  for (final row in rows) {
    final fxCache = FxCache(
      pair: row['pair'] as String,
      rate: (row['rate'] as num).toDouble(),
      fetchedAt: _unixToDateTime(row['fetched_at']),
    );

    await FxCache.db.insertRow(session, fxCache);
  }

  print('  Done');
}

Future<void> _importTickerMetadata(Session session, List<dynamic> rows) async {
  print('Importing ticker_metadata: ${rows.length} rows');

  for (final row in rows) {
    final tickerMeta = TickerMetadata(
      ticker: row['ticker'] as String,
      lastDailyDate: row['last_daily_date'] as String?,
      lastSyncedAt: row['last_synced_at'] != null
          ? _unixToDateTime(row['last_synced_at'])
          : null,
      lastIntradaySyncedAt: row['last_intraday_synced_at'] != null
          ? _unixToDateTime(row['last_intraday_synced_at'])
          : null,
      isActive: (row['is_active'] as int? ?? 1) == 1,
    );

    await TickerMetadata.db.insertRow(session, tickerMeta);
  }

  print('  Done');
}

Future<void> _importDividendEvents(Session session, List<dynamic> rows) async {
  print('Importing dividend_events: ${rows.length} rows');

  for (final row in rows) {
    final dividendEvent = DividendEvent(
      ticker: row['ticker'] as String,
      exDate: row['ex_date'] as String,
      amount: (row['amount'] as num).toDouble(),
      currency: row['currency'] as String,
      fetchedAt: _unixToDateTime(row['fetched_at']),
    );

    await DividendEvent.db.insertRow(session, dividendEvent);
  }

  print('  Done');
}

Future<void> _importIntradayPrices(Session session, List<dynamic> rows) async {
  print('Importing intraday_prices: ${rows.length} rows');

  // Batch insert for performance
  const batchSize = 500;
  var count = 0;

  for (var i = 0; i < rows.length; i += batchSize) {
    final batch = rows.skip(i).take(batchSize).map((row) {
      return IntradayPrice(
        ticker: row['ticker'] as String,
        timestamp: row['timestamp'] as int,
        open: (row['open'] as num).toDouble(),
        high: (row['high'] as num).toDouble(),
        low: (row['low'] as num).toDouble(),
        close: (row['close'] as num).toDouble(),
        volume: row['volume'] as int,
        currency: row['currency'] as String,
        fetchedAt: _unixToDateTime(row['fetched_at']),
      );
    }).toList();

    await IntradayPrice.db.insert(session, batch);
    count += batch.length;

    // Progress indicator
    if (count % 2000 == 0 || count == rows.length) {
      print('  Progress: $count/${rows.length}');
    }
  }

  print('  Done');
}
