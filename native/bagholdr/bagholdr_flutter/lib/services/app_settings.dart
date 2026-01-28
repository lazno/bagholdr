import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing persisted app settings.
///
/// Handles loading and saving settings like custom server URL.
/// Uses SharedPreferences for cross-platform persistence.
class AppSettings {
  static const String _serverUrlKey = 'custom_server_url';

  static late SharedPreferences _prefs;

  /// Initialize the settings service. Must be called before accessing settings.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the custom server URL, or null if not set.
  static String? get customServerUrl => _prefs.getString(_serverUrlKey);

  /// Set a custom server URL. Pass null to clear and use default.
  static Future<bool> setCustomServerUrl(String? url) async {
    if (url == null || url.isEmpty) {
      return _prefs.remove(_serverUrlKey);
    }
    return _prefs.setString(_serverUrlKey, url);
  }

  /// Get the server URL to use (custom or platform default).
  static String getServerUrl() {
    // Check for custom URL first
    final customUrl = customServerUrl;
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }

    // Check for dart-define override
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

  /// Get the default server URL for the current platform.
  static String getDefaultServerUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/';
    } else {
      return 'http://10.0.2.2:8080/';
    }
  }

  /// Check if a custom server URL is set.
  static bool get hasCustomServerUrl {
    final url = customServerUrl;
    return url != null && url.isNotEmpty;
  }

  /// Returns true if app is built for production (requires manual server config).
  static bool get requiresServerConfig {
    const flag = String.fromEnvironment('REQUIRE_SERVER_CONFIG');
    return flag == 'true';
  }

  /// Returns true if setup screen should be shown (production build without configured URL).
  static bool get needsSetup {
    return requiresServerConfig && !hasCustomServerUrl;
  }

  /// Validate a server URL format.
  /// Returns null if valid, or an error message if invalid.
  static String? validateServerUrl(String url) {
    if (url.isEmpty) {
      return 'URL cannot be empty';
    }

    // Check for valid URL format
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return 'Invalid URL format';
    }

    // Must have a scheme (http or https)
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'URL must start with http:// or https://';
    }

    // Must have a host
    if (!uri.hasAuthority || uri.host.isEmpty) {
      return 'URL must include a host (e.g., localhost or 10.0.2.2)';
    }

    return null; // Valid
  }
}
