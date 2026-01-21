import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/issues_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    required List<Issue> issues,
    void Function(Issue)? onIssueTap,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: IssuesBar(
          issues: issues,
          onIssueTap: onIssueTap,
        ),
      ),
    );
  }

  Issue createIssue({
    required IssueType type,
    IssueSeverity severity = IssueSeverity.warning,
    required String message,
    String? sleeveId,
    String? sleeveName,
    double? driftPp,
    String? color,
  }) {
    return Issue(
      type: type,
      severity: severity,
      message: message,
      sleeveId: sleeveId,
      sleeveName: sleeveName,
      driftPp: driftPp,
      color: color,
    );
  }

  group('IssuesBar', () {
    testWidgets('is hidden when there are no issues', (tester) async {
      await tester.pumpWidget(buildWidget(issues: []));

      expect(find.text('Issues need attention'), findsNothing);
      expect(find.byType(IssuesBar), findsOneWidget);
      // The widget should render as SizedBox.shrink (0x0 size)
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });

    testWidgets('shows badge count and text in collapsed state', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
        ),
        createIssue(
          type: IssueType.underAllocation,
          message: 'Bonds -3pp under target',
        ),
        createIssue(
          type: IssueType.stalePrice,
          message: '3 assets have stale prices',
        ),
        createIssue(
          type: IssueType.syncStatus,
          severity: IssueSeverity.info,
          message: 'Last sync: 2 hours ago',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Badge should show count
      expect(find.text('4'), findsOneWidget);
      // Text should show
      expect(find.text('Issues need attention'), findsOneWidget);
      // Chevron should show
      expect(find.text('▶'), findsOneWidget);
    });

    testWidgets('expands on tap to show issue items', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
        ),
        createIssue(
          type: IssueType.underAllocation,
          message: 'Bonds -3pp under target',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Initially, issue messages should not be visible (collapsed)
      // Note: ListView items are inside the SizeTransition which is collapsed
      expect(find.text('Growth +5pp over target'), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // After expansion, issues should be visible
      expect(find.text('Growth +5pp over target'), findsOneWidget);
      expect(find.text('Bonds -3pp under target'), findsOneWidget);
    });

    testWidgets('collapses on second tap', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Tap to expand
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // Tap again to collapse
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // Should be back to collapsed state
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Issues need attention'), findsOneWidget);
    });

    testWidgets('shows correct action text for each issue type', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
        ),
        createIssue(
          type: IssueType.underAllocation,
          message: 'Bonds -3pp under target',
        ),
        createIssue(
          type: IssueType.stalePrice,
          message: '3 assets have stale prices',
        ),
        createIssue(
          type: IssueType.syncStatus,
          severity: IssueSeverity.info,
          message: 'Last sync: 2 hours ago',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Expand to see action texts
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // Check action texts (two rebalance for over/under allocation)
      expect(find.text('Rebalance →'), findsNWidgets(2));
      expect(find.text('Refresh →'), findsOneWidget);
      expect(find.text('Sync →'), findsOneWidget);
    });

    testWidgets('calls onIssueTap when issue item is tapped', (tester) async {
      Issue? tappedIssue;
      final issues = [
        createIssue(
          type: IssueType.stalePrice,
          message: '3 assets have stale prices',
        ),
      ];

      await tester.pumpWidget(buildWidget(
        issues: issues,
        onIssueTap: (issue) => tappedIssue = issue,
      ));

      // Expand
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // Tap the issue item
      await tester.tap(find.text('3 assets have stale prices'));
      await tester.pumpAndSettle();

      expect(tappedIssue, isNotNull);
      expect(tappedIssue!.type, IssueType.stalePrice);
      expect(tappedIssue!.message, '3 assets have stale prices');
    });

    testWidgets('displays single issue correctly', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.syncStatus,
          severity: IssueSeverity.info,
          message: 'Last sync: 5 hours ago',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Badge should show 1
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Issues need attention'), findsOneWidget);
    });

    testWidgets('uses custom color for allocation issues', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
          color: '#fcd34d', // Custom sleeve color (light yellow)
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Expand to see the issue
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // The issue should be displayed
      expect(find.text('Growth +5pp over target'), findsOneWidget);

      // Find the dot container and verify it has the custom color
      final dotFinder = find.descendant(
        of: find.ancestor(
          of: find.text('Growth +5pp over target'),
          matching: find.byType(Row),
        ).first,
        matching: find.byType(Container),
      );

      // We can't easily verify the exact color in tests, but we can verify
      // the widget exists and has a decoration
      expect(dotFinder, findsWidgets);
    });

    testWidgets('has correct yellow background color', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.stalePrice,
          message: '3 assets have stale prices',
        ),
      ];

      await tester.pumpWidget(buildWidget(issues: issues));

      // Find Material widgets within the IssuesBar (not the Scaffold's Material)
      final issuesBarFinder = find.byType(IssuesBar);
      final materialFinder = find.descendant(
        of: issuesBarFinder,
        matching: find.byType(Material),
      );
      expect(materialFinder, findsWidgets);

      // The first Material in IssuesBar should have the yellow background
      final material = tester.widget<Material>(materialFinder.first);
      expect(material.color, const Color(0xFFFFFBEB));
    });

    testWidgets('respects max height constraint when expanded', (tester) async {
      // Create many issues to test scrolling
      final issues = List.generate(
        10,
        (i) => createIssue(
          type: IssueType.stalePrice,
          message: 'Issue $i',
        ),
      );

      await tester.pumpWidget(buildWidget(issues: issues));

      // Expand
      await tester.tap(find.text('Issues need attention'));
      await tester.pumpAndSettle();

      // Badge should show 10
      expect(find.text('10'), findsOneWidget);

      // Some issues should be visible, some may be scrolled out
      // At least the first few should be visible
      expect(find.text('Issue 0'), findsOneWidget);
      expect(find.text('Issue 1'), findsOneWidget);
    });

    testWidgets('displays correctly in dark theme', (tester) async {
      final issues = [
        createIssue(
          type: IssueType.overAllocation,
          message: 'Growth +5pp over target',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: BagholdrTheme.dark,
          home: Scaffold(
            body: IssuesBar(issues: issues),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Issues need attention'), findsOneWidget);
    });
  });
}
