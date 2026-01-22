import 'dart:async';

/// Global rate limiter for Yahoo Finance API.
///
/// Yahoo Finance has an unofficial rate limit of ~2000 requests/hour.
/// This rate limiter ensures we stay well under that by:
/// - Enforcing a minimum delay between requests (default 2 seconds)
/// - Queuing requests and processing them sequentially
/// - Being a singleton so ALL Yahoo requests go through it
///
/// With 2 second delay: 30 requests/min = 1800/hour (safe margin)
const int defaultMinDelayMs = 2000;

class _QueuedRequest {
  final Future<void> Function() run;
  final DateTime enqueuedAt;

  _QueuedRequest({required this.run, required this.enqueuedAt});
}

class YahooRateLimiter {
  final int minDelayMs;
  final List<_QueuedRequest> _queue = [];
  bool _isProcessing = false;
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _requestCount = 0;

  YahooRateLimiter({this.minDelayMs = defaultMinDelayMs});

  /// Enqueue a request to be executed with rate limiting.
  /// Returns a future that completes when the request completes.
  Future<T> enqueue<T>(Future<T> Function() execute) {
    final completer = Completer<T>();
    _queue.add(_QueuedRequest(
      run: () async {
        try {
          final result = await execute();
          completer.complete(result);
        } catch (error, stack) {
          completer.completeError(error, stack);
        }
      },
      enqueuedAt: DateTime.now(),
    ));
    _processQueue();
    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);

      // Calculate delay needed
      final now = DateTime.now();
      final timeSinceLastRequest =
          now.difference(_lastRequestTime).inMilliseconds;
      final delayNeeded =
          (minDelayMs - timeSinceLastRequest).clamp(0, minDelayMs);

      if (delayNeeded > 0) {
        await Future<void>.delayed(Duration(milliseconds: delayNeeded));
      }

      _lastRequestTime = DateTime.now();
      _requestCount++;
      await request.run();
    }

    _isProcessing = false;
  }

  /// Current queue length.
  int get queueLength => _queue.length;

  /// Whether currently processing requests.
  bool get isActive => _isProcessing;

  /// Total number of requests processed.
  int get totalRequests => _requestCount;
}

/// Singleton instance - all Yahoo requests go through this.
final yahooRateLimiter = YahooRateLimiter();
