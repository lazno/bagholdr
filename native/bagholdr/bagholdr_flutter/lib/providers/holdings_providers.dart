import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Parameters for holdings query.
@immutable
class HoldingsParams {
  const HoldingsParams({
    required this.portfolioId,
    required this.period,
    this.search,
    this.sleeveId,
    this.offset = 0,
    this.limit = 8,
  });

  final String portfolioId;
  final ReturnPeriod period;
  final String? search;
  final String? sleeveId;
  final int offset;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldingsParams &&
          runtimeType == other.runtimeType &&
          portfolioId == other.portfolioId &&
          period == other.period &&
          search == other.search &&
          sleeveId == other.sleeveId &&
          offset == other.offset &&
          limit == other.limit;

  @override
  int get hashCode =>
      portfolioId.hashCode ^
      period.hashCode ^
      search.hashCode ^
      sleeveId.hashCode ^
      offset.hashCode ^
      limit.hashCode;

  /// Creates a copy with updated values.
  HoldingsParams copyWith({
    String? portfolioId,
    ReturnPeriod? period,
    String? search,
    String? sleeveId,
    int? offset,
    int? limit,
  }) {
    return HoldingsParams(
      portfolioId: portfolioId ?? this.portfolioId,
      period: period ?? this.period,
      search: search ?? this.search,
      sleeveId: sleeveId ?? this.sleeveId,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }
}

/// Provider for fetching holdings with parameters.
///
/// Use with ref.watch(holdingsProvider(params)) to fetch holdings.
/// Invalidate this provider when assets are archived/unarchived/modified.
final holdingsProvider =
    FutureProvider.family<HoldingsListResponse, HoldingsParams>((ref, params) async {
  final client = ref.read(clientProvider);
  return await client.holdings.getHoldings(
    portfolioId: UuidValue.fromString(params.portfolioId),
    period: params.period,
    search: params.search,
    sleeveId: params.sleeveId != null ? UuidValue.fromString(params.sleeveId!) : null,
    offset: params.offset,
    limit: params.limit,
  );
});
