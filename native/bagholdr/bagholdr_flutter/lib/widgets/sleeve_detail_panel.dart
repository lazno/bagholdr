import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/formatters.dart' show Formatters;

/// Detail panel showing information about the selected sleeve.
///
/// Two display modes:
/// - **All view**: Minimal display (color bar, name, meta, value, return)
/// - **Specific sleeve view**: Full display with allocation metrics row
///
/// Usage:
/// ```dart
/// SleeveDetailPanel(
///   sleeveTree: sleeveTreeResponse,
///   selectedSleeveId: selectedId, // null for "All Sleeves"
///   hideBalances: false,
/// )
/// ```
class SleeveDetailPanel extends StatelessWidget {
  const SleeveDetailPanel({
    super.key,
    required this.sleeveTree,
    this.selectedSleeveId,
    this.hideBalances = false,
  });

  /// The sleeve tree data from the API.
  final SleeveTreeResponse sleeveTree;

  /// Currently selected sleeve ID (null = "All Sleeves" view).
  final String? selectedSleeveId;

  /// Whether to hide monetary values (privacy mode).
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final isAllView = selectedSleeveId == null;

    // Get the selected sleeve data
    final sleeve = isAllView ? null : _findSleeve(selectedSleeveId!);

    // Prepare display values
    final String name;
    final String meta;
    final double value;
    final double mwr;
    final double? twr;
    final String colorHex;

    if (isAllView || sleeve == null) {
      name = 'All Sleeves';
      final sleeveCount = _countAllSleeves(sleeveTree.sleeves);
      meta = '$sleeveCount sleeves · ${sleeveTree.totalAssetCount} assets';
      value = sleeveTree.totalValue;
      mwr = sleeveTree.totalMwr;
      twr = sleeveTree.totalTwr;
      colorHex = 'gradient'; // Special value for gradient
    } else {
      name = sleeve.name;
      meta = _buildMeta(sleeve);
      value = sleeve.value;
      mwr = sleeve.mwr;
      twr = sleeve.twr;
      colorHex = sleeve.color;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: isAllView ? const EdgeInsets.only(bottom: 8) : const EdgeInsets.all(16),
      decoration: isAllView
          ? null
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: color bar, name/meta, value/return
          _DetailTopRow(
            name: name,
            meta: meta,
            value: value,
            mwr: mwr,
            twr: twr,
            colorHex: colorHex,
            hideBalances: hideBalances,
          ),
          // Metrics row (only for specific sleeve)
          if (!isAllView && sleeve != null) ...[
            const SizedBox(height: 16),
            _DetailMetricsRow(sleeve: sleeve),
          ],
        ],
      ),
    );
  }

  /// Find a sleeve by ID in the tree.
  SleeveNode? _findSleeve(String id) {
    SleeveNode? search(List<SleeveNode> nodes) {
      for (final node in nodes) {
        if (node.id == id) return node;
        if (node.children != null) {
          final found = search(node.children!);
          if (found != null) return found;
        }
      }
      return null;
    }
    return search(sleeveTree.sleeves);
  }

  /// Count all sleeves in the tree.
  int _countAllSleeves(List<SleeveNode> nodes) {
    int count = nodes.length;
    for (final node in nodes) {
      if (node.children != null) {
        count += _countAllSleeves(node.children!);
      }
    }
    return count;
  }

  /// Build meta text for a sleeve.
  String _buildMeta(SleeveNode sleeve) {
    final parts = <String>[];
    if (sleeve.childSleeveCount > 0) {
      parts.add('${sleeve.childSleeveCount} sleeves');
    }
    parts.add('${sleeve.assetCount} assets');
    return parts.join(' · ');
  }
}

/// Top row of the detail panel with color bar, name/meta, and value/return.
class _DetailTopRow extends StatelessWidget {
  const _DetailTopRow({
    required this.name,
    required this.meta,
    required this.value,
    required this.mwr,
    required this.twr,
    required this.colorHex,
    required this.hideBalances,
  });

  final String name;
  final String meta;
  final double value;
  final double mwr;
  final double? twr;
  final String colorHex;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    final isPositive = mwr >= 0;
    final returnColor = isPositive ? colors.positive : colors.negative;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Color bar
        Container(
          width: 4,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: colorHex == 'gradient'
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6), // Blue (Core)
                      Color(0xFF3B82F6),
                      Color(0xFF3B82F6),
                      Color(0xFFF59E0B), // Amber (Satellite)
                    ],
                    stops: [0.0, 0.74, 0.75, 1.0],
                  )
                : null,
            color: colorHex != 'gradient' ? _parseColor(colorHex) : null,
          ),
        ),
        const SizedBox(width: 12),
        // Name and meta
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                meta,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Value and return
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hideBalances ? '•••••' : Formatters.formatCurrency(value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Formatters.formatPercent(mwr / 100, showSign: true),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: returnColor,
              ),
            ),
            if (twr != null) ...[
              const SizedBox(height: 2),
              Text(
                'TWR ${Formatters.formatPercent(twr! / 100, showSign: false)}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return Colors.grey;
  }
}

/// Metrics row showing Current, Target, and Status.
class _DetailMetricsRow extends StatelessWidget {
  const _DetailMetricsRow({required this.sleeve});

  final SleeveNode sleeve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    // Determine status text and color
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
      padding: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Current
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sleeve.currentPct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Current',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Target
          Expanded(
            child: Column(
              children: [
                Text(
                  '${sleeve.targetPct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Target',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
