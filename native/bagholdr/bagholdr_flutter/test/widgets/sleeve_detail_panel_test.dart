import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/sleeve_detail_panel.dart';
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
    bool hideBalances = false,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: SleeveDetailPanel(
          sleeveTree: sleeveTree,
          selectedSleeveId: selectedSleeveId,
          hideBalances: hideBalances,
        ),
      ),
    );
  }

  group('SleeveDetailPanel', () {
    testWidgets('shows "All Sleeves" when no selection', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
          ),
          createSleeveNode(
            id: 'satellite',
            name: 'Satellite',
            color: '#f59e0b',
          ),
        ],
        totalValue: 113482,
        totalMwr: 12.2,
        totalTwr: 10.5,
        totalAssetCount: 32,
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.text('All Sleeves'), findsOneWidget);
      expect(find.text('2 sleeves · 32 assets'), findsOneWidget);
      expect(find.text('€113,482.00'), findsOneWidget);
      expect(find.text('+12.20%'), findsOneWidget);
    });

    testWidgets('shows selected sleeve details', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
            currentPct: 75,
            driftPp: 0,
            driftStatus: 'ok',
            value: 85000,
            mwr: 8.2,
            twr: 6.1,
            assetCount: 18,
            childSleeveCount: 2,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'core',
      ));

      expect(find.text('Core'), findsOneWidget);
      expect(find.text('2 sleeves · 18 assets'), findsOneWidget);
      expect(find.text('€85,000.00'), findsOneWidget);
      expect(find.text('+8.20%'), findsOneWidget);
      expect(find.text('TWR 6.10%'), findsOneWidget);
    });

    testWidgets('shows allocation metrics for specific sleeve', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
            currentPct: 75,
            driftPp: 0,
            driftStatus: 'ok',
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'core',
      ));

      // Should show Current, Target, Status
      expect(find.text('75%'), findsNWidgets(2)); // Current and Target
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('On target'), findsOneWidget);
    });

    testWidgets('hides allocation metrics in "All" view', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: null, // All view
      ));

      // Should NOT show allocation metrics labels
      expect(find.text('Current'), findsNothing);
      expect(find.text('Target'), findsNothing);
      expect(find.text('Status'), findsNothing);
    });

    testWidgets('shows "over" drift status with positive pp', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'growth',
            name: 'Growth',
            color: '#fcd34d',
            targetPct: 15,
            currentPct: 20,
            driftPp: 5,
            driftStatus: 'over',
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'growth',
      ));

      expect(find.text('+5pp'), findsOneWidget);
    });

    testWidgets('shows "under" drift status with negative pp', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'bonds',
            name: 'Bonds',
            color: '#93c5fd',
            targetPct: 20,
            currentPct: 17,
            driftPp: -3,
            driftStatus: 'under',
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'bonds',
      ));

      expect(find.text('-3pp'), findsOneWidget);
    });

    testWidgets('hides values in privacy mode', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            value: 85000,
          ),
        ],
        totalValue: 113482,
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        hideBalances: true,
      ));

      expect(find.text('•••••'), findsOneWidget);
      expect(find.text('€113,482.00'), findsNothing);
    });

    testWidgets('shows TWR when available', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            mwr: 12,
            twr: 10.5,
          ),
        ],
        totalTwr: 10.5,
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.textContaining('TWR'), findsOneWidget);
    });

    testWidgets('hides TWR when null', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            twr: null,
          ),
        ],
        totalTwr: null,
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.textContaining('TWR'), findsNothing);
    });

    testWidgets('finds nested child sleeve', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            children: [
              createSleeveNode(
                id: 'equities',
                name: 'Equities',
                parentId: 'core',
                color: '#60a5fa',
                value: 62000,
                assetCount: 12,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'equities', // Select child sleeve
      ));

      expect(find.text('Equities'), findsOneWidget);
      expect(find.text('12 assets'), findsOneWidget);
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
            body: SleeveDetailPanel(sleeveTree: tree),
          ),
        ),
      );

      expect(find.text('All Sleeves'), findsOneWidget);
    });
  });
}
