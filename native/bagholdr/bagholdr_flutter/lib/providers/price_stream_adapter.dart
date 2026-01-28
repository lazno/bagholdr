import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart' show priceStreamProvider;
import '../services/price_stream_provider.dart';

/// Adapter provider that wraps the existing global PriceStreamProvider.
///
/// This allows screens to use ref.watch() to rebuild when prices update,
/// without rewriting the underlying PriceStreamProvider implementation.
final priceStreamAdapterProvider =
    ChangeNotifierProvider<PriceStreamProvider>((ref) {
  return priceStreamProvider;
});
