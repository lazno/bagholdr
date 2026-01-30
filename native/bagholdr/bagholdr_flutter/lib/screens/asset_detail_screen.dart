import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../main.dart' show client;
import '../providers/providers.dart';
import '../theme/colors.dart';
import '../utils/formatters.dart';
import '../widgets/time_range_bar.dart';

/// Full-screen asset detail view.
///
/// Shows complete asset information, position stats, returns for the selected
/// period, and order history. Includes edit controls for Yahoo symbol, asset
/// type, and sleeve assignment.
class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({
    super.key,
    required this.assetId,
    required this.portfolioId,
    required this.initialPeriod,
  });

  /// UUID of the asset to display.
  final String assetId;

  /// Portfolio context for weight calculation.
  final String portfolioId;

  /// Initial time period (inherited from dashboard).
  final TimePeriod initialPeriod;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  late TimePeriod _selectedPeriod;
  bool _isUpdatingSymbol = false;
  bool _isUpdatingType = false;
  bool _isUpdatingSleeve = false;
  bool _isRefreshingPrices = false;
  bool _isClearingHistory = false;
  bool _isArchiving = false;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialPeriod;
  }

  void _onPeriodChanged(TimePeriod period) {
    if (period == _selectedPeriod) return;
    setState(() => _selectedPeriod = period);
  }

  AssetDetailParams get _params => AssetDetailParams(
        assetId: widget.assetId,
        portfolioId: widget.portfolioId,
        period: toReturnPeriod(_selectedPeriod),
      );

  Future<void> _showEditYahooSymbolDialog(String? currentSymbol) async {
    final controller = TextEditingController(text: currentSymbol ?? '');

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Yahoo Symbol'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Symbol',
            hintText: 'e.g., SWDA.MI',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _updateYahooSymbol(result.isEmpty ? null : result);
    }
  }

  Future<void> _updateYahooSymbol(String? newSymbol) async {
    setState(() => _isUpdatingSymbol = true);
    try {
      await updateYahooSymbol(ref, widget.assetId, widget.portfolioId, newSymbol);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newSymbol != null
              ? 'Symbol updated to $newSymbol'
              : 'Symbol cleared'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingSymbol = false);
    }
  }

  Future<void> _showAssetTypePickerDialog(String currentType) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => _AssetTypePickerDialog(currentType: currentType),
    );

    if (result != null && result != currentType) {
      await _updateAssetType(result);
    }
  }

  Future<void> _updateAssetType(String newType) async {
    setState(() => _isUpdatingType = true);
    try {
      await updateAssetType(ref, widget.assetId, widget.portfolioId, newType);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Asset type updated to ${_formatAssetTypeLabel(newType)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingType = false);
    }
  }

  String _formatAssetTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'etf':
        return 'ETF';
      case 'stock':
        return 'Stock';
      case 'bond':
        return 'Bond';
      case 'fund':
        return 'Fund';
      case 'commodity':
        return 'Commodity';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }

  Future<void> _showSleevePickerDialog(String? currentSleeveId) async {
    // Fetch available sleeves
    List<SleeveOption>? sleeves;
    try {
      sleeves = await client.holdings.getSleevesForPicker(
        portfolioId: UuidValue.fromString(widget.portfolioId),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load sleeves: $e')),
      );
      return;
    }

    if (!mounted) return;

    // Show picker dialog
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => _SleevePickerDialog(
        sleeves: sleeves!,
        currentSleeveId: currentSleeveId,
      ),
    );

    // Result is:
    // - null: user cancelled
    // - empty string: user selected "Unassigned"
    // - sleeve ID: user selected a sleeve
    if (result == null) return; // Cancelled

    final newSleeveId = result.isEmpty ? null : result;

    // Don't update if same sleeve selected
    if (newSleeveId == currentSleeveId) return;

    await _updateSleeve(newSleeveId);
  }

  Future<void> _updateSleeve(String? sleeveId) async {
    setState(() => _isUpdatingSleeve = true);
    try {
      final result = await assignAssetToSleeve(ref, widget.assetId, widget.portfolioId, sleeveId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.sleeveName != null
              ? 'Assigned to ${result.sleeveName}'
              : 'Unassigned from sleeve'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingSleeve = false);
    }
  }

  Future<void> _refreshAssetPrices() async {
    setState(() => _isRefreshingPrices = true);
    try {
      final result = await refreshAssetPrices(ref, widget.assetId, widget.portfolioId);
      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Price updated: \u20ac${result.priceEur?.toStringAsFixed(2) ?? "N/A"}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Failed to refresh prices'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isRefreshingPrices = false);
    }
  }

  Future<void> _clearPriceHistory() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Price History'),
        content: const Text(
          'This will delete all historical price data for this asset. '
          'New prices will be fetched on the next refresh.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClearingHistory = true);
    try {
      final result = await clearPriceHistory(ref, widget.assetId, widget.portfolioId);
      if (!mounted) return;

      final total = result.dailyPricesCleared +
          result.intradayPricesCleared +
          result.dividendsCleared;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            total > 0
                ? 'Cleared $total price records'
                : 'No price data to clear',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isClearingHistory = false);
    }
  }

  Future<void> _archiveAsset(bool archive) async {
    // Show confirmation dialog
    final actionText = archive ? 'Archive' : 'Unarchive';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionText Asset'),
        content: Text(
          archive
              ? 'This asset will be hidden from your dashboard. You can unarchive it later from Settings > Manage Assets.'
              : 'This asset will be restored to your dashboard.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionText),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isArchiving = true);
    try {
      final success = await archiveAsset(ref, widget.assetId, widget.portfolioId, archive);
      if (!mounted) return;

      if (success) {
        if (archive) {
          // Asset was archived - navigate back to dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asset archived')),
          );
          Navigator.of(context).pop();
        } else {
          // Asset was unarchived - the detail view will auto-refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Asset unarchived')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update asset')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isArchiving = false);
    }
  }

  void _showActionMenu(bool isArchived) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.refresh, color: colorScheme.onSurface),
              title: const Text('Refresh prices'),
              enabled: !_isRefreshingPrices,
              onTap: () {
                Navigator.pop(context);
                _refreshAssetPrices();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.onSurface),
              title: const Text('Clear price history'),
              enabled: !_isClearingHistory,
              onTap: () {
                Navigator.pop(context);
                _clearPriceHistory();
              },
            ),
            ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
                color: colorScheme.onSurface,
              ),
              title: Text(isArchived ? 'Unarchive asset' : 'Archive asset'),
              enabled: !_isArchiving,
              onTap: () {
                Navigator.pop(context);
                _archiveAsset(!isArchived);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Watch the asset detail provider
    final assetDetailAsync = ref.watch(assetDetailProvider(_params));

    // Watch price stream for real-time updates
    ref.watch(priceStreamAdapterProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(assetDetailAsync.valueOrNull?.name ?? 'Asset Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () =>
                _showActionMenu(assetDetailAsync.valueOrNull?.isArchived ?? false),
          ),
        ],
      ),
      body: assetDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (detail) => _buildContent(detail),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load asset',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(assetDetailProvider(_params)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AssetDetailResponse detail) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset header with ISIN and type
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _AssetHeader(detail: detail),
          ),

          // Time period selector
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TimeRangeBar(
              selected: _selectedPeriod,
              onChanged: _onPeriodChanged,
              embedded: true,
            ),
          ),

          const SizedBox(height: 8),

          // Position summary
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: _PositionSummary(detail: detail),
          ),

          const SizedBox(height: 8),

          // Editable fields section
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: _EditableFieldsSection(
              detail: detail,
              onEditYahooSymbol: () =>
                  _showEditYahooSymbolDialog(detail.yahooSymbol),
              onEditAssetType: () =>
                  _showAssetTypePickerDialog(detail.assetType),
              onEditSleeve: () => _showSleevePickerDialog(detail.sleeveId),
              isUpdatingSymbol: _isUpdatingSymbol,
              isUpdatingType: _isUpdatingType,
              isUpdatingSleeve: _isUpdatingSleeve,
            ),
          ),

          const SizedBox(height: 8),

          // Order history
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: _OrderHistorySection(orders: detail.orders),
          ),
        ],
      ),
    );
  }
}

