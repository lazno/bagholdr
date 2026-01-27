import 'dart:math' as math;
import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../services/asset_returns_calculator.dart';

/// Endpoint for holdings/assets list data.
///
/// Returns holdings data for the Assets section of the dashboard.
/// Supports filtering by sleeve (hierarchical), search, and pagination.
/// Calculates MWR and TWR returns for each holding for the selected period.
class HoldingsEndpoint extends Endpoint {
  /// Get paginated holdings list with return calculations
  ///
  /// [portfolioId] - Portfolio to fetch holdings for
  /// [period] - Time period for return calculations
  /// [sleeveId] - Optional filter by sleeve (includes children)
  /// [search] - Optional search filter (symbol or name)
  /// [offset] - Pagination offset (default 0)
  /// [limit] - Page size (default 8)
  Future<HoldingsListResponse> getHoldings(
    Session session, {
    required UuidValue portfolioId,
    required ReturnPeriod period,
    UuidValue? sleeveId,
    String? search,
    int offset = 0,
    int limit = 8,
  }) async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // Get all holdings with quantity > 0
    final allHoldings = await Holding.db.find(
      session,
      where: (t) => t.quantity > 0.0,
    );

    // Get all non-archived assets
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetMap = {for (var a in allAssets) a.id!.toString(): a};
    final nonArchivedAssetIds = allAssets.map((a) => a.id!.toString()).toSet();

    // Filter holdings to only include non-archived assets
    final filteredHoldings = allHoldings
        .where((h) => nonArchivedAssetIds.contains(h.assetId.toString()))
        .toList();

    if (filteredHoldings.isEmpty) {
      return HoldingsListResponse(
        holdings: [],
        totalCount: 0,
        filteredCount: 0,
        totalValue: 0,
      );
    }

