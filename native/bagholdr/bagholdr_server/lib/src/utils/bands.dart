import '../generated/band.dart';
import '../generated/band_config.dart';
import '../generated/allocation_status.dart';

/// Default band configuration
final BandConfig defaultBandConfig = BandConfig(
  relativeTolerance: 20,
  absoluteFloor: 2,
  absoluteCap: 10,
);

/// Clamp a value between min and max
double _clamp(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}

/// Calculate the band bounds for a given target allocation
///
/// [targetPercent] - The target allocation percentage (e.g., 20 for 20%)
/// [config] - Band configuration
/// Returns Band with lower/upper bounds and half-width
Band calculateBand(double targetPercent, BandConfig config) {
  // Calculate relative half-width
  final relativeHalfWidth = targetPercent * (config.relativeTolerance / 100);

  // Clamp between floor and cap
  final halfWidth =
      _clamp(relativeHalfWidth, config.absoluteFloor, config.absoluteCap);

  // Calculate bounds, clamping to 0-100 range
  final lower = (targetPercent - halfWidth).clamp(0.0, 100.0);
  final upper = (targetPercent + halfWidth).clamp(0.0, 100.0);

  return Band(lower: lower, upper: upper, halfWidth: halfWidth);
}

/// Evaluate whether an actual allocation is within the acceptable band
///
/// [actualPercent] - The actual allocation percentage
/// [band] - The calculated band bounds
/// Returns 'ok' if within band, 'warning' if outside
AllocationStatus evaluateStatus(double actualPercent, Band band) {
  return actualPercent >= band.lower && actualPercent <= band.upper
      ? AllocationStatus.ok
      : AllocationStatus.warning;
}

/// Combined calculation: compute band and evaluate status in one call
({Band band, AllocationStatus status}) evaluateAllocation(
  double actualPercent,
  double targetPercent,
  BandConfig config,
) {
  final band = calculateBand(targetPercent, config);
  final status = evaluateStatus(actualPercent, band);
  return (band: band, status: status);
}

/// Format band as a display string
String formatBand(Band band) {
  return '${band.lower.toStringAsFixed(0)}-${band.upper.toStringAsFixed(0)}%';
}
