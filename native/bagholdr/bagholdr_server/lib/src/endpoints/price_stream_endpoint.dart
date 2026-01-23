import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/price_sync_service.dart';

/// Endpoint for real-time price streaming and sync control.
class PriceStreamEndpoint extends Endpoint {
  /// Stream of real-time price updates.
  /// Client subscribes to receive price updates as they happen.
  /// The stream stays open until the client disconnects.
  Stream<PriceUpdate> streamPriceUpdates(Session session) async* {
    print('[PriceStream] Client connected');
    try {
      await for (final update in PriceSyncService.instance.priceUpdates) {
        yield update;
      }
    } finally {
      print('[PriceStream] Client disconnected');
    }
  }

  /// Get the current sync status.
  Future<SyncStatus> getSyncStatus(Session session) async {
    return PriceSyncService.instance.status;
  }

  /// Trigger a manual price sync. Returns immediately, sync runs in background.
  Future<SyncStatus> triggerSync(Session session) async {
    PriceSyncService.instance.triggerSync(session.server.serverpod);
    return PriceSyncService.instance.status;
  }
}
