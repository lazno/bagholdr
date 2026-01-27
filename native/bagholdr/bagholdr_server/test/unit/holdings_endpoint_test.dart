import 'package:bagholdr_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('SleeveOption', () {
    test('has correct fields', () {
      final option = SleeveOption(
        id: 'test-id',
        name: 'Core > Equities',
        depth: 1,
      );

      expect(option.id, 'test-id');
      expect(option.name, 'Core > Equities');
      expect(option.depth, 1);
    });
  });

  group('AssignSleeveResult', () {
    test('represents successful assignment', () {
      final result = AssignSleeveResult(
        success: true,
        sleeveId: 'sleeve-123',
        sleeveName: 'Equities',
      );

      expect(result.success, true);
      expect(result.sleeveId, 'sleeve-123');
      expect(result.sleeveName, 'Equities');
    });

    test('represents successful unassignment', () {
      final result = AssignSleeveResult(
        success: true,
        sleeveId: null,
        sleeveName: null,
      );

      expect(result.success, true);
      expect(result.sleeveId, isNull);
      expect(result.sleeveName, isNull);
    });
  });
}
