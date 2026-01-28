import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_provider.dart';

/// Provider for portfolio issues (warnings, errors).
///
/// Returns issues such as allocation problems, missing prices, etc.
final issuesProvider =
    FutureProvider.family<IssuesResponse, String>((ref, portfolioId) async {
  final client = ref.read(clientProvider);
  return await client.issues.getIssues(
    portfolioId: UuidValue.fromString(portfolioId),
  );
});
