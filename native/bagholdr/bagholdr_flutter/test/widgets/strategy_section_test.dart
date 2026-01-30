import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/ring_chart.dart';
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
    testWidgets('renders child widgets', (tester) async {
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
      expect(find.byType(SleevePills), findsOneWidget);
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
      await tester.tap(find.text('Core'));
      await tester.pump();

      expect(notifiedSleeveId, 'core');
    });

    testWidgets('handles empty sleeve tree', (tester) async {
      final tree = createSleeveTree(sleeves: []);

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      expect(find.byType(StrategySection), findsOneWidget);
      expect(find.byType(RingChart), findsOneWidget);
      expect(find.byType(SleevePills), findsOneWidget);
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
      expect(find.byType(SleevePills), findsOneWidget);
    });

    testWidgets('shows bottom sheet when sleeve is selected', (tester) async {
      final tree = createSleeveTree(
        sleeves: [
          createSleeveNode(
            id: 'core',
            name: 'Core',
            color: '#3b82f6',
            value: 85000,
            assetCount: 10,
          ),
        ],
      );

      await tester.pumpWidget(buildWidget(sleeveTree: tree));

      // Tap the "Core" pill to select
      await tester.tap(find.text('Core'));
      await tester.pumpAndSettle();

      // Bottom sheet should appear with sleeve details
      expect(find.text('10 assets'), findsOneWidget);
    });

    testWidgets('toggle deselects sleeve when tapped again', (tester) async {
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

      // Tap to select
      await tester.tap(find.text('Core'));
      await tester.pumpAndSettle();
      expect(notifiedSleeveId, 'core');

      // Close bottom sheet
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();

      // Tap again to deselect
      await tester.tap(find.text('Core'));
      await tester.pump();
      expect(notifiedSleeveId, isNull);
    });
  });
}
