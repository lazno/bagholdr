import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'asset_providers.dart';
import 'client_provider.dart';
import 'holdings_providers.dart';
import 'issues_providers.dart';
import 'sleeve_providers.dart';
import 'valuation_providers.dart';

/// Archive or unarchive an asset and invalidate related providers.
///
/// Returns true if the operation was successful.
Future<bool> archiveAsset(
  WidgetRef ref,
  String assetId,
  String portfolioId,
  bool archive,
) async {
  final client = ref.read(clientProvider);
  final success = await client.holdings.archiveAsset(
    assetId: UuidValue.fromString(assetId),
    archived: archive,
  );

  if (success) {
    // Invalidate specific provider instances for the current portfolio
    // This ensures the dashboard refreshes with the correct data
    ref.invalidate(assetDetailProvider);
    ref.invalidate(holdingsProvider);
    ref.invalidate(portfolioValuationProvider(portfolioId));
    ref.invalidate(archivedAssetsProvider(portfolioId));
    ref.invalidate(chartDataProvider);
    ref.invalidate(historicalReturnsProvider(portfolioId));
    ref.invalidate(sleeveTreeProvider);
    ref.invalidate(issuesProvider(portfolioId));
  }

  return success;
}

/// Assign an asset to a sleeve and invalidate related providers.
Future<AssignSleeveResult> assignAssetToSleeve(
  WidgetRef ref,
  String assetId,
  String portfolioId,
  String? sleeveId,
) async {
  final client = ref.read(clientProvider);
  final result = await client.holdings.assignAssetToSleeve(
    assetId: UuidValue.fromString(assetId),
    sleeveId: sleeveId != null ? UuidValue.fromString(sleeveId) : null,
  );

  // Always invalidate sleeve tree and holdings when sleeve assignment changes
  ref.invalidate(assetDetailProvider);
  ref.invalidate(sleeveTreeProvider);
  ref.invalidate(holdingsProvider);
  ref.invalidate(portfolioValuationProvider(portfolioId));
  ref.invalidate(issuesProvider(portfolioId));

  return result;
}

/// Update an asset's Yahoo symbol.
Future<void> updateYahooSymbol(
  WidgetRef ref,
  String assetId,
  String portfolioId,
  String? newSymbol,
) async {
  final client = ref.read(clientProvider);
  await client.holdings.updateYahooSymbol(
    assetId: UuidValue.fromString(assetId),
    newSymbol: newSymbol,
  );

  // Invalidate all affected providers
  ref.invalidate(assetDetailProvider);
  ref.invalidate(holdingsProvider);
  ref.invalidate(portfolioValuationProvider(portfolioId));
  ref.invalidate(historicalReturnsProvider(portfolioId));
  ref.invalidate(chartDataProvider);
}

/// Update an asset's type.
Future<void> updateAssetType(
  WidgetRef ref,
  String assetId,
  String portfolioId,
  String newType,
) async {
  final client = ref.read(clientProvider);
  await client.holdings.updateAssetType(
    assetId: UuidValue.fromString(assetId),
    newType: newType,
  );

  ref.invalidate(assetDetailProvider);
  ref.invalidate(holdingsProvider);
  ref.invalidate(portfolioValuationProvider(portfolioId));
  ref.invalidate(sleeveTreeProvider);
}

/// Refresh prices for an asset.
Future<RefreshPriceResult> refreshAssetPrices(
  WidgetRef ref,
  String assetId,
  String portfolioId,
) async {
  final client = ref.read(clientProvider);
  final result = await client.holdings.refreshAssetPrices(
    assetId: UuidValue.fromString(assetId),
  );

  if (result.success) {
    ref.invalidate(assetDetailProvider);
    ref.invalidate(holdingsProvider);
    ref.invalidate(portfolioValuationProvider(portfolioId));
    ref.invalidate(chartDataProvider);
    ref.invalidate(historicalReturnsProvider(portfolioId));
    ref.invalidate(sleeveTreeProvider);
  }

  return result;
}

/// Clear price history for an asset.
Future<ClearPriceHistoryResult> clearPriceHistory(
  WidgetRef ref,
  String assetId,
  String portfolioId,
) async {
  final client = ref.read(clientProvider);
  final result = await client.holdings.clearPriceHistory(
    assetId: UuidValue.fromString(assetId),
  );

  ref.invalidate(assetDetailProvider);
  ref.invalidate(chartDataProvider);
  ref.invalidate(holdingsProvider);
  ref.invalidate(portfolioValuationProvider(portfolioId));
  ref.invalidate(historicalReturnsProvider(portfolioId));

  return result;
}
