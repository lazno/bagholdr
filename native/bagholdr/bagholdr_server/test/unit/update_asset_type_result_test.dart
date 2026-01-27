import 'package:bagholdr_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('UpdateAssetTypeResult', () {
    test('serializes successful result', () {
      final result = UpdateAssetTypeResult(
        success: true,
        newType: 'etf',
      );

      final json = result.toJson();

      expect(json['success'], isTrue);
      expect(json['newType'], 'etf');
    });

    test('deserializes successful result', () {
      final json = {
        'success': true,
        'newType': 'stock',
      };

      final result = UpdateAssetTypeResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.newType, 'stock');
    });

    test('handles null newType', () {
      final result = UpdateAssetTypeResult(
        success: false,
        newType: null,
      );

      final json = result.toJson();

      expect(json['success'], isFalse);
      expect(json['newType'], isNull);
    });

    test('round-trips through JSON', () {
      final original = UpdateAssetTypeResult(
        success: true,
        newType: 'bond',
      );

      final json = original.toJson();
      final restored = UpdateAssetTypeResult.fromJson(json);

      expect(restored.success, original.success);
      expect(restored.newType, original.newType);
    });
  });
}
