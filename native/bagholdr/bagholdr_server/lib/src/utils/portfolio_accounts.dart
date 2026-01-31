import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';

/// Helper functions for working with portfolio-account relationships.

/// Get the set of account IDs linked to a portfolio.
///
/// Returns an empty set if no accounts are linked.
Future<Set<UuidValue>> getPortfolioAccountIds(
  Session session,
  UuidValue portfolioId,
) async {
  final links = await PortfolioAccount.db.find(
    session,
    where: (t) => t.portfolioId.equals(portfolioId),
  );

  return links.map((l) => l.accountId).toSet();
}

/// Get holdings for a portfolio (filtered by linked accounts).
///
/// Returns all holdings that belong to accounts linked to the portfolio.
/// Holdings are aggregated by assetId if the same asset exists in multiple accounts.
Future<List<Holding>> getPortfolioHoldings(
  Session session,
  UuidValue portfolioId,
) async {
  final accountIds = await getPortfolioAccountIds(session, portfolioId);

  if (accountIds.isEmpty) {
    return [];
  }

  return await Holding.db.find(
    session,
    where: (t) => t.accountId.inSet(accountIds),
  );
}

/// Get orders for a portfolio (filtered by linked accounts).
///
/// Returns all orders that belong to accounts linked to the portfolio.
Future<List<Order>> getPortfolioOrders(
  Session session,
  UuidValue portfolioId, {
  Column Function(OrderTable)? orderBy,
  bool orderDescending = false,
}) async {
  final accountIds = await getPortfolioAccountIds(session, portfolioId);

  if (accountIds.isEmpty) {
    return [];
  }

  return await Order.db.find(
    session,
    where: (t) => t.accountId.inSet(accountIds),
    orderBy: orderBy,
    orderDescending: orderDescending,
  );
}

/// Aggregate holdings by asset ID.
///
/// When the same asset exists in multiple accounts, this combines them
/// into a single holding with summed quantity and cost basis.
Map<String, AggregatedHolding> aggregateHoldingsByAsset(List<Holding> holdings) {
  final aggregated = <String, AggregatedHolding>{};

  for (final holding in holdings) {
    final assetIdStr = holding.assetId.toString();

    if (aggregated.containsKey(assetIdStr)) {
      final existing = aggregated[assetIdStr]!;
      aggregated[assetIdStr] = AggregatedHolding(
        assetId: holding.assetId,
        quantity: existing.quantity + holding.quantity,
        totalCostEur: existing.totalCostEur + holding.totalCostEur,
      );
    } else {
      aggregated[assetIdStr] = AggregatedHolding(
        assetId: holding.assetId,
        quantity: holding.quantity,
        totalCostEur: holding.totalCostEur,
      );
    }
  }

  return aggregated;
}

/// Represents an aggregated holding across multiple accounts.
class AggregatedHolding {
  final UuidValue assetId;
  final double quantity;
  final double totalCostEur;

  const AggregatedHolding({
    required this.assetId,
    required this.quantity,
    required this.totalCostEur,
  });
}
