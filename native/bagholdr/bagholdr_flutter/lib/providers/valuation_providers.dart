import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Provider for portfolio valuation data.
///
/// Invalidate when assets are archived/unarchived or prices change significantly.
final portfolioValuationProvider =
    FutureProvider.family<PortfolioValuation, String>((ref, portfolioId) async {
  final client = ref.read(clientProvider);
  return await client.valuation.getPortfolioValuation(
    UuidValue.fromString(portfolioId),
  );
});

/// Provider for historical returns data.
///
/// Returns period-specific return metrics (MWR, TWR, absolute return, etc.).
final historicalReturnsProvider =
    FutureProvider.family<HistoricalReturnsResult, String>((ref, portfolioId) async {
  final client = ref.read(clientProvider);
  return await client.valuation.getHistoricalReturns(
    UuidValue.fromString(portfolioId),
  );
});

/// Parameters for chart data query.
@immutable
class ChartDataParams {
  const ChartDataParams({
    required this.portfolioId,
    required this.range,
  });

  final String portfolioId;
  final ChartRange range;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataParams &&
          runtimeType == other.runtimeType &&
          portfolioId == other.portfolioId &&
          range == other.range;

  @override
  int get hashCode => portfolioId.hashCode ^ range.hashCode;
}

/// Provider for chart data.
///
/// Returns data points for portfolio value chart.
final chartDataProvider =
    FutureProvider.family<ChartDataResult, ChartDataParams>((ref, params) async {
  final client = ref.read(clientProvider);
  return await client.valuation.getChartData(
    UuidValue.fromString(params.portfolioId),
    params.range,
  );
});