    // Get cached prices
    final cachedPrices = await PriceCache.db.find(session);
    final priceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};

    // Get all orders for cost basis and MWR calculation
    final allOrders = await Order.db.find(
      session,
      orderBy: (t) => t.orderDate,
    );

    // Get sleeve assignments (an asset can be in multiple sleeves)
    final allAssignments = await SleeveAsset.db.find(session);
    final assetSleeveMap = <String, Set<String>>{};
    for (final assignment in allAssignments) {
      final assetIdStr = assignment.assetId.toString();
      final sleeveIdStr = assignment.sleeveId.toString().toLowerCase();
      assetSleeveMap.putIfAbsent(assetIdStr, () => <String>{}).add(sleeveIdStr);
    }

    // Get sleeves for names and hierarchy
    final allSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
    );
    final sleeveMap = {for (var s in allSleeves) s.id!.toString(): s};

    // Build sleeve hierarchy for filtering
    // Note: Normalize UUIDs to lowercase for consistent comparison
    final descendantSleeveIds = <String>{};
    if (sleeveId != null) {
      final normalizedSleeveId = sleeveId.toString().toLowerCase();
      _collectDescendantSleeveIds(
        normalizedSleeveId,
        sleeveMap,
        descendantSleeveIds,
      );
      descendantSleeveIds.add(normalizedSleeveId);
    }

    // Calculate total portfolio value first (needed for weight calculation)
    double totalPortfolioValue = 0;
    final holdingValues = <String, double>{};

    for (final holding in filteredHoldings) {
      final assetIdStr = holding.assetId.toString();
      final asset = assetMap[assetIdStr];
      if (asset == null) continue;

      final lookupKey = asset.yahooSymbol ?? asset.ticker;
      final cachedPrice = priceMap[lookupKey];
      final valueEur = cachedPrice != null
          ? cachedPrice * holding.quantity
          : holding.totalCostEur;

      holdingValues[assetIdStr] = valueEur;
      totalPortfolioValue += valueEur;
    }

    // Calculate cost basis per asset using Average Cost Method
    final costBasisByAssetId = <String, double>{};
    final ordersByAssetId = <String, List<Order>>{};

    for (final order in allOrders) {
      final assetIdStr = order.assetId.toString();
      if (!nonArchivedAssetIds.contains(assetIdStr)) continue;
      ordersByAssetId.putIfAbsent(assetIdStr, () => []).add(order);
    }

    for (final entry in ordersByAssetId.entries) {
      final assetIdStr = entry.key;
      final assetOrders = List<Order>.from(entry.value)
        ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

      double totalQty = 0;
      double totalCostEur = 0;

      for (final order in assetOrders) {
        if (order.quantity > 0) {
          // BUY: add to cost basis
          totalQty += order.quantity;
          totalCostEur += order.totalEur;
        } else if (order.quantity < 0) {
          // SELL: reduce cost basis proportionally
          final soldQty = order.quantity.abs();
          if (totalQty > 0) {
            final avgCostEur = totalCostEur / totalQty;
            totalCostEur = math.max(0, totalCostEur - avgCostEur * soldQty);
            totalQty = math.max(0, totalQty - soldQty);
          }
        } else {
          // COMMISSION (quantity = 0): add to cost basis
          totalCostEur += order.totalEur;
        }
      }

      costBasisByAssetId[assetIdStr] = totalCostEur;
    }

    // Get historical prices for MWR/TWR calculations
    final comparisonDate = _getComparisonDate(period, allOrders);
    final lookbackDate =
        DateTime.parse(comparisonDate).subtract(const Duration(days: 5));
    final lookbackDateStr = _formatDate(lookbackDate);

    // Build yahoo symbols set
    final yahooSymbols = allAssets
        .where((a) => a.yahooSymbol != null)
        .map((a) => a.yahooSymbol!)
        .toSet();

    // Get historical prices
    final pricesResult = yahooSymbols.isNotEmpty
        ? await DailyPrice.db.find(
            session,
            where: (t) =>
                t.ticker.inSet(yahooSymbols) &
                (t.date >= lookbackDateStr) &
                (t.date <= todayStr),
          )
        : <DailyPrice>[];

    // Build price lookup: ticker -> date -> price
    // Use close (not adjClose) because adjClose is retroactively adjusted for
    // dividends/distributions, creating a mismatch with PriceCache (which stores
    // regularMarketPrice, an unadjusted value) and order totalEur (actual cost).
    final priceByTickerDate = <String, Map<String, double>>{};
    for (final p in pricesResult) {
      priceByTickerDate.putIfAbsent(p.ticker, () => {});
      priceByTickerDate[p.ticker]![p.date] = p.close;
    }

    // Get FX rates and derive FX rates from prices
    final fxRates = await FxCache.db.find(session);
    final fxRateMap = {for (var f in fxRates) f.pair: f.rate};
    final derivedFxRateMap = <String, double>{};
    for (final p in cachedPrices) {
      if (p.priceNative != 0) {
        derivedFxRateMap[p.ticker] = p.priceEur / p.priceNative;
      }
    }

    // Build holdings response list
    final holdingsData = <_HoldingData>[];
    final totalCount = filteredHoldings.length;

    for (final holding in filteredHoldings) {
      final assetIdStr = holding.assetId.toString();
      final asset = assetMap[assetIdStr];
      if (asset == null) continue;

      // Get sleeve info (asset can be in multiple sleeves)
      final holdingSleeveIds = assetSleeveMap[assetIdStr] ?? <String>{};

      // Apply sleeve filter - check if ANY of the asset's sleeves match
      String? matchingSleeveId;
      if (sleeveId != null) {
        // Find the first sleeve that matches the filter
        for (final sid in holdingSleeveIds) {
          if (descendantSleeveIds.contains(sid)) {
            matchingSleeveId = sid;
            break;
          }
        }
        if (matchingSleeveId == null) {
          continue; // Asset not in selected sleeve hierarchy
        }
      } else {
        // No filter - use first sleeve for display
        matchingSleeveId = holdingSleeveIds.isNotEmpty ? holdingSleeveIds.first : null;
      }

      final sleeve = matchingSleeveId != null ? sleeveMap[matchingSleeveId] : null;

      // Apply search filter
      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        final tickerMatch = asset.ticker.toLowerCase().contains(searchLower);
        final nameMatch = asset.name.toLowerCase().contains(searchLower);
        final symbolMatch = asset.yahooSymbol != null &&
            asset.yahooSymbol!.toLowerCase().contains(searchLower);
        if (!tickerMatch && !nameMatch && !symbolMatch) {
          continue;
        }
      }

      // Calculate all return metrics using the centralized calculator
      final assetOrders = ordersByAssetId[assetIdStr] ?? [];
      final returnsResult = AssetReturnsCalculator.calculate(
        asset: asset,
        orders: assetOrders,
        holding: holding,
        period: period,
        comparisonDate: comparisonDate,
        todayStr: todayStr,
        priceMap: priceMap,
        priceByTickerDate: priceByTickerDate,
        derivedFxRateMap: derivedFxRateMap,
        fxRateMap: fxRateMap,
      );

      // Use pre-calculated values for weight (need portfolio-level value)
      final valueEur = holdingValues[assetIdStr] ?? holding.totalCostEur;
      final weight =
          totalPortfolioValue > 0 ? (valueEur / totalPortfolioValue) * 100 : 0.0;

      holdingsData.add(_HoldingData(
        symbol: asset.yahooSymbol ?? asset.ticker,
        name: asset.name,
        isin: asset.isin,
        value: returnsResult.value,
        costBasis: returnsResult.costBasis,
        unrealizedPL: returnsResult.unrealizedPL,
        unrealizedPLPct: returnsResult.unrealizedPLPct,
        weight: weight,
        sleeveId: matchingSleeveId,
        sleeveName: sleeve?.name,
        assetId: assetIdStr,
        quantity: holding.quantity,
      ));
    }

    // Sort by value descending (largest positions first)
    holdingsData.sort((a, b) => b.value.compareTo(a.value));

    final filteredCount = holdingsData.length;

    // Apply pagination
    final paginatedData = holdingsData.skip(offset).take(limit).toList();

    // Convert to response objects
    final holdings = paginatedData
        .map((h) => HoldingResponse(
              symbol: h.symbol,
              name: h.name,
              isin: h.isin,
              value: (h.value * 100).round() / 100,
              costBasis: (h.costBasis * 100).round() / 100,
              unrealizedPL: (h.unrealizedPL * 100).round() / 100,
              unrealizedPLPct: h.unrealizedPLPct != null
                  ? (h.unrealizedPLPct! * 10000).round() / 100
                  : null,
              weight: (h.weight * 100).round() / 100,
              sleeveId: h.sleeveId,
              sleeveName: h.sleeveName,
              assetId: h.assetId,
              quantity: h.quantity,
            ))
        .toList();

    return HoldingsListResponse(
      holdings: holdings,
      totalCount: totalCount,
      filteredCount: filteredCount,
      totalValue: (totalPortfolioValue * 100).round() / 100,
    );
  }

  /// Recursively collect all descendant sleeve IDs (normalized to lowercase)
  void _collectDescendantSleeveIds(
    String parentSleeveId,
    Map<String, Sleeve> sleeveMap,
    Set<String> result,
  ) {
    for (final sleeve in sleeveMap.values) {
      final sleeveParentId = sleeve.parentSleeveId?.toString().toLowerCase();
      if (sleeveParentId == parentSleeveId) {
        final sleeveIdLower = sleeve.id!.toString().toLowerCase();
        result.add(sleeveIdLower);
        _collectDescendantSleeveIds(sleeveIdLower, sleeveMap, result);
      }
    }
  }

  /// Get comparison date for the given period
  String _getComparisonDate(ReturnPeriod period, List<Order> allOrders) {
    final now = DateTime.now();
    final sortedOrders = List<Order>.from(allOrders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));
    final firstOrderDateStr = sortedOrders.isNotEmpty
        ? _formatDate(sortedOrders.first.orderDate)
        : _formatDate(now);

    switch (period) {
      case ReturnPeriod.today:
        return _formatDate(now.subtract(const Duration(days: 1)));
      case ReturnPeriod.oneWeek:
        return _formatDate(now.subtract(const Duration(days: 7)));
      case ReturnPeriod.oneMonth:
        return _formatDate(DateTime(now.year, now.month - 1, now.day));
      case ReturnPeriod.sixMonths:
        return _formatDate(DateTime(now.year, now.month - 6, now.day));
      case ReturnPeriod.ytd:
        return _formatDate(DateTime(now.year - 1, 12, 31));
      case ReturnPeriod.oneYear:
        return _formatDate(DateTime(now.year - 1, now.month, now.day));
      case ReturnPeriod.all:
        return firstOrderDateStr;
    }
  }

  /// Format a DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Get detailed information for a single asset
  ///
  /// [assetId] - UUID of the asset to fetch
  /// [portfolioId] - Portfolio context (for sleeve assignment and weight)
  /// [period] - Time period for return calculations
  Future<AssetDetailResponse> getAssetDetail(
    Session session, {
    required UuidValue assetId,
    required UuidValue portfolioId,
    required ReturnPeriod period,
  }) async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // Fetch the asset
    final asset = await Asset.db.findById(session, assetId);
    if (asset == null) {
      throw Exception('Asset not found: $assetId');
    }

    // Fetch holding for this asset
    final holdings = await Holding.db.find(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    final holding = holdings.isNotEmpty ? holdings.first : null;

    if (holding == null || holding.quantity <= 0) {
      throw Exception('No holding found for asset: $assetId');
    }

    // Fetch all orders for this asset (most recent first)
    final orders = await Order.db.find(
      session,
      where: (t) => t.assetId.equals(assetId),
      orderBy: (t) => t.orderDate,
      orderDescending: true,
    );

    // Get cached price
    final cachedPrices = await PriceCache.db.find(session);
    final priceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};

    // Calculate total portfolio value for weight
    final allHoldings = await Holding.db.find(
      session,
      where: (t) => t.quantity > 0.0,
    );
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetMapLocal = {for (var a in allAssets) a.id!.toString(): a};

    double totalPortfolioValue = 0;
    for (final h in allHoldings) {
      final a = assetMapLocal[h.assetId.toString()];
      if (a == null) continue;
      final key = a.yahooSymbol ?? a.ticker;
      final price = priceMap[key];
      totalPortfolioValue += price != null ? price * h.quantity : h.totalCostEur;
    }

    // Get sleeve assignment
    final sleeveAssignments = await SleeveAsset.db.find(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    String? sleeveId;
    String? sleeveName;

    if (sleeveAssignments.isNotEmpty) {
      final assignment = sleeveAssignments.first;
      sleeveId = assignment.sleeveId.toString();
      final sleeve = await Sleeve.db.findById(session, assignment.sleeveId);
      sleeveName = sleeve?.name;
    }

    // Calculate returns using centralized calculator
    final comparisonDate = _getComparisonDate(period, orders);
    final lookbackDate =
        DateTime.parse(comparisonDate).subtract(const Duration(days: 5));
    final lookbackDateStr = _formatDate(lookbackDate);

    // Get historical prices
    Map<String, Map<String, double>> priceByTickerDate = {};
    if (asset.yahooSymbol != null) {
      final pricesResult = await DailyPrice.db.find(
        session,
        where: (t) =>
            t.ticker.equals(asset.yahooSymbol!) &
            (t.date >= lookbackDateStr) &
            (t.date <= todayStr),
      );
      for (final p in pricesResult) {
        priceByTickerDate.putIfAbsent(p.ticker, () => {});
        priceByTickerDate[p.ticker]![p.date] = p.close;
      }
    }

    // Get FX rates
    final fxRates = await FxCache.db.find(session);
    final fxRateMap = {for (var f in fxRates) f.pair: f.rate};
    final derivedFxRateMap = <String, double>{};
    for (final p in cachedPrices) {
      if (p.priceNative != 0) {
        derivedFxRateMap[p.ticker] = p.priceEur / p.priceNative;
      }
    }

    // Calculate all return metrics using the centralized calculator
    final returnsResult = AssetReturnsCalculator.calculate(
      asset: asset,
      orders: orders,
      holding: holding,
      period: period,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceMap: priceMap,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate weight
    final weight = totalPortfolioValue > 0
        ? (returnsResult.value / totalPortfolioValue) * 100
        : 0.0;

    // Convert orders to OrderSummary list
    final orderSummaries = orders.map((o) {
      String orderType;
      if (o.quantity > 0) {
        orderType = 'buy';
      } else if (o.quantity < 0) {
        orderType = 'sell';
      } else {
        orderType = 'fee';
      }

      return OrderSummary(
        orderDate: o.orderDate,
        orderType: orderType,
        quantity: o.quantity,
        priceNative: o.priceNative,
        totalNative: o.totalNative,
        totalEur: o.totalEur,
        currency: o.currency,
      );
    }).toList();

    return AssetDetailResponse(
      assetId: assetId.toString(),
      isin: asset.isin,
      ticker: asset.ticker,
      name: asset.name,
      yahooSymbol: asset.yahooSymbol,
      assetType: asset.assetType.name,
      currency: asset.currency,
      quantity: holding.quantity,
      value: (returnsResult.value * 100).round() / 100,
      costBasis: (returnsResult.costBasis * 100).round() / 100,
      weight: (weight * 100).round() / 100,
      // Unrealized P/L (paper gain on current holdings)
      unrealizedPL: (returnsResult.unrealizedPL * 100).round() / 100,
      unrealizedPLPct: returnsResult.unrealizedPLPct != null
          ? (returnsResult.unrealizedPLPct! * 10000).round() / 100
          : null,
      // Realized P/L (gains from sales during period)
      realizedPL: (returnsResult.realizedPL * 100).round() / 100,
      // Return metrics
      mwr: (returnsResult.mwr * 10000).round() / 100,
      twr: returnsResult.twr != null ? (returnsResult.twr! * 10000).round() / 100 : null,
      totalReturn: returnsResult.totalReturn != null
          ? (returnsResult.totalReturn! * 10000).round() / 100
          : null,
      sleeveId: sleeveId,
      sleeveName: sleeveName,
      orders: orderSummaries,
    );
  }

  /// Update the Yahoo symbol for an asset
  ///
  /// When the symbol changes, clears all cached price data for the old symbol
  /// to prevent stale data from affecting calculations.
  ///
  /// [assetId] - UUID of the asset to update
  /// [newSymbol] - New Yahoo symbol (null to clear)
  Future<UpdateYahooSymbolResult> updateYahooSymbol(
    Session session, {
    required UuidValue assetId,
    String? newSymbol,
  }) async {
    // 1. Fetch asset
    final asset = await Asset.db.findById(session, assetId);
    if (asset == null) {
      throw Exception('Asset not found: $assetId');
    }

    final oldSymbol = asset.yahooSymbol;
    var dailyCleared = 0;
    var intradayCleared = 0;
    var dividendsCleared = 0;

    // Trim whitespace from new symbol
    final trimmedNewSymbol = newSymbol?.trim();
    final effectiveNewSymbol =
        (trimmedNewSymbol?.isEmpty ?? true) ? null : trimmedNewSymbol;

    // 2. Clear price data if symbol actually changed
    if (oldSymbol != null && oldSymbol != effectiveNewSymbol) {
      final deletedDaily = await DailyPrice.db.deleteWhere(
        session,
        where: (t) => t.ticker.equals(oldSymbol),
      );
      dailyCleared = deletedDaily.length;

      final deletedIntraday = await IntradayPrice.db.deleteWhere(
        session,
        where: (t) => t.ticker.equals(oldSymbol),
      );
      intradayCleared = deletedIntraday.length;

      final deletedDividends = await DividendEvent.db.deleteWhere(
        session,
        where: (t) => t.ticker.equals(oldSymbol),
      );
      dividendsCleared = deletedDividends.length;

      await TickerMetadata.db.deleteWhere(
        session,
        where: (t) => t.ticker.equals(oldSymbol),
      );
      await PriceCache.db.deleteWhere(
        session,
        where: (t) => t.ticker.equals(oldSymbol),
      );
    }

    // 3. Update asset
    asset.yahooSymbol = effectiveNewSymbol;
    await Asset.db.updateRow(session, asset);

    return UpdateYahooSymbolResult(
      success: true,
      newSymbol: effectiveNewSymbol,
      dailyPricesCleared: dailyCleared,
      intradayPricesCleared: intradayCleared,
      dividendsCleared: dividendsCleared,
    );
  }

  /// Get available sleeves for assignment picker
  ///
  /// Returns a flat list of sleeves for the portfolio, with hierarchy
  /// indicated by depth field. Excludes cash sleeves.
  ///
  /// [portfolioId] - Portfolio to fetch sleeves for
  Future<List<SleeveOption>> getSleevesForPicker(
    Session session, {
    required UuidValue portfolioId,
  }) async {
    // Get all non-cash sleeves for this portfolio
    final allSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId) & t.isCash.equals(false),
      orderBy: (t) => t.sortOrder,
    );

    if (allSleeves.isEmpty) {
      return [];
    }

    // Build parent map for hierarchy lookup
    final sleeveMap = {for (var s in allSleeves) s.id!.toString(): s};
    final childrenMap = <String?, List<Sleeve>>{};
    for (final sleeve in allSleeves) {
      final parentId = sleeve.parentSleeveId?.toString();
      childrenMap.putIfAbsent(parentId, () => []).add(sleeve);
    }

    // Build flat list with hierarchy info using DFS
    final result = <SleeveOption>[];

    void addSleeveWithChildren(Sleeve sleeve, int depth, String prefix) {
      final displayName = prefix.isEmpty ? sleeve.name : '$prefix > ${sleeve.name}';
      result.add(SleeveOption(
        id: sleeve.id!.toString(),
        name: displayName,
        depth: depth,
      ));

      // Add children recursively
      final children = childrenMap[sleeve.id!.toString()] ?? [];
      for (final child in children) {
        addSleeveWithChildren(child, depth + 1, displayName);
      }
    }

    // Start with root sleeves (no parent)
    final rootSleeves = childrenMap[null] ?? [];
    for (final sleeve in rootSleeves) {
      addSleeveWithChildren(sleeve, 0, '');
    }

    return result;
  }

  /// Assign or unassign an asset to/from a sleeve
  ///
  /// [assetId] - UUID of the asset to assign
  /// [sleeveId] - UUID of the sleeve to assign to (null to unassign)
  Future<AssignSleeveResult> assignAssetToSleeve(
    Session session, {
    required UuidValue assetId,
    UuidValue? sleeveId,
  }) async {
    // Verify asset exists
    final asset = await Asset.db.findById(session, assetId);
    if (asset == null) {
      throw Exception('Asset not found: $assetId');
    }

    // Delete any existing sleeve assignments for this asset
    await SleeveAsset.db.deleteWhere(
      session,
      where: (t) => t.assetId.equals(assetId),
    );

    // If sleeveId is null, we're done (unassigned)
    if (sleeveId == null) {
      return AssignSleeveResult(
        success: true,
        sleeveId: null,
        sleeveName: null,
      );
    }

    // Verify sleeve exists
    final sleeve = await Sleeve.db.findById(session, sleeveId);
    if (sleeve == null) {
      throw Exception('Sleeve not found: $sleeveId');
    }

    // Create new assignment
    final assignment = SleeveAsset(
      sleeveId: sleeveId,
      assetId: assetId,
    );
    await SleeveAsset.db.insertRow(session, assignment);

    return AssignSleeveResult(
      success: true,
      sleeveId: sleeveId.toString(),
      sleeveName: sleeve.name,
    );
  }
}

/// Internal data class for holding calculations
class _HoldingData {
  final String symbol;
  final String name;
  final String isin;
  final double value;
  final double costBasis;
  final double unrealizedPL;
  final double? unrealizedPLPct;
  final double weight;
  final String? sleeveId;
  final String? sleeveName;
  final String assetId;
  final double quantity;

  const _HoldingData({
    required this.symbol,
    required this.name,
    required this.isin,
    required this.value,
    required this.costBasis,
    required this.unrealizedPL,
    required this.unrealizedPLPct,
    required this.weight,
    required this.sleeveId,
    required this.sleeveName,
    required this.assetId,
    required this.quantity,
  });
}
