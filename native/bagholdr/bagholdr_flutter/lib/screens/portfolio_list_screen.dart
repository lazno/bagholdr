import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/portfolio_selector.dart';
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
    }
    return portfolios;
  }

  void _onPortfolioChanged(Portfolio portfolio) {
    setState(() {
      _selectedPortfolio = portfolio;
    });
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
              // Hide balances toggle (placeholder)
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hide balances toggle (placeholder)'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 1),
                    ),
                  );
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
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Period: ${period.label}'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              portfolio.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dashboard content will go here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tap the portfolio name in the header\nto switch portfolios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
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
