import 'package:test/test.dart';
import 'package:bagholdr_server/src/utils/bands.dart';
import 'package:bagholdr_server/src/generated/band.dart';
import 'package:bagholdr_server/src/generated/band_config.dart';
import 'package:bagholdr_server/src/generated/allocation_status.dart';

void main() {
  group('calculateBand', () {
    final config = BandConfig(
      relativeTolerance: 20, // +/- 20% of target
      absoluteFloor: 2, // minimum +/- 2pp
      absoluteCap: 10, // maximum +/- 10pp
    );

    test('calculates band for 10% target', () {
      final band = calculateBand(10.0, config);
      // 10% * 20% = 2pp, which equals floor
      expect(band.halfWidth, equals(2.0));
      expect(band.lower, equals(8.0));
      expect(band.upper, equals(12.0));
    });

    test('calculates band for 50% target', () {
      final band = calculateBand(50.0, config);
      // 50% * 20% = 10pp, which equals cap
      expect(band.halfWidth, equals(10.0));
      expect(band.lower, equals(40.0));
      expect(band.upper, equals(60.0));
    });

    test('calculates band for 30% target', () {
      final band = calculateBand(30.0, config);
      // 30% * 20% = 6pp, between floor and cap
      expect(band.halfWidth, equals(6.0));
      expect(band.lower, equals(24.0));
      expect(band.upper, equals(36.0));
    });

    test('uses floor for small targets', () {
      final band = calculateBand(5.0, config);
      // 5% * 20% = 1pp, below floor of 2pp
      expect(band.halfWidth, equals(2.0));
      expect(band.lower, equals(3.0));
      expect(band.upper, equals(7.0));
    });

    test('uses cap for large targets', () {
      final band = calculateBand(80.0, config);
      // 80% * 20% = 16pp, above cap of 10pp
      expect(band.halfWidth, equals(10.0));
      expect(band.lower, equals(70.0));
      expect(band.upper, equals(90.0));
    });

    test('clamps lower bound to 0', () {
      final band = calculateBand(1.0, config);
      // Floor is 2pp, so lower would be -1, clamped to 0
      expect(band.lower, equals(0.0));
      expect(band.upper, equals(3.0));
    });

    test('clamps upper bound to 100', () {
      final band = calculateBand(99.0, config);
      expect(band.lower, lessThan(100.0));
      expect(band.upper, equals(100.0));
    });
  });

  group('evaluateStatus', () {
    test('returns ok when within band', () {
      final band = Band(lower: 20.0, upper: 40.0, halfWidth: 10.0);
      expect(evaluateStatus(25.0, band), equals(AllocationStatus.ok));
      expect(evaluateStatus(30.0, band), equals(AllocationStatus.ok));
      expect(evaluateStatus(35.0, band), equals(AllocationStatus.ok));
    });

    test('returns ok at boundaries', () {
      final band = Band(lower: 20.0, upper: 40.0, halfWidth: 10.0);
      expect(evaluateStatus(20.0, band), equals(AllocationStatus.ok));
      expect(evaluateStatus(40.0, band), equals(AllocationStatus.ok));
    });

    test('returns warning when below band', () {
      final band = Band(lower: 20.0, upper: 40.0, halfWidth: 10.0);
      expect(evaluateStatus(15.0, band), equals(AllocationStatus.warning));
      expect(evaluateStatus(19.99, band), equals(AllocationStatus.warning));
    });

    test('returns warning when above band', () {
      final band = Band(lower: 20.0, upper: 40.0, halfWidth: 10.0);
      expect(evaluateStatus(45.0, band), equals(AllocationStatus.warning));
      expect(evaluateStatus(40.01, band), equals(AllocationStatus.warning));
    });
  });

  group('evaluateAllocation', () {
    final config = BandConfig(
      relativeTolerance: 20,
      absoluteFloor: 2,
      absoluteCap: 10,
    );

    test('returns ok for allocation within band', () {
      final result = evaluateAllocation(28.0, 30.0, config);
      expect(result.status, equals(AllocationStatus.ok));
      expect(result.band.lower, equals(24.0));
      expect(result.band.upper, equals(36.0));
    });

    test('returns warning for allocation outside band', () {
      final result = evaluateAllocation(20.0, 30.0, config);
      expect(result.status, equals(AllocationStatus.warning));
    });
  });

  group('formatBand', () {
    test('formats band as percentage range', () {
      final band = Band(lower: 24.0, upper: 36.0, halfWidth: 6.0);
      expect(formatBand(band), equals('24-36%'));
    });

    test('rounds to integers', () {
      final band = Band(lower: 24.5, upper: 35.5, halfWidth: 5.5);
      // toStringAsFixed(0) rounds 24.5 to 25 and 35.5 to 36
      expect(formatBand(band), equals('25-36%'));
    });
  });
}
