import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'theme/theme.dart';
import 'screens/portfolio_list_screen.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
late final Client client;

/// Global theme mode notifier for app-wide theme switching.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Returns the server URL based on platform:
/// - Web: localhost (same machine)
/// - Android emulator: 10.0.2.2 (host machine from emulator)
/// - Physical device: requires SERVER_URL dart-define
String _getServerUrl() {
  // Allow override via dart-define
  const overrideUrl = String.fromEnvironment('SERVER_URL');
  if (overrideUrl.isNotEmpty) {
    return overrideUrl;
  }

  // Platform-specific defaults for local development
  if (kIsWeb) {
    return 'http://localhost:8080/';
  } else {
    // Android emulator uses 10.0.2.2 to reach host
    return 'http://10.0.2.2:8080/';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverUrl = _getServerUrl();

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
          home: const PortfolioListScreen(),
        );
      },
    );
  }
}
