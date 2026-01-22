import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/ring_chart.dart';
import 'package:bagholdr_flutter/widgets/sleeve_detail_panel.dart';
import 'package:bagholdr_flutter/widgets/sleeve_pills.dart';
import 'package:bagholdr_flutter/widgets/strategy_section.dart';
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
    bool hideBalances = false,
    void Function(String?)? onSleeveSelected,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StrategySection(
            sleeveTree: sleeveTree,
            hideBalances: hideBalances,
            onSleeveSelected: onSleeveSelected,
          ),
        ),
      ),
    );
  }

  group('StrategySection', () {
    testWidgets('renders all child widgets', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
            children: [
              createSleeveNode(
                id: 'equities',
                name: 'Equities',
                parentId: 'core',
                color: '#60a5fa',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.byType(RingChart), findsOneWidget);
      expect(find.byType(SleeveDetailPanel), findsOneWidget);
      expect(find.byType(SleevePills), findsOneWidget);
    });

    testWidgets('synchronizes selection when pill is tapped', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            value: 85000,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Initially shows "All Sleeves" in ring center and detail panel
      expect(find.text('All Sleeves'), findsNWidgets(2));

      // Tap the "Core" pill
      await tester.tap(find.text('Core').last); // Get the one in pills
      await tester.pumpAndSettle();

      // Now should show "Core" in detail panel and ring center
      expect(find.text('Core'), findsWidgets);
    });

    testWidgets('deselects when "All" pill is tapped', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            value: 85000,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // First select a sleeve by tapping the pill
      await tester.tap(find.text('Core').last);
      await tester.pumpAndSettle();

      // Now tap the "All" pill to go back to all sleeves view
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // Should be back to "All Sleeves" (in ring center and detail panel)
      expect(find.text('All Sleeves'), findsNWidgets(2));
    });

    testWidgets('calls onSleeveSelected callback', (tester) async {
      String? notifiedSleeveId = 'initial';
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
        onSleeveSelected: (id) => notifiedSleeveId = id,
      ));

      // Tap the "Core" pill
      await tester.tap(find.text('Core').last);
      await tester.pump();

      expect(notifiedSleeveId, 'core');
    });

    testWidgets('passes hideBalances to children', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
          ),
        ],
        totalValue: 113482,
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        hideBalances: true,
      ));

      // Values should be hidden in ring center and detail panel
      expect(find.text('•••••'), findsNWidgets(2)); // Ring center + detail panel
    });

    testWidgets('handles empty sleeve tree', (tester) async {
      final tree = createSleeveTree(sleeves: []);

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.byType(StrategySection), findsOneWidget);
      // "All Sleeves" appears in both ring center and detail panel
      expect(find.text('All Sleeves'), findsNWidgets(2));
      expect(find.text('All'), findsOneWidget);
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
            body: SingleChildScrollView(
              child: StrategySection(sleeveTree: tree),
            ),
          ),
        ),
      );

      expect(find.byType(StrategySection), findsOneWidget);
      expect(find.byType(RingChart), findsOneWidget);
      expect(find.byType(SleeveDetailPanel), findsOneWidget);
      expect(find.byType(SleevePills), findsOneWidget);
    });
  });
}