/// Header showing ISIN and asset type badge.
class _AssetHeader extends StatelessWidget {
  const _AssetHeader({required this.detail});

  final AssetDetailResponse detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            detail.isin,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            detail.assetType.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/// Position summary with value, unrealized P/L, and key stats.
class _PositionSummary extends StatelessWidget {
  const _PositionSummary({required this.detail});

  final AssetDetailResponse detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = context.financialColors;

    // All values come from the server (recalculated on price updates)
    final displayValue = detail.value;
    final displayUnrealizedPL = detail.unrealizedPL;
    final displayUnrealizedPLPct = detail.unrealizedPLPct != null
        ? detail.unrealizedPLPct! / 100
        : (detail.costBasis > 0
            ? displayUnrealizedPL / detail.costBasis
            : null);

    final isPositive = displayUnrealizedPL >= 0;
    final unrealizedColor =
        isPositive ? financialColors.positive : financialColors.negative;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value and unrealized P/L (paper gain) row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatCurrency(displayValue),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${detail.quantity.toStringAsFixed(detail.quantity == detail.quantity.roundToDouble() ? 0 : 2)} shares \u00b7 ${Formatters.formatPercent(detail.weight / 100)} of portfolio',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Unrealized P/L - the prominent "paper gain" number
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InfoTooltip(
                      message:
                          'Unrealized P/L (paper gain) on your current holdings. '
                          'For the selected period, this shows how much the price has moved '
                          'since the start of that period. Updates live with price changes.',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatSignedCurrency(displayUnrealizedPL),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: unrealizedColor,
                      ),
                    ),
                  ],
                ),
                if (displayUnrealizedPLPct != null)
                  Text(
                    '(${Formatters.formatPercent(displayUnrealizedPLPct, showSign: true)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: unrealizedColor,
                    ),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Stats grid
        _StatRow(
          label: 'Realized P/L',
          value: Formatters.formatSignedCurrency(detail.realizedPL),
          valueColor: detail.realizedPL >= 0
              ? financialColors.positive
              : financialColors.negative,
          tooltip:
              'Profit or loss from shares sold during the selected period. '
              'Calculated as sale proceeds minus average cost of sold shares.',
        ),
        _StatRow(
          label: 'TWR',
          value: detail.twr != null
              ? Formatters.formatPercent(detail.twr! / 100, showSign: true)
              : '\u2014',
          valueColor: detail.twr != null
              ? (detail.twr! >= 0
                  ? financialColors.positive
                  : financialColors.negative)
              : null,
          tooltip:
              'Time-Weighted Return measures pure investment performance, '
              'ignoring when you added or removed money. Use this to compare against benchmarks.',
        ),
        _StatRow(
          label: 'MWR',
          value: Formatters.formatPercent(detail.mwr / 100, showSign: true),
          valueColor:
              detail.mwr >= 0 ? financialColors.positive : financialColors.negative,
          tooltip:
              'Money-Weighted Return (XIRR) measures your actual rate of return, '
              'accounting for when you invested. This is your personal performance.',
        ),
        _StatRow(
          label: 'Cost basis',
          value: Formatters.formatCurrency(detail.costBasis),
          tooltip: 'Total amount paid for your current shares, calculated using '
              'the average cost method. Includes purchase price and fees.',
        ),
        _StatRow(
          label: 'Total return',
          value: detail.totalReturn != null
              ? Formatters.formatPercent(detail.totalReturn! / 100, showSign: true)
              : '\u2014',
          valueColor: detail.totalReturn != null
              ? (detail.totalReturn! >= 0
                  ? financialColors.positive
                  : financialColors.negative)
              : null,
          tooltip: 'Combined realized and unrealized return as a percentage. '
              'Includes both paper gains and locked-in profits from sales.',
        ),
      ],
    );
  }
}

