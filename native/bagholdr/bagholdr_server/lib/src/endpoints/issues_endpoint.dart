import 'package:serverpod/serverpod.dart' hide Order;

import '../generated/protocol.dart';
import '../utils/bands.dart';

/// Endpoint for detecting portfolio issues/health indicators.
///
/// Detects allocation drift, stale prices, and sync status issues.
class IssuesEndpoint extends Endpoint {
  /// Sleeve color mapping (consistent with sleeves endpoint)
  static const _sleeveColors = <String, String>{
    'Core': '#3b82f6',
    'Equities': '#60a5fa',
    'Bonds': '#93c5fd',
    'Satellite': '#f59e0b',
    'Safe Haven': '#fbbf24',
    'Growth': '#fcd34d',
  };

  /// Default color for unmapped sleeves
  static const _defaultColor = '#6b7280';

  /// Get portfolio issues
  ///
  /// [portfolioId] - Portfolio to check issues for
  Future<IssuesResponse> getIssues(
    Session session, {
    required UuidValue portfolioId,
  }) async {
    final now = DateTime.now();
    final issues = <Issue>[];

    // Get portfolio for band config
    final portfolio = await Portfolio.db.findById(session, portfolioId);
    if (portfolio == null) {
      throw Exception('Portfolio not found');
    }

    final bandConfig = BandConfig(
      relativeTolerance: portfolio.bandRelativeTolerance,
      absoluteFloor: portfolio.bandAbsoluteFloor,
      absoluteCap: portfolio.bandAbsoluteCap,
    );

    // Get allocation issues
    final allocationIssues = await _detectAllocationIssues(
      session,
      portfolioId,
      bandConfig,
    );
    issues.addAll(allocationIssues);

    // Get stale price issues
    final stalePriceIssue = await _detectStalePriceIssue(session, now);
    if (stalePriceIssue != null) {
      issues.add(stalePriceIssue);
    }

    // Get sync status issue
    final syncIssue = await _detectSyncStatusIssue(session, now);
    if (syncIssue != null) {
      issues.add(syncIssue);
    }

    // Sort: warnings first, then by type
    issues.sort((a, b) {
      final severityCompare = a.severity == IssueSeverity.warning ? 0 : 1;
      final severityCompareB = b.severity == IssueSeverity.warning ? 0 : 1;
      if (severityCompare != severityCompareB) {
        return severityCompare - severityCompareB;
      }
      return a.type.index - b.type.index;
    });

    return IssuesResponse(
      issues: issues,
      totalCount: issues.length,
    );
  }

  /// Detect allocation drift issues for sleeves
  Future<List<Issue>> _detectAllocationIssues(
    Session session,
    UuidValue portfolioId,
    BandConfig bandConfig,
  ) async {
    final issues = <Issue>[];

    // Get all sleeves for this portfolio (excluding cash sleeves)
    final allSleeves = await Sleeve.db.find(
      session,
      where: (t) => t.portfolioId.equals(portfolioId),
      orderBy: (t) => t.sortOrder,
    );
    final nonCashSleeves = allSleeves.where((s) => !s.isCash).toList();

    // Get all holdings with quantity > 0
    final allHoldings = await Holding.db.find(
      session,
      where: (t) => t.quantity > 0.0,
    );

    // Get all non-archived assets
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetMap = {for (var a in allAssets) a.id!.toString(): a};
    final nonArchivedAssetIds = allAssets.map((a) => a.id!.toString()).toSet();

    // Filter holdings to non-archived assets
    final filteredHoldings = allHoldings
        .where((h) => nonArchivedAssetIds.contains(h.assetId.toString()))
        .toList();

    // Get cached prices
    final cachedPrices = await PriceCache.db.find(session);
    final priceMap = {for (var p in cachedPrices) p.ticker: p.priceEur};

    // Get sleeve-asset assignments
    final allAssignments = await SleeveAsset.db.find(session);
    final sleeveIds = nonCashSleeves.map((s) => s.id!.toString()).toSet();
    final portfolioAssignments = allAssignments
        .where((a) => sleeveIds.contains(a.sleeveId.toString()))
        .toList();

    // Build asset to sleeve mapping
    final assetToSleeveMap = <String, String>{};
    for (final assignment in portfolioAssignments) {
      assetToSleeveMap[assignment.assetId.toString()] =
          assignment.sleeveId.toString();
    }

    // Calculate holding values
    final holdingValues = <String, double>{};
    double totalInvestedValue = 0;

    for (final holding in filteredHoldings) {
      final assetIdStr = holding.assetId.toString();
      final asset = assetMap[assetIdStr];
      if (asset == null) continue;

      final lookupKey = asset.yahooSymbol ?? asset.ticker;
      final cachedPrice = priceMap[lookupKey];
      final valueEur = cachedPrice != null
          ? cachedPrice * holding.quantity
          : holding.totalCostEur;

      holdingValues[assetIdStr] = valueEur;

      // Only count assigned assets toward invested value
      if (assetToSleeveMap.containsKey(assetIdStr)) {
        totalInvestedValue += valueEur;
      }
    }

    // Build direct values per sleeve
    final directValueMap = <String, double>{};

    for (final sleeveIdStr in sleeveIds) {
      final sleeveAssetIds = portfolioAssignments
          .where((a) => a.sleeveId.toString() == sleeveIdStr)
          .map((a) => a.assetId.toString())
          .toList();

      double directValue = 0;

      for (final assetIdStr in sleeveAssetIds) {
        final value = holdingValues[assetIdStr];
        if (value != null && value > 0) {
          directValue += value;
        }
      }

      directValueMap[sleeveIdStr] = directValue;
    }

    // Build children map for tree traversal
    final childrenMap = <String?, List<Sleeve>>{};
    for (final sleeve in nonCashSleeves) {
      final parentId = sleeve.parentSleeveId?.toString();
      childrenMap.putIfAbsent(parentId, () => []).add(sleeve);
    }

    // Check each sleeve for allocation drift
    for (final sleeve in nonCashSleeves) {
      final sleeveIdStr = sleeve.id!.toString();

      // Calculate total value (including descendants)
      final totalValue = _calculateSleeveTotal(
        sleeveIdStr,
        childrenMap,
        directValueMap,
      );

      // Calculate allocation percentages
      final currentPct = totalInvestedValue > 0
          ? (totalValue / totalInvestedValue) * 100
          : 0.0;

      // Calculate drift and check band
      final driftPp = currentPct - sleeve.budgetPercent;
      final band = calculateBand(sleeve.budgetPercent, bandConfig);
      final status = evaluateStatus(currentPct, band);

      if (status == AllocationStatus.warning) {
        final isOver = driftPp > 0;
        final color = _sleeveColors[sleeve.name] ?? _defaultColor;
        final roundedDrift = (driftPp.abs() * 10).round() / 10;

        issues.add(Issue(
          type: isOver ? IssueType.overAllocation : IssueType.underAllocation,
          severity: IssueSeverity.warning,
          message: isOver
              ? '${sleeve.name} +${roundedDrift}pp over target'
              : '${sleeve.name} -${roundedDrift}pp under target',
          sleeveId: sleeveIdStr,
          sleeveName: sleeve.name,
          driftPp: driftPp,
          color: color,
        ));
      }
    }

    return issues;
  }

