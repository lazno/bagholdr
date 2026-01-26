import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../import/derive_holdings.dart';
import '../import/directa_parser.dart';

/// Endpoint for importing orders from broker CSV files.
///
/// Parses CSV content, creates assets and orders, and derives holdings.
class ImportEndpoint extends Endpoint {
  /// Import orders from Directa CSV content.
  ///
  /// [csvContent] - The raw CSV content from Directa export
  ///
  /// Returns an [ImportResult] with counts and any errors encountered.
  Future<ImportResult> importDirectaCsv(
    Session session, {
    required String csvContent,
  }) async {
    final warnings = <String>[];

    // Parse CSV
    final parseResult = parseDirectaCSV(csvContent);

    // Convert parse errors to strings
    final errors = parseResult.errors.map((e) => e.toString()).toList();

    if (parseResult.orders.isEmpty && errors.isNotEmpty) {
      // No orders parsed - return early with errors
      return ImportResult(
        ordersImported: 0,
        rowsSkipped: parseResult.skippedRows,
        assetsCreated: 0,
        holdingsUpdated: 0,
        errors: errors,
        warnings: warnings,
      );
    }

    // Get existing assets by ISIN for lookup
    final existingAssets = await Asset.db.find(session);
    final assetByIsin = {for (var a in existingAssets) a.isin: a};

    var assetsCreated = 0;
    var ordersImported = 0;
    var ordersReplaced = 0;

    // Collect all order references from this import run
    final orderRefsInImport = parseResult.orders
        .where((o) => o.orderReference.isNotEmpty)
        .map((o) => o.orderReference)
        .toSet();

    // Delete existing orders with these references (allows corrections and
    // handles multiple partial fills with the same reference)
    for (final ref in orderRefsInImport) {
      final deleted = await Order.db.deleteWhere(
        session,
        where: (t) => t.orderReference.equals(ref),
      );
      ordersReplaced += deleted.length;
    }

    if (ordersReplaced > 0) {
      warnings.add('Replaced $ordersReplaced existing orders');
    }

    // Process each parsed order (no deduplication within a single import run)
    for (final parsedOrder in parseResult.orders) {
      // Find or create asset
      var asset = assetByIsin[parsedOrder.isin];
      if (asset == null) {
        // Create new asset
        asset = Asset(
          isin: parsedOrder.isin,
          ticker: parsedOrder.ticker,
          name: parsedOrder.name,
          assetType: AssetType.stock, // Default, can be changed later
          currency: parsedOrder.currency,
          archived: false,
        );
        asset = await Asset.db.insertRow(session, asset);
        assetByIsin[parsedOrder.isin] = asset;
        assetsCreated++;
      }

      // Calculate total values
      // Directa: currencyAmount is in native currency, amountEur is in EUR
      // totalNative = currencyAmount if non-zero, else amountEur
      final totalNative = parsedOrder.currencyAmount != 0
          ? parsedOrder.currencyAmount
          : parsedOrder.amountEur;
      final totalEur = parsedOrder.amountEur;

      // Calculate price per unit (avoid division by zero)
      final priceNative = parsedOrder.quantity != 0
          ? totalNative / parsedOrder.quantity.abs()
          : 0.0;

      // Create order
      final order = Order(
        assetId: asset.id!,
        orderDate: parsedOrder.transactionDate,
        quantity: parsedOrder.quantity,
        priceNative: priceNative,
        totalNative: totalNative,
        totalEur: totalEur,
        currency: parsedOrder.currency,
        orderReference:
            parsedOrder.orderReference.isEmpty ? null : parsedOrder.orderReference,
        importedAt: DateTime.now(),
      );
      await Order.db.insertRow(session, order);
      ordersImported++;
    }

    // Derive holdings from ALL orders (not just imported ones)
    final allOrders = await Order.db.find(
      session,
      orderBy: (t) => t.orderDate,
    );

    // Get all assets for ISIN lookup
    final allAssets = await Asset.db.find(session);
    final assetById = {for (var a in allAssets) a.id!.toString(): a};

    // Convert DB orders to OrderForDerivation
    final ordersForDerivation = allOrders.map((o) {
      final asset = assetById[o.assetId.toString()];
      return OrderForDerivation(
        assetIsin: asset?.isin ?? '',
        orderDate: o.orderDate,
        quantity: o.quantity,
        totalEur: o.totalEur,
        totalNative: o.totalNative,
      );
    }).toList();

    // Derive holdings
    final derivedHoldings = deriveHoldings(ordersForDerivation);

    // Upsert holdings
    var holdingsUpdated = 0;
    final assetByIsinForHoldings = {for (var a in allAssets) a.isin: a};

    for (final derived in derivedHoldings) {
      final asset = assetByIsinForHoldings[derived.assetIsin];
      if (asset == null) {
        warnings.add('Asset not found for ISIN: ${derived.assetIsin}');
        continue;
      }

      // Find existing holding
      final existingHolding = await Holding.db.findFirstRow(
        session,
        where: (t) => t.assetId.equals(asset.id!),
      );

      if (existingHolding != null) {
        // Update existing holding
        existingHolding.quantity = derived.quantity;
        existingHolding.totalCostEur = derived.totalCostEur;
        await Holding.db.updateRow(session, existingHolding);
      } else {
        // Create new holding
        final holding = Holding(
          assetId: asset.id!,
          quantity: derived.quantity,
          totalCostEur: derived.totalCostEur,
        );
        await Holding.db.insertRow(session, holding);
      }
      holdingsUpdated++;
    }

    // Delete holdings for assets that no longer have positions
    final derivedIsins = derivedHoldings.map((h) => h.assetIsin).toSet();
    final existingHoldings = await Holding.db.find(session);
    for (final holding in existingHoldings) {
      final asset = assetById[holding.assetId.toString()];
      if (asset != null && !derivedIsins.contains(asset.isin)) {
        await Holding.db.deleteRow(session, holding);
      }
    }

    return ImportResult(
      ordersImported: ordersImported,
      rowsSkipped: parseResult.skippedRows,
      assetsCreated: assetsCreated,
      holdingsUpdated: holdingsUpdated,
      errors: errors,
      warnings: warnings,
    );
  }
}
