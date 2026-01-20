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
/// Throws if calculation fails to converge
double xirr(List<XirrTransaction> transactions, {double guess = 0.1}) {
  if (transactions.isEmpty) {
    throw ArgumentError('At least one transaction is required');
  }

  // Sort transactions by date
  final sorted = List<XirrTransaction>.from(transactions)
    ..sort((a, b) => a.when.compareTo(b.when));

  final firstDate = sorted.first.when;

  // Helper: calculate years between two dates
  double yearsBetween(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return diff.inMilliseconds / (365.25 * 24 * 60 * 60 * 1000);
  }

  // Helper: calculate NPV (Net Present Value) at a given rate
  double npv(double rate) {
    double total = 0;
    for (final tx in sorted) {
      final years = yearsBetween(firstDate, tx.when);
      if (rate <= -1 && years > 0) {
        // Avoid negative base with fractional exponent
        return double.infinity;
      }
      total += tx.amount / math.pow(1 + rate, years);
    }
    return total;
  }

  // Helper: calculate derivative of NPV
  double npvDerivative(double rate) {
    double total = 0;
    for (final tx in sorted) {
      final years = yearsBetween(firstDate, tx.when);
      if (years == 0) continue;
      if (rate <= -1 && years > 0) {
        return double.negativeInfinity;
      }
      total -= years * tx.amount / math.pow(1 + rate, years + 1);
    }
    return total;
  }

  // Newton-Raphson iteration
  double rate = guess;
  const maxIterations = 100;
  const tolerance = 1e-10;

  for (var i = 0; i < maxIterations; i++) {
    final value = npv(rate);
    final derivative = npvDerivative(rate);

    if (derivative.abs() < 1e-15) {
      // Derivative too small, can't continue
      break;
    }

    final newRate = rate - value / derivative;

    // Check for convergence
    if ((newRate - rate).abs() < tolerance) {
      return newRate;
    }

    rate = newRate;

    // Bound the rate to prevent divergence
    if (rate < -0.999) rate = -0.999;
    if (rate > 10) rate = 10;
  }

  // If Newton-Raphson didn't converge, try bisection method
  double low = -0.999;
  double high = 10.0;

  // Find bracket
  double npvLow = npv(low);
  double npvHigh = npv(high);

  // If same sign, expand search
  if (npvLow * npvHigh > 0) {
    // Try to find a valid bracket
    for (var i = 0; i < 20; i++) {
      if (npvLow > 0) {
        low *= 2;
        if (low < -0.999) low = -0.999;
        npvLow = npv(low);
      } else {
        high *= 2;
        npvHigh = npv(high);
      }
      if (npvLow * npvHigh <= 0) break;
    }
  }

  // Bisection search
  for (var i = 0; i < maxIterations; i++) {
    final mid = (low + high) / 2;
    final npvMid = npv(mid);

    if (npvMid.abs() < tolerance) {
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

/// Cash flow for MWR calculation
class CashFlow {
  final String date; // YYYY-MM-DD
  final double amount; // Positive for buys (inflows), negative for sells (outflows)

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
