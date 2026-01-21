import 'dart:convert';
import 'dart:math' as math;
import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../utils/bands.dart';
import '../utils/returns.dart';

/// Endpoint for portfolio valuation and allocation calculations.
///
/// Calculates portfolio valuation and allocation percentages.
/// Uses cached prices if available, falls back to cost basis.
/// Supports n-ary tree structure for sleeves - parent sleeves include
/// the value of all their descendants.
///
/// Key concepts:
/// - Cash is NOT a sleeve - it's shown separately
/// - "Invested Only" view: percentages relative to assigned holdings only
/// - "Total Portfolio" view: percentages relative to holdings + cash
/// - Band evaluation only applies to Invested view
class ValuationEndpoint extends Endpoint {
  /// Get full portfolio valuation with allocation breakdown
  Future<PortfolioValuation> getPortfolioValuation(
    Session session,
    UuidValue portfolioId,
  ) async {
    // Get portfolio
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found');
    }

    // Build band configuration from portfolio settings
    final bandConfig = BandConfig(
      relativeTolerance: portfolio.bandRelativeTolerance,
      absoluteFloor: portfolio.bandAbsoluteFloor,
      absoluteCap: portfolio.bandAbsoluteCap,
    );

    // Get all holdings with quantity > 0
    final allHoldings = await Holding.db.find(
      session,
      where: (t) => t.quantity > 0,
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

    // Get cached prices - use yahooSymbol for lookup
    final cachedPrices = await PriceCache.db.find(session);
    final priceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};
    final fullPriceMap = {for (var p in cachedPrices) p.ticker: p};

    // Get last sync time from cached prices
    DateTime? lastSyncAt;
    if (cachedPrices.isNotEmpty) {
      lastSyncAt = cachedPrices.fold<DateTime>(
        cachedPrices.first.fetchedAt,
        (latest, p) => p.fetchedAt.isAfter(latest) ? p.fetchedAt : latest,
      );
    }

