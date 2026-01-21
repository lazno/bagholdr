import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';

/// Hero value display showing invested value, returns, cash, and total.
///
/// Displays:
/// - Left column: Invested amount, MWR %, absolute return, TWR %
/// - Right column: Cash balance, Total value
///
/// Supports hideBalances mode to mask monetary values while keeping
/// percentages visible.
///
/// Usage:
/// ```dart
/// HeroValueDisplay(
///   investedValue: 113482.0,
///   mwr: 0.122,
///   twr: 0.105,
///   returnAbs: 12348.0,
///   cashBalance: 6452.0,
///   totalValue: 119934.0,
///   hideBalances: false,
/// )
/// ```
class HeroValueDisplay extends StatelessWidget {
  const HeroValueDisplay({
    super.key,
    required this.investedValue,
    required this.mwr,
    this.twr,
    required this.returnAbs,
    required this.cashBalance,
    required this.totalValue,
    this.hideBalances = false,
  });

  /// Current market value of holdings (excludes cash).
  final double investedValue;

  /// Money-Weighted Return (compounded) for the selected period.
  /// This is the big return number showing user's actual return.
  final double mwr;

  /// Time-Weighted Return for the selected period.
  /// Shows portfolio performance independent of cash flow timing.
  /// Nullable - may fail to calculate in some edge cases.
  final double? twr;

  /// Absolute return in EUR (investedValue - costBasis).
  final double returnAbs;

  /// Cash balance in the portfolio.
  final double cashBalance;

  /// Total portfolio value (invested + cash).
  final double totalValue;

  /// When true, masks monetary values with "•••••".
  /// Percentages remain visible.
  final bool hideBalances;

  static const _hiddenText = '•••••';

  @override
  Widget build(BuildContext context) {
    final financialColors = context.financialColors;
    final colorScheme = Theme.of(context).colorScheme;

    final returnColor =
        mwr >= 0 ? financialColors.positive : financialColors.negative;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (main)
        Expanded(
          child: _MainColumn(
            investedValue: investedValue,
            mwr: mwr,
            twr: twr,
            returnAbs: returnAbs,
            returnColor: returnColor,
            hideBalances: hideBalances,
            neutralColor: financialColors.neutral,
          ),
        ),
        // Right column (side)
        _SideColumn(
          cashBalance: cashBalance,
          totalValue: totalValue,
          hideBalances: hideBalances,
          labelColor: colorScheme.outline,
          valueColor: colorScheme.onSurface,
          mutedColor: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

/// Left column: Invested amount, MWR, absolute return, TWR.
class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.investedValue,
    required this.mwr,
    this.twr,
    required this.returnAbs,
    required this.returnColor,
    required this.hideBalances,
    required this.neutralColor,
  });

  final double investedValue;
  final double mwr;
  final double? twr;
  final double returnAbs;
  final Color returnColor;
  final bool hideBalances;
  final Color neutralColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'INVESTED',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Amount
        Text(
          hideBalances
              ? HeroValueDisplay._hiddenText
              : Formatters.formatCurrency(investedValue),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        // MWR + Absolute return row
        Row(
          children: [
            Text(
              Formatters.formatPercent(mwr, showSign: true),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: returnColor,
              ),
            ),
            const SizedBox(width: 6),
            if (!hideBalances)
              Text(
                Formatters.formatSignedCurrency(returnAbs),
                style: TextStyle(
                  fontSize: 13,
                  color: returnColor,
                ),
              ),
          ],
        ),
        // TWR row
        if (twr != null) ...[
          const SizedBox(height: 2),
          Text(
            'TWR ${Formatters.formatPercent(twr!, showSign: true)}',
            style: TextStyle(
              fontSize: 11,
              color: neutralColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Right column: Cash and Total values.
class _SideColumn extends StatelessWidget {
  const _SideColumn({
    required this.cashBalance,
    required this.totalValue,
    required this.hideBalances,
    required this.labelColor,
    required this.valueColor,
    required this.mutedColor,
  });

  final double cashBalance;
  final double totalValue;
  final bool hideBalances;
  final Color labelColor;
  final Color valueColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Cash
        _SideItem(
          label: 'CASH',
          value: hideBalances
              ? HeroValueDisplay._hiddenText
              : Formatters.formatCurrency(cashBalance),
          labelColor: labelColor,
          valueColor: valueColor,
          valueFontSize: 14,
        ),
        const SizedBox(height: 8),
        // Total
        _SideItem(
          label: 'TOTAL',
          value: hideBalances
              ? HeroValueDisplay._hiddenText
              : Formatters.formatCurrency(totalValue),
          labelColor: labelColor,
          valueColor: mutedColor,
          valueFontSize: 13,
        ),
      ],
    );
  }
}

/// Individual item in the side column with label and value.
class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    required this.valueFontSize,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
