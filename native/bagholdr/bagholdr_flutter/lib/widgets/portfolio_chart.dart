import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import 'time_range_bar.dart';

/// Maps UI TimePeriod to API ChartRange.
///
/// Note: API doesn't have YTD or 3M for chart, so we approximate:
/// - 3M -> threeMonths
/// - YTD -> sixMonths (close approximation for first half of year)
ChartRange toChartRange(TimePeriod period) {
  switch (period) {
    case TimePeriod.oneMonth:
      return ChartRange.oneMonth;
    case TimePeriod.threeMonths:
      return ChartRange.threeMonths;
    case TimePeriod.sixMonths:
      return ChartRange.sixMonths;
    case TimePeriod.ytd:
      // YTD not supported by API, use sixMonths as approximation
      return ChartRange.sixMonths;
    case TimePeriod.oneYear:
      return ChartRange.oneYear;
    case TimePeriod.all:
      return ChartRange.all;
  }
}

/// Portfolio value chart displaying invested value and cost basis over time.
///
/// Features:
/// - Green area chart with gradient fill for invested value
/// - Grey dashed line for cost basis
/// - Interactive: tap to select a data point and see its value
/// - Tooltip showing selected or current value
/// - X-axis date labels
/// - Legend below chart
///
/// Usage:
/// ```dart
/// PortfolioChart(
///   dataPoints: chartData.dataPoints,
///   hideBalances: false,
/// )
/// ```
class PortfolioChart extends StatefulWidget {
  const PortfolioChart({
    super.key,
    required this.dataPoints,
    this.hideBalances = false,
  });

  /// Chart data points containing date, investedValue, and costBasis.
  final List<ChartDataPoint> dataPoints;

  /// When true, masks the tooltip value with "...".
  final bool hideBalances;

  /// Chart height in pixels.
  static const double chartHeight = 200;

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart> {
  /// Index of the currently touched data point, or null if none.
  int? _touchedIndex;

  /// X position of the touch for tooltip positioning (in pixels).
  double? _touchX;

  /// Y position of the touched spot for tooltip positioning (0-1 ratio from top).
  double? _touchYRatio;

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return const SizedBox(
        height: PortfolioChart.chartHeight,
        child: Center(
          child: Text('No chart data available'),
        ),
      );
    }

