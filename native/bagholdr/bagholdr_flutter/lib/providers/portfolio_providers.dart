import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Provider for fetching all portfolios.
///
/// Returns a list of Portfolio objects from the server.
/// Invalidate this provider when portfolios are created/deleted/modified.
final portfoliosProvider = FutureProvider<List<Portfolio>>((ref) async {
  final client = ref.read(clientProvider);
  return await client.portfolio.getPortfolios();
});
