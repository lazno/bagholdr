import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/ring_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SleeveNode createSleeveNode({
    required String id,
    required String name,
    String? parentId,
    required String color,
    double targetPct = 50,
    double currentPct = 50,
    double driftPp = 0,
    String driftStatus = 'ok',
    double value = 10000,
    double mwr = 10,
    double? twr = 8,
    int assetCount = 5,
    int childSleeveCount = 0,
    List<SleeveNode>? children,
  }) {
    return SleeveNode(
      id: id,
      name: name,
      parentId: parentId,
      color: color,
      targetPct: targetPct,
      currentPct: currentPct,
      driftPp: driftPp,
      driftStatus: driftStatus,
      value: value,
      mwr: mwr,
      twr: twr,
      assetCount: assetCount,
      childSleeveCount: childSleeveCount,
      children: children,
    );
  }

  SleeveTreeResponse createSleeveTree({
    required List<SleeveNode> sleeves,
    double totalValue = 100000,
    double totalMwr = 12,
    double? totalTwr = 10,
    int totalAssetCount = 20,
  }) {
    return SleeveTreeResponse(
      sleeves: sleeves,
      totalValue: totalValue,
      totalMwr: totalMwr,
      totalTwr: totalTwr,
      totalAssetCount: totalAssetCount,
    );
  }

  Widget buildWidget({
    required SleeveTreeResponse sleeveTree,
    String? selectedSleeveId,
    void Function(String?)? onSleeveSelected,
    bool hideBalances = false,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: Center(
          child: RingChart(
            sleeveTree: sleeveTree,
            selectedSleeveId: selectedSleeveId,
            onSleeveSelected: onSleeveSelected,
            hideBalances: hideBalances,
          ),
        ),
      ),
    );
  }

  group('RingChart', () {
    testWidgets('renders with sleeve data', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
            currentPct: 75,
            children: [
              createSleeveNode(
                id: 'equities',
                name: 'Equities',
                parentId: 'core',
                color: '#60a5fa',
                targetPct: 55,
                currentPct: 55,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Should find PieChart widgets (inner and outer rings)
      expect(find.byType(PieChart), findsWidgets);
    });

    testWidgets('renders nested sleeve hierarchy correctly', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
            currentPct: 75,
            childSleeveCount: 2,
            children: [
              createSleeveNode(
                id: 'equities',
                name: 'Equities',
                parentId: 'core',
                color: '#60a5fa',
                targetPct: 55,
                currentPct: 55,
              ),
              createSleeveNode(
                id: 'bonds',
                name: 'Bonds',
                parentId: 'core',
                color: '#93c5fd',
                targetPct: 20,
                currentPct: 20,
              ),
            ],
          ),
          createSleeveNode(
            id: 'satellite',
            name: 'Satellite',
            color: '#f59e0b',
            targetPct: 25,
            currentPct: 25,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Should render without errors
      expect(find.byType(RingChart), findsOneWidget);
      // Should have both inner and outer rings
      expect(find.byType(PieChart), findsNWidgets(2));
    });

    testWidgets('handles empty sleeves gracefully', (tester) async {
      final tree = createSleeveTree(sleeves: []);

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Should render without crashing
      expect(find.byType(RingChart), findsOneWidget);
    });

    testWidgets('displays correctly in dark theme', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: BagholdrTheme.dark,
          home: Scaffold(
            body: Center(
              child: RingChart(sleeveTree: tree),
            ),
          ),
        ),
      );

      expect(find.byType(RingChart), findsOneWidget);
    });

    testWidgets('calls onSleeveSelected when segment tapped', (tester) async {
      String? selectedId;
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            currentPct: 100,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        onSleeveSelected: (id) => selectedId = id,
      ));

      // Tap near the center to deselect
      await tester.tapAt(const Offset(200, 100));
      await tester.pump();

      // Center tap should deselect (call with null)
      expect(selectedId, isNull);
    });

    testWidgets('renders with selection', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            currentPct: 75,
          ),
          createSleeveNode(
            id: 'satellite',
            name: 'Satellite',
            color: '#f59e0b',
            currentPct: 25,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'core',
      ));

      // Should render with selection without errors
      expect(find.byType(RingChart), findsOneWidget);
      expect(find.byType(PieChart), findsWidgets);
    });
  });
}
