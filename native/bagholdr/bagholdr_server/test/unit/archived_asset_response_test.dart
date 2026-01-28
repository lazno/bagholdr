import 'package:test/test.dart';
import 'package:bagholdr_server/src/generated/protocol.dart';

void main() {
  group('ArchivedAssetResponse', () {
    test('creates response with all fields', () {
      final response = ArchivedAssetResponse(
        id: 'test-id-123',
        name: 'Test Asset',
        isin: 'IE00B4L5Y983',
        yahooSymbol: 'IWDA.AS',
        lastKnownValue: 12345.67,
      );

      expect(response.id, equals('test-id-123'));
      expect(response.name, equals('Test Asset'));
      expect(response.isin, equals('IE00B4L5Y983'));
      expect(response.yahooSymbol, equals('IWDA.AS'));
      expect(response.lastKnownValue, equals(12345.67));
    });

    test('allows null yahooSymbol', () {
      final response = ArchivedAssetResponse(
        id: 'test-id-123',
        name: 'Test Asset',
        isin: 'IE00B4L5Y983',
        yahooSymbol: null,
        lastKnownValue: 1000.0,
      );

      expect(response.yahooSymbol, isNull);
    });

    test('allows null lastKnownValue', () {
      final response = ArchivedAssetResponse(
        id: 'test-id-123',
        name: 'Test Asset',
        isin: 'IE00B4L5Y983',
        yahooSymbol: 'IWDA.AS',
        lastKnownValue: null,
      );

      expect(response.lastKnownValue, isNull);
    });

    test('serializes to JSON correctly', () {
      final response = ArchivedAssetResponse(
        id: 'test-id-123',
        name: 'Test Asset',
        isin: 'IE00B4L5Y983',
        yahooSymbol: 'IWDA.AS',
        lastKnownValue: 12345.67,
      );

      final json = response.toJson();
      expect(json['id'], equals('test-id-123'));
      expect(json['name'], equals('Test Asset'));
      expect(json['isin'], equals('IE00B4L5Y983'));
      expect(json['yahooSymbol'], equals('IWDA.AS'));
      expect(json['lastKnownValue'], equals(12345.67));
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'test-id-456',
        'name': 'Another Asset',
        'isin': 'LU0378449770',
        'yahooSymbol': 'SXRV.DE',
        'lastKnownValue': 9876.54,
      };

      final response = ArchivedAssetResponse.fromJson(json);
      expect(response.id, equals('test-id-456'));
      expect(response.name, equals('Another Asset'));
      expect(response.isin, equals('LU0378449770'));
      expect(response.yahooSymbol, equals('SXRV.DE'));
      expect(response.lastKnownValue, equals(9876.54));
    });

    test('deserializes null fields from JSON', () {
      final json = {
        'id': 'test-id-789',
        'name': 'Minimal Asset',
        'isin': 'US0378331005',
        'yahooSymbol': null,
        'lastKnownValue': null,
      };

      final response = ArchivedAssetResponse.fromJson(json);
      expect(response.yahooSymbol, isNull);
      expect(response.lastKnownValue, isNull);
    });
  });
}
