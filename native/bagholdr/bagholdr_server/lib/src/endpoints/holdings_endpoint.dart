import 'dart:math' as math;
import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../utils/returns.dart';

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

    // Get sleeve assignments
    final allAssignments = await SleeveAsset.db.find(session);
    final assetSleeveMap = <String, UuidValue>{};
    for (final assignment in allAssignments) {
      assetSleeveMap[assignment.assetId.toString()] = assignment.sleeveId;
    }

    // Get sleeves for names and hierarchy
    final allSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
    );
    final sleeveMap = {for (var s in allSleeves) s.id!.toString(): s};

    // Build sleeve hierarchy for filtering
    final descendantSleeveIds = <String>{};
    if (sleeveId != null) {
      _collectDescendantSleeveIds(
        sleeveId.toString(),
        sleeveMap,
        descendantSleeveIds,
      );
      descendantSleeveIds.add(sleeveId.toString());
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
    final priceByTickerDate = <String, Map<String, double>>{};
    for (final p in pricesResult) {
      priceByTickerDate.putIfAbsent(p.ticker, () => {});
      priceByTickerDate[p.ticker]![p.date] = p.adjClose;
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

      // Get sleeve info
      final holdingSleeveId = assetSleeveMap[assetIdStr];
      final sleeve = holdingSleeveId != null
          ? sleeveMap[holdingSleeveId.toString()]
          : null;

      // Apply sleeve filter
      if (sleeveId != null) {
        if (holdingSleeveId == null ||
            !descendantSleeveIds.contains(holdingSleeveId.toString())) {
          continue;
        }
      }

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

      // Calculate values
      final valueEur = holdingValues[assetIdStr] ?? holding.totalCostEur;
      final costBasisEur = costBasisByAssetId[assetIdStr] ?? holding.totalCostEur;
      final pl = valueEur - costBasisEur;
      final weight =
          totalPortfolioValue > 0 ? (valueEur / totalPortfolioValue) * 100 : 0.0;

      // Calculate MWR for this asset
      final assetOrders = ordersByAssetId[assetIdStr] ?? [];
      final mwrResult = _calculateAssetMWR(
        assetId: assetIdStr,
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

      // Calculate TWR for this asset
      final twrResult = _calculateAssetTWR(
        assetId: assetIdStr,
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

      holdingsData.add(_HoldingData(
        symbol: asset.yahooSymbol ?? asset.ticker,
        name: asset.name,
        isin: asset.isin,
        value: valueEur,
        costBasis: costBasisEur,
        pl: pl,
        weight: weight,
        mwr: mwrResult,
        twr: twrResult,
        sleeveId: holdingSleeveId?.toString(),
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
              pl: (h.pl * 100).round() / 100,
              weight: (h.weight * 100).round() / 100,
              mwr: (h.mwr * 100).round() / 100,
              twr: h.twr != null ? (h.twr! * 100).round() / 100 : null,
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

  /// Recursively collect all descendant sleeve IDs
  void _collectDescendantSleeveIds(
    String parentSleeveId,
    Map<String, Sleeve> sleeveMap,
    Set<String> result,
  ) {
    for (final sleeve in sleeveMap.values) {
      if (sleeve.parentSleeveId?.toString() == parentSleeveId) {
        result.add(sleeve.id!.toString());
        _collectDescendantSleeveIds(sleeve.id!.toString(), sleeveMap, result);
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

  /// Calculate MWR for a single asset
  double _calculateAssetMWR({
    required String assetId,
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
    required ReturnPeriod period,
    required String comparisonDate,
    required String todayStr,
    required Map<String, double> priceMap,
    required Map<String, Map<String, double>> priceByTickerDate,
    required Map<String, double> derivedFxRateMap,
    required Map<String, double> fxRateMap,
  }) {
    // Get current value
    final lookupKey = asset.yahooSymbol ?? asset.ticker;
    final currentPrice = priceMap[lookupKey];
    if (currentPrice == null || holding.quantity <= 0) {
      return 0;
    }
    final currentValue = currentPrice * holding.quantity;

    // Get historical price at comparison date
    final historicalPrice =
        _getHistoricalPrice(asset, comparisonDate, priceByTickerDate, derivedFxRateMap, fxRateMap);

    if (historicalPrice == null || historicalPrice <= 0) {
      // No historical price - use simple return from cost basis
      if (holding.totalCostEur > 0) {
        return (currentValue - holding.totalCostEur) / holding.totalCostEur;
      }
      return 0;
    }

    // Filter orders in period
    final ordersInPeriod = orders
        .where((o) =>
            _formatDate(o.orderDate).compareTo(comparisonDate) > 0 &&
            _formatDate(o.orderDate).compareTo(todayStr) <= 0)
        .toList();

    // Build position at comparison date
    double positionAtStart = 0;
    double costAtStart = 0;

    for (final order in orders) {
      if (_formatDate(order.orderDate).compareTo(comparisonDate) <= 0) {
        if (order.quantity > 0) {
          positionAtStart += order.quantity;
          costAtStart += order.totalEur;
        } else if (order.quantity < 0) {
          final soldQty = order.quantity.abs();
          if (positionAtStart > 0) {
            final avgCost = costAtStart / positionAtStart;
            costAtStart = math.max(0, costAtStart - avgCost * soldQty);
            positionAtStart = math.max(0, positionAtStart - soldQty);
          }
        }
      }
    }

    final startValue = positionAtStart * historicalPrice;

    // If no starting position, can't calculate MWR
    if (startValue <= 0) {
      // If this is a new position acquired during the period, use cost basis return
      if (holding.totalCostEur > 0) {
        return (currentValue - holding.totalCostEur) / holding.totalCostEur;
      }
      return 0;
    }

    // Calculate period years
    final startDate = DateTime.parse(comparisonDate);
    final endDate = DateTime.parse(todayStr);
    final periodMs = endDate.difference(startDate).inMilliseconds;
    final periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

    // Build cash flows for XIRR
    final cashFlows = ordersInPeriod
        .where((o) => o.quantity != 0)
        .map((o) => CashFlow(
              date: _formatDate(o.orderDate),
              amount: o.quantity > 0 ? o.totalEur : -o.totalEur.abs(),
            ))
        .toList();

    final mwrResult = calculateMWR(
      startDate: comparisonDate,
      endDate: todayStr,
      startValue: startValue,
      endValue: currentValue,
      cashFlows: cashFlows,
    );

    // Return compounded return for periods < 1 year, annualized for longer
    return periodYears >= 1 ? mwrResult.annualizedReturn : mwrResult.compoundedReturn;
  }

  /// Calculate TWR for a single asset
  double? _calculateAssetTWR({
    required String assetId,
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
    required ReturnPeriod period,
    required String comparisonDate,
    required String todayStr,
    required Map<String, double> priceMap,
    required Map<String, Map<String, double>> priceByTickerDate,
    required Map<String, double> derivedFxRateMap,
    required Map<String, double> fxRateMap,
  }) {
    // Get current price
    final lookupKey = asset.yahooSymbol ?? asset.ticker;
    final currentPrice = priceMap[lookupKey];
    if (currentPrice == null || holding.quantity <= 0) {
      return null;
    }

    // Get historical price at comparison date
    final historicalPrice =
        _getHistoricalPrice(asset, comparisonDate, priceByTickerDate, derivedFxRateMap, fxRateMap);

    if (historicalPrice == null || historicalPrice <= 0) {
      return null;
    }

    // Simple price return for TWR (ignores cash flows)
    return (currentPrice - historicalPrice) / historicalPrice;
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

    // Apply FX conversion if needed
    final derivedFxRate = derivedFxRateMap[asset.yahooSymbol!];
    if (derivedFxRate != null) {
      return price * derivedFxRate;
    }

    // Fall back to FX cache rate
    if (asset.currency != 'EUR') {
      final fxRate = fxRateMap['${asset.currency}EUR'] ?? 1.0;
      return price * fxRate;
    }

    return price;
  }

  /// Format a DateTime to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

/// Internal data class for holding calculations
class _HoldingData {
  final String symbol;
  final String name;
  final String isin;
  final double value;
  final double costBasis;
  final double pl;
  final double weight;
  final double mwr;
  final double? twr;
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
    required this.pl,
    required this.weight,
    required this.mwr,
    required this.twr,
    required this.sleeveId,
    required this.sleeveName,
    required this.assetId,
    required this.quantity,
  });
}
