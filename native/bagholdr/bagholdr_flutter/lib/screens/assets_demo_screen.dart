import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/assets_section.dart';
import '../widgets/time_range_bar.dart';

/// Demo screen to verify the AssetsSection widget.
///
/// This screen shows the assets section with mock data and
/// demonstrates all features: search, filtering, pagination.
class AssetsDemoScreen extends StatefulWidget {
  const AssetsDemoScreen({super.key});

  @override
  State<AssetsDemoScreen> createState() => _AssetsDemoScreenState();
}

class _AssetsDemoScreenState extends State<AssetsDemoScreen> {
  String _searchQuery = '';
  TimePeriod _selectedPeriod = TimePeriod.oneYear;
  final String _selectedSleeve = 'All';
  int _displayedCount = 8;
  bool _isLoading = false;
  List<HoldingResponse> _holdings = [];
  int _totalCount = 0;
  int _filteredCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  Future<void> _loadHoldings() async {
    setState(() => _isLoading = true);

    try {
      // Get the first portfolio
      final portfolios = await client.portfolio.getPortfolios();
      if (portfolios.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final portfolioId = portfolios.first.id!;
      final period = toReturnPeriod(_selectedPeriod);

      final response = await client.holdings.getHoldings(
        portfolioId: portfolioId,
        period: period,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        offset: 0,
        limit: _displayedCount,
      );

      setState(() {
        _holdings = response.holdings;
        _totalCount = response.totalCount;
        _filteredCount = response.filteredCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading holdings: $e')),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _displayedCount = 8;
    });
    _loadHoldings();
  }

  void _onLoadMore() {
    setState(() => _displayedCount += 8);
    _loadHoldings();
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
      _displayedCount = 8;
    });
    _loadHoldings();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Demo'),
        backgroundColor: colorScheme.surface,
      ),
      body: Column(
        children: [
          TimeRangeBar(
            selected: _selectedPeriod,
            onChanged: _onPeriodChanged,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: AssetsSection(
                holdings: _holdings,
                totalCount: _totalCount,
                filteredCount: _filteredCount,
                selectedSleeveName: _selectedSleeve,
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
                isLoading: _isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