    // fl_chart needs at least 2 points to render a line
    if (widget.dataPoints.length < 2) {
      final financialColors = context.financialColors;
      final currentValue = widget.dataPoints.first.investedValue;
      return SizedBox(
        height: PortfolioChart.chartHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Formatters.formatCurrencyCompact(currentValue),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: financialColors.positive,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Not enough data for chart',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final financialColors = context.financialColors;
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate min/max for Y axis
    final allValues = <double>[];
    for (final point in widget.dataPoints) {
      allValues.add(point.investedValue);
      allValues.add(point.costBasis);
    }
    final minY = allValues.reduce((a, b) => a < b ? a : b);
    final maxY = allValues.reduce((a, b) => a > b ? a : b);
    var range = maxY - minY;

    // Handle edge case where all values are the same
    if (range == 0) {
      range = maxY * 0.2;
      if (range == 0) range = 1000;
    }

    // Add padding to min/max
    final paddedMinY = minY - range * 0.05;
    final paddedMaxY = maxY + range * 0.15; // Extra top padding for tooltip

    // Build x-axis labels
    final xLabels = _buildXAxisLabels(widget.dataPoints);

    // Get touched data point for tooltip
    final touchedPoint = _touchedIndex != null
        ? widget.dataPoints[_touchedIndex!]
        : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chart with tooltip overlay (clipBehavior none allows tooltip to overflow)
        ClipRect(
          clipBehavior: Clip.none,
          child: SizedBox(
            height: PortfolioChart.chartHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main chart
                    LineChart(
                      LineChartData(
                        minY: paddedMinY,
                        maxY: paddedMaxY,
                        gridData: _buildGridData(colorScheme, paddedMinY, paddedMaxY),
                        titlesData: _buildTitlesData(
                          xLabels,
                          colorScheme,
                          widget.dataPoints.length,
                          paddedMinY,
                          paddedMaxY,
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          _buildValueLine(widget.dataPoints, financialColors),
                          _buildCostBasisLine(widget.dataPoints, financialColors),
                        ],
                        lineTouchData: _buildTouchData(
                          financialColors,
                          colorScheme,
                          constraints.maxWidth,
                          paddedMinY,
                          paddedMaxY,
                        ),
                      ),
                    ),
                    // Custom tooltip overlay
                    if (touchedPoint != null && _touchX != null)
                      _buildTooltipOverlay(
                        touchedPoint,
                        financialColors,
                        colorScheme,
                        constraints.maxWidth,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        // Legend
        _ChartLegend(
          valueColor: financialColors.chartValue,
          costBasisColor: financialColors.chartCostBasis,
          textColor: colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  /// Build custom tooltip overlay positioned at touch location.
  Widget _buildTooltipOverlay(
    ChartDataPoint dataPoint,
    FinancialColors financialColors,
    ColorScheme colorScheme,
    double chartWidth,
  ) {
    final date = _parseDate(dataPoint.date);
    const tooltipWidth = 140.0;
    const tooltipHeight = 68.0; // Approximate height: 3 lines + padding
    const margin = 8.0;

    // Calculate tooltip X position - center on touch
    // Account for left Y-axis labels (45px reserved)
    const leftPadding = 45.0;

    // _touchX is relative to the chart data area, add left padding offset
    var tooltipX = leftPadding + (_touchX ?? 0) - tooltipWidth / 2;

    // Clamp to keep tooltip fully visible within chart width
    // Left edge: minimum margin
    // Right edge: chart width minus tooltip width minus margin
    final maxX = chartWidth - tooltipWidth - margin;
    tooltipX = tooltipX.clamp(margin, maxX);

    // Calculate tooltip Y position - above the touched data point
    // _touchYRatio: 0 = top of chart, 1 = bottom
    // Account for bottom axis labels (24px reserved)
    const chartAreaHeight = PortfolioChart.chartHeight - 24;
    final pointY = chartAreaHeight * (_touchYRatio ?? 0);

    // Position tooltip above the point with some margin
    var tooltipY = pointY - tooltipHeight - 12;

    // If tooltip would overflow above the chart, position it below the point
    if (tooltipY < -margin) {
      tooltipY = pointY + 20; // 20px below point (accounts for dot size)
    }

    return Positioned(
      left: tooltipX,
      top: tooltipY,
      child: Container(
        width: tooltipWidth,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTooltipDate(date),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Invested: ${widget.hideBalances ? "..." : Formatters.formatCurrencyCompact(dataPoint.investedValue)}',
              style: TextStyle(
                fontSize: 11,
                color: financialColors.chartValue,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Cost basis: ${widget.hideBalances ? "..." : Formatters.formatCurrencyCompact(dataPoint.costBasis)}',
              style: TextStyle(
                fontSize: 11,
                color: financialColors.chartCostBasis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build touch interaction data.
  LineTouchData _buildTouchData(
    FinancialColors financialColors,
    ColorScheme colorScheme,
    double chartWidth,
    double paddedMinY,
    double paddedMaxY,
  ) {
    // Calculate the data area width (chart width minus left Y-axis labels)
    const leftPadding = 45.0;
    final dataAreaWidth = chartWidth - leftPadding;

    return LineTouchData(
      enabled: true,
      touchSpotThreshold: 20,
      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
        // Dismiss tooltip when touch ends (finger lifted)
        if (event is FlTapUpEvent ||
            event is FlPanEndEvent ||
            event is FlLongPressEnd ||
            event is FlPointerExitEvent) {
          setState(() {
            _touchedIndex = null;
            _touchX = null;
            _touchYRatio = null;
          });
          return;
        }

        // Update tooltip position while touching
        if (response?.lineBarSpots != null &&
            response!.lineBarSpots!.isNotEmpty) {
          final spot = response.lineBarSpots!.first;
          final spotIndex = spot.spotIndex;

          // Calculate X position relative to data area
          final xRatio = spot.x / (widget.dataPoints.length - 1);
          final touchX = xRatio * dataAreaWidth;

          // Calculate Y ratio (0 = top of chart, 1 = bottom)
          // spot.y is the actual value, we need to convert to ratio
          final yRange = paddedMaxY - paddedMinY;
          final yRatio = 1 - (spot.y - paddedMinY) / yRange;

          setState(() {
            _touchedIndex = spotIndex;
            _touchX = touchX;
            _touchYRatio = yRatio;
          });
        }
      },
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: financialColors.chartValue.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: colorScheme.surface,
                  strokeWidth: 2,
                  strokeColor: financialColors.chartValue,
                );
              },
            ),
          );
        }).toList();
      },
      // Disable built-in tooltip - we use custom overlay
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) => Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        getTooltipItems: (_) => [],
      ),
    );
  }

  /// Format date for tooltip display.
  String _formatTooltipDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Build grid lines at 25%, 50%, 75% of value range.
  FlGridData _buildGridData(
    ColorScheme colorScheme,
    double minY,
    double maxY,
  ) {
    final range = maxY - minY;
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: range / 4,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          strokeWidth: 1,
        );
      },
    );
  }

  /// Build titles data (X-axis and Y-axis labels).
  FlTitlesData _buildTitlesData(
    List<_XLabel> xLabels,
    ColorScheme colorScheme,
    int dataPointCount,
    double minY,
    double maxY,
  ) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45,
          interval: (maxY - minY) / 4,
          getTitlesWidget: (value, meta) {
            // Don't show min/max labels to avoid clutter
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                Formatters.formatCurrencyCompact(value),
                style: TextStyle(
                  fontSize: 9,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            for (final label in xLabels) {
              if (label.index == index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.text,
                    style: TextStyle(
                      fontSize: 9,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Build value line with gradient area fill.
  LineChartBarData _buildValueLine(
    List<ChartDataPoint> points,
    FinancialColors colors,
  ) {
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.investedValue);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      color: colors.chartValue,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.chartValue.withValues(alpha: 0.35),
            colors.chartValue.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }

  /// Build cost basis line (dashed grey).
  LineChartBarData _buildCostBasisLine(
    List<ChartDataPoint> points,
    FinancialColors colors,
  ) {
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.costBasis);
    }).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      color: colors.chartCostBasis.withValues(alpha: 0.6),
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      dashArray: [5, 4],
    );
  }

  /// Build evenly spaced x-axis labels based on data points.
  List<_XLabel> _buildXAxisLabels(List<ChartDataPoint> points) {
    if (points.isEmpty) return [];

    final targetLabels = points.length > 30 ? 7 : 5;
    final interval = (points.length - 1) / (targetLabels - 1);

    final labels = <_XLabel>[];
    for (var i = 0; i < targetLabels; i++) {
      final index = (i * interval).round().clamp(0, points.length - 1);
      final date = _parseDate(points[index].date);

      String text;
      if (i == targetLabels - 1) {
        text = 'Now';
      } else {
        text = _formatDateLabel(date);
      }

      labels.add(_XLabel(index: index, text: text));
    }

    return labels;
  }

  /// Parse YYYY-MM-DD date string.
  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Format date as abbreviated month (Jan, Feb, etc.).
  String _formatDateLabel(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[date.month - 1];
  }
}

/// X-axis label with index and text.
class _XLabel {
  const _XLabel({required this.index, required this.text});
  final int index;
  final String text;
}

/// Legend showing value and cost basis line indicators.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.valueColor,
    required this.costBasisColor,
    required this.textColor,
  });

  final Color valueColor;
  final Color costBasisColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(
            color: valueColor,
            isDashed: false,
            label: 'Invested',
            textColor: textColor,
          ),
          const SizedBox(width: 20),
          _LegendItem(
            color: costBasisColor,
            isDashed: true,
            label: 'Cost basis',
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}

/// Individual legend item with line indicator and label.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.isDashed,
    required this.label,
    required this.textColor,
  });

  final Color color;
  final bool isDashed;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 2,
          child: CustomPaint(
            painter: _LinePainter(color: color, isDashed: isDashed),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for legend line (solid or dashed).
class _LinePainter extends CustomPainter {
  const _LinePainter({required this.color, required this.isDashed});

  final Color color;
  final bool isDashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (isDashed) {
      const dashWidth = 3.0;
      const dashSpace = 2.0;
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset((x + dashWidth).clamp(0, size.width), size.height / 2),
          paint,
        );
        x += dashWidth + dashSpace;
      }
    } else {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDashed != isDashed;
  }
}
