import 'dart:async';

import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';

/// Factory function for creating the price stream.
/// Default uses the global client; can be overridden for testing.
typedef PriceStreamFactory = Stream<PriceUpdate> Function();

/// Connection status for the price stream.
enum ConnectionStatus {
  connected,
  connecting,
  disconnected,
}

/// Manages the real-time price stream subscription and provides
/// current prices to the widget tree.
class PriceStreamProvider extends ChangeNotifier {
  /// Creates a provider with an optional custom stream factory (for testing).
  PriceStreamProvider({PriceStreamFactory? streamFactory})
      : _streamFactory =
            streamFactory ?? (() => client.priceStream.streamPriceUpdates());
  final PriceStreamFactory _streamFactory;

  /// Current prices by ISIN.
  final Map<String, PriceUpdate> _prices = {};

  /// ISINs that were recently updated (for animation).
  final Set<String> _recentlyUpdated = {};

  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  DateTime? _lastUpdateAt;
  Timer? _reconnectTimer;
  StreamSubscription<PriceUpdate>? _subscription;

  /// Unmodifiable view of current prices.
  Map<String, PriceUpdate> get prices => Map.unmodifiable(_prices);

  /// Current connection status.
  ConnectionStatus get connectionStatus => _connectionStatus;

  /// When the last price update was received.
  DateTime? get lastUpdateAt => _lastUpdateAt;

  /// Check if an ISIN was recently updated (within last 5 seconds).
  bool isRecentlyUpdated(String isin) => _recentlyUpdated.contains(isin);

  /// Get price for a specific ISIN (null if not yet received).
  PriceUpdate? getPrice(String isin) => _prices[isin];

  /// Start listening to price updates.
  void connect() {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting) {
      return;
    }
    _connectionStatus = ConnectionStatus.connecting;
    notifyListeners();
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();

    try {
      final stream = _streamFactory();
      _subscription = stream.listen(
        _onPriceUpdate,
        onError: _onError,
        onDone: _onDone,
      );
      _connectionStatus = ConnectionStatus.connected;
      notifyListeners();
    } catch (e) {
      debugPrint('Price stream connection failed: $e');
      _connectionStatus = ConnectionStatus.disconnected;
      notifyListeners();
      _scheduleReconnect();
    }
  }

  void _onPriceUpdate(PriceUpdate update) {
    _prices[update.isin] = update;
    _lastUpdateAt = DateTime.now();

    // Mark as recently updated (auto-clear after 5 seconds).
    _recentlyUpdated.add(update.isin);
    Timer(const Duration(seconds: 5), () {
      _recentlyUpdated.remove(update.isin);
      notifyListeners();
    });

    if (_connectionStatus != ConnectionStatus.connected) {
      _connectionStatus = ConnectionStatus.connected;
    }
    notifyListeners();
  }

  void _onError(Object error) {
    debugPrint('Price stream error: $error');
    _connectionStatus = ConnectionStatus.disconnected;
    notifyListeners();
    _scheduleReconnect();
  }

  void _onDone() {
    _connectionStatus = ConnectionStatus.disconnected;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      if (_connectionStatus == ConnectionStatus.disconnected) {
        connect();
      }
    });
  }

  /// Stop listening to price updates.
  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _reconnectTimer?.cancel();
    _connectionStatus = ConnectionStatus.disconnected;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
