import 'package:flutter_test/flutter_test.dart';
import 'package:bagholdr_flutter/services/app_settings.dart';

void main() {
  group('AppSettings.validateServerUrl', () {
    test('returns null for valid http URL', () {
      expect(AppSettings.validateServerUrl('http://localhost:8080/'), isNull);
      expect(AppSettings.validateServerUrl('http://192.168.1.100:8080'), isNull);
      expect(AppSettings.validateServerUrl('http://10.0.2.2:8080/'), isNull);
    });

    test('returns null for valid https URL', () {
      expect(AppSettings.validateServerUrl('https://api.example.com/'), isNull);
      expect(AppSettings.validateServerUrl('https://myserver.local:443'), isNull);
    });

    test('returns error for empty URL', () {
      expect(AppSettings.validateServerUrl(''), equals('URL cannot be empty'));
    });

    test('returns error for URL without scheme', () {
      final error = AppSettings.validateServerUrl('localhost:8080');
      expect(error, equals('URL must start with http:// or https://'));
    });

    test('returns error for URL with invalid scheme', () {
      final error = AppSettings.validateServerUrl('ftp://example.com');
      expect(error, equals('URL must start with http:// or https://'));
    });

    test('returns error for URL without host', () {
      final error = AppSettings.validateServerUrl('http://');
      expect(error, equals('URL must include a host (e.g., localhost or 10.0.2.2)'));
    });

    test('returns error for malformed URL', () {
      // This depends on how Uri.tryParse handles it
      final error = AppSettings.validateServerUrl('not a url at all');
      expect(error, isNotNull);
    });

    test('accepts URLs with paths', () {
      expect(AppSettings.validateServerUrl('http://example.com/api'), isNull);
      expect(AppSettings.validateServerUrl('https://api.example.com/v1/'), isNull);
    });

    test('accepts URLs with port numbers', () {
      expect(AppSettings.validateServerUrl('http://localhost:3000'), isNull);
      expect(AppSettings.validateServerUrl('http://localhost:8080'), isNull);
      expect(AppSettings.validateServerUrl('https://example.com:443'), isNull);
    });
  });

  group('AppSettings.getDefaultServerUrl', () {
    // Note: These tests verify the URL format, not the actual kIsWeb value
    // which requires runtime platform detection
    test('returns a valid URL format', () {
      final url = AppSettings.getDefaultServerUrl();
      expect(url, startsWith('http://'));
      expect(url, endsWith('/'));
      expect(AppSettings.validateServerUrl(url), isNull);
    });
  });
}
