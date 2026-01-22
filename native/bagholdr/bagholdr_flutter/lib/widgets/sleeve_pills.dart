import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

/// Simple horizontal legend for sleeve selection.
class SleevePills extends StatelessWidget {
  const SleevePills({
    super.key,
    required this.sleeveTree,
    this.selectedSleeveId,
    this.onSleeveSelected,
  });

  final SleeveTreeResponse sleeveTree;
  final String? selectedSleeveId;
  final void Function(String? sleeveId)? onSleeveSelected;

  @override
  Widget build(BuildContext context) {
    // Flatten all sleeves in order
    final allSleeves = <SleeveNode>[];
    for (final parent in sleeveTree.sleeves) {
      allSleeves.add(parent);
      if (parent.children != null) {
        allSleeves.addAll(parent.children!);
      }
    }

    // Build related IDs for dimming logic
    final relatedIds = _getRelatedIds(allSleeves);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          for (int i = 0; i < allSleeves.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _LegendItem(
              sleeve: allSleeves[i],
              isSelected: selectedSleeveId == allSleeves[i].id,
              isDimmed: selectedSleeveId != null && !relatedIds.contains(allSleeves[i].id),
              onTap: () => onSleeveSelected?.call(allSleeves[i].id),
            ),
          ],
        ],
      ),
    );
  }

  Set<String> _getRelatedIds(List<SleeveNode> allSleeves) {
    if (selectedSleeveId == null) return {};

    final related = <String>{selectedSleeveId!};
    final sleeveMap = {for (var s in allSleeves) s.id: s};
    final selected = sleeveMap[selectedSleeveId];
    if (selected == null) return related;

    // Add parent
    if (selected.parentId != null) {
      related.add(selected.parentId!);
    }

    // Add children
    for (final sleeve in allSleeves) {
      if (sleeve.parentId == selectedSleeveId) {
        related.add(sleeve.id);
      }
    }

    // If selected is a child, add siblings
    if (selected.parentId != null) {
      for (final sleeve in allSleeves) {
        if (sleeve.parentId == selected.parentId) {
          related.add(sleeve.id);
        }
      }
    }

    return related;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.sleeve,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  final SleeveNode sleeve;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(sleeve.color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDimmed ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sleeve.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
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
