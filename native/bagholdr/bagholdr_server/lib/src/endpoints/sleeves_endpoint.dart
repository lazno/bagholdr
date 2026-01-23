import 'dart:math' as math;
import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../utils/bands.dart';
import '../utils/returns.dart';

/// Endpoint for sleeve hierarchy and allocation data.
///
/// Returns sleeve tree with allocation percentages, drift status,
/// and MWR/TWR returns for each sleeve for the Strategy section.
class SleevesEndpoint extends Endpoint {
  /// Sleeve color mapping (consistent across the app)
  static const _sleeveColors = <String, String>{
    'Core': '#3b82f6',
    'Equities': '#60a5fa',
    'Bonds': '#93c5fd',
    'Satellite': '#f59e0b',
    'Safe Haven': '#fbbf24',
    'Growth': '#fcd34d',
  };

  /// Default color for unmapped sleeves
  static const _defaultColor = '#6b7280';

  /// Get sleeve hierarchy with allocation and return data
  ///
  /// [portfolioId] - Portfolio to fetch sleeves for
  /// [period] - Time period for return calculations
  Future<SleeveTreeResponse> getSleeveTree(
    Session session, {
    required UuidValue portfolioId,
    required ReturnPeriod period,
  }) async {
    final now = DateTime.now();
    final todayStr = _formatDate(now);

    // Get portfolio for band config
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found');
    }

    final bandConfig = BandConfig(
      relativeTolerance: portfolio.bandRelativeTolerance,
      absoluteFloor: portfolio.bandAbsoluteFloor,
      absoluteCap: portfolio.bandAbsoluteCap,
    );

