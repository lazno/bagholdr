import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/strategy_section_v2.dart';
import '../widgets/time_range_bar.dart';

/// Demo screen to verify the StrategySection widget.
///
/// This screen shows the strategy section with real API data and
/// demonstrates sleeve selection synchronization between ring chart,
/// detail panel, and pills.
class StrategyDemoScreen extends StatefulWidget {
  const StrategyDemoScreen({super.key});

  @override
  State<StrategyDemoScreen> createState() => _StrategyDemoScreenState();
}

class _StrategyDemoScreenState extends State<StrategyDemoScreen> {
  TimePeriod _selectedPeriod = TimePeriod.oneYear;
  bool _hideBalances = false;
  bool _isLoading = true;
  SleeveTreeResponse? _sleeveTree;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSleeveTree();
  }

  Future<void> _loadSleeveTree() async {
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
      final period = toReturnPeriod(_selectedPeriod);

      final response = await client.sleeves.getSleeveTree(
        portfolioId: portfolioId,
        period: period,
      );

      setState(() {
        _sleeveTree = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading sleeves: $e';
      });
    }
  }

  void _onPeriodChanged(TimePeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadSleeveTree();
  }

  void _onSleeveSelected(String? sleeveId) {
    // Show which sleeve was selected
    final sleeveName = sleeveId == null
        ? 'All Sleeves'
        : _findSleeveName(sleeveId) ?? sleeveId;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $sleeveName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String? _findSleeveName(String id) {
    if (_sleeveTree == null) return null;

    String? search(List<SleeveNode> nodes) {
      for (final node in nodes) {
        if (node.id == id) return node.name;
        if (node.children != null) {
          final found = search(node.children!);
          if (found != null) return found;
        }
      }
      return null;
    }

    return search(_sleeveTree!.sleeves);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Demo'),
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
              onPressed: _loadSleeveTree,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_sleeveTree == null) {
      return const Center(child: Text('No sleeve data'));
    }

    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: StrategySectionV2(
        sleeveTree: _sleeveTree!,
        hideBalances: _hideBalances,
        onSleeveSelected: _onSleeveSelected,
      ),
    );
  }
}