    // Get portfolio rules for concentration limits
    final rules = await PortfolioRule.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
    );

    // Get global cash
    final cashRow = await GlobalCash.db.findFirstRow(
      session,
      where: (t) => t.cashId.equals('default'),
    );
    final cashEur = cashRow?.amountEur ?? 0;

    // Get all orders to calculate native currency cost basis
    final allOrders = await Order.db.find(session);

    // Calculate native cost basis per asset using Average Cost Method
    final nativeCostByAssetId = <String, double>{};
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
      double totalCostNative = 0;

      for (final order in assetOrders) {
        if (order.quantity > 0) {
          // BUY: add to cost basis
          totalQty += order.quantity;
          totalCostNative += order.totalNative;
        } else if (order.quantity < 0) {
          // SELL: reduce cost basis proportionally
          final soldQty = order.quantity.abs();
          if (totalQty > 0) {
            final avgCostNative = totalCostNative / totalQty;
            totalCostNative =
                math.max(0, totalCostNative - avgCostNative * soldQty);
            totalQty = math.max(0, totalQty - soldQty);
          }
        } else {
          // COMMISSION (quantity = 0): add to cost basis
          totalCostNative += order.totalNative;
        }
      }

      nativeCostByAssetId[assetIdStr] = totalCostNative;
    }

    // Build partial asset valuations (percentOfInvested calculated later)
    final assetValuationsPartial = <_PartialAssetValuation>[];
    for (final holding in filteredHoldings) {
      final assetIdStr = holding.assetId.toString();
      final asset = assetMap[assetIdStr];
      if (asset == null) continue;

      // Look up price by yahooSymbol if available
      final lookupKey = asset.yahooSymbol ?? asset.ticker;
      final cachedPrice = priceMap[lookupKey];
      final fullPrice = fullPriceMap[lookupKey];
      final usingCostBasis = cachedPrice == null;
      final priceEur = cachedPrice;

      // Value: use price * quantity if we have price, else use cost basis
      final valueEur =
          priceEur != null ? priceEur * holding.quantity : holding.totalCostEur;

      // Native currency cost basis from orders
      final costBasisNative = nativeCostByAssetId[assetIdStr] ?? 0;
      // Implied FX rate at time of purchase
      final impliedHistoricalFxRate =
          costBasisNative != 0 ? holding.totalCostEur / costBasisNative : null;

      assetValuationsPartial.add(_PartialAssetValuation(
        assetId: assetIdStr,
        isin: asset.isin,
        ticker: asset.ticker,
        name: asset.name,
        assetType: asset.assetType,
        quantity: holding.quantity,
        priceEur: priceEur,
        costBasisEur: holding.totalCostEur,
        valueEur: valueEur,
        usingCostBasis: usingCostBasis,
        currency: fullPrice?.currency ?? asset.currency,
        priceNative: fullPrice?.priceNative,
        costBasisNative: costBasisNative,
        impliedHistoricalFxRate: impliedHistoricalFxRate,
      ));
    }

    // Get portfolio sleeves
    final allPortfolioSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
      orderBy: (t) => t.sortOrder,
    );

    // Filter out cash sleeves for the result
    final portfolioSleeves =
        allPortfolioSleeves.where((s) => !s.isCash).toList();

    // Build children map for tree traversal
    final childrenMap = <String?, List<Sleeve>>{};
    for (final sleeve in allPortfolioSleeves) {
      final parentId = sleeve.parentSleeveId?.toString();
      childrenMap.putIfAbsent(parentId, () => []).add(sleeve);
    }

    // Get sleeve asset assignments
    final allAssignments = await SleeveAsset.db.find(session);
    final sleeveIds = portfolioSleeves.map((s) => s.id!.toString()).toSet();
    final portfolioAssignments =
        allAssignments.where((a) => sleeveIds.contains(a.sleeveId.toString()));

    // Calculate totals first (needed for percentages)
    final totalHoldingsValueEur =
        assetValuationsPartial.fold<double>(0, (sum, a) => sum + a.valueEur);
    final totalCostBasisEur = assetValuationsPartial.fold<double>(
        0, (sum, a) => sum + a.costBasisEur);
    final totalValueEur = totalHoldingsValueEur + cashEur;

    // Find unassigned assets
    final assignedAssetIds = portfolioAssignments.map((a) => a.assetId.toString()).toSet();
    final unassignedValueEur = assetValuationsPartial
        .where((a) => !assignedAssetIds.contains(a.assetId))
        .fold<double>(0, (sum, a) => sum + a.valueEur);

    // Invested value = assigned holdings only (NO cash)
    final assignedHoldingsValueEur = totalHoldingsValueEur - unassignedValueEur;
    final investedValueEur = assignedHoldingsValueEur;

    // Build full asset valuations with percentages
    final assetValuations = assetValuationsPartial
        .map((a) => AssetValuation(
              isin: a.isin,
              ticker: a.ticker,
              name: a.name,
              assetType: a.assetType,
              quantity: a.quantity,
              priceEur: a.priceEur,
              costBasisEur: a.costBasisEur,
              valueEur: a.valueEur,
              usingCostBasis: a.usingCostBasis,
              percentOfInvested: investedValueEur > 0
                  ? (a.valueEur / investedValueEur) * 100
                  : 0,
              currency: a.currency,
              priceNative: a.priceNative,
              costBasisNative: a.costBasisNative,
              impliedHistoricalFxRate: a.impliedHistoricalFxRate,
            ))
        .toList();

    // Create asset map for quick lookup by ID
    final assetValuationByIdMap = <String, AssetValuation>{};
    for (var i = 0; i < assetValuationsPartial.length; i++) {
      assetValuationByIdMap[assetValuationsPartial[i].assetId] =
          assetValuations[i];
    }

    // Build direct assets and values per sleeve
    final directAssetsMap = <String, List<AssetValuation>>{};
    final directValueMap = <String, double>{};

    for (final sleeve in portfolioSleeves) {
      final sleeveIdStr = sleeve.id!.toString();
      final sleeveAssetIds = portfolioAssignments
          .where((a) => a.sleeveId.toString() == sleeveIdStr)
          .map((a) => a.assetId.toString())
          .toList();

      final directAssets = sleeveAssetIds
          .map((id) => assetValuationByIdMap[id])
          .whereType<AssetValuation>()
          .toList();

      final directValue =
          directAssets.fold<double>(0, (sum, a) => sum + a.valueEur);

      directAssetsMap[sleeveIdStr] = directAssets;
      directValueMap[sleeveIdStr] = directValue;
    }

    // Find unassigned assets
    final unassignedAssets = assetValuations
        .where((a) {
          final assetId = assetValuationsPartial
              .firstWhere((p) => p.isin == a.isin)
              .assetId;
          return !assignedAssetIds.contains(assetId);
        })
        .toList();

    // Build sleeve allocations with recursive totals and band evaluation
    var violationCount = 0;

    final sleeveAllocations = <SleeveAllocation>[];
    for (final sleeve in portfolioSleeves) {
      final sleeveIdStr = sleeve.id!.toString();
      final directAssets = directAssetsMap[sleeveIdStr] ?? [];
      final directValueEur = directValueMap[sleeveIdStr] ?? 0;

      // Calculate total including all descendants
      final sleeveTotal = _calculateSleeveTotal(
        sleeveIdStr,
        childrenMap,
        directValueMap,
      );

      // Dual percentages
      final actualPercentInvested =
          investedValueEur > 0 ? (sleeveTotal / investedValueEur) * 100 : 0.0;
      final actualPercentTotal =
          totalValueEur > 0 ? (sleeveTotal / totalValueEur) * 100 : 0.0;

      // Calculate band and status (based on invested percentage)
      final band = calculateBand(sleeve.budgetPercent, bandConfig);
      final status = evaluateStatus(actualPercentInvested, band);

      if (status == AllocationStatus.warning) {
        violationCount++;
      }

      final deltaPercent = actualPercentInvested - sleeve.budgetPercent;

      sleeveAllocations.add(SleeveAllocation(
        sleeveId: sleeveIdStr,
        sleeveName: sleeve.name,
        parentSleeveId: sleeve.parentSleeveId?.toString(),
        budgetPercent: sleeve.budgetPercent,
        directAssets: directAssets,
        directValueEur: directValueEur,
        totalValueEur: sleeveTotal,
        actualPercentInvested: actualPercentInvested,
        actualPercentTotal: actualPercentTotal,
        band: band,
        status: status,
        deltaPercent: deltaPercent,
      ));
    }

    // Check if all prices are available
    final hasAllPrices = assetValuations.every((a) => !a.usingCostBasis);

    // Find assets missing Yahoo symbols
    final missingSymbolAssets = filteredHoldings
        .where((h) {
          final asset = assetMap[h.assetId.toString()];
          return asset != null && asset.yahooSymbol == null;
        })
        .map((h) {
          final asset = assetMap[h.assetId.toString()]!;
          return MissingSymbolAsset(
            isin: asset.isin,
            ticker: asset.ticker,
            name: asset.name,
          );
        })
        .toList();

    // Find assets with stale prices (older than 24 hours)
    const stalePriceThresholdHours = 24;
    final stalePriceThresholdMs = stalePriceThresholdHours * 60 * 60 * 1000;
    final now = DateTime.now();

    final stalePriceAssets = <StalePriceAsset>[];
    for (final holding in filteredHoldings) {
      final asset = assetMap[holding.assetId.toString()];
      if (asset == null) continue;

      final lookupKey = asset.yahooSymbol ?? asset.ticker;
      final priceEntry = fullPriceMap[lookupKey];
      if (priceEntry == null) continue;

      final ageMs = now.difference(priceEntry.fetchedAt).inMilliseconds;
      if (ageMs > stalePriceThresholdMs) {
        stalePriceAssets.add(StalePriceAsset(
          isin: asset.isin,
          ticker: asset.ticker,
          name: asset.name,
          lastFetchedAt: priceEntry.fetchedAt,
          hoursStale: ageMs ~/ (60 * 60 * 1000),
        ));
      }
    }

    // Evaluate concentration limit rules
    final concentrationViolations = <ConcentrationViolation>[];

    // Only check assigned assets for concentration
    final assignedAssetsForConcentration = assetValuations.where((a) {
      final assetId = assetValuationsPartial
          .firstWhere((p) => p.isin == a.isin)
          .assetId;
      return assignedAssetIds.contains(assetId);
    }).toList();

    for (final rule in rules) {
      if (!rule.enabled || rule.ruleType != 'concentration_limit') {
        continue;
      }

      // Parse config JSON
      Map<String, dynamic>? config;
      if (rule.config != null) {
        try {
          config = jsonDecode(rule.config!) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }
      }
      if (config == null) continue;

      final maxPercent = (config['maxPercent'] as num?)?.toDouble() ?? 100;
      final assetTypes = (config['assetTypes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      for (final asset in assignedAssetsForConcentration) {
        // Skip if rule has asset type filter and this asset doesn't match
        if (assetTypes != null && assetTypes.isNotEmpty) {
          if (!assetTypes.contains(asset.assetType.name)) {
            continue;
          }
        }

        // Check if asset exceeds the limit
        if (asset.percentOfInvested > maxPercent) {
          concentrationViolations.add(ConcentrationViolation(
            ruleId: rule.id!.toString(),
            ruleName: rule.name,
            assetIsin: asset.isin,
            assetName: asset.name,
            assetTicker: asset.ticker,
            assetType: asset.assetType,
            actualPercent: asset.percentOfInvested,
            maxPercent: maxPercent,
          ));
        }
      }
    }

    final concentrationViolationCount = concentrationViolations.length;
    final totalViolationCount = violationCount + concentrationViolationCount;

    return PortfolioValuation(
      portfolioId: portfolio.id!.toString(),
      portfolioName: portfolio.name,
      cashEur: cashEur,
      totalHoldingsValueEur: totalHoldingsValueEur,
      assignedHoldingsValueEur: assignedHoldingsValueEur,
      unassignedValueEur: unassignedValueEur,
      investedValueEur: investedValueEur,
      totalValueEur: totalValueEur,
      totalCostBasisEur: totalCostBasisEur,
      sleeves: sleeveAllocations,
      unassignedAssets: unassignedAssets,
      bandConfig: bandConfig,
      violationCount: violationCount,
      hasAllPrices: hasAllPrices,
      missingSymbolAssets: missingSymbolAssets,
      stalePriceAssets: stalePriceAssets,
      stalePriceThresholdHours: stalePriceThresholdHours,
      concentrationViolations: concentrationViolations,
      concentrationViolationCount: concentrationViolationCount,
      totalViolationCount: totalViolationCount,
      lastSyncAt: lastSyncAt,
    );
  }

  /// Get historical chart data for portfolio value visualization.
  /// Returns daily data points with portfolio value and cost basis over time.
  Future<ChartDataResult> getChartData(
    Session session,
    UuidValue portfolioId,
    ChartRange range,
  ) async {
    final now = DateTime.now();
    final endDateStr = _formatDate(now);

    // Verify portfolio exists
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found');
    }

    // Get all non-archived assets
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetMap = {for (var a in allAssets) a.id!.toString(): a};
    final nonArchivedAssetIds = allAssets.map((a) => a.id!.toString()).toSet();

    // Get all orders for non-archived assets
    final allOrders = await Order.db.find(
      session,
      orderBy: (t) => t.orderDate,
    );
    final filteredOrders = allOrders
        .where((o) => nonArchivedAssetIds.contains(o.assetId.toString()))
        .toList();

    if (filteredOrders.isEmpty) {
      return ChartDataResult(dataPoints: [], hasData: false);
    }

    // Find earliest order date for 'all' range
    final firstOrderDate = filteredOrders.fold<DateTime>(
      filteredOrders.first.orderDate,
      (earliest, o) => o.orderDate.isBefore(earliest) ? o.orderDate : earliest,
    );

    // Calculate start date based on range
    DateTime startDate;
    switch (range) {
      case ChartRange.oneMonth:
        startDate = DateTime(now.year, now.month - 1, now.day);
      case ChartRange.threeMonths:
        startDate = DateTime(now.year, now.month - 3, now.day);
      case ChartRange.sixMonths:
        startDate = DateTime(now.year, now.month - 6, now.day);
      case ChartRange.oneYear:
        startDate = DateTime(now.year - 1, now.month, now.day);
      case ChartRange.all:
        startDate = firstOrderDate;
    }
    final startDateStr = _formatDate(startDate);

    // Get FX rates for currency conversion
    final fxRates = await FxCache.db.find(session);
    final fxRateMap = {for (var f in fxRates) f.pair: f.rate};

    // Build list of yahoo symbols we need prices for
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
                (t.date >= startDateStr) &
                (t.date <= endDateStr),
          )
        : <DailyPrice>[];

    // Build price lookup: ticker -> date -> price
    final priceByTickerDate = <String, Map<String, ({double close, String currency})>>{};
    for (final p in pricesResult) {
      priceByTickerDate.putIfAbsent(p.ticker, () => {});
      priceByTickerDate[p.ticker]![p.date] = (close: p.adjClose, currency: p.currency);
    }

    // Process orders to build position snapshots
    final sortedOrders = List<Order>.from(filteredOrders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    final positionsByDate = <String, Map<String, ({double quantity, double costBasisEur, double avgCostEur})>>{};
    var currentPositions = <String, ({double quantity, double costBasisEur, double avgCostEur})>{};

    String lastDate = '';
    for (final order in sortedOrders) {
      final orderDateStr = _formatDate(order.orderDate);

      if (orderDateStr != lastDate && lastDate.isNotEmpty) {
        positionsByDate[lastDate] = Map.from(currentPositions);
      }

      final assetIdStr = order.assetId.toString();
      final existing = currentPositions[assetIdStr] ??
          (quantity: 0.0, costBasisEur: 0.0, avgCostEur: 0.0);

      if (order.quantity > 0) {
        // BUY
        final newQuantity = existing.quantity + order.quantity;
        final newCostBasis = existing.costBasisEur + order.totalEur;
        currentPositions[assetIdStr] = (
          quantity: newQuantity,
          costBasisEur: newCostBasis,
          avgCostEur: newQuantity > 0 ? newCostBasis / newQuantity : 0,
        );
      } else if (order.quantity < 0) {
        // SELL
        final soldQty = order.quantity.abs();
        final costReduction = existing.avgCostEur * soldQty;
        final newQuantity = math.max(0.0, existing.quantity - soldQty);
        final newCostBasis =
            math.max(0.0, existing.costBasisEur - costReduction);
        currentPositions[assetIdStr] = (
          quantity: newQuantity,
          costBasisEur: newCostBasis,
          avgCostEur: existing.avgCostEur,
        );
      } else {
        // COMMISSION
        currentPositions[assetIdStr] = (
          quantity: existing.quantity,
          costBasisEur: existing.costBasisEur + order.totalEur,
          avgCostEur: existing.quantity > 0
              ? (existing.costBasisEur + order.totalEur) / existing.quantity
              : existing.avgCostEur,
        );
      }

      lastDate = orderDateStr;
    }
    if (lastDate.isNotEmpty) {
      positionsByDate[lastDate] = Map.from(currentPositions);
    }

    // Collect unique dates that have price data
    final uniqueDates = <String>{};
    for (final dateMap in priceByTickerDate.values) {
      for (final date in dateMap.keys) {
        if (date.compareTo(startDateStr) >= 0 &&
            date.compareTo(endDateStr) <= 0) {
          uniqueDates.add(date);
        }
      }
    }
    // Also include order dates
    for (final date in positionsByDate.keys) {
      if (date.compareTo(startDateStr) >= 0) {
        uniqueDates.add(date);
      }
    }
    final sortedDates = uniqueDates.toList()..sort();

    // Get current prices from priceCache for today
    final cachedPrices = await PriceCache.db.find(session);
    final currentPriceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};
    final derivedFxRateMap = <String, double>{};
    for (final p in cachedPrices) {
      if (p.priceNative != 0) {
        derivedFxRateMap[p.ticker] = p.priceEur / p.priceNative;
      }
    }

    double getFxRateToEur(String currency) {
      if (currency == 'EUR') return 1;
      return fxRateMap['${currency}EUR'] ?? 1;
    }

    Map<String, ({double quantity, double costBasisEur, double avgCostEur})>
        getPositionsForDate(String date) {
      String bestDate = '';
      Map<String, ({double quantity, double costBasisEur, double avgCostEur})>?
          bestSnapshot;

      for (final entry in positionsByDate.entries) {
        if (entry.key.compareTo(date) <= 0 &&
            entry.key.compareTo(bestDate) > 0) {
          bestDate = entry.key;
          bestSnapshot = entry.value;
        }
      }
      return bestSnapshot ?? {};
    }

    // Build sorted dates per ticker
    final sortedDatesByTicker = <String, List<String>>{};
    for (final entry in priceByTickerDate.entries) {
      sortedDatesByTicker[entry.key] = entry.value.keys.toList()..sort();
    }

    ({double price, String currency})? getPriceForDate(
        String assetId, String date) {
      final asset = assetMap[assetId];
      if (asset?.yahooSymbol == null) return null;

      final tickerPrices = priceByTickerDate[asset!.yahooSymbol!];
      if (tickerPrices == null) return null;

      // Try exact date
      final exactPrice = tickerPrices[date];
      if (exactPrice != null) {
        return (price: exactPrice.close, currency: exactPrice.currency);
      }

      // Find nearest prior date
      final tickerDates = sortedDatesByTicker[asset.yahooSymbol!] ?? [];
      String nearestDate = '';
      for (final d in tickerDates) {
        if (d.compareTo(date) <= 0 && d.compareTo(nearestDate) > 0) {
          nearestDate = d;
        }
      }

      if (nearestDate.isNotEmpty) {
        final priceData = tickerPrices[nearestDate];
        if (priceData != null) {
          return (price: priceData.close, currency: priceData.currency);
        }
      }
      return null;
    }

    // Calculate data points
    final dataPoints = <ChartDataPoint>[];
    final todayStr = endDateStr;

    for (final date in sortedDates) {
      final positions = getPositionsForDate(date);
      final isToday = date == todayStr;

      double investedValue = 0;
      double costBasis = 0;

      for (final entry in positions.entries) {
        final assetId = entry.key;
        final position = entry.value;

        if (position.quantity <= 0) continue;

        costBasis += position.costBasisEur;

        final asset = assetMap[assetId];
        if (asset?.yahooSymbol == null) {
          investedValue += position.costBasisEur;
          continue;
        }

        if (isToday) {
          final currentPrice = currentPriceMap[asset!.yahooSymbol!];
          if (currentPrice != null) {
            investedValue += currentPrice * position.quantity;
          } else {
            final priceData = getPriceForDate(assetId, date);
            if (priceData != null) {
              final fxRate = getFxRateToEur(priceData.currency);
              investedValue += priceData.price * position.quantity * fxRate;
            } else {
              investedValue += position.costBasisEur;
            }
          }
        } else {
          final priceData = getPriceForDate(assetId, date);
          if (priceData != null) {
            final derivedFxRate = derivedFxRateMap[asset!.yahooSymbol!];
            final fxRate = derivedFxRate ?? getFxRateToEur(priceData.currency);
            investedValue += priceData.price * position.quantity * fxRate;
          } else {
            investedValue += position.costBasisEur;
          }
        }
      }

      dataPoints.add(ChartDataPoint(
        date: date,
        investedValue: (investedValue * 100).round() / 100,
        costBasis: (costBasis * 100).round() / 100,
      ));
    }

    return ChartDataResult(dataPoints: dataPoints, hasData: dataPoints.isNotEmpty);
  }

  /// Get historical returns for different time periods.
  /// Calculates portfolio value at historical dates and compares to current value.
  Future<HistoricalReturnsResult> getHistoricalReturns(
    Session session,
    UuidValue portfolioId,
  ) async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // Verify portfolio exists
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found');
    }

    // Get all non-archived assets
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetMap = {for (var a in allAssets) a.id!.toString(): a};
    final nonArchivedAssetIds = allAssets.map((a) => a.id!.toString()).toSet();

    // Get all orders
    final allOrders = await Order.db.find(
      session,
      orderBy: (t) => t.orderDate,
    );
    final filteredOrders = allOrders
        .where((o) => nonArchivedAssetIds.contains(o.assetId.toString()))
        .toList();

    if (filteredOrders.isEmpty) {
      return HistoricalReturnsResult(
        currentValue: 0,
        returns: {},
        assetReturns: {},
      );
    }

    // Sort orders
    final sortedOrders = List<Order>.from(filteredOrders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));
    final firstOrderDate = sortedOrders.first.orderDate;
    final firstOrderDateStr = _formatDate(firstOrderDate);

    // Calculate comparison dates
    String getComparisonDate(ReturnPeriod period) {
      final date = DateTime.now();
      switch (period) {
        case ReturnPeriod.today:
          return _formatDate(date.subtract(const Duration(days: 1)));
        case ReturnPeriod.oneWeek:
          return _formatDate(date.subtract(const Duration(days: 7)));
        case ReturnPeriod.oneMonth:
          return _formatDate(DateTime(date.year, date.month - 1, date.day));
        case ReturnPeriod.sixMonths:
          return _formatDate(DateTime(date.year, date.month - 6, date.day));
        case ReturnPeriod.ytd:
          return _formatDate(DateTime(date.year - 1, 12, 31));
        case ReturnPeriod.oneYear:
          return _formatDate(DateTime(date.year - 1, date.month, date.day));
        case ReturnPeriod.all:
          return firstOrderDateStr;
      }
    }

    final periods = ReturnPeriod.values;
    final comparisonDates = {for (var p in periods) p: getComparisonDate(p)};

    // Find earliest date needed
    final allDatesNeeded = {todayStr, ...comparisonDates.values};
    final sortedDatesForPrices = allDatesNeeded.toList()..sort();
    final earliestDate = DateTime.parse(sortedDatesForPrices.first);
    final lookbackDate = earliestDate.subtract(const Duration(days: 5));
    final lookbackDateStr = _formatDate(lookbackDate);

    // Get FX rates
    final fxRates = await FxCache.db.find(session);
    final fxRateMap = {for (var f in fxRates) f.pair: f.rate};

    // Get historical prices
    final yahooSymbols = allAssets
        .where((a) => a.yahooSymbol != null)
        .map((a) => a.yahooSymbol!)
        .toSet();

    final pricesResult = yahooSymbols.isNotEmpty
        ? await DailyPrice.db.find(
            session,
            where: (t) =>
                t.ticker.inSet(yahooSymbols) &
                (t.date >= lookbackDateStr) &
                (t.date <= todayStr),
          )
        : <DailyPrice>[];

    final priceByTickerDate = <String, Map<String, ({double close, String currency})>>{};
    for (final p in pricesResult) {
      priceByTickerDate.putIfAbsent(p.ticker, () => {});
      priceByTickerDate[p.ticker]![p.date] = (close: p.adjClose, currency: p.currency);
    }

    // Process orders to build position snapshots
    final positionsByDate = <String, Map<String, ({double quantity, double costBasisEur, double avgCostEur})>>{};
    var currentPositions = <String, ({double quantity, double costBasisEur, double avgCostEur})>{};

    String lastDate = '';
    for (final order in sortedOrders) {
      final orderDateStr = _formatDate(order.orderDate);

      if (orderDateStr != lastDate && lastDate.isNotEmpty) {
        positionsByDate[lastDate] = Map.from(currentPositions);
      }

      final assetIdStr = order.assetId.toString();
      final existing = currentPositions[assetIdStr] ??
          (quantity: 0.0, costBasisEur: 0.0, avgCostEur: 0.0);

      if (order.quantity > 0) {
        final newQuantity = existing.quantity + order.quantity;
        final newCostBasis = existing.costBasisEur + order.totalEur;
        currentPositions[assetIdStr] = (
          quantity: newQuantity,
          costBasisEur: newCostBasis,
          avgCostEur: newQuantity > 0 ? newCostBasis / newQuantity : 0,
        );
      } else if (order.quantity < 0) {
        final soldQty = order.quantity.abs();
        final costReduction = existing.avgCostEur * soldQty;
        final newQuantity = math.max(0.0, existing.quantity - soldQty);
        final newCostBasis =
            math.max(0.0, existing.costBasisEur - costReduction);
        currentPositions[assetIdStr] = (
          quantity: newQuantity,
          costBasisEur: newCostBasis,
          avgCostEur: existing.avgCostEur,
        );
      } else {
        currentPositions[assetIdStr] = (
          quantity: existing.quantity,
          costBasisEur: existing.costBasisEur + order.totalEur,
          avgCostEur: existing.quantity > 0
              ? (existing.costBasisEur + order.totalEur) / existing.quantity
              : existing.avgCostEur,
        );
      }

      lastDate = orderDateStr;
    }
    if (lastDate.isNotEmpty) {
      positionsByDate[lastDate] = Map.from(currentPositions);
    }

    // Get current prices
    final cachedPrices = await PriceCache.db.find(session);
    final currentPriceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};
    final derivedFxRateMap = <String, double>{};
    for (final p in cachedPrices) {
      if (p.priceNative != 0) {
        derivedFxRateMap[p.ticker] = p.priceEur / p.priceNative;
      }
    }

    double getFxRateToEur(String currency) {
      if (currency == 'EUR') return 1;
      return fxRateMap['${currency}EUR'] ?? 1;
    }

    Map<String, ({double quantity, double costBasisEur, double avgCostEur})>
        getPositionsForDate(String date) {
      String bestDate = '';
      Map<String, ({double quantity, double costBasisEur, double avgCostEur})>?
          bestSnapshot;

      for (final entry in positionsByDate.entries) {
        if (entry.key.compareTo(date) <= 0 &&
            entry.key.compareTo(bestDate) > 0) {
          bestDate = entry.key;
          bestSnapshot = entry.value;
        }
      }
      return bestSnapshot ?? {};
    }

    final datesByTicker = <String, List<String>>{};
    for (final entry in priceByTickerDate.entries) {
      datesByTicker[entry.key] = entry.value.keys.toList()..sort();
    }

    ({double price, String currency, String actualDate})? getPriceForDate(
        String assetId, String targetDate) {
      final asset = assetMap[assetId];
      if (asset?.yahooSymbol == null) return null;

      final tickerPrices = priceByTickerDate[asset!.yahooSymbol!];
      if (tickerPrices == null) return null;

      // Try exact date
      final exactPrice = tickerPrices[targetDate];
      if (exactPrice != null) {
        return (
          price: exactPrice.close,
          currency: exactPrice.currency,
          actualDate: targetDate
        );
      }

      // Find nearest prior date
      final tickerDates = datesByTicker[asset.yahooSymbol!] ?? [];
      String nearestDate = '';
      for (final d in tickerDates) {
        if (d.compareTo(targetDate) <= 0 && d.compareTo(nearestDate) > 0) {
          nearestDate = d;
        }
      }

      if (nearestDate.isNotEmpty) {
        final priceData = tickerPrices[nearestDate];
        if (priceData != null) {
          return (
            price: priceData.close,
            currency: priceData.currency,
            actualDate: nearestDate
          );
        }
      }
      return null;
    }

    double calculatePortfolioValue(String date, bool usePriceCache) {
      final positions = getPositionsForDate(date);
      double totalValue = 0;

      for (final entry in positions.entries) {
        final assetId = entry.key;
        final position = entry.value;

        if (position.quantity <= 0) continue;

        final asset = assetMap[assetId];
        if (asset?.yahooSymbol == null) {
          totalValue += position.costBasisEur;
          continue;
        }

        if (usePriceCache) {
          final currentPrice = currentPriceMap[asset!.yahooSymbol!];
          if (currentPrice != null) {
            totalValue += currentPrice * position.quantity;
          } else {
            totalValue += position.costBasisEur;
          }
        } else {
          final priceData = getPriceForDate(assetId, date);
          if (priceData != null) {
            final derivedFxRate = derivedFxRateMap[asset!.yahooSymbol!];
            final fxRate = derivedFxRate ?? getFxRateToEur(priceData.currency);
            totalValue += priceData.price * position.quantity * fxRate;
          } else {
            totalValue += position.costBasisEur;
          }
        }
      }

      return (totalValue * 100).round() / 100;
    }

    // Calculate current value
    final currentValue = calculatePortfolioValue(todayStr, true);

    // Calculate total cost basis
    final totalCostBasis = currentPositions.values.fold<double>(
      0,
      (sum, pos) => sum + pos.costBasisEur,
    );

    // Extract cash flows for MWR
    final cashFlows = sortedOrders
        .where((o) => o.quantity != 0)
        .map((o) => CashFlow(
              date: _formatDate(o.orderDate),
              amount: o.quantity > 0 ? o.totalEur : -o.totalEur.abs(),
            ))
        .toList();

    // Calculate returns for each period
    final returns = <String, PeriodReturn>{};
    final assetReturns = <String, Map<String, AssetPeriodReturn>>{};

    // Get current holdings for asset returns
    final currentHoldings = getPositionsForDate(todayStr);
    final holdingAssetIds = currentHoldings.entries
        .where((e) => e.value.quantity > 0)
        .map((e) => e.key)
        .toList();

    String? getAssetFirstOrderDate(String assetId) {
      final assetOrders = sortedOrders
          .where((o) => o.assetId.toString() == assetId && o.quantity > 0)
          .toList();
      if (assetOrders.isEmpty) return null;
      return _formatDate(assetOrders.first.orderDate);
    }

    for (final period in periods) {
      final comparisonDate = comparisonDates[period]!;
      final isAllPeriod = period == ReturnPeriod.all;

      // For "all" period, use the value at EOD of first order date (includes first day's orders)
      // For other periods, use value at comparison date (excludes that day's orders)
      final startValue = isAllPeriod
          ? calculatePortfolioValue(comparisonDate, true)
          : calculatePortfolioValue(comparisonDate, false);

      if (DateTime.parse(comparisonDate).isAfter(firstOrderDate) ||
          DateTime.parse(comparisonDate).isAtSameMomentAs(firstOrderDate)) {
        if (startValue <= 0) continue;

        final mwrResult = calculateMWR(
          startDate: comparisonDate,
          endDate: todayStr,
          startValue: startValue,
          endValue: currentValue,
          cashFlows: cashFlows,
        );

        // Calculate TWR (time-weighted return) for portfolio performance comparison
        final twrResult = calculateTWR(
          startDate: comparisonDate,
          endDate: todayStr,
          cashFlows: cashFlows,
          getPortfolioValueAtDate: (date) => calculatePortfolioValue(date, false),
        );

        // Absolute return
        final absoluteReturn = isAllPeriod
            ? currentValue - totalCostBasis
            : currentValue - startValue - mwrResult.netCashFlow;

        // Display return percent
        double displayReturnPercent;
        if (isAllPeriod) {
          displayReturnPercent = totalCostBasis > 0
              ? (currentValue - totalCostBasis) / totalCostBasis
              : 0;
        } else if (mwrResult.periodYears >= 1) {
          displayReturnPercent = mwrResult.annualizedReturn;
        } else {
          displayReturnPercent = mwrResult.compoundedReturn;
        }

        // TWR may be null if calculation failed (e.g., portfolio hit zero value)
        final twrPercent = twrResult.isValid && twrResult.twr != null
            ? (twrResult.twr! * 10000).round() / 100
            : null;

        returns[period.name] = PeriodReturn(
          period: period,
          currentValue: currentValue,
          startValue: startValue,
          absoluteReturn: (absoluteReturn * 100).round() / 100,
          compoundedReturn: (displayReturnPercent * 10000).round() / 100,
          annualizedReturn: (mwrResult.annualizedReturn * 10000).round() / 100,
          twr: twrPercent,
          periodYears: (mwrResult.periodYears * 100).round() / 100,
          comparisonDate: comparisonDate,
          netCashFlow: (mwrResult.netCashFlow * 100).round() / 100,
          cashFlowCount: mwrResult.cashFlowCount,
        );

        // Per-asset returns
        final periodAssetReturns = <String, AssetPeriodReturn>{};

        for (final assetId in holdingAssetIds) {
          final asset = assetMap[assetId];
          if (asset == null) continue;

          final currentPrice = asset.yahooSymbol != null
              ? currentPriceMap[asset.yahooSymbol!]
              : null;
          final position = currentHoldings[assetId];
          final quantity = position?.quantity ?? 0;
          final costBasisEur = position?.costBasisEur ?? 0;

          final assetFirstOrder = getAssetFirstOrderDate(assetId);
          final isShortHolding =
              assetFirstOrder != null && assetFirstOrder.compareTo(comparisonDate) > 0;
          final effectiveStartDate =
              isShortHolding ? assetFirstOrder : comparisonDate;

          final historicalPriceData = getPriceForDate(assetId, effectiveStartDate);
          final historicalPrice = historicalPriceData != null
              ? historicalPriceData.price *
                  (derivedFxRateMap[asset.yahooSymbol!] ??
                      getFxRateToEur(historicalPriceData.currency))
              : null;

          double? compoundedReturnAsset;
          double? annualizedReturnAsset;
          double? periodYearsAsset;
          double? absoluteReturnAsset;

          if (currentPrice != null && quantity > 0) {
            final currentAssetValue = currentPrice * quantity;

            if (isAllPeriod) {
              absoluteReturnAsset =
                  ((currentAssetValue - costBasisEur) * 100).round() / 100;
            } else if (historicalPrice != null) {
              final historicalValue = historicalPrice * quantity;
              absoluteReturnAsset =
                  ((currentAssetValue - historicalValue) * 100).round() / 100;
            }

            if (historicalPrice != null && historicalPrice > 0) {
              final simpleReturn = (currentPrice - historicalPrice) / historicalPrice;
              compoundedReturnAsset = (simpleReturn * 10000).round() / 100;

              final startDateObj = DateTime.parse(effectiveStartDate);
              final endDateObj = DateTime.parse(todayStr);
              final periodMs =
                  endDateObj.difference(startDateObj).inMilliseconds;
              periodYearsAsset = periodMs / (365.25 * 24 * 60 * 60 * 1000);

              if (periodYearsAsset > 0) {
                final annualized =
                    math.pow(1 + simpleReturn, 1 / periodYearsAsset) - 1;
                annualizedReturnAsset = (annualized * 10000).round() / 100;
              } else {
                annualizedReturnAsset = compoundedReturnAsset;
              }
            }
          }

          periodAssetReturns[asset.isin] = AssetPeriodReturn(
            isin: asset.isin,
            ticker: asset.ticker,
            currentPrice: currentPrice,
            historicalPrice: historicalPrice,
            absoluteReturn: absoluteReturnAsset,
            compoundedReturn: compoundedReturnAsset,
            annualizedReturn: annualizedReturnAsset,
            periodYears: periodYearsAsset != null
                ? (periodYearsAsset * 100).round() / 100
                : null,
            isShortHolding: isShortHolding,
            holdingPeriodLabel: isShortHolding && periodYearsAsset != null
                ? formatPeriodLabel(periodYearsAsset)
                : null,
          );
        }

        assetReturns[period.name] = periodAssetReturns;
      }
    }

    return HistoricalReturnsResult(
      currentValue: currentValue,
      returns: returns,
      assetReturns: assetReturns,
    );
  }

  /// Recursively calculate total value for a sleeve including all descendants
  double _calculateSleeveTotal(
    String sleeveId,
    Map<String?, List<Sleeve>> childrenMap,
    Map<String, double> directValueMap,
  ) {
    // Start with direct value
    double total = directValueMap[sleeveId] ?? 0;

    // Add totals from all children recursively (excluding cash sleeves)
    final children =
        (childrenMap[sleeveId] ?? []).where((c) => !c.isCash).toList();
    for (final child in children) {
      total += _calculateSleeveTotal(
          child.id!.toString(), childrenMap, directValueMap);
    }

    return total;
  }

  /// Format a DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

/// Partial asset valuation (before percentage calculation)
class _PartialAssetValuation {
  final String assetId;
  final String isin;
  final String ticker;
  final String name;
  final AssetType assetType;
  final double quantity;
  final double? priceEur;
  final double costBasisEur;
  final double valueEur;
  final bool usingCostBasis;
  final String currency;
  final double? priceNative;
  final double costBasisNative;
  final double? impliedHistoricalFxRate;

  const _PartialAssetValuation({
    required this.assetId,
    required this.isin,
    required this.ticker,
    required this.name,
    required this.assetType,
    required this.quantity,
    required this.priceEur,
    required this.costBasisEur,
    required this.valueEur,
    required this.usingCostBasis,
    required this.currency,
    required this.priceNative,
    required this.costBasisNative,
    required this.impliedHistoricalFxRate,
  });
}
