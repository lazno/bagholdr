import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart' show priceStreamProvider;
import '../providers/providers.dart';
import '../widgets/assets_section.dart';
import '../widgets/hero_value_display.dart';
import '../widgets/portfolio_chart.dart';
import '../widgets/portfolio_selector.dart';
import '../widgets/time_range_bar.dart';
import 'asset_detail_screen.dart';

/// Dashboard screen showing portfolio overview and holdings.
class PortfolioListScreen extends ConsumerStatefulWidget {
  const PortfolioListScreen({super.key});

  @override
  ConsumerState<PortfolioListScreen> createState() =>
      _PortfolioListScreenState();
}

class _PortfolioListScreenState extends ConsumerState<PortfolioListScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  Portfolio? _selectedPortfolio;
  TimePeriod _selectedPeriod = TimePeriod.oneYear;
  String _searchQuery = '';
  int _displayedCount = 8;

  @override
  void initState() {
    super.initState();
    // Connect to real-time price stream
    priceStreamProvider.connect();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for reactivity
    final portfoliosAsync = ref.watch(portfoliosProvider);
    final hideBalancesValue = ref.watch(hideBalancesProvider);
    final priceStream = ref.watch(priceStreamAdapterProvider);

    final bgColor = Theme.of(context).colorScheme.surfaceContainerLow;

    return portfoliosAsync.when(
      loading: () => Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(child: _buildErrorState(error)),
      ),
      data: (portfolios) {
        if (portfolios.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(child: _buildEmptyState()),
          );
        }

        // Auto-select first portfolio if none selected
        final selected = _selectedPortfolio ?? portfolios.first;
        if (_selectedPortfolio == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedPortfolio = portfolios.first);
              // Update global portfolio ID for cross-screen access
              ref.read(selectedPortfolioIdProvider.notifier).state =
                  portfolios.first.id!.toString();
            }
          });
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  _buildControlBar(portfolios, selected),
                  Expanded(
                    child: _DashboardContent(
                      portfolio: selected,
                      selectedPeriod: _selectedPeriod,
                      searchQuery: _searchQuery,
                      displayedCount: _displayedCount,
                      hideBalances: hideBalancesValue,
                      priceStream: priceStream,
                      searchFocusNode: _searchFocusNode,
                      onSearchChanged: _onSearchChanged,
                      onLoadMore: _onLoadMore,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _displayedCount = 8;
    });
  }

  void _onLoadMore() {
    setState(() => _displayedCount += 8);
  }

  void _onPortfolioChanged(Portfolio portfolio) {
    setState(() {
      _selectedPortfolio = portfolio;
      _searchQuery = '';
      _displayedCount = 8;
    });
    // Update global portfolio ID for cross-screen access
    ref.read(selectedPortfolioIdProvider.notifier).state =
        portfolio.id!.toString();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to: ${portfolio.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
      _displayedCount = 8;
    });
  }

  Widget _buildControlBar(List<Portfolio> portfolios, Portfolio selected) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          PortfolioSelector(
            portfolios: portfolios,
            selected: selected,
            onChanged: _onPortfolioChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TimeRangeBar(
              selected: _selectedPeriod,
              onChanged: _onPeriodChanged,
              embedded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load portfolios',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(portfoliosProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolios yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a portfolio to get started tracking your investments.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard content that watches all the data providers.
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.portfolio,
    required this.selectedPeriod,
    required this.searchQuery,
    required this.displayedCount,
    required this.hideBalances,
    required this.priceStream,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onLoadMore,
  });

  final Portfolio portfolio;
  final TimePeriod selectedPeriod;
  final String searchQuery;
  final int displayedCount;
  final bool hideBalances;
  final dynamic priceStream;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onLoadMore;

  /// Maps TimePeriod to the return period key used in historical returns
  String _getReturnPeriodKey(TimePeriod period) {
    switch (period) {
      case TimePeriod.oneMonth:
        return 'oneMonth';
      case TimePeriod.sixMonths:
        return 'sixMonths';
      case TimePeriod.ytd:
        return 'ytd';
      case TimePeriod.oneYear:
        return 'oneYear';
      case TimePeriod.all:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioId = portfolio.id!.toString();
    final period = toReturnPeriod(selectedPeriod);
    final chartRange = toChartRange(selectedPeriod);

    // Watch all data providers
    final valuationAsync = ref.watch(portfolioValuationProvider(portfolioId));
    final historicalReturnsAsync =
        ref.watch(historicalReturnsProvider(portfolioId));
    final chartDataAsync = ref.watch(chartDataProvider(
      ChartDataParams(portfolioId: portfolioId, range: chartRange),
    ));
    final holdingsAsync = ref.watch(holdingsProvider(
      HoldingsParams(
        portfolioId: portfolioId,
        period: period,
        search: searchQuery.isEmpty ? null : searchQuery,
        offset: 0,
        limit: displayedCount,
      ),
    ));

    // Get period-specific return data
    final periodKey = _getReturnPeriodKey(selectedPeriod);
    final periodReturn =
        historicalReturnsAsync.valueOrNull?.returns[periodKey];

    // Values from valuation endpoint
    final valuation = valuationAsync.valueOrNull;
    final investedValue = valuation?.investedValueEur ?? 0;
    final cashBalance = valuation?.cashEur ?? 0;
    final totalValue = valuation?.totalValueEur ?? 0;

    // Values from historical returns (period-specific)
    final mwr =
        periodReturn != null ? periodReturn.compoundedReturn / 100 : 0.0;
    final twr = periodReturn?.twr != null ? periodReturn!.twr! / 100 : null;
    final totalReturn =
        periodReturn?.totalReturn != null ? periodReturn!.totalReturn! / 100 : null;
    final returnAbs = periodReturn?.absoluteReturn ?? 0;

    // Get chart data
    final chartData = chartDataAsync.valueOrNull;

    // Get holdings data
    final holdingsData = holdingsAsync.valueOrNull;
    final holdings = holdingsData?.holdings ?? [];
    final totalCount = holdingsData?.totalCount ?? 0;
    final filteredCount = holdingsData?.filteredCount ?? 0;
    final isLoadingHoldings = holdingsAsync.isLoading;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section - full width, prominent
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroValueDisplay(
                  investedValue: investedValue,
                  mwr: mwr,
                  twr: twr,
                  totalReturn: totalReturn,
                  returnAbs: returnAbs,
                  cashBalance: cashBalance,
                  totalValue: totalValue,
                  hideBalances: hideBalances,
                ),
                const SizedBox(height: 24),
                if (chartDataAsync.isLoading)
                  const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (chartData != null && chartData.hasData)
                  PortfolioChart(
                    dataPoints: chartData.dataPoints,
                    hideBalances: hideBalances,
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'No chart data available',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Assets section
          Container(
            color: colorScheme.surface,
            child: AssetsSection(
              holdings: holdings,
              totalCount: totalCount,
              filteredCount: filteredCount,
              selectedSleeveName: 'All',
              searchQuery: searchQuery,
              onSearchChanged: onSearchChanged,
              onLoadMore: onLoadMore,
              hasMore: holdings.length < filteredCount,
              searchFocusNode: searchFocusNode,
              onAssetTap: (holding) {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => AssetDetailScreen(
                          assetId: holding.assetId,
                          portfolioId: portfolioId,
                          initialPeriod: selectedPeriod,
                        ),
                      ),
                    )
                    .then((_) => searchFocusNode.unfocus());
              },
              isLoading: isLoadingHoldings,
              hideBalances: hideBalances,
              isRecentlyUpdated: (isin) =>
                  priceStreamProvider.isRecentlyUpdated(isin),
            ),
          ),
        ],
      ),
    );
  }
}
