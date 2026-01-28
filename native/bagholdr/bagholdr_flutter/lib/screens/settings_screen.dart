import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart' show client, initializeClient, priceStreamProvider;
import '../providers/providers.dart';
import '../services/app_settings.dart';
import '../services/price_stream_provider.dart';
import '../theme/colors.dart';
import 'app_shell.dart';
import 'manage_assets_screen.dart';

/// Settings screen with app configuration options.
///
/// Includes:
/// - Theme toggle (light/dark/system)
/// - Privacy mode toggle (blur values)
/// - Server URL configuration (for dev)
/// - Connection status indicator
/// - About/version info
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers to rebuild on changes
    final priceStream = ref.watch(priceStreamAdapterProvider);
    final hideBalancesValue = ref.watch(hideBalancesProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final portfolioId = ref.watch(selectedPortfolioIdProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 8),
            // Connection Status Section
            _buildSectionHeader(context, 'Connection'),
            _ConnectionStatusTile(priceStream: priceStream),

            const SizedBox(height: 16),

            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            _ThemeTile(currentMode: currentThemeMode, ref: ref),
            _PrivacyModeTile(isHidden: hideBalancesValue, ref: ref),

            const SizedBox(height: 16),

            // Portfolio Section
            _buildSectionHeader(context, 'Portfolio'),
            _ManageAssetsTile(portfolioId: portfolioId),

            const SizedBox(height: 16),

            // Developer Section
            _buildSectionHeader(context, 'Developer'),
            const _ServerUrlTile(),

            const SizedBox(height: 16),

            // About Section
            _buildSectionHeader(context, 'About'),
            const _AboutTile(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ConnectionStatusTile extends StatelessWidget {
  const _ConnectionStatusTile({required this.priceStream});

  final PriceStreamProvider priceStream;

  String _formatLastUpdate(DateTime? lastUpdateAt) {
    if (lastUpdateAt == null) return '';
    final diff = DateTime.now().difference(lastUpdateAt);
    if (diff.inSeconds < 60) return ' - just now';
    if (diff.inMinutes < 60) return ' - ${diff.inMinutes}m ago';
    return ' - ${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final status = priceStream.connectionStatus;
    final lastUpdate = priceStream.lastUpdateAt;

    final (Color statusColor, IconData icon, String statusText, String subtitle) =
        switch (status) {
      ConnectionStatus.connected => (
          financialColors.positive,
          Icons.cloud_done,
          'Connected',
          'Live prices${_formatLastUpdate(lastUpdate)}',
        ),
      ConnectionStatus.connecting => (
          colorScheme.onSurfaceVariant,
          Icons.cloud_sync,
          'Connecting',
          'Establishing connection...',
        ),
      ConnectionStatus.disconnected => (
          colorScheme.error,
          Icons.cloud_off,
          'Disconnected',
          'Prices may be stale',
        ),
    };

    return Container(
      color: colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        title: Text(statusText),
        subtitle: Text(subtitle),
        trailing: status == ConnectionStatus.disconnected
            ? TextButton(
                onPressed: () => priceStreamProvider.connect(),
                child: const Text('Reconnect'),
              )
            : null,
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.currentMode, required this.ref});

  final ThemeMode currentMode;
  final WidgetRef ref;

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System default',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(themeModeProvider.notifier).state = value;
              Navigator.pop(dialogContext);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(_themeModeLabel(mode)),
                value: mode,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            currentMode == ThemeMode.dark
                ? Icons.dark_mode
                : currentMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: const Text('Theme'),
        subtitle: Text(_themeModeLabel(currentMode)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(context),
      ),
    );
  }
}

class _PrivacyModeTile extends StatelessWidget {
  const _PrivacyModeTile({required this.isHidden, required this.ref});

  final bool isHidden;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: const Text('Privacy mode'),
        subtitle: const Text('Hide currency values'),
        value: isHidden,
        onChanged: (value) {
          ref.read(hideBalancesProvider.notifier).state = value;
        },
      ),
    );
  }
}

class _ManageAssetsTile extends StatelessWidget {
  const _ManageAssetsTile({required this.portfolioId});

  final String? portfolioId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),
        title: const Text('Manage Assets'),
        subtitle: const Text('View and unarchive assets'),
        trailing: const Icon(Icons.chevron_right),
        enabled: portfolioId != null,
        onTap: portfolioId != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageAssetsScreen(portfolioId: portfolioId!),
                  ),
                );
              }
            : null,
      ),
    );
  }
}

class _ServerUrlTile extends StatelessWidget {
  const _ServerUrlTile();

  Future<void> _showServerUrlDialog(BuildContext context) async {
    final currentUrl = AppSettings.getServerUrl();
    final controller = TextEditingController(
      text: AppSettings.customServerUrl ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String? validationError;

    // Capture context-dependent objects before async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Server URL'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current: $currentUrl',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'https://bagholdr.example.com/',
                    errorText: validationError,
                  ),
                  onChanged: (value) {
                    if (validationError != null) {
                      setDialogState(() => validationError = null);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final url = controller.text.trim();

                // Validate URL
                final error = AppSettings.validateServerUrl(url);
                if (error != null) {
                  setDialogState(() => validationError = error);
                  return;
                }

                // Ensure URL ends with /
                final normalizedUrl = url.endsWith('/') ? url : '$url/';
                Navigator.pop(context, normalizedUrl);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return; // Cancelled

    // Save the URL
    final success = await AppSettings.setCustomServerUrl(result);

    if (!success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to save server URL'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Reinitialize the client with the new URL
    initializeClient(AppSettings.getServerUrl());

    // Reset price stream connection
    priceStreamProvider.disconnect();

    // Navigate to AppShell, clearing the navigation stack
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCustom = AppSettings.hasCustomServerUrl;

    return Container(
      color: colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.dns_outlined,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),
        title: const Text('Server URL'),
        subtitle: Text(
          isCustom ? '${client.host} (custom)' : '${client.host} (default)',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showServerUrlDialog(context),
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.info_outline,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        title: const Text('Bagholdr'),
        subtitle: const Text('Version 1.0.0'),
        onTap: () {
          showAboutDialog(
            context: context,
            applicationName: 'Bagholdr',
            applicationVersion: '1.0.0',
            applicationLegalese: 'Portfolio tracking and rebalancing app',
          );
        },
      ),
    );
  }
}