/// Single stat row with label, value, and optional tooltip.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.tooltip,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (tooltip != null) ...[
                const SizedBox(width: 4),
                _InfoTooltip(message: tooltip!),
              ],
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small info icon that shows a tooltip on tap.
class _InfoTooltip extends StatelessWidget {
  const _InfoTooltip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Icon(
        Icons.info_outline,
        size: 16,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
    );
  }
}

/// Editable fields with edit icons.
class _EditableFieldsSection extends StatelessWidget {
  const _EditableFieldsSection({
    required this.detail,
    this.onEditYahooSymbol,
    this.onEditAssetType,
    this.onEditSleeve,
    this.isUpdatingSymbol = false,
    this.isUpdatingType = false,
    this.isUpdatingSleeve = false,
  });

  final AssetDetailResponse detail;
  final VoidCallback? onEditYahooSymbol;
  final VoidCallback? onEditAssetType;
  final VoidCallback? onEditSleeve;
  final bool isUpdatingSymbol;
  final bool isUpdatingType;
  final bool isUpdatingSleeve;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EditableField(
          label: 'Yahoo Symbol',
          value: detail.yahooSymbol ?? '\u2014',
          onEdit: onEditYahooSymbol ?? () {},
          isLoading: isUpdatingSymbol,
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        _EditableField(
          label: 'Asset Type',
          value: _formatAssetType(detail.assetType),
          onEdit: onEditAssetType ?? () {},
          isLoading: isUpdatingType,
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        _EditableField(
          label: 'Sleeve',
          value: detail.sleeveName ?? 'Unassigned',
          onEdit: onEditSleeve ?? () {},
          isLoading: isUpdatingSleeve,
        ),
      ],
    );
  }

  String _formatAssetType(String type) {
    switch (type.toLowerCase()) {
      case 'etf':
        return 'ETF';
      case 'stock':
        return 'Stock';
      case 'bond':
        return 'Bond';
      case 'fund':
        return 'Fund';
      case 'commodity':
        return 'Commodity';
      case 'other':
        return 'Other';
      default:
        return type;
    }
  }
}

