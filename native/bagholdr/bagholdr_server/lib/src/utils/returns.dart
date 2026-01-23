import 'dart:math' as math;

/// Cash flow transaction for XIRR calculation
class XirrTransaction {
  final double amount;
  final DateTime when;

  const XirrTransaction({required this.amount, required this.when});
}

/// Calculate XIRR (Extended Internal Rate of Return) using Newton-Raphson method
///
/// XIRR finds the rate r such that:
/// sum(amount_i / (1 + r)^years_i) = 0
///
/// where years_i is the number of years from the first transaction to transaction i
///
/// Returns the annualized rate of return (e.g., 0.085 for 8.5% p.a.)
/// Throws if calculation fails to converge or inputs are invalid
double xirr(List<XirrTransaction> transactions, {double guess = 0.1}) {
  if (transactions.isEmpty) {
    throw ArgumentError('At least one transaction is required');
  }

  // Validate: must have both positive and negative cash flows for IRR to exist
  final hasPositive = transactions.any((tx) => tx.amount > 0);
  final hasNegative = transactions.any((tx) => tx.amount < 0);
  if (!hasPositive || !hasNegative) {
    throw ArgumentError(
        'XIRR requires both positive and negative cash flows');
  }

  // Sort transactions by date
  final sorted = List<XirrTransaction>.from(transactions)
    ..sort((a, b) => a.when.compareTo(b.when));

  final firstDate = sorted.first.when;

  // Rate bounds - tighter than before for realistic financial scenarios
  const minRate = -0.99; // -99% (near total loss)
  const maxRate = 5.0; // +500% annual return

  // Helper: calculate years between two dates
  double yearsBetween(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return diff.inMilliseconds / (365.25 * 24 * 60 * 60 * 1000);
  }

  // Helper: calculate NPV (Net Present Value) at a given rate
  double npv(double rate) {
    if (rate <= -1) return double.infinity;
    double total = 0;
    for (final tx in sorted) {
      final years = yearsBetween(firstDate, tx.when);
      total += tx.amount / math.pow(1 + rate, years);
    }
    return total;
  }

  // Helper: calculate derivative of NPV
  double npvDerivative(double rate) {
    if (rate <= -1) return double.negativeInfinity;
    double total = 0;
    for (final tx in sorted) {
      final years = yearsBetween(firstDate, tx.when);
      if (years == 0) continue;
      total -= years * tx.amount / math.pow(1 + rate, years + 1);
    }
    return total;
  }

  // Newton-Raphson iteration
  // Clamp initial guess to valid range to avoid immediate non-finite results
  double rate = guess.clamp(minRate, maxRate);
  const maxIterations = 100;
  const tolerance = 1e-10;
  const npvTolerance = 1e-10;

  for (var i = 0; i < maxIterations; i++) {
    final value = npv(rate);
    final derivative = npvDerivative(rate);

    // Check for NaN/Infinity - abort Newton if numerical issues
    if (!value.isFinite || !derivative.isFinite) {
      break;
    }

    // Check if NPV is already close enough to zero
    if (value.abs() < npvTolerance) {
      return rate;
    }

    if (derivative.abs() < 1e-15) {
      // Derivative too small, can't continue Newton
      break;
    }

    final newRate = rate - value / derivative;

    // Check for NaN after division
    if (!newRate.isFinite) {
      break;
    }

    // Check for convergence (both step size AND NPV should be small)
    if ((newRate - rate).abs() < tolerance && value.abs() < npvTolerance) {
      return newRate;
    }

    rate = newRate;

    // Bound the rate to prevent divergence
    if (rate < minRate) rate = minRate;
    if (rate > maxRate) rate = maxRate;
  }

  // If Newton-Raphson didn't converge, try bisection method
  double low = minRate;
  double high = maxRate;

  // Find bracket
  double npvLow = npv(low);
  double npvHigh = npv(high);

  // Check if root is already at endpoints
  if (npvLow.isFinite && npvLow.abs() < npvTolerance) return low;
  if (npvHigh.isFinite && npvHigh.abs() < npvTolerance) return high;

  // If same sign, try to find a valid bracket by scanning
  if (npvLow * npvHigh > 0) {
    // Try a grid search to find a sign change
    // Use 200 steps for finer resolution to catch narrow zero-crossings
    const steps = 200;
    final stepSize = (maxRate - minRate) / steps;
    double? foundLow;
    double? foundHigh;
    double? prevNpv;
    double prevRate = minRate;

    for (var i = 0; i <= steps; i++) {
      final testRate = minRate + i * stepSize;
      final testNpv = npv(testRate);

      // Skip non-finite values (overflow/underflow edge cases)
      if (!testNpv.isFinite) continue;

      if (prevNpv != null && prevNpv * testNpv < 0) {
        // Found a sign change
        foundLow = prevRate;
        foundHigh = testRate;
        break;
      }
      prevNpv = testNpv;
      prevRate = testRate;
    }

    if (foundLow != null && foundHigh != null) {
      low = foundLow;
      high = foundHigh;
      npvLow = npv(low);
      npvHigh = npv(high);
    } else {
      // No bracket found - no solution in range
      throw StateError(
          'XIRR: No solution found in range [$minRate, $maxRate]');
    }
  }

  // Bisection search
  for (var i = 0; i < maxIterations; i++) {
    final mid = (low + high) / 2;
    final npvMid = npv(mid);

    if (npvMid.abs() < npvTolerance) {
      return mid;
    }

    if (npvLow * npvMid < 0) {
      high = mid;
      npvHigh = npvMid;
    } else {
      low = mid;
      npvLow = npvMid;
    }

    if ((high - low).abs() < tolerance) {
      return mid;
    }
  }

  throw StateError('XIRR calculation failed to converge');
}

