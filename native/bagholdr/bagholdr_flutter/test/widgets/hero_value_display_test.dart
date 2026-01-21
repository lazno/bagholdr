import 'package:bagholdr_flutter/theme/colors.dart';
import 'package:bagholdr_flutter/theme/theme.dart';
import 'package:bagholdr_flutter/widgets/hero_value_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({
    double investedValue = 113482.0,
    double mwr = 0.122,
    double? twr = 0.105,
    double returnAbs = 12348.0,
    double cashBalance = 6452.0,
    double totalValue = 119934.0,
    bool hideBalances = false,
  }) {
    return MaterialApp(
      theme: BagholdrTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: HeroValueDisplay(
            investedValue: investedValue,
            mwr: mwr,
            twr: twr,
            returnAbs: returnAbs,
            cashBalance: cashBalance,
            totalValue: totalValue,
            hideBalances: hideBalances,
          ),
        ),
      ),
    );
  }

  group('HeroValueDisplay', () {
    testWidgets('displays all values correctly', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Labels
      expect(find.text('INVESTED'), findsOneWidget);
      expect(find.text('CASH'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);

      // Values (with currency formatting)
      expect(find.text('€113,482.00'), findsOneWidget);
      expect(find.text('€6,452.00'), findsOneWidget);
      expect(find.text('€119,934.00'), findsOneWidget);

      // Returns
      expect(find.text('+12.20%'), findsOneWidget);
      expect(find.text('+€12,348.00'), findsOneWidget);
      expect(find.text('TWR +10.50%'), findsOneWidget);
    });

    testWidgets('hides monetary values in hideBalances mode', (tester) async {
      await tester.pumpWidget(buildWidget(hideBalances: true));

      // Hidden values
      expect(find.text('•••••'), findsNWidgets(3)); // invested, cash, total

      // Percentages still visible
      expect(find.text('+12.20%'), findsOneWidget);
      expect(find.text('TWR +10.50%'), findsOneWidget);

      // Absolute return hidden
      expect(find.text('+€12,348.00'), findsNothing);
    });

    testWidgets('shows positive return in green', (tester) async {
      await tester.pumpWidget(buildWidget(mwr: 0.10));

      // Find the MWR text and verify it uses positive color
      final mwrFinder = find.text('+10.00%');
      expect(mwrFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(mwrFinder);
      final financialColors = FinancialColors.light;
      expect(textWidget.style?.color, financialColors.positive);
    });

    testWidgets('shows negative return in red', (tester) async {
      await tester.pumpWidget(buildWidget(mwr: -0.05, returnAbs: -5000.0));

      // MWR should show negative
      expect(find.text('-5.00%'), findsOneWidget);

      // Absolute return should show negative
      expect(find.text('-€5,000.00'), findsOneWidget);

      final mwrFinder = find.text('-5.00%');
      final textWidget = tester.widget<Text>(mwrFinder);
      final financialColors = FinancialColors.light;
      expect(textWidget.style?.color, financialColors.negative);
    });

    testWidgets('handles null TWR gracefully', (tester) async {
      await tester.pumpWidget(buildWidget(twr: null));

      // TWR should not be displayed
      expect(find.textContaining('TWR'), findsNothing);

      // Other values should still appear
      expect(find.text('€113,482.00'), findsOneWidget);
      expect(find.text('+12.20%'), findsOneWidget);
    });

    testWidgets('displays correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: BagholdrTheme.dark,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: HeroValueDisplay(
                investedValue: 113482.0,
                mwr: 0.122,
                twr: 0.105,
                returnAbs: 12348.0,
                cashBalance: 6452.0,
                totalValue: 119934.0,
                hideBalances: false,
              ),
            ),
          ),
        ),
      );

      // Values should display
      expect(find.text('€113,482.00'), findsOneWidget);
      expect(find.text('+12.20%'), findsOneWidget);
    });
  });
}