    // Get all sleeves for this portfolio (excluding cash sleeves)
    final allSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
      orderBy: (t) => t.sortOrder,
    );
    final nonCashSleeves = allSleeves.where((s) => !s.isCash).toList();
    final sleeveMap = {for (var s in nonCashSleeves) s.id!.toString(): s};

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

    // Filter holdings to non-archived assets
    final filteredHoldings = allHoldings
        .where((h) => nonArchivedAssetIds.contains(h.assetId.toString()))
        .toList();

    // Get cached prices
    final cachedPrices = await PriceCache.db.find(session);
    final priceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};

    // Get sleeve-asset assignments
    final allAssignments = await SleeveAsset.db.find(session);
    final sleeveIds = nonCashSleeves.map((s) => s.id!.toString()).toSet();
    final portfolioAssignments = allAssignments
        .where((a) => sleeveIds.contains(a.sleeveId.toString()))
        .toList();

    // Build asset to sleeve mapping
    final assetToSleeveMap = <String, String>{};
    for (final assignment in portfolioAssignments) {
      assetToSleeveMap[assignment.assetId.toString()] =
          assignment.sleeveId.toString();
    }

    // Calculate holding values
    final holdingValues = <String, double>{};
    double totalInvestedValue = 0;

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

      // Only count assigned assets toward invested value
      if (assetToSleeveMap.containsKey(assetIdStr)) {
        totalInvestedValue += valueEur;
      }
    }

    // Build direct values and asset counts per sleeve
    final directValueMap = <String, double>{};
    final directAssetCountMap = <String, int>{};

    for (final sleeveIdStr in sleeveIds) {
      final sleeveAssetIds = portfolioAssignments
          .where((a) => a.sleeveId.toString() == sleeveIdStr)
          .map((a) => a.assetId.toString())
          .toList();

      double directValue = 0;
      int assetCount = 0;

      for (final assetIdStr in sleeveAssetIds) {
        final value = holdingValues[assetIdStr];
        if (value != null && value > 0) {
          directValue += value;
          assetCount++;
        }
      }

      directValueMap[sleeveIdStr] = directValue;
      directAssetCountMap[sleeveIdStr] = assetCount;
    }

    // Build children map for tree traversal
    final childrenMap = <String?, List<Sleeve>>{};
    for (final sleeve in nonCashSleeves) {
      final parentId = sleeve.parentSleeveId?.toString();
      childrenMap.putIfAbsent(parentId, () => []).add(sleeve);
    }

    // Get all orders for MWR/TWR calculations
    final allOrders = await Order.db.find(
      session,
      orderBy: (t) => t.orderDate,
    );
    final filteredOrders = allOrders
        .where((o) => nonArchivedAssetIds.contains(o.assetId.toString()))
        .toList();

    // Get comparison date for the period
    final comparisonDate = _getComparisonDate(period, filteredOrders);

    // Get historical prices for return calculations
    final lookbackDate =
        DateTime.parse(comparisonDate).subtract(const Duration(days: 5));
    final lookbackDateStr = _formatDate(lookbackDate);

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

    final priceByTickerDate = <String, Map<String, double>>{};
    for (final p in pricesResult) {
      priceByTickerDate.putIfAbsent(p.ticker, () => {});
      priceByTickerDate[p.ticker]![p.date] = p.close;
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

    // Build sleeve nodes recursively
    List<SleeveNode> buildSleeveNodes(String? parentId) {
      final children = childrenMap[parentId] ?? [];
      final nodes = <SleeveNode>[];

      for (final sleeve in children) {
        final sleeveIdStr = sleeve.id!.toString();

        // Calculate total value (including descendants)
        final totalValue = _calculateSleeveTotal(
          sleeveIdStr,
          childrenMap,
          directValueMap,
        );

        // Calculate allocation percentages
        final currentPct = totalInvestedValue > 0
            ? (totalValue / totalInvestedValue) * 100
            : 0.0;

        // Calculate drift
        final driftPp = currentPct - sleeve.budgetPercent;
        final band = calculateBand(sleeve.budgetPercent, bandConfig);
        final status = evaluateStatus(currentPct, band);
        final driftStatus = status == AllocationStatus.ok
            ? 'ok'
            : (driftPp > 0 ? 'over' : 'under');

        // Calculate MWR/TWR for this sleeve
        final sleeveAssetIds = _collectSleeveAssetIds(
          sleeveIdStr,
          childrenMap,
          portfolioAssignments,
        );

        final mwrTwr = _calculateSleeveMwrTwr(
          sleeveAssetIds: sleeveAssetIds,
          assetMap: assetMap,
          holdingValues: holdingValues,
          filteredHoldings: filteredHoldings,
          filteredOrders: filteredOrders,
          period: period,
          comparisonDate: comparisonDate,
          todayStr: todayStr,
          priceMap: priceMap,
          priceByTickerDate: priceByTickerDate,
          derivedFxRateMap: derivedFxRateMap,
          fxRateMap: fxRateMap,
        );

        // Count direct assets and child sleeves
        final directAssetCount = directAssetCountMap[sleeveIdStr] ?? 0;
        final directChildren = childrenMap[sleeveIdStr] ?? [];
        final childSleeveCount = directChildren.length;

        // Build child nodes recursively
        final childNodes = buildSleeveNodes(sleeveIdStr);

        nodes.add(SleeveNode(
          id: sleeveIdStr,
          name: sleeve.name,
          parentId: parentId,
          color: _sleeveColors[sleeve.name] ?? _defaultColor,
          targetPct: sleeve.budgetPercent,
          currentPct: (currentPct * 100).round() / 100,
          driftPp: (driftPp * 100).round() / 100,
          driftStatus: driftStatus,
          value: (totalValue * 100).round() / 100,
          mwr: (mwrTwr.mwr * 10000).round() / 100,
          twr: mwrTwr.twr != null ? (mwrTwr.twr! * 10000).round() / 100 : null,
          totalReturn: mwrTwr.totalReturn != null
              ? (mwrTwr.totalReturn! * 10000).round() / 100
              : null,
          assetCount: directAssetCount,
          childSleeveCount: childSleeveCount,
          children: childNodes.isNotEmpty ? childNodes : null,
        ));
      }

      return nodes;
    }

    // Build root-level nodes (sleeves with no parent)
    final rootNodes = buildSleeveNodes(null);

    // Calculate total portfolio MWR/TWR
    final allAssignedAssetIds = assetToSleeveMap.keys.toSet();
    final portfolioMwrTwr = _calculateSleeveMwrTwr(
      sleeveAssetIds: allAssignedAssetIds,
      assetMap: assetMap,
      holdingValues: holdingValues,
      filteredHoldings: filteredHoldings,
      filteredOrders: filteredOrders,
      period: period,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceMap: priceMap,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Count total assets
    final totalAssetCount = allAssignedAssetIds
        .where((id) => holdingValues[id] != null && holdingValues[id]! > 0)
        .length;

    return SleeveTreeResponse(
      sleeves: rootNodes,
      totalValue: (totalInvestedValue * 100).round() / 100,
      totalMwr: (portfolioMwrTwr.mwr * 10000).round() / 100,
      totalTwr: portfolioMwrTwr.twr != null
          ? (portfolioMwrTwr.twr! * 10000).round() / 100
          : null,
      totalReturn: portfolioMwrTwr.totalReturn != null
          ? (portfolioMwrTwr.totalReturn! * 10000).round() / 100
          : null,
      totalAssetCount: totalAssetCount,
    );
  }

  /// Recursively calculate total value for a sleeve including all descendants
  double _calculateSleeveTotal(
    String sleeveId,
    Map<String?, List<Sleeve>> childrenMap,
    Map<String, double> directValueMap,
  ) {
    double total = directValueMap[sleeveId] ?? 0;

    final children = childrenMap[sleeveId] ?? [];
    for (final child in children) {
      total += _calculateSleeveTotal(
        child.id!.toString(),
        childrenMap,
        directValueMap,
      );
    }

    return total;
  }

  /// Collect all asset IDs belonging to a sleeve and its descendants
  Set<String> _collectSleeveAssetIds(
    String sleeveId,
    Map<String?, List<Sleeve>> childrenMap,
    List<SleeveAsset> assignments,
  ) {
    final assetIds = <String>{};

    // Direct assets
    for (final assignment in assignments) {
      if (assignment.sleeveId.toString() == sleeveId) {
        assetIds.add(assignment.assetId.toString());
      }
    }

    // Descendant assets
    final children = childrenMap[sleeveId] ?? [];
    for (final child in children) {
      assetIds.addAll(_collectSleeveAssetIds(
        child.id!.toString(),
        childrenMap,
        assignments,
      ));
    }

    return assetIds;
  }

  /// Calculate MWR, TWR, and Total Return for a set of assets (sleeve or portfolio)
  ({double mwr, double? twr, double? totalReturn}) _calculateSleeveMwrTwr({
    required Set<String> sleeveAssetIds,
    required Map<String, Asset> assetMap,
    required Map<String, double> holdingValues,
    required List<Holding> filteredHoldings,
    required List<Order> filteredOrders,
    required ReturnPeriod period,
    required String comparisonDate,
    required String todayStr,
    required Map<String, double> priceMap,
    required Map<String, Map<String, double>> priceByTickerDate,
    required Map<String, double> derivedFxRateMap,
    required Map<String, double> fxRateMap,
  }) {
    if (sleeveAssetIds.isEmpty) {
      return (mwr: 0, twr: null, totalReturn: null);
    }

    // Calculate current sleeve value
    double currentSleeveValue = 0;
    for (final assetId in sleeveAssetIds) {
      currentSleeveValue += holdingValues[assetId] ?? 0;
    }

    if (currentSleeveValue <= 0) {
      return (mwr: 0, twr: null, totalReturn: null);
    }

    // Get orders for sleeve assets
    final sleeveOrders = filteredOrders
        .where((o) => sleeveAssetIds.contains(o.assetId.toString()))
        .toList()
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    if (sleeveOrders.isEmpty) {
      return (mwr: 0, twr: null, totalReturn: null);
    }

    // Find the first order date for this sleeve (for short holding detection)
    final firstSleeveOrderDate = _formatDate(sleeveOrders.first.orderDate);

    // Check if this is a "short holding" - sleeve acquired after comparison date
    final isShortHolding = firstSleeveOrderDate.compareTo(comparisonDate) > 0;
    final effectiveStartDate =
        isShortHolding ? firstSleeveOrderDate : comparisonDate;

    // Build position snapshots for historical value calculation
    final positionsByDate = <String, Map<String, ({double qty, double cost})>>{};
    var currentPositions = <String, ({double qty, double cost})>{};

    String lastDate = '';
    for (final order in sleeveOrders) {
      final orderDateStr = _formatDate(order.orderDate);

      if (orderDateStr != lastDate && lastDate.isNotEmpty) {
        positionsByDate[lastDate] = Map.from(currentPositions);
      }

      final assetIdStr = order.assetId.toString();
      final existing = currentPositions[assetIdStr] ?? (qty: 0.0, cost: 0.0);

      if (order.quantity > 0) {
        currentPositions[assetIdStr] = (
          qty: existing.qty + order.quantity,
          cost: existing.cost + order.totalEur,
        );
      } else if (order.quantity < 0) {
        final soldQty = order.quantity.abs();
        final avgCost = existing.qty > 0 ? existing.cost / existing.qty : 0;
        currentPositions[assetIdStr] = (
          qty: math.max(0, existing.qty - soldQty),
          cost: math.max(0, existing.cost - avgCost * soldQty),
        );
      } else {
        currentPositions[assetIdStr] = (
          qty: existing.qty,
          cost: existing.cost + order.totalEur,
        );
      }

      lastDate = orderDateStr;
    }
    if (lastDate.isNotEmpty) {
      positionsByDate[lastDate] = Map.from(currentPositions);
    }

    // Get positions at a given date
    Map<String, ({double qty, double cost})> getPositionsForDate(String date) {
      String bestDate = '';
      Map<String, ({double qty, double cost})>? bestSnapshot;

      for (final entry in positionsByDate.entries) {
        if (entry.key.compareTo(date) <= 0 &&
            entry.key.compareTo(bestDate) > 0) {
          bestDate = entry.key;
          bestSnapshot = entry.value;
        }
      }
      return bestSnapshot ?? {};
    }

    // Calculate start value at effective start date
    final startPositions = getPositionsForDate(effectiveStartDate);
    double startValue = 0;

    for (final entry in startPositions.entries) {
      final assetId = entry.key;
      final position = entry.value;
      if (position.qty <= 0) continue;

      final asset = assetMap[assetId];
      if (asset?.yahooSymbol == null) {
        startValue += position.cost;
        continue;
      }

      final historicalPrice = _getHistoricalPrice(
        asset!,
        effectiveStartDate,
        priceByTickerDate,
        derivedFxRateMap,
        fxRateMap,
      );

      if (historicalPrice != null) {
        startValue += historicalPrice * position.qty;
      } else {
        startValue += position.cost;
      }
    }

    if (startValue <= 0) {
      // No starting value - can't calculate meaningful return
      // But total return can still work for ALL period (startValue=0, all orders included)
      if (period == ReturnPeriod.all) {
        final orderTuples = sleeveOrders
            .map((o) => (
                  quantity: o.quantity,
                  totalEur: o.totalEur,
                  date: _formatDate(o.orderDate),
                ))
            .toList();
        final totalReturnResult = calculateTotalReturn(
          startValue: 0,
          endValue: currentSleeveValue,
          orders: orderTuples,
          periodStartDate: '1900-01-01',
          periodEndDate: todayStr,
        );
        return (mwr: 0, twr: null, totalReturn: totalReturnResult);
      }
      return (mwr: 0, twr: null, totalReturn: null);
    }

    // Calculate period using effective start date
    final startDate = DateTime.parse(effectiveStartDate);
    final endDate = DateTime.parse(todayStr);
    final periodMs = endDate.difference(startDate).inMilliseconds;
    final periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

    // Build cash flows for MWR (only flows AFTER effective start date)
    final cashFlows = sleeveOrders
        .where((o) =>
            o.quantity != 0 &&
            _formatDate(o.orderDate).compareTo(effectiveStartDate) > 0 &&
            _formatDate(o.orderDate).compareTo(todayStr) <= 0)
        .map((o) => CashFlow(
              date: _formatDate(o.orderDate),
              amount: o.quantity > 0 ? o.totalEur : -o.totalEur.abs(),
            ))
        .toList();

    // Calculate MWR
    final mwrResult = calculateMWR(
      startDate: effectiveStartDate,
      endDate: todayStr,
      startValue: startValue,
      endValue: currentSleeveValue,
      cashFlows: cashFlows,
    );

    final mwr = periodYears >= 1
        ? mwrResult.annualizedReturn
        : mwrResult.compoundedReturn;

    // Calculate TWR using effective start date
    double getSleeveValueAtDate(String date) {
      final positions = getPositionsForDate(date);
      double value = 0;

      for (final entry in positions.entries) {
        final assetId = entry.key;
        final position = entry.value;
        if (position.qty <= 0) continue;

        final asset = assetMap[assetId];
        if (asset?.yahooSymbol == null) {
          value += position.cost;
          continue;
        }

        // Use current price for today, historical otherwise
        if (date == todayStr) {
          final currentPrice = priceMap[asset!.yahooSymbol!];
          if (currentPrice != null) {
            value += currentPrice * position.qty;
          } else {
            value += position.cost;
          }
        } else {
          final historicalPrice = _getHistoricalPrice(
            asset!,
            date,
            priceByTickerDate,
            derivedFxRateMap,
            fxRateMap,
          );
          if (historicalPrice != null) {
            value += historicalPrice * position.qty;
          } else {
            value += position.cost;
          }
        }
      }

      return value;
    }

    final twrResult = calculateTWR(
      startDate: effectiveStartDate,
      endDate: todayStr,
      cashFlows: cashFlows,
      getPortfolioValueAtDate: getSleeveValueAtDate,
    );

    // Calculate Total Return
    final isAllPeriod = period == ReturnPeriod.all;
    final totalReturnStartValue = isAllPeriod ? 0.0 : startValue;
    final totalReturnPeriodStart = isAllPeriod ? '1900-01-01' : effectiveStartDate;

    final orderTuples = sleeveOrders
        .map((o) => (
              quantity: o.quantity,
              totalEur: o.totalEur,
              date: _formatDate(o.orderDate),
            ))
        .toList();

    final totalReturnResult = calculateTotalReturn(
      startValue: totalReturnStartValue,
      endValue: currentSleeveValue,
      orders: orderTuples,
      periodStartDate: totalReturnPeriodStart,
      periodEndDate: todayStr,
    );

    return (
      mwr: mwr,
      twr: twrResult.isValid ? twrResult.twr : null,
      totalReturn: totalReturnResult,
    );
  }

  /// Get historical price for an asset at a given date
  double? _getHistoricalPrice(
    Asset asset,
    String targetDate,
    Map<String, Map<String, double>> priceByTickerDate,
    Map<String, double> derivedFxRateMap,
    Map<String, double> fxRateMap,
  ) {
    if (asset.yahooSymbol == null) return null;

    final tickerPrices = priceByTickerDate[asset.yahooSymbol!];
    if (tickerPrices == null) return null;

    // Try exact date
    var price = tickerPrices[targetDate];

    // If not found, find nearest prior date
    if (price == null) {
      String nearestDate = '';
      for (final date in tickerPrices.keys) {
        if (date.compareTo(targetDate) <= 0 && date.compareTo(nearestDate) > 0) {
          nearestDate = date;
        }
      }
      if (nearestDate.isNotEmpty) {
        price = tickerPrices[nearestDate];
      }
    }

    if (price == null) return null;

    // Apply FX conversion
    final derivedFxRate = derivedFxRateMap[asset.yahooSymbol!];
    if (derivedFxRate != null) {
      return price * derivedFxRate;
    }

    if (asset.currency != 'EUR') {
      final fxRate = fxRateMap['${asset.currency}EUR'] ?? 1.0;
      return price * fxRate;
    }

    return price;
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
}
