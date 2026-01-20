import 'package:bagholdr_client/bagholdr_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Portfolio type is available from client package', () {
    final p = Portfolio(
      name: 'Test Portfolio',
      bandRelativeTolerance: 20.0,
      bandAbsoluteFloor: 2.0,
      bandAbsoluteCap: 10.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    expect(p.name, equals('Test Portfolio'));
    expect(p.bandRelativeTolerance, equals(20.0));
  });
}
