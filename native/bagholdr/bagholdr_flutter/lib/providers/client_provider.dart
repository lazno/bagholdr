import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

/// Provider for the Serverpod client.
///
/// This provides access to the global client instance for making API calls.
/// The client is initialized in main.dart based on server URL configuration.
final clientProvider = Provider<Client>((ref) => client);