/// Single editable field row.
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.value,
    required this.onEdit,
    this.isLoading = false,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isLoading ? null : onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// Order history section with list of orders.
class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection({required this.orders});

  final List<OrderSummary> orders;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Orders',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...orders.map((order) => _OrderRow(order: order)),
      ],
    );
  }
}

/// Single order row in the history list.
class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = context.financialColors;
    final dateFormat = DateFormat('MMM d, yyyy');

    Color typeColor;
    String typeLabel;
    String quantityText;

    switch (order.orderType) {
      case 'buy':
        typeColor = financialColors.positive;
        typeLabel = 'BUY';
        quantityText =
            '+${order.quantity.abs().toStringAsFixed(order.quantity == order.quantity.roundToDouble() ? 0 : 2)}';
        break;
      case 'sell':
        typeColor = financialColors.negative;
        typeLabel = 'SELL';
        quantityText =
            '-${order.quantity.abs().toStringAsFixed(order.quantity == order.quantity.roundToDouble() ? 0 : 2)}';
        break;
      case 'fee':
        typeColor = colorScheme.onSurfaceVariant;
        typeLabel = 'FEE';
        quantityText = '';
        break;
      default:
        typeColor = colorScheme.onSurfaceVariant;
        typeLabel = order.orderType.toUpperCase();
        quantityText = order.quantity.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Date and type
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(order.orderDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ),

          // Quantity and price
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (quantityText.isNotEmpty)
                  Text(
                    quantityText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                if (order.orderType != 'fee' && order.priceNative > 0)
                  Text(
                    '@ ${_formatPrice(order.priceNative, order.currency)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Total
          Expanded(
            flex: 2,
            child: Text(
              Formatters.formatCurrency(order.totalEur.abs()),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price, String currency) {
    final symbol = currency == 'EUR'
        ? '\u20ac'
        : (currency == 'USD' ? '\$' : currency);
    return '$symbol${price.toStringAsFixed(2)}';
  }
}

/// Dialog for selecting a sleeve to assign an asset to.
class _SleevePickerDialog extends StatelessWidget {
  const _SleevePickerDialog({
    required this.sleeves,
    required this.currentSleeveId,
  });

  final List<SleeveOption> sleeves;
  final String? currentSleeveId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Assign to Sleeve'),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            // "Unassigned" option
            _SleeveOptionTile(
              name: 'Unassigned',
              depth: 0,
              isSelected: currentSleeveId == null,
              onTap: () => Navigator.pop(context, ''),
            ),
            if (sleeves.isNotEmpty)
              Divider(height: 1, color: colorScheme.outlineVariant),
            // Sleeve options
            ...sleeves.map((sleeve) => _SleeveOptionTile(
                  name: sleeve.name,
                  depth: sleeve.depth,
                  isSelected: sleeve.id == currentSleeveId,
                  onTap: () => Navigator.pop(context, sleeve.id),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

/// Single sleeve option row in the picker.
class _SleeveOptionTile extends StatelessWidget {
  const _SleeveOptionTile({
    required this.name,
    required this.depth,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final int depth;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24 + (depth * 16.0),
          right: 24,
          top: 12,
          bottom: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 20,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for selecting an asset type.
class _AssetTypePickerDialog extends StatelessWidget {
  const _AssetTypePickerDialog({required this.currentType});

  final String currentType;

  static const _assetTypes = [
    ('etf', 'ETF'),
    ('stock', 'Stock'),
    ('bond', 'Bond'),
    ('fund', 'Fund'),
    ('commodity', 'Commodity'),
    ('other', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Change Asset Type'),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: _assetTypes.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: colorScheme.outlineVariant),
          itemBuilder: (context, index) {
            final (value, label) = _assetTypes[index];
            final isSelected = currentType.toLowerCase() == value;

            return InkWell(
              onTap: () => Navigator.pop(context, value),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
