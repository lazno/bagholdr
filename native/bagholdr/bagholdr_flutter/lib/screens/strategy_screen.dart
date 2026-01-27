import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/assets_section.dart' show toReturnPeriod;
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
class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends State<StrategyScreen> {
  late Future<List<Portfolio>> _portfoliosFuture;
  Portfolio? _selectedPortfolio;
  TimePeriod _selectedPeriod = TimePeriod.oneYear;

  // Sleeve tree state
  SleeveTreeResponse? _sleeveTree;
  bool _isLoadingSleeveTree = false;

  // Issues state
  List<Issue> _issues = [];

  @override
  void initState() {
    super.initState();
    _portfoliosFuture = _loadPortfolios();
    hideBalances.addListener(_onHideBalancesChanged);
  }

  @override
  void dispose() {
    hideBalances.removeListener(_onHideBalancesChanged);
    super.dispose();
  }

  void _onHideBalancesChanged() {
    if (mounted) setState(() {});
  }

  Future<List<Portfolio>> _loadPortfolios() async {
    final portfolios = await client.portfolio.getPortfolios();
    if (portfolios.isNotEmpty && _selectedPortfolio == null) {
      setState(() {
        _selectedPortfolio = portfolios.first;
      });
      _loadSleeveTree(portfolios.first.id!);
      _loadIssues(portfolios.first.id!);
    }
    return portfolios;
  }

  Future<void> _loadSleeveTree(UuidValue portfolioId) async {
    final isInitialLoad = _sleeveTree == null;
    if (isInitialLoad) {
      setState(() => _isLoadingSleeveTree = true);
    }

    try {
      final period = toReturnPeriod(_selectedPeriod);
      final response = await client.sleeves.getSleeveTree(
        portfolioId: portfolioId,
        period: period,
      );
      setState(() {
        _sleeveTree = response;
        _isLoadingSleeveTree = false;
      });
    } catch (e) {
      setState(() => _isLoadingSleeveTree = false);
      debugPrint('Error loading sleeve tree: $e');
    }
  }

  Future<void> _loadIssues(UuidValue portfolioId) async {
    try {
      final response = await client.issues.getIssues(portfolioId: portfolioId);
      setState(() {
        _issues = response.issues;
      });
    } catch (e) {
      debugPrint('Error loading issues: $e');
    }
  }

  void _onPortfolioChanged(Portfolio portfolio) {
    setState(() {
      _selectedPortfolio = portfolio;
    });
    _loadSleeveTree(portfolio.id!);
    _loadIssues(portfolio.id!);
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    if (_selectedPortfolio != null) {
      _loadSleeveTree(_selectedPortfolio!.id!);
    }
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Portfolio>>(
      future: _portfoliosFuture,
      builder: (context, snapshot) {
        final bgColor = Theme.of(context).colorScheme.surfaceContainerLow;
        final colorScheme = Theme.of(context).colorScheme;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final portfolios = snapshot.data ?? [];

        if (portfolios.isEmpty) {
          return Scaffold(
            backgroundColor: bgColor,
            body: const SafeArea(
              child: Center(
                child: Text('No portfolios available'),
              ),
            ),
          );
        }

        final selected = _selectedPortfolio ?? portfolios.first;

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
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        IssuesBar(
                          issues: _issues,
                          onIssueTap: (issue) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Issue: ${issue.message}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        if (_isLoadingSleeveTree)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_sleeveTree != null)
                          StrategySectionV2(
                            sleeveTree: _sleeveTree!,
                            hideBalances: hideBalances.value,
                            // No onSleeveSelected - selection is local to this page
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'No sleeve data available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
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
}
