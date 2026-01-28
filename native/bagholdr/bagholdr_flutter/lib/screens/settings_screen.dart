import 'package:flutter/material.dart';

import '../main.dart';
import '../services/app_settings.dart';
import '../services/price_stream_provider.dart';
import '../theme/colors.dart';
import 'manage_assets_screen.dart';

/// Settings screen with app configuration options.
///
/// Includes:
/// - Theme toggle (light/dark/system)
/// - Privacy mode toggle (blur values)
/// - Server URL configuration (for dev)
/// - Connection status indicator
/// - About/version info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for connection status changes
    priceStreamProvider.addListener(_onStateChanged);
    hideBalances.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    priceStreamProvider.removeListener(_onStateChanged);
    hideBalances.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: SafeArea(
        child: ListView(
        children: [
          const SizedBox(height: 8),
          // Connection Status Section
          _buildSectionHeader(context, 'Connection'),
          _buildConnectionStatusTile(context),

          const SizedBox(height: 16),

          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeTile(context),
          _buildPrivacyModeTile(context),

          const SizedBox(height: 16),

          // Portfolio Section
          _buildSectionHeader(context, 'Portfolio'),
          _buildManageAssetsTile(context),

          const SizedBox(height: 16),

          // Developer Section
          _buildSectionHeader(context, 'Developer'),
          _buildServerUrlTile(context),

          const SizedBox(height: 16),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildAboutTile(context),
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

  Widget _buildConnectionStatusTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final status = priceStreamProvider.connectionStatus;
    final lastUpdate = priceStreamProvider.lastUpdateAt;

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

  String _formatLastUpdate(DateTime? lastUpdateAt) {
    if (lastUpdateAt == null) return '';
    final diff = DateTime.now().difference(lastUpdateAt);
    if (diff.inSeconds < 60) return ' - just now';
    if (diff.inMinutes < 60) return ' - ${diff.inMinutes}m ago';
    return ' - ${diff.inHours}h ago';
  }

  Widget _buildThemeTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentMode = themeMode.value;

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
      builder: (context) => AlertDialog(
        title: const Text('Choose theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: themeMode.value,
              onChanged: (value) {
                if (value != null) {
                  themeMode.value = value;
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPrivacyModeTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHidden = hideBalances.value;

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
          hideBalances.value = value;
        },
      ),
    );
  }

  Widget _buildManageAssetsTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioId = selectedPortfolioId.value;

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
                    builder: (_) => ManageAssetsScreen(portfolioId: portfolioId),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Widget _buildServerUrlTile(BuildContext context) {
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

  Future<void> _showServerUrlDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: AppSettings.customServerUrl ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String? validationError;

    // Capture scaffold messenger before async gap
    final messenger = ScaffoldMessenger.of(context);

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
                  'Default: ${AppSettings.getDefaultServerUrl()}',
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
                    labelText: 'Custom URL',
                    hintText: 'http://192.168.1.100:8080/',
                    errorText: validationError,
                    helperText: 'Leave empty to use default',
                    helperMaxLines: 2,
                  ),
                  onChanged: (value) {
                    if (validationError != null) {
                      setDialogState(() => validationError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Restart required after changing the URL.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
          actions: [
            if (AppSettings.hasCustomServerUrl)
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Reset to Default'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final url = controller.text.trim();

                // Empty is valid (reset to default)
                if (url.isEmpty) {
                  Navigator.pop(context, '');
                  return;
                }

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
    final success = await AppSettings.setCustomServerUrl(
      result.isEmpty ? null : result,
    );

    if (!mounted) return;

    if (success) {
      final message = result.isEmpty
          ? 'Server URL reset to default. Please restart the app.'
          : 'Server URL changed. Please restart the app.';

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );

      // Trigger rebuild to show updated subtitle
      setState(() {});
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to save server URL'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildAboutTile(BuildContext context) {
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
