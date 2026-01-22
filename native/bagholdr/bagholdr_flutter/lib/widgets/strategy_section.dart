import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/formatters.dart';
import 'ring_chart.dart';
import 'sleeve_pills.dart';

/// The Strategy section of the dashboard.
///
/// Combines:
/// - Ring chart (allocation donut)
/// - Sleeve detail panel
/// - Sleeve pills (filter)
///
/// All three widgets share selection state - tapping a segment in the ring,
/// a pill, or the ring center updates all widgets together.
///
/// Usage:
/// ```dart
/// StrategySection(
///   sleeveTree: sleeveTreeResponse,
///   hideBalances: false,
/// )
/// ```
class StrategySection extends StatefulWidget {
  const StrategySection({
    super.key,
    required this.sleeveTree,
    this.hideBalances = false,
    this.onSleeveSelected,
  });

  /// The sleeve tree data from the API.
  final SleeveTreeResponse sleeveTree;

  /// Whether to hide monetary values (privacy mode).
  final bool hideBalances;

  /// Optional callback when sleeve selection changes.
  /// This is useful for the parent (dashboard) to update the assets filter.
  final void Function(String? sleeveId)? onSleeveSelected;

  @override
  State<StrategySection> createState() => _StrategySectionState();
}

class _StrategySectionState extends State<StrategySection> {
  String? _selectedSleeveId;

  void _handleSleeveSelected(String? sleeveId) {
    final previousId = _selectedSleeveId;

    // Toggle behavior: tap same sleeve to deselect
    if (sleeveId == previousId) {
      setState(() {
        _selectedSleeveId = null;
      });
      widget.onSleeveSelected?.call(null);
      return;
    }

    setState(() {
      _selectedSleeveId = sleeveId;
    });
    widget.onSleeveSelected?.call(sleeveId);

    // Show bottom sheet when selecting a sleeve (not when deselecting)
    if (sleeveId != null) {
      _showSleeveDetailSheet(sleeveId);
    }
  }

  void _showSleeveDetailSheet(String sleeveId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SleeveDetailSheet(
        sleeveTree: widget.sleeveTree,
        sleeveId: sleeveId,
        hideBalances: widget.hideBalances,
        onClose: () => Navigator.pop(context),
      ),
    );
    // Note: dismissing sheet does NOT deselect - selection persists for asset filtering
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ring chart area - tap anywhere to deselect
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _handleSleeveSelected(null),
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 0),
            child: Center(
              child: RingChart(
                sleeveTree: widget.sleeveTree,
                selectedSleeveId: _selectedSleeveId,
                onSleeveSelected: _handleSleeveSelected,
                hideBalances: widget.hideBalances,
              ),
            ),
          ),
        ),
        // Sleeve pills (right after chart)
        SleevePills(
          sleeveTree: widget.sleeveTree,
          selectedSleeveId: _selectedSleeveId,
          onSleeveSelected: _handleSleeveSelected,
        ),
      ],
    );
  }
}

/// Bottom sheet showing sleeve details.
class _SleeveDetailSheet extends StatelessWidget {
  const _SleeveDetailSheet({
    required this.sleeveTree,
    required this.sleeveId,
    required this.hideBalances,
    required this.onClose,
  });

  final SleeveTreeResponse sleeveTree;
  final String sleeveId;
  final bool hideBalances;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;
    final sleeve = _findSleeve(sleeveId);

    if (sleeve == null) return const SizedBox.shrink();

    final isPositive = sleeve.mwr >= 0;
    final returnColor = isPositive ? colors.positive : colors.negative;

    // Determine status
    final String statusText;
    final Color statusColor;
    if (sleeve.driftStatus == 'ok') {
      statusText = 'On target';
      statusColor = colors.positive;
    } else if (sleeve.driftStatus == 'over') {
      statusText = '+${sleeve.driftPp.abs().toStringAsFixed(0)}pp';
      statusColor = colors.issueOver;
    } else {
      statusText = '-${sleeve.driftPp.abs().toStringAsFixed(0)}pp';
      statusColor = colors.issueUnder;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: color bar + name + value
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(sleeve.color),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sleeve.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sleeve.assetCount} assets',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hideBalances
                              ? '•••••'
                              : Formatters.formatCurrency(sleeve.value),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.formatPercent(sleeve.mwr / 100,
                              showSign: true),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: returnColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Metrics row
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MetricColumn(
                          value: '${sleeve.currentPct.toStringAsFixed(0)}%',
                          label: 'Current',
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: _MetricColumn(
                          value: '${sleeve.targetPct.toStringAsFixed(0)}%',
                          label: 'Target',
                          alignment: CrossAxisAlignment.center,
                        ),
                      ),
                      Expanded(
                        child: _MetricColumn(
                          value: statusText,
                          label: 'Status',
                          valueColor: statusColor,
                          alignment: CrossAxisAlignment.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SleeveNode? _findSleeve(String id) {
    for (final parent in sleeveTree.sleeves) {
      if (parent.id == id) return parent;
      if (parent.children != null) {
        for (final child in parent.children!) {
          if (child.id == id) return child;
        }
      }
    }
    return null;
  }

  Color _parseColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return Colors.grey;
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.value,
    required this.label,
    required this.alignment,
    this.valueColor,
  });

  final String value;
  final String label;
  final CrossAxisAlignment alignment;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
