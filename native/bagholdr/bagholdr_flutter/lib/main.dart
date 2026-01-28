import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'services/app_settings.dart';
import 'services/price_stream_provider.dart';
import 'theme/theme.dart';
import 'screens/app_shell.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
late final Client client;

/// Global theme mode notifier for app-wide theme switching.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Global privacy mode notifier for hiding/showing balances.
final hideBalances = ValueNotifier<bool>(false);

/// Global selected portfolio ID for cross-screen access.
/// Set by PortfolioListScreen when a portfolio is selected.
final selectedPortfolioId = ValueNotifier<String?>(null);

/// Global price stream provider for real-time price updates.
final priceStreamProvider = PriceStreamProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings (loads from SharedPreferences)
  await AppSettings.initialize();

  final serverUrl = AppSettings.getServerUrl();

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(const BagholdrApp());
}

class BagholdrApp extends StatelessWidget {
  const BagholdrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Bagholdr',
          theme: BagholdrTheme.light,
          darkTheme: BagholdrTheme.dark,
          themeMode: mode,
          home: const AppShell(),
        );
      },
    );
  }
}
