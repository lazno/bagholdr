import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:bagholdr_server/src/import/derive_holdings.dart';

/// Golden source test - verifies Dart deriveHoldings matches TypeScript exactly
///
/// This test loads real orders from the TypeScript SQLite database and verifies
/// that the Dart implementation produces identical holdings.
void main() {
  group('Golden Source Holdings Test', () {
    late List<OrderForDerivation> orders;
    late List<Map<String, dynamic>> expectedHoldings;

    setUpAll(() {
      // Load fixture from TypeScript dump
      final fixturePath =
          'test/fixtures/golden_source_orders_holdings.json';
      final file = File(fixturePath);

      if (!file.existsSync()) {
        fail('Fixture file not found: $fixturePath\n'
            'Run: cd server && npx tsx scripts/dump-orders-holdings.ts');
      }

      final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      // Parse orders
      final rawOrders = data['orders'] as List<dynamic>;
      orders = rawOrders.map((o) {
        final orderData = o as Map<String, dynamic>;
        return OrderForDerivation(
          assetIsin: orderData['assetIsin'] as String,
          orderDate: DateTime.parse(orderData['orderDate'] as String),
          quantity: (orderData['quantity'] as num).toDouble(),
          totalEur: (orderData['totalEur'] as num).toDouble(),
          totalNative: (orderData['totalNative'] as num).toDouble(),
        );
      }).toList();

      expectedHoldings = (data['expectedHoldings'] as List<dynamic>)
          .map((h) => h as Map<String, dynamic>)
          .toList();

      print('Loaded ${orders.length} orders');
      print('Expected ${expectedHoldings.length} holdings');
    });

    test('deriveHoldings matches TypeScript output exactly', () {
      // Run Dart implementation
      final derivedHoldings = deriveHoldings(orders);

      // Sort for comparison
      derivedHoldings.sort((a, b) => a.assetIsin.compareTo(b.assetIsin));

      // Verify count
      expect(derivedHoldings.length, equals(expectedHoldings.length),
          reason: 'Holdings count mismatch');

      // Verify each holding
      for (var i = 0; i < expectedHoldings.length; i++) {
        final expected = expectedHoldings[i];
        final actual = derivedHoldings[i];

        final expectedIsin = expected['assetIsin'] as String;
        final expectedQty = (expected['quantity'] as num).toDouble();
        final expectedCost = (expected['totalCostEur'] as num).toDouble();

        expect(actual.assetIsin, equals(expectedIsin),
            reason: 'ISIN mismatch at index $i');

        expect(actual.quantity, closeTo(expectedQty, 0.0001),
            reason:
                'Quantity mismatch for $expectedIsin: expected $expectedQty, got ${actual.quantity}');

        // Allow small floating point tolerance
        expect(actual.totalCostEur, closeTo(expectedCost, 0.01),
            reason:
                'Cost mismatch for $expectedIsin: expected $expectedCost, got ${actual.totalCostEur}');
      }

      print('\nAll ${derivedHoldings.length} holdings match!');
    });

    test('prints detailed comparison for debugging', () {
      final derivedHoldings = deriveHoldings(orders);
      derivedHoldings.sort((a, b) => a.assetIsin.compareTo(b.assetIsin));

      print('\nDetailed comparison:');
      print('=' * 80);
      print('${'ISIN'.padRight(15)} | '
          '${'Expected Qty'.padRight(12)} | '
          '${'Actual Qty'.padRight(12)} | '
          '${'Expected Cost'.padRight(14)} | '
          '${'Actual Cost'.padRight(14)} | '
          'Match');
      print('-' * 80);

      var allMatch = true;
      for (var i = 0; i < expectedHoldings.length; i++) {
        final expected = expectedHoldings[i];
        final actual = derivedHoldings[i];

        final isin = expected['assetIsin'] as String;
        final expectedQty = (expected['quantity'] as num).toDouble();
        final expectedCost = (expected['totalCostEur'] as num).toDouble();

        final qtyMatch = (actual.quantity - expectedQty).abs() < 0.0001;
        final costMatch = (actual.totalCostEur - expectedCost).abs() < 0.01;
        final match = qtyMatch && costMatch;

        if (!match) allMatch = false;

        print('${isin.padRight(15)} | '
            '${expectedQty.toStringAsFixed(2).padLeft(12)} | '
            '${actual.quantity.toStringAsFixed(2).padLeft(12)} | '
            '${expectedCost.toStringAsFixed(2).padLeft(14)} | '
            '${actual.totalCostEur.toStringAsFixed(2).padLeft(14)} | '
            '${match ? "✓" : "✗"}');
      }

      print('=' * 80);
      expect(allMatch, isTrue, reason: 'Some holdings do not match');
    });
  });
}
