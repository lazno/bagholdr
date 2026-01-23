import 'package:flutter/material.dart';

import '../services/price_stream_provider.dart';
import '../theme/colors.dart';

/// A compact indicator showing the real-time price connection status.
/// Placed in the AppBar to inform users whether prices are live.
class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({
    super.key,
    required this.status,
    this.lastUpdateAt,
  });

  final ConnectionStatus status;
  final DateTime? lastUpdateAt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final (Color color, IconData icon, String tooltip) = switch (status) {
      ConnectionStatus.connected => (
        financialColors.positive,
        Icons.wifi,
        'Live prices${_formatLastUpdate()}',
      ),
      ConnectionStatus.connecting => (
        colorScheme.onSurfaceVariant,
        Icons.sync,
        'Connecting...',
      ),
      ConnectionStatus.disconnected => (
        colorScheme.error,
        Icons.wifi_off,
        'Offline - prices may be stale',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  String _formatLastUpdate() {
    if (lastUpdateAt == null) return '';
    final diff = DateTime.now().difference(lastUpdateAt!);
    if (diff.inSeconds < 60) return ' - just now';
    if (diff.inMinutes < 60) return ' - ${diff.inMinutes}m ago';
    return ' - ${diff.inHours}h ago';
  }
}
