import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Parameters for asset detail query.
@immutable
class AssetDetailParams {
  const AssetDetailParams({
    required this.assetId,
    required this.portfolioId,
    required this.period,
  });

  final String assetId;
  final String portfolioId;
  final ReturnPeriod period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssetDetailParams &&
          runtimeType == other.runtimeType &&
          assetId == other.assetId &&
          portfolioId == other.portfolioId &&
          period == other.period;

  @override
  int get hashCode =>
      assetId.hashCode ^ portfolioId.hashCode ^ period.hashCode;
}

/// Provider for asset detail data.
///
/// Invalidate when asset is modified, archived, or prices update.
final assetDetailProvider =
    FutureProvider.family<AssetDetailResponse, AssetDetailParams>(
        (ref, params) async {
  final client = ref.read(clientProvider);
  return await client.holdings.getAssetDetail(
    assetId: UuidValue.fromString(params.assetId),
    portfolioId: UuidValue.fromString(params.portfolioId),
    period: params.period,
  );
});

/// Provider for archived assets list.
///
/// Invalidate when assets are archived/unarchived.
final archivedAssetsProvider =
    FutureProvider.family<List<ArchivedAssetResponse>, String>(
        (ref, portfolioId) async {
  final client = ref.read(clientProvider);
  return await client.holdings.getArchivedAssets(
    portfolioId: UuidValue.fromString(portfolioId),
  );
});
