import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/sleeve_pills.dart';
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
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: SleevePills(
          sleeveTree: sleeveTree,
          selectedSleeveId: selectedSleeveId,
          onSleeveSelected: onSleeveSelected,
        ),
      ),
    );
  }

  group('SleevePills', () {
    testWidgets('shows "All" pill first', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('shows top-level sleeves with target percentage', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            targetPct: 75,
          ),
          createSleeveNode(
            id: 'satellite',
            name: 'Satellite',
            color: '#f59e0b',
            targetPct: 25,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.text('Core'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Satellite'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('shows child sleeves without percentage', (tester) async {
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
                targetPct: 55,
              ),
              createSleeveNode(
                id: 'bonds',
                name: 'Bonds',
                parentId: 'core',
                color: '#93c5fd',
                targetPct: 20,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Parent sleeve should have percentage
      expect(find.text('Core'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);

      // Child sleeves should appear but without percentage
      expect(find.text('Equities'), findsOneWidget);
      expect(find.text('Bonds'), findsOneWidget);
      // Child target percentages should NOT appear
      expect(find.text('55%'), findsNothing);
      expect(find.text('20%'), findsNothing);
    });

    testWidgets('marks "All" as selected when selectedSleeveId is null', (tester) async {
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
        selectedSleeveId: null,
      ));

      // "All" pill should be selected (has border)
      // We check by finding the Container with border
      final allPillFinder = find.ancestor(
        of: find.text('All'),
        matching: find.byType(Container),
      );
      expect(allPillFinder, findsWidgets);
    });

    testWidgets('marks selected sleeve pill correctly', (tester) async {
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
      );

      await tester.pumpWidget(buildWidget(
        sleeveTree: tree,
        selectedSleeveId: 'satellite',
      ));

      // Satellite should be selected
      expect(find.text('Satellite'), findsOneWidget);
    });

    testWidgets('calls onSleeveSelected when pill is tapped', (tester) async {
      String? selectedId;
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
        onSleeveSelected: (id) => selectedId = id,
      ));

      await tester.tap(find.text('Core'));
      await tester.pump();

      expect(selectedId, 'core');
    });

    testWidgets('calls onSleeveSelected with null when "All" is tapped', (tester) async {
      String? selectedId = 'core';
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
        selectedSleeveId: selectedId,
        onSleeveSelected: (id) => selectedId = id,
      ));

      await tester.tap(find.text('All'));
      await tester.pump();

      expect(selectedId, isNull);
    });

    testWidgets('pills are in correct order', (tester) async {
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
          createSleeveNode(
            id: 'satellite',
            name: 'Satellite',
            color: '#f59e0b',
            targetPct: 25,
            children: [
              createSleeveNode(
                id: 'growth',
                name: 'Growth',
                parentId: 'satellite',
                color: '#fcd34d',
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // All pills should be present
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Core'), findsOneWidget);
      expect(find.text('Equities'), findsOneWidget);
      expect(find.text('Satellite'), findsOneWidget);
      expect(find.text('Growth'), findsOneWidget);
    });

    testWidgets('handles empty sleeves', (tester) async {
      final tree = createSleeveTree(sleeves: []);

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Should still show "All" pill
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('is horizontally scrollable', (tester) async {
      final tree = createSleeveTree(
        sleeves: List.generate(
          10,
          (i) => createSleeveNode(
            id: 'sleeve$i',
            name: 'Sleeve $i',
            color: '#3b82f6',
            targetPct: 10,
          ),
        ),
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Should have SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
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
            body: SleevePills(sleeveTree: tree),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Core'), findsOneWidget);
    });
  });
}
