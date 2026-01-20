import 'package:intl/intl.dart';

/// Number formatting utilities for financial data display.
///
/// All formatters use Euro (€) as the default currency with
/// European number formatting (comma as thousand separator).
class Formatters {
  Formatters._();

  /// Standard currency format with thousands separator.
  /// Example: 1234.56 → €1,234.56
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IE', // Irish English uses € with comma separator
    symbol: '€',
    decimalDigits: 2,
  );

  /// Compact currency format for large numbers.
  /// Example: 113500 → €113k
  static final _currencyCompactFormat = NumberFormat.compactCurrency(
    locale: 'en_IE',
    symbol: '€',
    decimalDigits: 0,
  );

  /// Percent format with variable decimals.
  static final _percentFormat = NumberFormat.decimalPercentPattern(
    locale: 'en_IE',
    decimalDigits: 2,
  );

  /// Format a number as currency.
  /// Example: 1234.56 → €1,234.56
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Format a large number as compact currency.
  /// Example: 113500 → €113k
  /// Example: 1500000 → €1.5M
  static String formatCurrencyCompact(double value) {
    return _currencyCompactFormat.format(value);
  }

  /// Format a decimal as percentage.
  ///
  /// [value] is expected to be a decimal (0.1234 = 12.34%)
  /// [showSign] adds + prefix for positive values
  ///
  /// Examples:
  /// - formatPercent(0.1234) → 12.34%
  /// - formatPercent(0.1234, showSign: true) → +12.34%
  /// - formatPercent(-0.0567, showSign: true) → -5.67%
  static String formatPercent(double value, {bool showSign = false}) {
    final formatted = _percentFormat.format(value);
    if (showSign && value > 0) {
      return '+$formatted';
    }
    return formatted;
  }

  /// Format currency with sign prefix.
  /// Example: 1234 → +€1,234
  /// Example: -456.78 → -€456.78
  static String formatSignedCurrency(double value) {
    final absValue = value.abs();
    final formatted = _currencyFormat.format(absValue);

    if (value > 0) {
      return '+$formatted';
    } else if (value < 0) {
      return '-$formatted';
    }
    return formatted;
  }

  /// Format currency with sign, using compact format for large numbers.
  /// Example: 12348 → +€12k
  /// Example: -5200 → -€5.2k
  static String formatSignedCurrencyCompact(double value) {
    final absValue = value.abs();
    final formatted = _currencyCompactFormat.format(absValue);

    if (value > 0) {
      return '+$formatted';
    } else if (value < 0) {
      return '-$formatted';
    }
    return formatted;
  }

  /// Format percentage points (pp) for allocation drift.
  /// Example: 5.0 → +5pp
  /// Example: -3.0 → -3pp
  static String formatDriftPp(double pp) {
    final rounded = pp.round();
    if (rounded > 0) {
      return '+${rounded}pp';
    } else if (rounded < 0) {
      return '${rounded}pp';
    }
    return 'On target';
  }

  /// Format a weight percentage (0-100 scale).
  /// Example: 37.5 → 37.5%
  static String formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return '${weight.round()}%';
    }
    return '${weight.toStringAsFixed(1)}%';
  }

  /// Format annualized return (XIRR).
  /// Example: 0.084 → 8.4% p.a.
  static String formatXirr(double value) {
    final pct = (value * 100).toStringAsFixed(1);
    return '$pct% p.a.';
  }

  /// Format XIRR in parentheses.
  /// Example: 0.084 → (8.4% p.a.)
  static String formatXirrParens(double value) {
    return '(${formatXirr(value)})';
  }
}
