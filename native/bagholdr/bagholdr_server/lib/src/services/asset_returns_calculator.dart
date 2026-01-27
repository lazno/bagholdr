import 'dart:math' as math;

import '../generated/protocol.dart';
import '../utils/returns.dart';

/// Result of asset return calculations
class AssetReturnsResult {
  /// Current market value of the asset
  final double value;

  /// Total cost basis of the asset
  final double costBasis;

  /// Period-specific P/L (changes with time range)
  /// Calculated as: currentValue - startValue + netCashFlows
  /// This is the total return (realized + unrealized) for the period
  final double periodPL;

  /// Unrealized P/L (paper gain) for the period
  /// This is the price gain on current holdings only, excluding sales
  /// - ALL period: current value - cost basis
  /// - Other periods: current value - reference value
  ///   (where reference = qty at start × price at start + cost of new purchases)
  final double unrealizedPL;

  /// Unrealized P/L as a percentage of the reference value
  final double? unrealizedPLPct;

  /// Realized P/L from sales during the period
  /// - ALL period: sum of all realized gains from all sales ever
  /// - Other periods: sum of realized gains from sales during the period
  final double realizedPL;

  /// Money-weighted return (MWR/XIRR)
  final double mwr;

  /// Time-weighted return (TWR)
  final double? twr;

  /// Total return percentage
  final double? totalReturn;

  const AssetReturnsResult({
    required this.value,
    required this.costBasis,
    required this.periodPL,
    required this.unrealizedPL,
    required this.unrealizedPLPct,
    required this.realizedPL,
    required this.mwr,
    required this.twr,
    required this.totalReturn,
  });
}

/// Calculator for asset return metrics
///
/// This class centralizes all return calculations for a single asset.
/// It's a pure calculation class with no database dependencies - all
/// required data must be passed in.
class AssetReturnsCalculator {
  AssetReturnsCalculator._();

