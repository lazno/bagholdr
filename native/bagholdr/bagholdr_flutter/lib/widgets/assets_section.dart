import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/formatters.dart';
import 'time_range_bar.dart';

/// Maps UI TimePeriod to API ReturnPeriod.
ReturnPeriod toReturnPeriod(TimePeriod period) {
  switch (period) {
    case TimePeriod.oneMonth:
      return ReturnPeriod.oneMonth;
    case TimePeriod.sixMonths:
      return ReturnPeriod.sixMonths;
    case TimePeriod.ytd:
      return ReturnPeriod.ytd;
    case TimePeriod.oneYear:
      return ReturnPeriod.oneYear;
    case TimePeriod.all:
      return ReturnPeriod.all;
  }
}

/// Assets section displaying a filterable, paginated list of holdings.
///
/// This widget is embedded in the dashboard and shows:
/// - Section header with title and count badge
/// - Search bar for filtering by symbol/name
/// - Horizontally scrollable table with Asset, Performance, Weight columns
/// - "Show more assets" pagination button
///
/// Usage:
/// ```dart
/// AssetsSection(
///   holdings: holdingsResponse.holdings,
///   totalCount: holdingsResponse.totalCount,
///   filteredCount: holdingsResponse.filteredCount,
///   selectedSleeveName: 'All',
///   onSearch: (query) => fetchHoldings(search: query),
///   onLoadMore: () => fetchHoldings(offset: currentOffset + 8),
///   hasMore: displayedCount < filteredCount,
/// )
/// ```
class AssetsSection extends StatelessWidget {
  const AssetsSection({
    super.key,
    required this.holdings,
    required this.totalCount,
    required this.filteredCount,
    required this.selectedSleeveName,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onLoadMore,
    required this.hasMore,
    required this.onAssetTap,
    this.isLoading = false,
    this.hideBalances = false,
  });

  /// List of holdings to display.
  final List<HoldingResponse> holdings;

  /// Total holdings count (before any filtering).
  final int totalCount;

  /// Count after search/sleeve filter is applied.
  final int filteredCount;

  /// Name of the selected sleeve for display in count badge.
  final String selectedSleeveName;

  /// Current search query.
  final String searchQuery;

  /// Callback when search query changes.
  final ValueChanged<String> onSearchChanged;

  /// Callback to load more assets (pagination).
  final VoidCallback onLoadMore;

  /// Whether there are more assets to load.
  final bool hasMore;

  /// Callback when an asset row is tapped.
  final ValueChanged<HoldingResponse> onAssetTap;

  /// Whether data is currently loading.
  final bool isLoading;

  /// Whether to hide currency values for privacy.
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          _AssetsSectionHeader(
            sleeveName: selectedSleeveName,
            count: filteredCount,
          ),
          const SizedBox(height: 12),

          // Search bar
          _SearchBar(
            value: searchQuery,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          // Asset table
          if (holdings.isEmpty && !isLoading)
            _NoResultsMessage()
          else ...[
            _AssetTable(
              holdings: holdings,
              onAssetTap: onAssetTap,
              hideBalances: hideBalances,
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _LoadMoreButton(
                  onTap: onLoadMore,
                  isLoading: isLoading,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Section header with "Assets" title and count badge.
class _AssetsSectionHeader extends StatelessWidget {
  const _AssetsSectionHeader({
    required this.sleeveName,
    required this.count,
  });

  final String sleeveName;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Assets',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$sleeveName \u00b7 $count',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Search bar with search icon and input field.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value)
                ..selection = TextSelection.collapsed(offset: value.length),
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search assets...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive asset table that fills available width.
///
/// On wider screens, the Asset column expands to fill space.
/// On narrow screens (< minWidth), enables horizontal scrolling.
class _AssetTable extends StatelessWidget {
  const _AssetTable({
    required this.holdings,
    required this.onAssetTap,
    required this.hideBalances,
  });

  final List<HoldingResponse> holdings;
  final ValueChanged<HoldingResponse> onAssetTap;
  final bool hideBalances;

  // Fixed widths for Performance and Weight columns
  static const double _perfColWidth = 115.0;
  static const double _weightColWidth = 55.0;
  // Minimum width for Asset column
  static const double _minAssetColWidth = 180.0;
  // Minimum total width before scrolling kicks in
  static const double _minTableWidth =
      _minAssetColWidth + _perfColWidth + _weightColWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // If screen is wide enough, use full width with flexible Asset column
        if (availableWidth >= _minTableWidth) {
          return Column(
            children: [
              _AssetTableHeader(
                assetColWidth: availableWidth - _perfColWidth - _weightColWidth,
              ),
              ...holdings.map(
                (holding) => _AssetRow(
                  holding: holding,
                  onTap: () => onAssetTap(holding),
                  assetColWidth:
                      availableWidth - _perfColWidth - _weightColWidth,
                  hideBalances: hideBalances,
                ),
              ),
            ],
          );
        }

        // On narrow screens, enable horizontal scrolling
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _minTableWidth,
            child: Column(
              children: [
                _AssetTableHeader(assetColWidth: _minAssetColWidth),
                ...holdings.map(
                  (holding) => _AssetRow(
                    holding: holding,
                    onTap: () => onAssetTap(holding),
                    assetColWidth: _minAssetColWidth,
                    hideBalances: hideBalances,
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

/// Asset table header row.
class _AssetTableHeader extends StatelessWidget {
  const _AssetTableHeader({required this.assetColWidth});

  final double assetColWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      letterSpacing: 0.3,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: assetColWidth,
            child: Text(
              'ASSET',
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: _AssetTable._perfColWidth,
            child: Text(
              'PERFORMANCE',
              style: headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: _AssetTable._weightColWidth,
            child: Text(
              'WEIGHT',
              style: headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual asset row in the table.
class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.holding,
    required this.onTap,
    required this.assetColWidth,
    required this.hideBalances,
  });

  final HoldingResponse holding;
  final VoidCallback onTap;
  final double assetColWidth;
  final bool hideBalances;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = context.financialColors;

    final isPositive = holding.pl >= 0;
    final plColor = isPositive ? financialColors.positive : financialColors.negative;
    final mwrColor = holding.mwr >= 0 ? financialColors.positive : financialColors.negative;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
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
            // Column 1: Asset (name, symbol, value)
            SizedBox(
              width: assetColWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          holding.symbol,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' \u00b7 ',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      Text(
                        hideBalances
                            ? '•••••'
                            : Formatters.formatCurrency(holding.value),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Column 2: Performance (P/L, MWR, TWR)
            SizedBox(
              width: _AssetTable._perfColWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hideBalances
                        ? '•••••'
                        : Formatters.formatSignedCurrency(holding.pl),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hideBalances ? colorScheme.onSurfaceVariant : plColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatPercent(holding.mwr / 100, showSign: true),
                    style: TextStyle(
                      fontSize: 10,
                      color: mwrColor,
                    ),
                  ),
                  if (holding.twr != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      'TWR ${Formatters.formatPercent(holding.twr! / 100, showSign: true)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Column 3: Weight
            SizedBox(
              width: _AssetTable._weightColWidth,
              child: Text(
                Formatters.formatWeight(holding.weight),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Show more assets" pagination button.
class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({
    required this.onTap,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Text(
                  'Show more assets',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Message shown when no assets match the search/filter.
class _NoResultsMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No assets match your search',
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
