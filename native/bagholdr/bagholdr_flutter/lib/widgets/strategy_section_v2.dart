import 'dart:math' as math;

import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/formatters.dart';
import 'sleeve_pills.dart';

/// Strategy section V2 with animated slide transition.
///
/// When a sleeve is selected:
/// - Entire chart slides to the left and shrinks
/// - Details slide in from the right
/// - All slices remain visible, selected one highlighted
class StrategySectionV2 extends StatefulWidget {
  const StrategySectionV2({
    super.key,
    required this.sleeveTree,
    this.hideBalances = false,
    this.onSleeveSelected,
  });

  final SleeveTreeResponse sleeveTree;
  final bool hideBalances;
  final void Function(String? sleeveId)? onSleeveSelected;

  @override
  State<StrategySectionV2> createState() => _StrategySectionV2State();
}

class _StrategySectionV2State extends State<StrategySectionV2>
    with SingleTickerProviderStateMixin {
  String? _selectedSleeveId;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Use a custom curve for smoother, more modern feel
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: const Cubic(0.2, 0.9, 0.3, 1.0), // Fast start, gentle settle
      reverseCurve: Curves.easeInQuad,
    );
  }

  @override
  void didUpdateWidget(StrategySectionV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.sleeveTree, oldWidget.sleeveTree)) {
      // Reset selection when data changes (e.g., portfolio switch)
      _animationController.reset();
      setState(() => _selectedSleeveId = null);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSleeveSelected(String? sleeveId) {
    if (sleeveId == _selectedSleeveId) {
      // Toggle off
      _animationController.reverse();
      setState(() => _selectedSleeveId = null);
      widget.onSleeveSelected?.call(null);
    } else if (sleeveId != null) {
      // Select new sleeve
      setState(() => _selectedSleeveId = sleeveId);
      _animationController.forward();
      widget.onSleeveSelected?.call(sleeveId);
    } else {
      // Deselect
      _animationController.reverse();
      setState(() => _selectedSleeveId = null);
      widget.onSleeveSelected?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Animated chart + details area
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _AnimatedChartArea(
              sleeveTree: widget.sleeveTree,
              selectedSleeveId: _selectedSleeveId,
              animationValue: _animation.value,
              hideBalances: widget.hideBalances,
              onSleeveSelected: _handleSleeveSelected,
            );
          },
        ),
        // Sleeve pills
        SleevePills(
          sleeveTree: widget.sleeveTree,
          selectedSleeveId: _selectedSleeveId,
          onSleeveSelected: _handleSleeveSelected,
        ),
      ],
    );
  }
}

/// The animated chart area with sliding chart and details.
class _AnimatedChartArea extends StatefulWidget {
  const _AnimatedChartArea({
    required this.sleeveTree,
    required this.selectedSleeveId,
    required this.animationValue,
    required this.hideBalances,
    required this.onSleeveSelected,
  });

  final SleeveTreeResponse sleeveTree;
  final String? selectedSleeveId;
  final double animationValue; // 0 = unselected, 1 = selected
  final bool hideBalances;
  final void Function(String? sleeveId) onSleeveSelected;

  @override
  State<_AnimatedChartArea> createState() => _AnimatedChartAreaState();
}