/// Calculate Total Return for a period.
///
/// Total Return answers: "How much did I get back vs how much did I put in?"
///
/// Formula: (endValue + sellProceeds) / (startValue + buyCosts + feeCosts) - 1
///
/// For ALL period: startValue=0, all orders included.
/// For sub-periods: startValue = position at start × historical price.
///
/// Returns null if denominator <= 0 (no cost basis).
double? calculateTotalReturn({
  required double startValue,
  required double endValue,
  required List<({double quantity, double totalEur, String date})> orders,
  required String periodStartDate,
  required String periodEndDate,
}) {
  double buyCosts = 0;
  double sellProceeds = 0;
  double feeCosts = 0;

  for (final order in orders) {
    // Include orders where date > periodStartDate && date <= periodEndDate
    if (order.date.compareTo(periodStartDate) <= 0) continue;
    if (order.date.compareTo(periodEndDate) > 0) continue;

    if (order.quantity > 0) {
      // Buy
      buyCosts += order.totalEur;
    } else if (order.quantity < 0) {
      // Sell
      sellProceeds += order.totalEur.abs();
    } else {
      // Fee/commission (quantity == 0)
      feeCosts += order.totalEur;
    }
  }

  final denominator = startValue + buyCosts + feeCosts;
  if (denominator <= 0) return null;

  return (endValue + sellProceeds) / denominator - 1;
}

/// External cash flow (contribution or withdrawal) for return calculations.
///
/// In the context of portfolio tracking:
/// - A "buy" order represents an external contribution (money flowing INTO the portfolio)
/// - A "sell" order represents a withdrawal (money flowing OUT of the portfolio)
///
/// These are EXTERNAL flows that change the total capital in the portfolio.
/// Internal trades (e.g., selling Stock A to buy Stock B) are NOT cash flows
/// because they don't change the total portfolio value.
///
/// **Timing assumption**: Cash flows are assumed to occur at the START of the
/// specified date, before any market movement on that day.
class CashFlow {
  /// Date of the cash flow (YYYY-MM-DD format)
  final String date;

  /// Amount of the cash flow:
  /// - Positive = contribution/deposit (buy order - money flows IN)
  /// - Negative = withdrawal (sell order - money flows OUT)
  final double amount;

  const CashFlow({required this.date, required this.amount});
}

/// Result of MWR calculation
class MwrResult {
  final double annualizedReturn;
  final double compoundedReturn;
  final double netCashFlow;
  final int cashFlowCount;
  final double periodYears;

  const MwrResult({
    required this.annualizedReturn,
    required this.compoundedReturn,
    required this.netCashFlow,
    required this.cashFlowCount,
    required this.periodYears,
  });
}

