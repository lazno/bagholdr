import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/assets_section.dart';
import '../widgets/hero_value_display.dart';
import '../widgets/issues_bar.dart';
import '../widgets/portfolio_selector.dart';
import '../widgets/strategy_section_v2.dart';
import '../widgets/time_range_bar.dart';

/// Test screen demonstrating the PortfolioSelector component.
///
/// This screen shows the selector in a header context, matching how
/// it will be used in the actual dashboard.
class PortfolioListScreen extends StatefulWidget {
  const PortfolioListScreen({super.key});

  @override
  State<PortfolioListScreen> createState() => _PortfolioListScreenState();
}

class _PortfolioListScreenState extends State<PortfolioListScreen> {
  late Future<List<Portfolio>> _portfoliosFuture;
  Portfolio? _selectedPortfolio;
  TimePeriod _selectedPeriod = TimePeriod.oneYear;
  bool _hideBalances = false;

  // Assets section state
  List<HoldingResponse> _holdings = [];
  int _totalCount = 0;
  int _filteredCount = 0;
  String _searchQuery = '';
  int _displayedCount = 8;
  bool _isLoadingHoldings = false;

  // Issues state
  List<Issue> _issues = [];

  // Strategy section state
  SleeveTreeResponse? _sleeveTree;
  bool _isLoadingSleeveTree = false;
  String? _selectedSleeveId;

  @override
  void initState() {
    super.initState();
    _portfoliosFuture = _loadPortfolios();
  }

  Future<List<Portfolio>> _loadPortfolios() async {
    final portfolios = await client.portfolio.getPortfolios();
    // Auto-select first portfolio if none selected
    if (portfolios.isNotEmpty && _selectedPortfolio == null) {
      setState(() {
        _selectedPortfolio = portfolios.first;
      });
      // Load holdings, issues, and sleeve tree for the first portfolio
      _loadHoldings(portfolios.first.id!);
      _loadIssues(portfolios.first.id!);
      _loadSleeveTree(portfolios.first.id!);
    }
    return portfolios;
  }

  Future<void> _loadIssues(UuidValue portfolioId) async {
    try {
      final response = await client.issues.getIssues(portfolioId: portfolioId);
      setState(() {
        _issues = response.issues;
      });
    } catch (e) {
      // Silently fail for issues - they're not critical
      debugPrint('Error loading issues: $e');
    }
  }

  Future<void> _loadSleeveTree(UuidValue portfolioId) async {
    setState(() => _isLoadingSleeveTree = true);

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

  Future<void> _loadHoldings(UuidValue portfolioId) async {
    setState(() => _isLoadingHoldings = true);

    try {
      final period = toReturnPeriod(_selectedPeriod);
      // Convert string sleeveId to UuidValue if selected
      UuidValue? sleeveUuid;
      if (_selectedSleeveId != null) {
        sleeveUuid = UuidValue.fromString(_selectedSleeveId!);
      }

      final response = await client.holdings.getHoldings(
        portfolioId: portfolioId,
        period: period,
        sleeveId: sleeveUuid,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        offset: 0,
        limit: _displayedCount,
      );

      setState(() {
        _holdings = response.holdings;
        _totalCount = response.totalCount;
        _filteredCount = response.filteredCount;
        _isLoadingHoldings = false;
      });
    } catch (e) {
      setState(() => _isLoadingHoldings = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading holdings: $e')),
        );
      }
    }
  }

  void _onSleeveSelected(String? sleeveId) {
    setState(() {
      _selectedSleeveId = sleeveId;
      _displayedCount = 8;
    });
    if (_selectedPortfolio != null) {
      _loadHoldings(_selectedPortfolio!.id!);
    }
  }

  String _getSelectedSleeveName() {
    if (_selectedSleeveId == null || _sleeveTree == null) return 'All';
    for (final parent in _sleeveTree!.sleeves) {
      if (parent.id == _selectedSleeveId) return parent.name;
      if (parent.children != null) {
        for (final child in parent.children!) {
          if (child.id == _selectedSleeveId) return child.name;
        }
      }
    }
    return 'All';
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _displayedCount = 8;
    });
    if (_selectedPortfolio != null) {
      _loadHoldings(_selectedPortfolio!.id!);
    }
  }

  void _onLoadMore() {
    setState(() => _displayedCount += 8);
    if (_selectedPortfolio != null) {
      _loadHoldings(_selectedPortfolio!.id!);
    }
  }

  void _onPortfolioChanged(Portfolio portfolio) {
    setState(() {
      _selectedPortfolio = portfolio;
      _searchQuery = '';
      _displayedCount = 8;
    });
    _loadHoldings(portfolio.id!);
    _loadIssues(portfolio.id!);
    _loadSleeveTree(portfolio.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to: ${portfolio.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Portfolio>>(
      future: _portfoliosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: _buildErrorState(snapshot.error!),
          );
        }

        final portfolios = snapshot.data ?? [];

        if (portfolios.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Portfolios')),
            body: _buildEmptyState(),
          );
        }

        final selected = _selectedPortfolio ?? portfolios.first;

        return Scaffold(
          appBar: AppBar(
            // Mockup-style header with hamburger + selector
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu pressed (placeholder)'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            title: PortfolioSelector(
              portfolios: portfolios,
              selected: selected,
              onChanged: _onPortfolioChanged,
            ),
            titleSpacing: 0,
            actions: [
              // Hide balances toggle
              IconButton(
                icon: Icon(
                  _hideBalances
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _hideBalances = !_hideBalances;
                  });
                },
              ),
              // Status indicator (placeholder)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E), // green-500
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              TimeRangeBar(
                selected: _selectedPeriod,
                onChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                    _displayedCount = 8;
                  });
                  if (_selectedPortfolio != null) {
                    _loadHoldings(_selectedPortfolio!.id!);
                    _loadSleeveTree(_selectedPortfolio!.id!);
                  }
                },
              ),
              Expanded(child: _buildDashboardPlaceholder(selected)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardPlaceholder(Portfolio portfolio) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section with value display
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HeroValueDisplay with sample data
                HeroValueDisplay(
                  investedValue: 113482.0,
                  mwr: 0.122, // +12.2% MWR
                  twr: 0.105, // +10.5% TWR
                  returnAbs: 12348.0,
                  cashBalance: 6452.0,
                  totalValue: 119934.0,
                  hideBalances: _hideBalances,
                ),
                const SizedBox(height: 24),
                // Placeholder for chart
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Chart placeholder\n(NAPP-023)',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Strategy section
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Text(
                    'Strategy',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                // Issues bar (NAPP-013c)
                IssuesBar(
                  issues: _issues,
                  onIssueTap: (issue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Issue tapped: ${issue.message}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                // Strategy section
                if (_isLoadingSleeveTree)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_sleeveTree != null)
                  StrategySectionV2(
                    sleeveTree: _sleeveTree!,
                    hideBalances: _hideBalances,
                    onSleeveSelected: _onSleeveSelected,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'No sleeve data available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Assets section (NAPP-018)
          AssetsSection(
            holdings: _holdings,
            totalCount: _totalCount,
            filteredCount: _filteredCount,
            selectedSleeveName: _getSelectedSleeveName(),
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onLoadMore: _onLoadMore,
            hasMore: _holdings.length < _filteredCount,
            onAssetTap: (holding) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped: ${holding.name}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            isLoading: _isLoadingHoldings,
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
              onPressed: () {
                setState(() {
                  _portfoliosFuture = _loadPortfolios();
                });
              },
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
