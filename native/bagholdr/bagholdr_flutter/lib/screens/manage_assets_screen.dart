import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../utils/formatters.dart';
import 'asset_detail_screen.dart';
import '../widgets/time_range_bar.dart';

/// Screen for managing assets (viewing and unarchiving archived assets).
///
/// Accessible from Settings. Shows a list of archived assets with dimmed
/// styling and "Archived" badges. Tapping an asset navigates to its detail
/// screen where the user can unarchive it.
class ManageAssetsScreen extends StatefulWidget {
  const ManageAssetsScreen({
    super.key,
    required this.portfolioId,
  });

  /// Portfolio context for fetching archived assets.
  final String portfolioId;

  @override
  State<ManageAssetsScreen> createState() => _ManageAssetsScreenState();
}

class _ManageAssetsScreenState extends State<ManageAssetsScreen> {
  List<ArchivedAssetResponse>? _archivedAssets;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArchivedAssets();
  }

  Future<void> _loadArchivedAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assets = await client.holdings.getArchivedAssets(
        portfolioId: UuidValue.fromString(widget.portfolioId),
      );
      if (!mounted) return;
      setState(() {
        _archivedAssets = assets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToAssetDetail(ArchivedAssetResponse asset) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(
          assetId: asset.id,
          portfolioId: widget.portfolioId,
          initialPeriod: TimePeriod.all,
        ),
      ),
    );
    // Refresh list when returning (asset may have been unarchived)
    _loadArchivedAssets();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Manage Assets'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
                'Failed to load assets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadArchivedAssets,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final assets = _archivedAssets ?? [];

    if (assets.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadArchivedAssets,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          return _ArchivedAssetTile(
            asset: assets[index],
            onTap: () => _navigateToAssetDetail(assets[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No archived assets',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Assets you archive will appear here.\nYou can archive assets from the asset detail screen.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List tile for an archived asset.
class _ArchivedAssetTile extends StatelessWidget {
  const _ArchivedAssetTile({
    required this.asset,
    required this.onTap,
  });

  final ArchivedAssetResponse asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Archived',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        asset.yahooSymbol ?? asset.isin,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (asset.lastKnownValue != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    Formatters.formatCurrency(asset.lastKnownValue!),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
