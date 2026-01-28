import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bagholdr_flutter/screens/setup_server_url_screen.dart';

void main() {
  group('SetupServerUrlScreen', () {
    testWidgets('displays app name and instructions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      expect(find.text('Bagholdr'), findsOneWidget);
      expect(find.text('Portfolio Tracking'), findsOneWidget);
      expect(find.text('Enter your server URL'), findsOneWidget);
      expect(
        find.text('Connect to your Bagholdr server to get started.'),
        findsOneWidget,
      );
    });

    testWidgets('has URL input field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Server URL'), findsOneWidget);
    });

    testWidgets('has continue button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    });

    testWidgets('shows validation error for empty URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      // Tap continue without entering a URL
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('URL cannot be empty'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid URL', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      // Enter invalid URL
      await tester.enterText(find.byType(TextFormField), 'not-a-url');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('URL must start with http:// or https://'), findsOneWidget);
    });

    testWidgets('clears validation error when typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      // Trigger validation error
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('URL cannot be empty'), findsOneWidget);

      // Start typing
      await tester.enterText(find.byType(TextFormField), 'h');
      await tester.pump();

      expect(find.text('URL cannot be empty'), findsNothing);
    });

    testWidgets('prevents back navigation with PopScope', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SetupServerUrlScreen(),
        ),
      );

      // Find the PopScope and verify canPop is false
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });
  });
}