/// Calculate Money-Weighted Return (MWR) using XIRR for a period.
///
/// MWR (also called XIRR) finds the constant annual rate of return that would
/// produce the actual profit, given when money was added/removed.
///
/// This gives users their actual rate of return on their money.
MwrResult calculateMWR({
  required String startDate,
  required String endDate,
  required double startValue,
  required double endValue,
  required List<CashFlow> cashFlows,
}) {
  // Filter cash flows within the range (exclusive start, inclusive end)
  final flowsInRange = cashFlows
      .where((cf) => cf.date.compareTo(startDate) > 0 && cf.date.compareTo(endDate) <= 0)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  // Calculate period in years
  final startDateObj = DateTime.parse(startDate);
  final endDateObj = DateTime.parse(endDate);
  final periodMs = endDateObj.difference(startDateObj).inMilliseconds;
  final periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

  // Calculate net cash flow
  final netCashFlow = flowsInRange.fold<double>(0, (sum, cf) => sum + cf.amount);

  // Edge case: very short period (< 1 day) - use simple return
  if (periodYears < 1 / 365) {
    final simpleReturn = startValue > 0 ? (endValue - startValue - netCashFlow) / startValue : 0.0;
    return MwrResult(
      annualizedReturn: simpleReturn,
      compoundedReturn: simpleReturn,
      netCashFlow: netCashFlow,
      cashFlowCount: flowsInRange.length,
      periodYears: periodYears,
    );
  }

  // Edge case: no start value - can't calculate return
  if (startValue <= 0) {
    return MwrResult(
      annualizedReturn: 0,
      compoundedReturn: 0,
      netCashFlow: netCashFlow,
      cashFlowCount: flowsInRange.length,
      periodYears: periodYears,
    );
  }

  // If no cash flows, use simple annualized return
  if (flowsInRange.isEmpty) {
    final simpleReturn = (endValue - startValue) / startValue;
    // Annualize: (1 + total)^(1/years) - 1
    final annualized = periodYears > 0
        ? (math.pow(1 + simpleReturn, 1 / periodYears) - 1).toDouble()
        : simpleReturn;
    return MwrResult(
      annualizedReturn: annualized,
      compoundedReturn: simpleReturn,
      netCashFlow: 0,
      cashFlowCount: 0,
      periodYears: periodYears,
    );
  }

  // Build XIRR transactions
  // Convention: outflows (money invested) are negative, inflows (money received) are positive
  final transactions = <XirrTransaction>[];

  // Starting value as initial outflow (we "bought" the portfolio at start)
  transactions.add(XirrTransaction(
    amount: -startValue,
    when: startDateObj,
  ));

  // Cash flows during period
  // Buys (positive in our CashFlow) = money going into portfolio = outflow for XIRR = negative
  // Sells (negative in our CashFlow) = money coming from portfolio = inflow for XIRR = positive
  for (final cf in flowsInRange) {
    transactions.add(XirrTransaction(
      amount: -cf.amount, // Negate: our convention is opposite to XIRR
      when: DateTime.parse(cf.date),
    ));
  }

  // Ending value as final inflow (we "sold" the portfolio at end)
  transactions.add(XirrTransaction(
    amount: endValue,
    when: endDateObj,
  ));

  try {
    // XIRR returns annualized rate directly
    final annualizedReturn = xirr(transactions);

    // Calculate compounded return: (1 + annual)^years - 1
    final compoundedReturn =
        (math.pow(1 + annualizedReturn, periodYears) - 1).toDouble();

    return MwrResult(
      annualizedReturn: annualizedReturn,
      compoundedReturn: compoundedReturn,
      netCashFlow: netCashFlow,
      cashFlowCount: flowsInRange.length,
      periodYears: periodYears,
    );
  } catch (_) {
    // XIRR failed to converge - fall back to simple return
    final simpleReturn = (endValue - startValue - netCashFlow) / startValue;
    final annualized = periodYears > 0
        ? (math.pow(1 + simpleReturn, 1 / periodYears) - 1).toDouble()
        : simpleReturn;
    return MwrResult(
      annualizedReturn: annualized,
      compoundedReturn: simpleReturn,
      netCashFlow: netCashFlow,
      cashFlowCount: flowsInRange.length,
      periodYears: periodYears,
    );
  }
}

