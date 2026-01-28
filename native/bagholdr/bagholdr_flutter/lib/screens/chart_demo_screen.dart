import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/hero_value_display.dart';
import '../widgets/portfolio_chart.dart';
import '../widgets/time_range_bar.dart';

/// Demo screen to verify the PortfolioChart widget.
///
/// This screen shows the hero section including value display and chart
/// with real API data.
class ChartDemoScreen extends StatefulWidget {
  const ChartDemoScreen({super.key});

  @override
  State<ChartDemoScreen> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends State<ChartDemoScreen> {
  TimePeriod _selectedPeriod = TimePeriod.oneYear;
  bool _hideBalances = false;
  bool _isLoading = true;
  ChartDataResult? _chartData;
  HistoricalReturnsResult? _returnsData;
  PortfolioValuation? _valuation;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the first portfolio
      final portfolios = await client.portfolio.getPortfolios();
      if (portfolios.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No portfolios found';
        });
        return;
      }

      final portfolioId = portfolios.first.id!;
      final chartRange = toChartRange(_selectedPeriod);

      // Load chart data, returns data, and valuation in parallel
      final results = await Future.wait([
        client.valuation.getChartData(portfolioId, chartRange),
        client.valuation.getHistoricalReturns(portfolioId),
        client.valuation.getPortfolioValuation(portfolioId),
      ]);

      setState(() {
        _chartData = results[0] as ChartDataResult;
        _returnsData = results[1] as HistoricalReturnsResult;
        _valuation = results[2] as PortfolioValuation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading data: $e';
      });
    }
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Demo'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_hideBalances ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _hideBalances = !_hideBalances),
            tooltip: _hideBalances ? 'Show balances' : 'Hide balances',
          ),
        ],
      ),
      body: Column(
        children: [
          TimeRangeBar(
            selected: _selectedPeriod,
            onChanged: _onPeriodChanged,
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_chartData == null || _returnsData == null || _valuation == null) {
      return const Center(child: Text('No data available'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Get return data for the selected period
    final periodKey = _getPeriodKey(_selectedPeriod);
    final periodReturn = _returnsData!.returns[periodKey];

    // Calculate values for hero display
    final investedValue = _valuation!.investedValueEur;
    final cashBalance = _valuation!.cashEur;
    final totalValue = _valuation!.totalValueEur;
    final mwr = (periodReturn?.compoundedReturn ?? 0) / 100; // Convert to decimal
    final twr = periodReturn?.twr != null ? periodReturn!.twr! / 100 : null;
    final returnAbs = periodReturn?.absoluteReturn ?? 0;

    return Container(
      color: colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Value display
                  HeroValueDisplay(
                    investedValue: investedValue,
                    mwr: mwr,
                    twr: twr,
                    returnAbs: returnAbs,
                    cashBalance: cashBalance,
                    totalValue: totalValue,
                    hideBalances: _hideBalances,
                  ),
                  const SizedBox(height: 16),
                  // Chart
                  PortfolioChart(
                    dataPoints: _chartData!.dataPoints,
                    hideBalances: _hideBalances,
                  ),
                ],
              ),
            ),
            // Debug info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data points: ${_chartData!.dataPoints.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_chartData!.dataPoints.isNotEmpty) ...[
                    Text(
                      'First date: ${_chartData!.dataPoints.first.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Last date: ${_chartData!.dataPoints.last.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Current value: ${_chartData!.dataPoints.last.investedValue}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Current cost basis: ${_chartData!.dataPoints.last.costBasis}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Map TimePeriod to API return period key.
  String _getPeriodKey(TimePeriod period) {
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
}
