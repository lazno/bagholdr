import 'dart:math';

import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart' show Formatters;

/// A semicircle donut chart showing sleeve allocation hierarchy.
///
/// Renders two concentric semicircle arcs:
/// - Inner arc: Top-level sleeves (e.g., Core, Satellite)
/// - Outer arc: Child sleeves (e.g., Equities, Bonds, Safe Haven, Growth)
///
/// The semicircle effect is achieved by adding an invisible "spacer" section
/// that occupies the bottom half of the circle, making visible segments
/// naturally span only 180°.
///
/// Supports selection with toggle behavior:
/// - Tap segment to select, tap again to deselect
/// - Selected segment pops out (larger radius)
/// - Unrelated segments get dimmed
/// - Center shows selected sleeve value and name
///
/// Usage:
/// ```dart
/// RingChart(
///   sleeveTree: sleeveTreeResponse,
///   selectedSleeveId: selectedId,
///   onSleeveSelected: (id) => setState(() => selectedId = id),
///   hideBalances: false,
/// )
/// ```
class RingChart extends StatelessWidget {
  const RingChart({
    super.key,
    required this.sleeveTree,
    this.selectedSleeveId,
    this.onSleeveSelected,
    this.hideBalances = false,
  });

  /// The sleeve tree data from the API.
  final SleeveTreeResponse sleeveTree;

  /// Currently selected sleeve ID (null = "All Sleeves" view).
  final String? selectedSleeveId;

  /// Callback when a sleeve segment is tapped.
  /// Pass null to deselect (show "All Sleeves").
  final void Function(String? sleeveId)? onSleeveSelected;

  /// Whether to hide monetary values (privacy mode).
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    // Flatten the tree to get all sleeves for rendering
    final allSleeves = _flattenTree(sleeveTree.sleeves);
    final topLevelSleeves =
        sleeveTree.sleeves.where((s) => s.parentId == null).toList();

    // Build outer ring sections that align with parents
    // If a parent has no children, we add a transparent placeholder
    final outerRingSections = <_OuterRingSection>[];
    for (final parent in topLevelSleeves) {
      final children =
          allSleeves.where((s) => s.parentId == parent.id).toList();
      if (children.isEmpty) {
        // No children - add transparent placeholder matching parent's arc
        outerRingSections.add(_OuterRingSection(
          sleeve: null,
          value: parent.currentPct > 0 ? parent.currentPct : 0.1,
          color: Colors.transparent,
          parentId: parent.id,
        ));
      } else {
        for (final child in children) {
          outerRingSections.add(_OuterRingSection(
            sleeve: child,
            value: child.currentPct > 0 ? child.currentPct : 0.1,
            color: _parseColor(child.color),
            parentId: parent.id,
          ));
        }
      }
    }

    // For backward compatibility, also keep childSleeves list
    final childSleeves = outerRingSections
        .where((s) => s.sleeve != null)
        .map((s) => s.sleeve!)
        .toList();

    // Build related sleeve IDs for dimming logic
    final relatedIds = _getRelatedSleeveIds(selectedSleeveId, allSleeves);

    // Two concentric rings stacked
    const chartSize = 400.0;

