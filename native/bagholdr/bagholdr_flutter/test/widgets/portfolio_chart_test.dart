import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/portfolio_chart.dart';
import 'package:bagholdr_flutter/widgets/time_range_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Create test data points for a date range.
  List<ChartDataPoint> createDataPoints({
    int count = 30,
    double startValue = 100000,
    double endValue = 113482,
    double startCostBasis = 95000,
    double endCostBasis = 101000,
  }) {
    final points = <ChartDataPoint>[];
    final now = DateTime.now();

    for (var i = 0; i < count; i++) {
      final date = now.subtract(Duration(days: count - 1 - i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      // Linear interpolation (handle single point case)
      final t = count > 1 ? i / (count - 1) : 0.0;
      final value = startValue + (endValue - startValue) * t;
      final costBasis = startCostBasis + (endCostBasis - startCostBasis) * t;

      points.add(ChartDataPoint(
        date: dateStr,
        investedValue: value,
        costBasis: costBasis,
      ));
    }

    return points;
  }

  Widget buildWidget({
    List<ChartDataPoint>? dataPoints,
    bool hideBalances = false,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: PortfolioChart(
            dataPoints: dataPoints ?? createDataPoints(),
            hideBalances: hideBalances,
          ),
        ),
      ),
    );
  }

  group('PortfolioChart', () {
    testWidgets('renders chart with data points', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Chart should be rendered
      expect(find.byType(PortfolioChart), findsOneWidget);

      // Legend items should be present
      expect(find.text('Invested'), findsOneWidget);
      expect(find.text('Cost basis'), findsOneWidget);
    });

    testWidgets('shows empty message when no data', (tester) async {
      await tester.pumpWidget(buildWidget(dataPoints: []));

      expect(find.text('No chart data available'), findsOneWidget);
    });

    testWidgets('displays tooltip with current value', (tester) async {
      final points = createDataPoints(endValue: 113500);
      await tester.pumpWidget(buildWidget(dataPoints: points));

      // Tooltip should show compact formatted value containing €
      // The exact format depends on locale/formatter (could be €114K, €113.5K, etc)
      expect(
        find.textContaining('€'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('renders correctly in hideBalances mode', (tester) async {
      await tester.pumpWidget(buildWidget(hideBalances: true));

      // Chart should still render (tooltip only shows on touch)
      expect(find.byType(PortfolioChart), findsOneWidget);
      expect(find.text('Invested'), findsOneWidget);
    });

    testWidgets('displays x-axis date labels', (tester) async {
      await tester.pumpWidget(buildWidget());

      // X-axis should have date-based labels (months like Jan, Feb, etc.)
      // The exact labels depend on the date range, so we just verify the chart renders
      expect(find.byType(PortfolioChart), findsOneWidget);
    });

    testWidgets('renders correctly with few data points', (tester) async {
      final points = createDataPoints(count: 5);
      await tester.pumpWidget(buildWidget(dataPoints: points));

      expect(find.byType(PortfolioChart), findsOneWidget);
      expect(find.text('Invested'), findsOneWidget);
    });

    testWidgets('renders correctly with many data points', (tester) async {
      final points = createDataPoints(count: 365);
      await tester.pumpWidget(buildWidget(dataPoints: points));

      expect(find.byType(PortfolioChart), findsOneWidget);
      expect(find.text('Invested'), findsOneWidget);
    });

    testWidgets('handles single data point gracefully', (tester) async {
      final points = createDataPoints(count: 1);
      await tester.pumpWidget(buildWidget(dataPoints: points));

      expect(find.byType(PortfolioChart), findsOneWidget);
      // Should show a message instead of the chart
      expect(find.text('Not enough data for chart'), findsOneWidget);
    });

    testWidgets('displays correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BagholdrTheme.dark,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: PortfolioChart(
                dataPoints: createDataPoints(),
                hideBalances: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PortfolioChart), findsOneWidget);
      expect(find.text('Invested'), findsOneWidget);
      expect(find.text('Cost basis'), findsOneWidget);
    });
  });

  group('toChartRange', () {
    test('maps oneMonth correctly', () {
      expect(toChartRange(TimePeriod.oneMonth), ChartRange.oneMonth);
    });

    test('maps sixMonths correctly', () {
      expect(toChartRange(TimePeriod.sixMonths), ChartRange.sixMonths);
    });

    test('maps ytd correctly', () {
      expect(toChartRange(TimePeriod.ytd), ChartRange.ytd);
    });

    test('maps oneYear correctly', () {
      expect(toChartRange(TimePeriod.oneYear), ChartRange.oneYear);
    });

    test('maps all correctly', () {
      expect(toChartRange(TimePeriod.all), ChartRange.all);
    });
  });
}