class _AnimatedChartAreaState extends State<_AnimatedChartArea>
    with SingleTickerProviderStateMixin {
  double _swipeProgress = 0; // 0 = no swipe, 1 = fully swiped away
  late AnimationController _swipeResetController;
  double _swipeStartValue = 0;

  @override
  void initState() {
    super.initState();
    _swipeResetController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _swipeResetController.addListener(_onSwipeResetTick);
  }

  @override
  void dispose() {
    _swipeResetController.removeListener(_onSwipeResetTick);
    _swipeResetController.dispose();
    super.dispose();
  }

  void _onSwipeResetTick() {
    setState(() {
      // Animate from _swipeStartValue back to 0
      _swipeProgress = _swipeStartValue * (1 - _swipeResetController.value);
    });
  }

  @override
  void didUpdateWidget(_AnimatedChartArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset swipe progress when selection changes to ensure clean state
    if (widget.selectedSleeveId != oldWidget.selectedSleeveId) {
      _swipeProgress = 0;
      _swipeResetController.reset();
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Cancel any ongoing reset animation
    if (_swipeResetController.isAnimating) {
      _swipeResetController.stop();
    }
    // Only allow dragging right (positive delta)
    if (details.delta.dx > 0 || _swipeProgress > 0) {
      setState(() {
        _swipeProgress = (_swipeProgress + details.delta.dx / 150).clamp(0.0, 1.0);
      });
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    // Dismiss if swiped far enough or fast enough
    if (_swipeProgress > 0.4 || velocity > 300) {
      // Complete the swipe - dismiss
      widget.onSleeveSelected(null);
      setState(() {
        _swipeProgress = 0;
      });
    } else {
      // Animate back to 0 smoothly
      _swipeStartValue = _swipeProgress;
      _swipeResetController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    const totalHeight = 200.0;

    // Find selected sleeve
    final selectedSleeve = widget.selectedSleeveId != null
        ? _findSleeve(widget.selectedSleeveId!)
        : null;

    // Layout animation combines controller animation with swipe progress
    // When swiping, the layout should also animate back proportionally
    final layoutAnimation = widget.animationValue * (1 - _swipeProgress);

    // Chart size synced with combined layout animation
    const largeChartSize = 400.0;
    const smallChartSize = 140.0;
    final chartSize = largeChartSize - (largeChartSize - smallChartSize) * layoutAnimation;
    const visibleHeight = totalHeight;

    // Details: 70% when fully selected (more room for content)
    const detailsRatio = 0.70;
    final chartWidthRatio = 1.0 - (detailsRatio * layoutAnimation);

    // Swipe translates the details panel off screen
    final swipeTranslate = _swipeProgress * 150;
    final detailsOpacity = (1.0 - _swipeProgress * 0.5).clamp(0.0, 1.0);

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final chartWidth = totalWidth * chartWidthRatio;
          final detailsWidth = totalWidth * detailsRatio; // Fixed width for details content

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Chart - positioned and sized based on layout animation
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: chartWidth,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => _handleChartTap(details, chartSize, chartWidth),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _SlidingChart(
                      sleeveTree: widget.sleeveTree,
                      selectedSleeveId: widget.selectedSleeveId,
                      chartSize: chartSize,
                      visibleHeight: visibleHeight,
                    ),
                  ),
                ),
              ),
              // Details panel - fixed width, slides in/out
              if (selectedSleeve != null && layoutAnimation > 0.05)
                Positioned(
                  left: chartWidth,
                  top: 0,
                  bottom: 0,
                  width: detailsWidth, // Fixed width prevents reflow
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    onTap: () => widget.onSleeveSelected(null),
                    behavior: HitTestBehavior.opaque,
                    child: Opacity(
                      opacity: layoutAnimation * detailsOpacity,
                      child: Transform.translate(
                        // Slide in from right, then swipe out to right
                        offset: Offset(
                          (1 - layoutAnimation) * 30 + swipeTranslate,
                          0,
                        ),
                        child: _SleeveDetails(
                          sleeveTree: widget.sleeveTree,
                          sleeve: selectedSleeve,
                          hideBalances: widget.hideBalances,
                          onClose: () => widget.onSleeveSelected(null),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  SleeveNode? _findSleeve(String id) {
    for (final parent in widget.sleeveTree.sleeves) {
      if (parent.id == id) return parent;
      if (parent.children != null) {
        for (final child in parent.children!) {
          if (child.id == id) return child;
        }
      }
    }
    return null;
  }

  void _handleChartTap(TapUpDetails details, double chartSize, double chartWidth) {
    // Center X must use chartWidth (the GestureDetector's width) because the
    // chart is centered within the container by Align. When the chart is wider
    // than the container, it overflows symmetrically so the visual center is
    // always at chartWidth/2 in the GestureDetector's coordinate space.
    final center = Offset(chartWidth / 2, chartSize / 2);
    final tapPos = details.localPosition;
    final distance = (tapPos - center).distance;
    final angle = _getAngleFromCenter(tapPos, center);

    // Scale the hit detection based on chart size
    final scale = chartSize / 400.0;
    final innerRadius = 70 * scale;
    final midRadius = 110 * scale;
    final outerRadius = 152 * scale;

    final allSleeves = _flattenTree(widget.sleeveTree.sleeves);
    final topLevelSleeves = widget.sleeveTree.sleeves.where((s) => s.parentId == null).toList();
    final outerRingSections = _buildOuterRingSections(allSleeves, topLevelSleeves);

    if (distance < innerRadius) {
      widget.onSleeveSelected(null);
    } else if (distance <= midRadius) {
      final sleeveId = _findSleeveAtAngle(angle, topLevelSleeves);
      if (sleeveId != null) {
        widget.onSleeveSelected(sleeveId);
      } else {
        widget.onSleeveSelected(null);
      }
    } else if (distance <= outerRadius) {
      final sleeveId = _findOuterSleeveAtAngle(angle, outerRingSections);
      if (sleeveId != null) {
        widget.onSleeveSelected(sleeveId);
      } else {
        widget.onSleeveSelected(null);
      }
    } else {
      widget.onSleeveSelected(null);
    }
  }

  double _getAngleFromCenter(Offset point, Offset center) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return (math.atan2(dy, dx) * 180 / math.pi) + 180;
  }

  String? _findSleeveAtAngle(double angle, List<SleeveNode> sleeves) {
    if (angle > 180) return null;
    double totalPct = sleeves.fold(0.0, (sum, s) => sum + (s.currentPct > 0 ? s.currentPct : 0.1));
    double currentAngle = 0;
    for (final sleeve in sleeves) {
      final pct = sleeve.currentPct > 0 ? sleeve.currentPct : 0.1;
      final sweepAngle = (pct / totalPct) * 180;
      if (angle >= currentAngle && angle < currentAngle + sweepAngle) {
        return sleeve.id;
      }
      currentAngle += sweepAngle;
    }
    return null;
  }

  String? _findOuterSleeveAtAngle(double angle, List<_OuterRingSection> sections) {
    if (angle > 180) return null;
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

  List<_OuterRingSection> _buildOuterRingSections(List<SleeveNode> allSleeves, List<SleeveNode> topLevelSleeves) {
    final sections = <_OuterRingSection>[];
    for (final parent in topLevelSleeves) {
      final children = allSleeves.where((s) => s.parentId == parent.id).toList();
      if (children.isEmpty) {
        sections.add(_OuterRingSection(
          sleeve: null,
          value: parent.currentPct > 0 ? parent.currentPct : 0.1,
          color: Colors.transparent,
          parentId: parent.id,
        ));
      } else {
        for (final child in children) {
          sections.add(_OuterRingSection(
            sleeve: child,
            value: child.currentPct > 0 ? child.currentPct : 0.1,
            color: _parseColor(child.color),
            parentId: parent.id,
          ));
        }
      }
    }
    return sections;
  }

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

  Color _parseColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return Colors.grey;
  }
}

/// The sliding/scaling chart.
class _SlidingChart extends StatelessWidget {
  const _SlidingChart({
    required this.sleeveTree,
    required this.selectedSleeveId,
    required this.chartSize,
    required this.visibleHeight,
  });

  final SleeveTreeResponse sleeveTree;
  final String? selectedSleeveId;
  final double chartSize;
  final double visibleHeight;

  @override
  Widget build(BuildContext context) {
    final allSleeves = _flattenTree(sleeveTree.sleeves);
    final topLevelSleeves = sleeveTree.sleeves.where((s) => s.parentId == null).toList();
    final relatedIds = _getRelatedSleeveIds(selectedSleeveId, allSleeves);

    // Build outer ring sections
    final outerRingSections = <_OuterRingSection>[];
    for (final parent in topLevelSleeves) {
      final children = allSleeves.where((s) => s.parentId == parent.id).toList();
      if (children.isEmpty) {
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

    // Scale radii based on chart size
    final scale = chartSize / 400.0;
    final outerRadius = 42 * scale;
    final outerSelectedRadius = 54 * scale;
    final outerCenterSpace = 110 * scale;
    final innerRadius = 40 * scale;
    final innerSelectedRadius = 50 * scale;
    final innerCenterSpace = 70 * scale;

    List<PieChartSectionData> buildOuterSections() {
      final sections = <PieChartSectionData>[];
      double totalValue = 0;

      for (final section in outerRingSections) {
        final isSelected = section.sleeve != null && selectedSleeveId == section.sleeve!.id;
        final isRelated = section.sleeve == null ||
            selectedSleeveId == null ||
            relatedIds.contains(section.sleeve!.id);

        sections.add(PieChartSectionData(
          value: section.value,
          radius: isSelected ? outerSelectedRadius : outerRadius,
          color: section.sleeve == null
              ? Colors.transparent
              : (isRelated ? section.color : section.color.withValues(alpha: 0.2)),
          showTitle: section.sleeve != null && chartSize > 200,
          title: section.sleeve != null ? '${section.value.toStringAsFixed(0)}%' : '',
          titleStyle: TextStyle(
            fontSize: 11 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.5,
        ));
        totalValue += section.value;
      }

      sections.add(PieChartSectionData(
        value: totalValue,
        radius: 0,
        color: Colors.transparent,
        showTitle: false,
      ));

      return sections;
    }

    List<PieChartSectionData> buildInnerSections() {
      final sections = <PieChartSectionData>[];
      double totalValue = 0;

      for (final sleeve in topLevelSleeves) {
        final value = sleeve.currentPct > 0 ? sleeve.currentPct : 0.1;
        final isSelected = selectedSleeveId == sleeve.id;
        final isRelated = selectedSleeveId == null || relatedIds.contains(sleeve.id);
        final color = _parseColor(sleeve.color);

        sections.add(PieChartSectionData(
          value: value,
          radius: isSelected ? innerSelectedRadius : innerRadius,
          color: isRelated ? color : color.withValues(alpha: 0.2),
          showTitle: chartSize > 200,
          title: '${sleeve.currentPct.toStringAsFixed(0)}%',
          titleStyle: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.5,
        ));
        totalValue += value;
      }

      sections.add(PieChartSectionData(
        value: totalValue,
        radius: 0,
        color: Colors.transparent,
        showTitle: false,
      ));

      return sections;
    }

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
              // Outer ring
              IgnorePointer(
                child: PieChart(
                  PieChartData(
                    sections: buildOuterSections(),
                    sectionsSpace: 2 * scale,
                    centerSpaceRadius: outerCenterSpace,
                    startDegreeOffset: 180,
                  ),
                ),
              ),
              // Inner ring
              IgnorePointer(
                child: PieChart(
                  PieChartData(
                    sections: buildInnerSections(),
                    sectionsSpace: 2 * scale,
                    centerSpaceRadius: innerCenterSpace,
                    startDegreeOffset: 180,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Set<String> _getRelatedSleeveIds(String? selectedId, List<SleeveNode> allSleeves) {
    if (selectedId == null) return {};
    final related = <String>{selectedId};
    final sleeveMap = {for (var s in allSleeves) s.id: s};
    final selected = sleeveMap[selectedId];
    if (selected == null) return related;

    String? parentId = selected.parentId;
    while (parentId != null) {
      related.add(parentId);
      parentId = sleeveMap[parentId]?.parentId;
    }

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

  Color _parseColor(String hex) {
    final hexClean = hex.replaceFirst('#', '');
    if (hexClean.length == 6) {
      return Color(int.parse('FF$hexClean', radix: 16));
    }
    return Colors.grey;
  }
}

/// Sleeve details panel - uses golden ratio space meaningfully.
class _SleeveDetails extends StatelessWidget {
  const _SleeveDetails({
    required this.sleeveTree,
    required this.sleeve,
    required this.hideBalances,
    required this.onClose,
  });

  final SleeveTreeResponse sleeveTree;
  final SleeveNode sleeve;
  final bool hideBalances;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.financialColors;

    final isPositive = sleeve.mwr >= 0;
    final returnColor = isPositive ? colors.positive : colors.negative;

    // Count assets including children
    int totalAssets = sleeve.assetCount;
    if (sleeve.children != null) {
      for (final child in sleeve.children!) {
        totalAssets += child.assetCount;
      }
    }

    // Calculate return in currency (approximate based on MWR)
    // returnAbs = value * mwr / (1 + mwr)
    final mwrDecimal = sleeve.mwr / 100;
    final returnAbs = sleeve.value * mwrDecimal / (1 + mwrDecimal);

    // Determine status
    final String statusText;
    final Color statusColor;
    if (sleeve.driftStatus == 'ok') {
      statusText = 'On target';
      statusColor = colors.positive;
    } else if (sleeve.driftStatus == 'over') {
      statusText = '+${sleeve.driftPp.abs().toStringAsFixed(0)}pp over';
      statusColor = colors.issueOver;
    } else {
      statusText = '-${sleeve.driftPp.abs().toStringAsFixed(0)}pp under';
      statusColor = colors.issueUnder;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Name with color bar and asset count
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _parseColor(sleeve.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                sleeve.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$totalAssets assets',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Middle: Two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Value and performance
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hideBalances ? '•••••' : Formatters.formatCurrency(sleeve.value),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          Formatters.formatPercent(sleeve.mwr / 100, showSign: true),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: returnColor,
                          ),
                        ),
                        if (!hideBalances) ...[
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatSignedCurrency(returnAbs),
                            style: TextStyle(
                              fontSize: 11,
                              color: returnColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'TWR ${Formatters.formatPercent((sleeve.twr ?? sleeve.mwr) / 100, showSign: true)}',
                      style: TextStyle(
                        fontSize: 9,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Right: Allocation comparison
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current vs Target
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${sleeve.currentPct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'current',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '→',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${sleeve.targetPct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'target',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Status badge
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
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

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SideMetric extends StatelessWidget {
  const _SideMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

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
