/// Holdings Derivation
///
/// Derives current holdings from all imported orders using the Average Cost Method.
/// Holdings are global - aggregated across all orders.
///
/// Average Cost Method:
/// - On buys: add to total cost basis and quantity
/// - On sells: reduce cost basis proportionally based on average cost per share
/// - The average cost per share only changes on buys, not on sells
///
/// Example:
/// - Buy 100 @ €10 = €1000 cost, avg = €10.00
/// - Buy 50 @ €14 = €700 cost, total = €1700, qty = 150, avg = €11.33
/// - Sell 75 @ €15 → reduce cost by 75 × €11.33 = €850, remaining = €850, qty = 75, avg still = €11.33

import 'dart:math' as math;

/// Intermediate holding derived from orders
/// Note: This is for calculation purposes, not the DB model
class DerivedHolding {
  final String assetIsin;
  final double quantity;
  final double totalCostEur;
  final double totalCostNative;

  const DerivedHolding({
    required this.assetIsin,
    required this.quantity,
    required this.totalCostEur,
    required this.totalCostNative,
  });

  @override
  String toString() =>
      'DerivedHolding(isin: $assetIsin, qty: $quantity, costEur: $totalCostEur, costNative: $totalCostNative)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivedHolding &&
          runtimeType == other.runtimeType &&
          assetIsin == other.assetIsin &&
          quantity == other.quantity &&
          totalCostEur == other.totalCostEur &&
          totalCostNative == other.totalCostNative;

  @override
  int get hashCode =>
      assetIsin.hashCode ^ quantity.hashCode ^ totalCostEur.hashCode ^ totalCostNative.hashCode;
}

/// Order data for holdings derivation
/// This is a minimal interface that can work with both ParsedOrder and DB Order
class OrderForDerivation {
  final String assetIsin;
  final DateTime orderDate;
  final double quantity;
  final double totalEur;
  final double totalNative;

  const OrderForDerivation({
    required this.assetIsin,
    required this.orderDate,
    required this.quantity,
    required this.totalEur,
    required this.totalNative,
  });
}

/// Derive holdings from a list of orders using Average Cost Method
///
/// Orders are processed chronologically. For each ISIN:
/// - Buys: add cost and quantity
/// - Sells: reduce cost proportionally (avgCost × soldQty)
/// - Commissions (qty=0): add to cost basis without changing quantity
List<DerivedHolding> deriveHoldings(List<OrderForDerivation> orders) {
  // Group orders by ISIN
  final ordersByIsin = <String, List<OrderForDerivation>>{};
  for (final order in orders) {
    ordersByIsin.putIfAbsent(order.assetIsin, () => []).add(order);
  }

  final holdings = <DerivedHolding>[];

  for (final entry in ordersByIsin.entries) {
    final isin = entry.key;
    final isinOrders = entry.value;

    // Sort orders by date (chronological processing is essential for average cost)
    final sortedOrders = List<OrderForDerivation>.from(isinOrders)
      ..sort((a, b) => a.orderDate.compareTo(b.orderDate));

    var totalQty = 0.0;
    var totalCostEur = 0.0;
    var totalCostNative = 0.0;

    for (final order in sortedOrders) {
      if (order.quantity > 0) {
        // BUY: add to cost basis and quantity
        totalQty += order.quantity;
        totalCostEur += order.totalEur;
        totalCostNative += order.totalNative;
      } else if (order.quantity < 0) {
        // SELL: reduce cost basis proportionally using average cost
        final soldQty = order.quantity.abs();

        if (totalQty > 0) {
          // Calculate average cost per share before this sale
          final avgCostEur = totalCostEur / totalQty;
          final avgCostNative = totalCostNative / totalQty;

          // Reduce cost basis by (sold quantity × average cost)
          final costReductionEur = avgCostEur * soldQty;
          final costReductionNative = avgCostNative * soldQty;

          totalCostEur = math.max(0, totalCostEur - costReductionEur);
          totalCostNative = math.max(0, totalCostNative - costReductionNative);
          totalQty = math.max(0, totalQty - soldQty);
        }
      } else {
        // COMMISSION (quantity = 0): add to cost basis without changing quantity
        totalCostEur += order.totalEur;
        totalCostNative += order.totalNative;
      }
    }

    // Only include positions with remaining quantity
    if (totalQty > 0) {
      holdings.add(DerivedHolding(
        assetIsin: isin,
        quantity: totalQty,
        totalCostEur: totalCostEur,
        totalCostNative: totalCostNative,
      ));
    }
  }

  return holdings;
}
