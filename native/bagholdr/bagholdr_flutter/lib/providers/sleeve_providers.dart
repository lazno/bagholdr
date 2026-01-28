import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Parameters for sleeve tree query.
@immutable
class SleeveTreeParams {
  const SleeveTreeParams({
    required this.portfolioId,
    required this.period,
  });

  final String portfolioId;
  final ReturnPeriod period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleeveTreeParams &&
          runtimeType == other.runtimeType &&
          portfolioId == other.portfolioId &&
          period == other.period;

  @override
  int get hashCode => portfolioId.hashCode ^ period.hashCode;
}

/// Provider for sleeve tree data (allocation visualization).
///
/// Invalidate when assets are assigned/unassigned to sleeves.
final sleeveTreeProvider =
    FutureProvider.family<SleeveTreeResponse, SleeveTreeParams>((ref, params) async {
  final client = ref.read(clientProvider);
  return await client.sleeves.getSleeveTree(
    portfolioId: UuidValue.fromString(params.portfolioId),
    period: params.period,
  );
});