  /// Recursively calculate total value for a sleeve including all descendants
  double _calculateSleeveTotal(
    String sleeveId,
    Map<String?, List<Sleeve>> childrenMap,
    Map<String, double> directValueMap,
  ) {
    double total = directValueMap[sleeveId] ?? 0;

    final children = childrenMap[sleeveId] ?? [];
    for (final child in children) {
      total += _calculateSleeveTotal(
        child.id!.toString(),
        childrenMap,
        directValueMap,
      );
    }

    return total;
  }

  /// Detect stale price issue (aggregated for all stale assets)
  Future<Issue?> _detectStalePriceIssue(Session session, DateTime now) async {
    final staleThreshold = now.subtract(const Duration(hours: 24));

    // Get all non-archived assets with yahoo symbols
    final allAssets = await Asset.db.find(
      session,
      where: (t) => t.archived.equals(false),
    );
    final assetsWithSymbol =
        allAssets.where((a) => a.yahooSymbol != null).toList();

    if (assetsWithSymbol.isEmpty) return null;

    // Get all price cache entries
    final cachedPrices = await PriceCache.db.find(session);
    final priceByTicker = {for (var p in cachedPrices) p.ticker: p};

    // Get all holdings to know which assets are currently held
    final allHoldings = await Holding.db.find(
      session,
      where: (t) => t.quantity > 0.0,
    );
    final heldAssetIds = allHoldings.map((h) => h.assetId.toString()).toSet();

    // Count stale prices for held assets
    int staleCount = 0;
    for (final asset in assetsWithSymbol) {
      if (!heldAssetIds.contains(asset.id!.toString())) continue;

      final price = priceByTicker[asset.yahooSymbol];
      if (price == null || price.fetchedAt.isBefore(staleThreshold)) {
        staleCount++;
      }
    }

    if (staleCount == 0) return null;

    return Issue(
      type: IssueType.stalePrice,
      severity: IssueSeverity.warning,
      message: staleCount == 1
          ? '1 asset has stale prices'
          : '$staleCount assets have stale prices',
    );
  }

  /// Detect sync status issue (time since last order import)
  Future<Issue?> _detectSyncStatusIssue(Session session, DateTime now) async {
    // Find the most recent order by importedAt
    final orders = await Order.db.find(
      session,
      orderBy: (t) => t.importedAt,
      orderDescending: true,
      limit: 1,
    );

    if (orders.isEmpty) {
      return Issue(
        type: IssueType.syncStatus,
        severity: IssueSeverity.info,
        message: 'No orders imported yet',
      );
    }

    final lastImportedAt = orders.first.importedAt;
    final hoursSinceSync = now.difference(lastImportedAt).inHours;

    // Only show issue if > 2 hours since last sync
    if (hoursSinceSync < 2) return null;

    final duration = _formatDuration(now.difference(lastImportedAt));

    return Issue(
      type: IssueType.syncStatus,
      severity: IssueSeverity.info,
      message: 'Last sync: $duration ago',
    );
  }

  /// Format duration as human-readable string
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    }
    return 'just now';
  }
}
