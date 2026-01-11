/**
 * Band Calculation Utilities
 *
 * Bands define tolerance around target allocations using a relative tolerance
 * with absolute floor and cap to prevent both overly-tight and overly-loose bounds.
 *
 * Formula:
 *   halfWidth = clamp(targetPercent * relativeTolerance/100, absoluteFloor, absoluteCap)
 *   lower = max(0, target - halfWidth)
 *   upper = min(100, target + halfWidth)
 *
 * Examples with defaults (20% relative, 2pp floor, 10pp cap):
 *   - 5% target  → halfWidth = max(1, 2) = 2pp  → 3-7%
 *   - 20% target → halfWidth = 4pp              → 16-24%
 *   - 60% target → halfWidth = min(12, 10) = 10pp → 50-70%
 */
/**
 * Default band configuration
 */
export const DEFAULT_BAND_CONFIG = {
    relativeTolerance: 20,
    absoluteFloor: 2,
    absoluteCap: 10
};
/**
 * Clamp a value between min and max
 */
function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}
/**
 * Calculate the band bounds for a given target allocation
 *
 * @param targetPercent - The target allocation percentage (e.g., 20 for 20%)
 * @param config - Band configuration
 * @returns Band with lower/upper bounds and half-width
 */
export function calculateBand(targetPercent, config) {
    // Calculate relative half-width
    const relativeHalfWidth = targetPercent * (config.relativeTolerance / 100);
    // Clamp between floor and cap
    const halfWidth = clamp(relativeHalfWidth, config.absoluteFloor, config.absoluteCap);
    // Calculate bounds, clamping to 0-100 range
    const lower = Math.max(0, targetPercent - halfWidth);
    const upper = Math.min(100, targetPercent + halfWidth);
    return { lower, upper, halfWidth };
}
/**
 * Evaluate whether an actual allocation is within the acceptable band
 *
 * @param actualPercent - The actual allocation percentage
 * @param band - The calculated band bounds
 * @returns 'ok' if within band, 'warning' if outside
 */
export function evaluateStatus(actualPercent, band) {
    return actualPercent >= band.lower && actualPercent <= band.upper ? 'ok' : 'warning';
}
/**
 * Combined calculation: compute band and evaluate status in one call
 *
 * @param actualPercent - The actual allocation percentage
 * @param targetPercent - The target allocation percentage
 * @param config - Band configuration
 * @returns Object with band info and status
 */
export function evaluateAllocation(actualPercent, targetPercent, config) {
    const band = calculateBand(targetPercent, config);
    const status = evaluateStatus(actualPercent, band);
    return { band, status };
}
/**
 * Format band as a display string
 *
 * @param band - The calculated band
 * @returns String like "16-24%" or "3-7%"
 */
export function formatBand(band) {
    return `${band.lower.toFixed(0)}-${band.upper.toFixed(0)}%`;
}