    Widget buildChart({
      required List<SleeveNode> sleeves,
      required double radius,
      required double selectedRadius,
      required double centerSpaceRadius,
    }) {
      return RepaintBoundary(
        child: ClipRect(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: PieChart(
              PieChartData(
                sections: _buildSectionsWithSpacer(
                  sleeves: sleeves,
                  radius: radius,
                  selectedRadius: selectedRadius,
                  selectedSleeveId: selectedSleeveId,
                  relatedIds: relatedIds,
                ),
                sectionsSpace: 2,
                centerSpaceRadius: centerSpaceRadius,
                startDegreeOffset: 180,
              ),
            ),
          ),
        ),
      );
    }

    // Build outer ring sections with alignment (no badges - they get clipped)
    List<PieChartSectionData> buildOuterRingSections() {
      final sections = <PieChartSectionData>[];
      double totalValue = 0;

      for (final section in outerRingSections) {
        final isSelected = section.sleeve != null && selectedSleeveId == section.sleeve!.id;
        final isRelated = section.sleeve == null ||
            selectedSleeveId == null ||
            relatedIds.contains(section.sleeve!.id);

        sections.add(PieChartSectionData(
          value: section.value,
          radius: isSelected ? 54 : 42,
          color: section.sleeve == null
              ? Colors.transparent
              : (isRelated ? section.color : section.color.withValues(alpha: 0.2)),
          showTitle: section.sleeve != null,
          title: section.sleeve != null
              ? '${section.value.toStringAsFixed(0)}%'
              : '',
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.5,
        ));
        totalValue += section.value;
      }

      // Add spacer for bottom half
      sections.add(PieChartSectionData(
        value: totalValue,
        radius: 0,
        color: Colors.transparent,
        showTitle: false,
      ));

      return sections;
    }

    const visibleHeight = 200.0; // Only top half

    return SizedBox(
      width: chartSize,
      height: visibleHeight,
      child: UnconstrainedBox(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: chartSize,
          height: chartSize,
          child: Stack(
        children: [
          // Outer ring (child sleeves) - BEHIND, no touch handling
          if (outerRingSections.isNotEmpty)
            RepaintBoundary(
              child: ClipRect(
                child: SizedBox(
                  width: chartSize,
                  height: chartSize,
                  child: IgnorePointer(
                    child: PieChart(
                      PieChartData(
                        sections: buildOuterRingSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 110,
                        startDegreeOffset: 180,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Inner ring (top-level sleeves) - BEHIND, no touch handling
          IgnorePointer(
            child: buildChart(
              sleeves: topLevelSleeves,
              radius: 40,
              selectedRadius: 50,
              centerSpaceRadius: 70,
            ),
          ),
          // Invisible touch handler on top - only covers the chart area
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: GestureDetector(
              onTapUp: (details) {
                final center = Offset(chartSize / 2, chartSize / 2);
                final tapPos = details.localPosition;
                final distance = (tapPos - center).distance;
                final angle = _getAngleFromCenter(tapPos, center);

                // Determine which ring was tapped based on distance
                // Inner ring: 70 to 110 (centerSpace 70, radius 40)
                // Outer ring: 110 to 152 (centerSpace 110, radius 42)

                if (distance < 70) {
                  // Tapped center - deselect
                  onSleeveSelected?.call(null);
                } else if (distance <= 110) {
                  // Inner ring area - find which section
                  final sleeveId = _findSleeveAtAngle(angle, topLevelSleeves);
                  if (sleeveId != null) {
                    _handleSleeveSelected(sleeveId);
                  } else {
                    onSleeveSelected?.call(null);
                  }
                } else if (distance <= 152) {
                  // Outer ring area - find which section
                  final sleeveId = _findOuterSleeveAtAngle(angle, outerRingSections);
                  if (sleeveId != null) {
                    _handleSleeveSelected(sleeveId);
                  } else {
                    onSleeveSelected?.call(null);
                  }
                } else {
                  // Outside rings - deselect
                  onSleeveSelected?.call(null);
                }
              },
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  /// Handle sleeve selection with toggle behavior.
  void _handleSleeveSelected(String sleeveId) {
    if (selectedSleeveId == sleeveId) {
      // Toggle off - deselect
      onSleeveSelected?.call(null);
    } else {
      // Select this sleeve
      onSleeveSelected?.call(sleeveId);
    }
  }

  /// Get angle from center point (0-360, starting from left going clockwise).
  double _getAngleFromCenter(Offset point, Offset center) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    var angle = (atan2(dy, dx) * 180 / pi) + 180; // 0-360, 0 = left
    return angle;
  }

  /// Find which sleeve is at the given angle (for inner ring).
  String? _findSleeveAtAngle(double angle, List<SleeveNode> sleeves) {
    // Only consider angles in the visible semicircle (0-180, top half)
    // With startDegreeOffset: 180, sections start at left (180°) and go clockwise
    // So angle 0-180 maps to the visible semicircle
    if (angle > 180) return null; // Bottom half (spacer)

    double totalPct = sleeves.fold(0.0, (sum, s) => sum + (s.currentPct > 0 ? s.currentPct : 0.1));
    double currentAngle = 0;

    for (final sleeve in sleeves) {
      final pct = sleeve.currentPct > 0 ? sleeve.currentPct : 0.1;
      final sweepAngle = (pct / totalPct) * 180; // 180° for visible half

      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return sleeve.id;
      }
      currentAngle += sweepAngle;
    }
    return null;
  }

  /// Find which outer sleeve is at the given angle.
  String? _findOuterSleeveAtAngle(double angle, List<_OuterRingSection> sections) {
    if (angle > 180) return null; // Bottom half (spacer)

    double totalValue = sections.fold(0.0, (sum, s) => sum + s.value);
    double currentAngle = 0;

    for (final section in sections) {
      final sweepAngle = (section.value / totalValue) * 180;

      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return section.sleeve?.id;
      }
      currentAngle += sweepAngle;
    }
    return null;
  }

  /// Build pie chart sections for a single ring with an invisible spacer.
  ///
  /// The spacer takes up the left 180° of the circle, making the
  /// visible sleeves naturally form a semicircle on the right side.
  List<PieChartSectionData> _buildSectionsWithSpacer({
    required List<SleeveNode> sleeves,
    required double radius,
    required double selectedRadius,
    required String? selectedSleeveId,
    required Set<String> relatedIds,
  }) {
    final sections = <PieChartSectionData>[];

    // Handle edge case: no sleeves
    if (sleeves.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          radius: radius,
          color: Colors.grey.withValues(alpha: 0.2),
          showTitle: false,
        ),
        PieChartSectionData(
          value: 1,
          radius: 0,
          color: Colors.transparent,
          showTitle: false,
        ),
      ];
    }

    // Calculate total value for the spacer
    double totalValue = 0;
    for (final sleeve in sleeves) {
      totalValue += sleeve.currentPct > 0 ? sleeve.currentPct : 0.1;
    }

    // Build visible sections
    for (final sleeve in sleeves) {
      final isSelected = selectedSleeveId == sleeve.id;
      final isRelated =
          selectedSleeveId == null || relatedIds.contains(sleeve.id);
      final color = _parseColor(sleeve.color);

      sections.add(PieChartSectionData(
        value: sleeve.currentPct > 0 ? sleeve.currentPct : 0.1,
        radius: isSelected ? selectedRadius : radius,
        color: isRelated ? color : color.withValues(alpha: 0.2),
        showTitle: true,
        title: '${sleeve.currentPct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.5,
      ));
    }

    // Invisible spacer section - takes up the left half (180°)
    // Value equals total of visible sections so it spans exactly 180°
    sections.add(PieChartSectionData(
      value: totalValue,
      radius: 0, // Invisible - no radius
      color: Colors.transparent,
      showTitle: false,
    ));

    return sections;
  }

  /// Flatten the sleeve tree into a single list.
  List<SleeveNode> _flattenTree(List<SleeveNode> nodes) {
    final result = <SleeveNode>[];
    for (final node in nodes) {
      result.add(node);
      if (node.children != null) {
        result.addAll(_flattenTree(node.children!));
      }
    }
    return result;
  }

  /// Get all sleeve IDs related to the selected sleeve.
  /// Includes the sleeve itself, its ancestors, and its descendants.
  Set<String> _getRelatedSleeveIds(
      String? selectedId, List<SleeveNode> allSleeves) {
    if (selectedId == null) return {};

    final related = <String>{selectedId};
    final sleeveMap = {for (var s in allSleeves) s.id: s};
    final selected = sleeveMap[selectedId];
    if (selected == null) return related;

    // Add ancestors
    String? parentId = selected.parentId;
    while (parentId != null) {
      related.add(parentId);
      parentId = sleeveMap[parentId]?.parentId;
    }

    // Add descendants
    void addDescendants(String id) {
      for (final sleeve in allSleeves) {
        if (sleeve.parentId == id) {
          related.add(sleeve.id);
          addDescendants(sleeve.id);
        }
      }
    }

    addDescendants(selectedId);

    return related;
  }

  /// Parse hex color string to Color.
  Color _parseColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return Colors.grey;
  }
}

/// Helper class for outer ring sections
class _OuterRingSection {
  final SleeveNode? sleeve;
  final double value;
  final Color color;
  final String parentId;

  _OuterRingSection({
    required this.sleeve,
    required this.value,
    required this.color,
    required this.parentId,
  });
}

/// The center of the ring chart showing value and label.
class _RingCenter extends StatelessWidget {
  const _RingCenter({
    required this.sleeveTree,
    required this.selectedSleeveId,
    required this.allSleeves,
    required this.hideBalances,
  });

  final SleeveTreeResponse sleeveTree;
  final String? selectedSleeveId;
  final List<SleeveNode> allSleeves;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get display data based on selection
    final String label;
    final double value;

    if (selectedSleeveId == null) {
      label = 'All Sleeves';
      value = sleeveTree.totalValue;
    } else {
      final sleeve =
          allSleeves.where((s) => s.id == selectedSleeveId).firstOrNull;
      if (sleeve != null) {
        label = sleeve.name;
        value = sleeve.value;
      } else {
        label = 'All Sleeves';
        value = sleeveTree.totalValue;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Value
        Text(
          hideBalances ? '•••••' : Formatters.formatCurrencyCompact(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
