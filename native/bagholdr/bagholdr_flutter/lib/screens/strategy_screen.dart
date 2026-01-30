import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/issues_bar.dart';
import '../widgets/portfolio_selector.dart';
import '../widgets/strategy_section_v2.dart';
import '../widgets/time_range_bar.dart';

/// Strategy screen showing sleeve allocation visualization.
///
/// Displays:
/// - Portfolio selector and time range bar
/// - Issues bar (allocation-related issues)
/// - Two-ring pie chart with sleeve breakdown
/// - Sleeve detail panel on selection
class StrategyScreen extends ConsumerStatefulWidget {
  const StrategyScreen({super.key});

  @override
  ConsumerState<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends ConsumerState<StrategyScreen> {
  Portfolio? _selectedPortfolio;
  TimePeriod _selectedPeriod = TimePeriod.oneYear;

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final portfoliosAsync = ref.watch(portfoliosProvider);
    final hideBalancesValue = ref.watch(hideBalancesProvider);

    // Watch price stream for real-time updates
    ref.watch(priceStreamAdapterProvider);

    final bgColor = Theme.of(context).colorScheme.surfaceContainerLow;
    final colorScheme = Theme.of(context).colorScheme;

    return portfoliosAsync.when(
      loading: () => Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(child: Text('Error: $error')),
        ),
      ),
      data: (portfolios) {
        if (portfolios.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const SafeArea(
              child: Center(child: Text('No portfolios available')),
            ),
          );
        }

        // Auto-select first portfolio if none selected
        final selected = _selectedPortfolio ?? portfolios.first;
        if (_selectedPortfolio == null) {
          // Schedule the state update for after the build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _selectedPortfolio = portfolios.first);
          });
        }

        final portfolioId = selected.id!.toString();
        final period = toReturnPeriod(_selectedPeriod);

        // Watch sleeve tree for this portfolio/period
        final sleeveTreeAsync = ref.watch(
          sleeveTreeProvider(SleeveTreeParams(
            portfolioId: portfolioId,
            period: period,
          )),
        );

        // Watch issues for this portfolio
        final issuesAsync = ref.watch(issuesProvider(portfolioId));

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildControlBar(portfolios, selected),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      color: colorScheme.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text(
                              'Allocation',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IssuesBar(
                            issues: issuesAsync.valueOrNull?.issues ?? [],
                            onIssueTap: (issue) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Issue: ${issue.message}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          sleeveTreeAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (error, stack) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('Error: $error'),
                            ),
                            data: (sleeveTree) => StrategySectionV2(
                              sleeveTree: sleeveTree,
                              hideBalances: hideBalancesValue,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onPortfolioChanged(Portfolio portfolio) {
    setState(() => _selectedPortfolio = portfolio);
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() => _selectedPeriod = period);
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
}
