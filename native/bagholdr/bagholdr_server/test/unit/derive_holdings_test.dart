import 'package:test/test.dart';
import 'package:bagholdr_server/src/import/derive_holdings.dart';

void main() {
  group('deriveHoldings', () {
    test('creates holding from single buy', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.assetIsin, equals('IE00BK5BQT80'));
      expect(holdings.first.quantity, equals(100));
      expect(holdings.first.totalCostEur, equals(1000));
      expect(holdings.first.totalCostNative, equals(1000));
    });

    test('accumulates multiple buys for same ISIN', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 15),
          quantity: 50,
          totalEur: 700,
          totalNative: 700,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(150));
      expect(holdings.first.totalCostEur, equals(1700));
    });

    test('handles sell with average cost reduction', () {
      // Buy 100 @ €10 = €1000 cost, avg = €10
      // Buy 50 @ €14 = €700 cost, total = €1700, qty = 150, avg = €11.33
      // Sell 75 → reduce cost by 75 × €11.33 = €850, remaining cost = €850, qty = 75
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 15),
          quantity: 50,
          totalEur: 700,
          totalNative: 700,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 2, 1),
          quantity: -75, // Sell
          totalEur: 900, // Sell proceeds (not used for cost calc)
          totalNative: 900,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(75));
      // Average cost was €11.33... (1700/150), reduction = 75 * 11.33... = 850
      // Remaining cost = 1700 - 850 = 850
      expect(holdings.first.totalCostEur, closeTo(850, 0.01));
    });

    test('adds commission to cost basis without changing quantity', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 0, // Commission
          totalEur: 5,
          totalNative: 5,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(100)); // Unchanged
      expect(holdings.first.totalCostEur, equals(1005)); // Increased by commission
    });

    test('excludes fully sold positions', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 2, 1),
          quantity: -100, // Sell all
          totalEur: 1200,
          totalNative: 1200,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings, isEmpty);
    });

    test('processes orders chronologically', () {
      // Orders provided out of order - should still calculate correctly
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 2, 1), // Later date
          quantity: -50,
          totalEur: 600,
          totalNative: 600,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1), // Earlier date
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(50));
      expect(holdings.first.totalCostEur, equals(500)); // 50% sold, 50% cost remains
    });

    test('handles multiple assets independently', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'US0378331005',
          orderDate: DateTime(2024, 1, 1),
          quantity: 50,
          totalEur: 500,
          totalNative: 550,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(2));

      final etfHolding = holdings.firstWhere((h) => h.assetIsin == 'IE00BK5BQT80');
      expect(etfHolding.quantity, equals(100));
      expect(etfHolding.totalCostEur, equals(1000));

      final stockHolding = holdings.firstWhere((h) => h.assetIsin == 'US0378331005');
      expect(stockHolding.quantity, equals(50));
      expect(stockHolding.totalCostEur, equals(500));
      expect(stockHolding.totalCostNative, equals(550));
    });

    test('handles zero quantity in sell (no division by zero)', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: -10, // Sell without any buys
          totalEur: 100,
          totalNative: 100,
        ),
      ];

      final holdings = deriveHoldings(orders);

      // Should not crash and should have no holdings
      expect(holdings, isEmpty);
    });

    test('clamps cost to zero on oversell', () {
      final orders = [
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000,
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'IE00BK5BQT80',
          orderDate: DateTime(2024, 2, 1),
          quantity: -150, // Sell more than owned (edge case)
          totalEur: 1500,
          totalNative: 1500,
        ),
      ];

      final holdings = deriveHoldings(orders);

      // Quantity clamped to 0, so position is excluded
      expect(holdings, isEmpty);
    });

    test('tracks EUR and native costs independently', () {
      // USD-denominated asset
      final orders = [
        OrderForDerivation(
          assetIsin: 'US0378331005',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 900, // EUR equivalent
          totalNative: 1000, // USD amount
        ),
        OrderForDerivation(
          assetIsin: 'US0378331005',
          orderDate: DateTime(2024, 2, 1),
          quantity: -50,
          totalEur: 500,
          totalNative: 550,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(50));
      expect(holdings.first.totalCostEur, equals(450)); // 50% of 900
      expect(holdings.first.totalCostNative, equals(500)); // 50% of 1000
    });

    test('returns empty list for empty input', () {
      final holdings = deriveHoldings([]);
      expect(holdings, isEmpty);
    });

    test('example from docstring: buy 100@10, buy 50@14, sell 75', () {
      // This is the exact example from the TypeScript docstring
      final orders = [
        OrderForDerivation(
          assetIsin: 'TEST',
          orderDate: DateTime(2024, 1, 1),
          quantity: 100,
          totalEur: 1000, // 100 @ €10
          totalNative: 1000,
        ),
        OrderForDerivation(
          assetIsin: 'TEST',
          orderDate: DateTime(2024, 1, 15),
          quantity: 50,
          totalEur: 700, // 50 @ €14
          totalNative: 700,
        ),
        OrderForDerivation(
          assetIsin: 'TEST',
          orderDate: DateTime(2024, 2, 1),
          quantity: -75,
          totalEur: 1125, // Sell at €15 (proceeds, not used)
          totalNative: 1125,
        ),
      ];

      final holdings = deriveHoldings(orders);

      expect(holdings.length, equals(1));
      expect(holdings.first.quantity, equals(75));

      // After 2 buys: qty=150, cost=€1700, avg=€11.333...
      // Sell 75: reduce cost by 75 × 11.333... = €850
      // Remaining: qty=75, cost=€850
      expect(holdings.first.totalCostEur, closeTo(850, 0.01));
    });
  });
}