/// Format a period duration for display
/// Returns "1d", "2w", "1mo", "3mo", "6mo", "1y", etc.
String formatPeriodLabel(double years) {
  final days = (years * 365.25).round();
  if (days < 7) return '${days}d';
  if (days < 30) return '${(days / 7).round()}w';
  if (days < 365) return '${(days / 30).round()}mo';
  return '${years.toStringAsFixed(1)}y';
}

/// Result of TWR calculation
class TwrResult {
  /// Compounded return over the period (e.g., 0.15 = 15% total return)
  /// Null if calculation failed (e.g., portfolio value hit zero)
  final double? twr;

  /// Number of cash flows in the period
  final int cashFlowCount;

  /// Whether the calculation completed successfully
  final bool isValid;

  /// Error message if calculation failed
  final String? error;

  const TwrResult({
    required this.twr,
    required this.cashFlowCount,
    this.isValid = true,
    this.error,
  });

  /// Create a failed result
  const TwrResult.failed(this.error)
      : twr = null,
        cashFlowCount = 0,
        isValid = false;
}

/// Calculate Time-Weighted Return (TWR) for a period.
///
/// TWR measures portfolio performance independent of external cash flows.
/// It answers: "How would $1 invested at the start have grown?"
///
/// ## Algorithm
/// 1. Break the period into sub-periods at each cash flow date
/// 2. Calculate return for each sub-period: (end - start) / start
/// 3. Geometrically link: TWR = [(1+R1) × (1+R2) × ... × (1+Rn)] - 1
///
/// ## Date Semantics
///
/// The return is measured from **end of startDate** to **end of endDate**.
/// This means startDate's market movement is NOT included in the return.
///
/// Example: TWR from Jan 1 to Dec 31 measures growth from Jan 1 close to Dec 31 close.
/// If you want to include Jan 1's return, use Dec 31 (prior year) as startDate.
///
/// ## Timing Contract
///
/// **Cash flows** are assumed to occur at START of day:
/// - A deposit on July 1st means: money available at market open July 1st
/// - A withdrawal on July 1st means: money removed at market open July 1st
///
/// **getPortfolioValueAtDate(date)** must return END-of-day value:
/// - Holdings as of that date (orders on date D included in holdings for D)
/// - Prices as of market close on that date
/// - For non-trading days (weekends/holidays), must return the most recent
///   available valuation (using last known prices)
/// - Must return a finite, non-negative value (will fail otherwise)
///
/// This "start-of-day flow + EOD valuation" convention is an approximation.
/// It assumes overnight movement between prior close and market open is negligible.
/// Alternative conventions exist (e.g., EOD flows) but this is internally consistent.
///
/// ## Edge Cases
/// - Returns [TwrResult.failed] if portfolio value drops to zero or negative mid-period
/// - Returns [TwrResult.failed] if start value is zero but there are cash flows
/// - Returns TWR of 0 if start value is zero and no cash flows (nothing to measure)
/// - Returns [TwrResult.failed] if callback returns non-finite or negative values
/// - Handles multiple cash flows on the same day by aggregating them
///
/// ## Parameters
/// - [startDate] - Period start date (YYYY-MM-DD). EOD value is the starting point.
/// - [endDate] - Period end date (YYYY-MM-DD). EOD value is the ending point.
/// - [cashFlows] - List of external contributions/withdrawals (see [CashFlow]).
///   The returned [cashFlowCount] is the raw number of flows, not unique dates.
/// - [getPortfolioValueAtDate] - Callback returning EOD portfolio value for any date.
TwrResult calculateTWR({
  required String startDate,
  required String endDate,
  required List<CashFlow> cashFlows,
  required double Function(String date) getPortfolioValueAtDate,
}) {
  // Helper to validate callback results
  String? validateValue(double value, String date) {
    if (!value.isFinite) {
      return 'Invalid portfolio value (non-finite) for $date';
    }
    if (value < 0) {
      return 'Invalid portfolio value (negative) for $date';
    }
    return null;
  }

  // Filter and sort cash flows within the range (exclusive start, inclusive end)
  // Exclusive start because startDate's value is our starting point (already invested)
  final flowsInRange = cashFlows
      .where((cf) => cf.date.compareTo(startDate) > 0 && cf.date.compareTo(endDate) <= 0)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final startValue = getPortfolioValueAtDate(startDate);

  // Validate start value
  final startError = validateValue(startValue, startDate);
  if (startError != null) {
    return TwrResult.failed(startError);
  }

  // Edge case: no starting capital
  if (startValue == 0) {
    if (flowsInRange.isNotEmpty) {
      // Can't measure return when starting from zero with contributions
      return const TwrResult.failed(
        'Cannot calculate TWR: no starting capital on startDate but cash flows exist',
      );
    }
    // No capital and no flows - nothing to measure
    return const TwrResult(twr: 0, cashFlowCount: 0);
  }

  // If no cash flows, use simple return
  if (flowsInRange.isEmpty) {
    final endValue = getPortfolioValueAtDate(endDate);
    final endError = validateValue(endValue, endDate);
    if (endError != null) {
      return TwrResult.failed(endError);
    }
    return TwrResult(
      twr: (endValue - startValue) / startValue,
      cashFlowCount: 0,
    );
  }

  // Group cash flows by date (multiple orders on same day are one event)
  final flowsByDate = <String, double>{};
  for (final flow in flowsInRange) {
    flowsByDate[flow.date] = (flowsByDate[flow.date] ?? 0) + flow.amount;
  }

  final uniqueDates = flowsByDate.keys.toList()..sort();

  // Helper: get previous calendar date
  // Note: The callback is responsible for handling non-trading days
  // (e.g., returning Friday's value when asked for Saturday)
  String getPreviousDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final prevDate = date.subtract(const Duration(days: 1));
    return '${prevDate.year.toString().padLeft(4, '0')}-'
        '${prevDate.month.toString().padLeft(2, '0')}-'
        '${prevDate.day.toString().padLeft(2, '0')}';
  }

  // Calculate sub-period returns using geometric linking
  double twrProduct = 1;
  String subPeriodStart = startDate;
  double subPeriodStartValue = startValue;

  for (final flowDate in uniqueDates) {
    // Value "just before" the cash flow = end of previous day
    // This captures all market movement up to but not including flowDate
    final dayBefore = getPreviousDate(flowDate);
    final valueBeforeFlow = dayBefore.compareTo(subPeriodStart) >= 0
        ? getPortfolioValueAtDate(dayBefore)
        : subPeriodStartValue;

    // Validate valueBeforeFlow
    final beforeError = validateValue(valueBeforeFlow, dayBefore);
    if (beforeError != null) {
      return TwrResult.failed(beforeError);
    }

    // Check if market losses dropped portfolio to zero
    if (valueBeforeFlow == 0) {
      return TwrResult.failed(
        'Portfolio value dropped to zero by $dayBefore (market losses). TWR undefined.',
      );
    }

    // Calculate and chain sub-period return
    // Note: subPeriodStartValue > 0 is guaranteed by earlier checks
    final subReturn = (valueBeforeFlow - subPeriodStartValue) / subPeriodStartValue;
    twrProduct *= 1 + subReturn;

    // New starting point for next sub-period:
    // Value just before flow + the cash flow amount
    // This represents the capital base immediately after the flow
    final cashFlowAmount = flowsByDate[flowDate]!;
    subPeriodStartValue = valueBeforeFlow + cashFlowAmount;
    subPeriodStart = flowDate;

    // Check if flow resulted in zero/negative value (full withdrawal)
    if (subPeriodStartValue <= 0 && flowDate != endDate) {
      return TwrResult.failed(
        'Portfolio fully withdrawn on $flowDate. TWR undefined for remaining period.',
      );
    }
  }

  // Final sub-period (from last cash flow to end date)
  final endValue = getPortfolioValueAtDate(endDate);

  // Validate end value
  final endError = validateValue(endValue, endDate);
  if (endError != null) {
    return TwrResult.failed(endError);
  }

  if (subPeriodStartValue > 0) {
    final finalReturn = (endValue - subPeriodStartValue) / subPeriodStartValue;
    twrProduct *= 1 + finalReturn;
  }

  return TwrResult(
    twr: twrProduct - 1,
    cashFlowCount: flowsInRange.length,
  );
}
