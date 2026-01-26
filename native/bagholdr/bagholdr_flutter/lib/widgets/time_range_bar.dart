import 'package:flutter/material.dart';

/// Time periods for filtering financial data.
enum TimePeriod {
  oneMonth('1M'),
  sixMonths('6M'),
  ytd('YTD'),
  oneYear('1Y'),
  all('ALL');

  const TimePeriod(this.label);

  /// Display label for the period (e.g., "1M", "YTD").
  final String label;
}

/// A time range selector with equal-width period buttons.
///
/// Uses theme colors for proper light/dark mode support.
///
/// Set [embedded] to true when placing inside another container (e.g., a control bar).
/// When embedded, no outer padding or decoration is applied.
///
/// Usage:
/// ```dart
/// TimeRangeBar(
///   selected: TimePeriod.oneYear,
///   onChanged: (period) => setState(() => _period = period),
/// )
/// ```
class TimeRangeBar extends StatelessWidget {
  const TimeRangeBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.embedded = false,
  });

  /// Currently selected time period.
  final TimePeriod selected;

  /// Called when user selects a different period.
  final ValueChanged<TimePeriod> onChanged;

  /// When true, renders without container decoration (for embedding in other widgets).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final buttons = Row(
      children: TimePeriod.values.map((period) {
        final isActive = period == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _PeriodButton(
              period: period,
              isActive: isActive,
              onTap: () => onChanged(period),
            ),
          ),
        );
      }).toList(),
    );

    if (embedded) {
      return buttons;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: buttons,
    );
  }
}

/// Individual period button within the TimeRangeBar.
class _PeriodButton extends StatelessWidget {
  const _PeriodButton({
    required this.period,
    required this.isActive,
    required this.onTap,
  });

  final TimePeriod period;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isActive
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            period.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