  /// Calculate all return metrics for a single asset
  ///
  /// [asset] - The asset to calculate returns for
  /// [orders] - All orders for this asset (will be sorted internally)
  /// [holding] - Current holding for the asset
  /// [period] - Time period for calculations
  /// [comparisonDate] - Start date for the period (YYYY-MM-DD)
  /// [todayStr] - End date for calculations (YYYY-MM-DD)
  /// [priceMap] - Map of ticker -> current price in EUR
  /// [priceByTickerDate] - Map of ticker -> date -> historical price
  /// [derivedFxRateMap] - Map of ticker -> derived FX rate
  /// [fxRateMap] - Map of currency pair -> FX rate
  static AssetReturnsResult calculate({
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
    final currentValue = currentPrice != null
        ? currentPrice * holding.quantity
        : holding.totalCostEur;

    // Calculate cost basis using average cost method
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    double totalQty = 0;
    double totalCostEur = 0;

    for (final order in sortedOrders) {
      if (order.quantity > 0) {
        // BUY
        totalQty += order.quantity;
        totalCostEur += order.totalEur;
      } else if (order.quantity < 0) {
        // SELL
        final soldQty = order.quantity.abs();
        if (totalQty > 0) {
          final avgCostEur = totalCostEur / totalQty;
          totalCostEur = math.max(0, totalCostEur - avgCostEur * soldQty);
          totalQty = math.max(0, totalQty - soldQty);
        }
      } else {
        // COMMISSION (quantity = 0)
        totalCostEur += order.totalEur;
      }
    }

    final costBasis = totalCostEur;

    // Calculate MWR
    final mwr = _calculateMWR(
      asset: asset,
      orders: sortedOrders,
      holding: holding,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceMap: priceMap,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate TWR
    final twr = _calculateTWR(
      asset: asset,
      orders: sortedOrders,
      holding: holding,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceMap: priceMap,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate Total Return
    final totalReturn = _calculateTotalReturn(
      asset: asset,
      orders: sortedOrders,
      holding: holding,
      period: period,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceMap: priceMap,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate Period P/L (total return for period)
    final periodPL = _calculatePeriodPL(
      asset: asset,
      orders: sortedOrders,
      holding: holding,
      currentValue: currentValue,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate Unrealized P/L (paper gain on current holdings)
    final unrealizedResult = _calculateUnrealizedPL(
      asset: asset,
      orders: sortedOrders,
      holding: holding,
      currentValue: currentValue,
      costBasis: costBasis,
      period: period,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
      priceByTickerDate: priceByTickerDate,
      derivedFxRateMap: derivedFxRateMap,
      fxRateMap: fxRateMap,
    );

    // Calculate Realized P/L (gains from sales)
    final realizedPL = _calculateRealizedPL(
      orders: sortedOrders,
      period: period,
      comparisonDate: comparisonDate,
      todayStr: todayStr,
    );

    return AssetReturnsResult(
      value: currentValue,
      costBasis: costBasis,
      periodPL: periodPL,
      unrealizedPL: unrealizedResult.amount,
      unrealizedPLPct: unrealizedResult.percentage,
      realizedPL: realizedPL,
      mwr: mwr,
      twr: twr,
      totalReturn: totalReturn,
    );
  }

  /// Calculate MWR for a single asset
  static double _calculateMWR({
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
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

    // Sort orders by date
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    // Find first buy order (to determine if this is a short holding)
    final firstBuyOrder = sortedOrders.cast<Order?>().firstWhere(
          (o) => o != null && o.quantity > 0,
          orElse: () => null,
        );

    if (firstBuyOrder == null) {
      // No buy orders, can't calculate return
      return 0;
    }

    final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);

    // Check if this is a "short holding" - asset acquired after comparison date
    final isShortHolding = firstOrderDateStr.compareTo(comparisonDate) > 0;
    final effectiveStartDate =
        isShortHolding ? firstOrderDateStr : comparisonDate;

    // Get historical price at effective start date
    final historicalPrice = _getHistoricalPrice(
        asset, effectiveStartDate, priceByTickerDate, derivedFxRateMap, fxRateMap);

    if (historicalPrice == null || historicalPrice <= 0) {
      // No historical price - use simple return from cost basis
      if (holding.totalCostEur > 0) {
        return (currentValue - holding.totalCostEur) / holding.totalCostEur;
      }
      return 0;
    }

    // Build position at effective start date
    double positionAtStart = 0;
    double costAtStart = 0;

    for (final order in sortedOrders) {
      if (_formatDate(order.orderDate).compareTo(effectiveStartDate) <= 0) {
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

    // Calculate period years using effective start date
    final startDate = DateTime.parse(effectiveStartDate);
    final endDate = DateTime.parse(todayStr);
    final periodMs = endDate.difference(startDate).inMilliseconds;
    final periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

    // Build cash flows for XIRR (only flows AFTER effective start date)
    final cashFlows = sortedOrders
        .where((o) =>
            o.quantity != 0 &&
            _formatDate(o.orderDate).compareTo(effectiveStartDate) > 0 &&
            _formatDate(o.orderDate).compareTo(todayStr) <= 0)
        .map((o) => CashFlow(
              date: _formatDate(o.orderDate),
              amount: o.quantity > 0 ? o.totalEur : -o.totalEur.abs(),
            ))
        .toList();

    final mwrResult = calculateMWR(
      startDate: effectiveStartDate,
      endDate: todayStr,
      startValue: startValue,
      endValue: currentValue,
      cashFlows: cashFlows,
    );

    // Return compounded return for periods < 1 year, annualized for longer
    return periodYears >= 1 ? mwrResult.annualizedReturn : mwrResult.compoundedReturn;
  }

  /// Calculate TWR for a single asset
  static double? _calculateTWR({
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
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

    // Sort orders by date and find first buy order
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    final firstBuyOrder = sortedOrders.cast<Order?>().firstWhere(
          (o) => o != null && o.quantity > 0,
          orElse: () => null,
        );

    if (firstBuyOrder == null) {
      return null;
    }

    final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);

    // Check if this is a "short holding" - asset acquired after comparison date
    final isShortHolding = firstOrderDateStr.compareTo(comparisonDate) > 0;
    final effectiveStartDate =
        isShortHolding ? firstOrderDateStr : comparisonDate;

    // Get historical price at effective start date
    final historicalPrice = _getHistoricalPrice(
        asset, effectiveStartDate, priceByTickerDate, derivedFxRateMap, fxRateMap);

    if (historicalPrice == null || historicalPrice <= 0) {
      return null;
    }

    // Simple price return for TWR (ignores cash flows)
    return (currentPrice - historicalPrice) / historicalPrice;
  }

  /// Calculate Total Return for a single asset
  static double? _calculateTotalReturn({
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
      return null;
    }
    final currentValue = currentPrice * holding.quantity;

    // Sort orders by date
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    // Find first buy order
    final firstBuyOrder = sortedOrders.cast<Order?>().firstWhere(
          (o) => o != null && o.quantity > 0,
          orElse: () => null,
        );

    if (firstBuyOrder == null) {
      return null;
    }

    final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);
    final isAllPeriod = period == ReturnPeriod.all;

    // For ALL period: startValue=0, include all orders from the beginning
    // For sub-periods: calculate position at start and use historical price
    double startValue;
    String periodStartDate;

    if (isAllPeriod) {
      startValue = 0;
      periodStartDate = '1900-01-01';
    } else {
      final isShortHolding = firstOrderDateStr.compareTo(comparisonDate) > 0;
      final effectiveStartDate =
          isShortHolding ? firstOrderDateStr : comparisonDate;
      periodStartDate = effectiveStartDate;

      // Build position at effective start date
      double positionAtStart = 0;
      for (final order in sortedOrders) {
        if (_formatDate(order.orderDate).compareTo(effectiveStartDate) <= 0) {
          if (order.quantity > 0) {
            positionAtStart += order.quantity;
          } else if (order.quantity < 0) {
            positionAtStart =
                (positionAtStart - order.quantity.abs()).clamp(0, double.infinity);
          }
        }
      }

      // Get historical price at start
      final historicalPrice = _getHistoricalPrice(
          asset, effectiveStartDate, priceByTickerDate, derivedFxRateMap, fxRateMap);

      if (historicalPrice != null && positionAtStart > 0) {
        startValue = positionAtStart * historicalPrice;
      } else {
        startValue = 0;
      }
    }

    // Build order tuples for calculateTotalReturn
    final orderTuples = sortedOrders
        .map((o) => (
              quantity: o.quantity,
              totalEur: o.totalEur,
              date: _formatDate(o.orderDate),
            ))
        .toList();

    return calculateTotalReturn(
      startValue: startValue,
      endValue: currentValue,
      orders: orderTuples,
      periodStartDate: periodStartDate,
      periodEndDate: todayStr,
    );
  }

  /// Calculate unrealized P/L (paper gain / Kursgewinn) for the period
  ///
  /// This calculates the price gain on CURRENT holdings only.
  ///
  /// For ALL period: current value - cost basis
  /// For other periods: currentQty × (currentPrice - referencePrice)
  ///   where referencePrice is weighted average of:
  ///   - historical price at start for "old" shares (min of currentQty, positionAtStart)
  ///   - purchase price for "new" shares bought during period
  static ({double amount, double? percentage}) _calculateUnrealizedPL({
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
    required double currentValue,
    required double costBasis,
    required ReturnPeriod period,
    required String comparisonDate,
    required String todayStr,
    required Map<String, Map<String, double>> priceByTickerDate,
    required Map<String, double> derivedFxRateMap,
    required Map<String, double> fxRateMap,
  }) {
    // For ALL period, unrealized P/L is simply current value - cost basis
    if (period == ReturnPeriod.all) {
      final unrealized = currentValue - costBasis;
      final percentage = costBasis > 0 ? unrealized / costBasis : null;
      return (amount: unrealized, percentage: percentage);
    }

    final currentQty = holding.quantity;
    if (currentQty <= 0) {
      return (amount: 0.0, percentage: null);
    }

    // Find first buy order to check for short holding
    final firstBuyOrder = orders.cast<Order?>().firstWhere(
          (o) => o != null && o.quantity > 0,
          orElse: () => null,
        );

    if (firstBuyOrder == null) {
      return (amount: 0.0, percentage: null);
    }

    final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);
    final isShortHolding = firstOrderDateStr.compareTo(comparisonDate) > 0;
    final effectiveStartDate = isShortHolding ? firstOrderDateStr : comparisonDate;

    // Build position at effective start date
    double positionAtStart = 0;
    for (final order in orders) {
      final orderDateStr = _formatDate(order.orderDate);
      if (orderDateStr.compareTo(effectiveStartDate) <= 0) {
        if (order.quantity > 0) {
          positionAtStart += order.quantity;
        } else if (order.quantity < 0) {
          positionAtStart = math.max(0, positionAtStart - order.quantity.abs());
        }
      }
    }

    // Get historical price at start
    final historicalPrice = _getHistoricalPrice(
      asset,
      effectiveStartDate,
      priceByTickerDate,
      derivedFxRateMap,
      fxRateMap,
    );

    // Calculate shares bought during the period and their cost
    double sharesBoughtDuringPeriod = 0;
    double costOfNewPurchases = 0;
    for (final order in orders) {
      final orderDateStr = _formatDate(order.orderDate);
      if (orderDateStr.compareTo(effectiveStartDate) > 0 &&
          orderDateStr.compareTo(todayStr) <= 0) {
        if (order.quantity > 0) {
          sharesBoughtDuringPeriod += order.quantity;
          costOfNewPurchases += order.totalEur;
        }
        // Note: sells don't affect the reference calculation for unrealized P/L
      }
    }

    // Calculate reference value for CURRENT holdings
    // Current holdings consist of:
    // 1. "Old" shares: min(currentQty, positionAtStart) shares valued at historical price
    // 2. "New" shares: max(0, currentQty - positionAtStart) shares valued at purchase cost
    //
    // If we sold shares, currentQty < positionAtStart, so all current shares are "old"
    // If we bought shares, currentQty > positionAtStart, some are "new"

    final oldShares = math.min(currentQty, positionAtStart);
    final newShares = math.max(0.0, currentQty - positionAtStart);

    double referenceValue = 0;

    // Reference for old shares (at historical price)
    if (historicalPrice != null && oldShares > 0) {
      referenceValue += oldShares * historicalPrice;
    } else if (oldShares > 0) {
      // No historical price - fall back to proportional cost basis
      // This is an approximation when we don't have price data
      referenceValue += (oldShares / currentQty) * costBasis;
    }

    // Reference for new shares (at purchase cost)
    if (newShares > 0 && sharesBoughtDuringPeriod > 0) {
      // Use proportional cost of new purchases
      final avgNewShareCost = costOfNewPurchases / sharesBoughtDuringPeriod;
      referenceValue += newShares * avgNewShareCost;
    }

    final unrealized = currentValue - referenceValue;
    final percentage = referenceValue > 0 ? unrealized / referenceValue : null;

    return (amount: unrealized, percentage: percentage);
  }

  /// Calculate realized P/L from sales during the period
  ///
  /// For ALL period: sum of all realized gains from all sales ever
  /// For other periods: sum of realized gains from sales during the period
  ///
  /// Realized gain per sale = sale proceeds - (avg cost at time of sale × qty sold)
  static double _calculateRealizedPL({
    required List<Order> orders,
    required ReturnPeriod period,
    required String comparisonDate,
    required String todayStr,
  }) {
    // Process orders chronologically to track avg cost at each sale
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    // Determine the date range for realized P/L
    String startDate;
    if (period == ReturnPeriod.all) {
      startDate = '1900-01-01'; // Include all sales
    } else {
      // Find first buy order for effective start date
      final firstBuyOrder = sortedOrders.cast<Order?>().firstWhere(
            (o) => o != null && o.quantity > 0,
            orElse: () => null,
          );
      if (firstBuyOrder != null) {
        final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);
        startDate = firstOrderDateStr.compareTo(comparisonDate) > 0
            ? firstOrderDateStr
            : comparisonDate;
      } else {
        startDate = comparisonDate;
      }
    }

    double totalQty = 0;
    double totalCostEur = 0;
    double realizedPL = 0;

    for (final order in sortedOrders) {
      final orderDateStr = _formatDate(order.orderDate);

      if (order.quantity > 0) {
        // BUY: add to position
        totalQty += order.quantity;
        totalCostEur += order.totalEur;
      } else if (order.quantity < 0) {
        // SELL: calculate realized P/L if within period
        final soldQty = order.quantity.abs();
        final saleProceeds = order.totalEur.abs();

        if (totalQty > 0) {
          final avgCost = totalCostEur / totalQty;
          final costOfSold = avgCost * soldQty;

          // Only count this sale if it's within the period
          if (orderDateStr.compareTo(startDate) > 0 &&
              orderDateStr.compareTo(todayStr) <= 0) {
            realizedPL += saleProceeds - costOfSold;
          }

          // Update running totals (always, regardless of period)
          totalCostEur = math.max(0, totalCostEur - costOfSold);
          totalQty = math.max(0, totalQty - soldQty);
        }
      } else {
        // COMMISSION: add to cost basis
        totalCostEur += order.totalEur;
      }
    }

    return realizedPL;
  }

  /// Calculate period-specific absolute return for an asset
  ///
  /// Returns: currentValue - startValue - netBuys + netSells
  static double _calculatePeriodPL({
    required Asset asset,
    required List<Order> orders,
    required Holding holding,
    required double currentValue,
    required String comparisonDate,
    required String todayStr,
    required Map<String, Map<String, double>> priceByTickerDate,
    required Map<String, double> derivedFxRateMap,
    required Map<String, double> fxRateMap,
  }) {
    // Sort orders by date
    final sortedOrders = List<Order>.from(orders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    // Find first buy order to determine if this is a short holding
    final firstBuyOrder = sortedOrders.cast<Order?>().firstWhere(
          (o) => o != null && o.quantity > 0,
          orElse: () => null,
        );

    if (firstBuyOrder == null) {
      return 0;
    }

    final firstOrderDateStr = _formatDate(firstBuyOrder.orderDate);
    final isShortHolding = firstOrderDateStr.compareTo(comparisonDate) > 0;
    final effectiveStartDate = isShortHolding ? firstOrderDateStr : comparisonDate;

    // Build position at effective start date
    double positionAtStart = 0;
    for (final order in sortedOrders) {
      if (_formatDate(order.orderDate).compareTo(effectiveStartDate) <= 0) {
        if (order.quantity > 0) {
          positionAtStart += order.quantity;
        } else if (order.quantity < 0) {
          positionAtStart = (positionAtStart - order.quantity.abs()).clamp(0, double.infinity);
        }
      }
    }

    // Get historical price at start
    final historicalPrice = _getHistoricalPrice(
      asset,
      effectiveStartDate,
      priceByTickerDate,
      derivedFxRateMap,
      fxRateMap,
    );

    double startValue = 0;
    if (historicalPrice != null && positionAtStart > 0) {
      startValue = positionAtStart * historicalPrice;
    }

    // Calculate net cash flows during period (buys are negative, sells are positive)
    double netCashFlows = 0;
    for (final order in sortedOrders) {
      final orderDateStr = _formatDate(order.orderDate);
      if (orderDateStr.compareTo(effectiveStartDate) > 0 &&
          orderDateStr.compareTo(todayStr) <= 0) {
        if (order.quantity > 0) {
          // Buy: money out (negative for return calculation)
          netCashFlows -= order.totalEur;
        } else if (order.quantity < 0) {
          // Sell: money in (positive for return calculation)
          netCashFlows += order.totalEur.abs();
        }
        // Fees (quantity=0) don't affect absolute return calculation directly
      }
    }

    // Period return = current value - start value + net cash flows from sales - cash spent on buys
    // Which simplifies to: current value - start value + netCashFlows
    return currentValue - startValue + netCashFlows;
  }

  /// Get historical price for an asset at a given date
  static double? _getHistoricalPrice(
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
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
