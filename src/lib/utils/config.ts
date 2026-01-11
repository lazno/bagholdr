/**
 * Shared application configuration constants
 * These are safe to use on both client and server
 */

// Auto-refresh settings
export const DEFAULT_AUTO_REFRESH_INTERVAL_MS = 5 * 60 * 1000; // 5 minutes
export const MIN_AUTO_REFRESH_INTERVAL_MS = 1 * 60 * 1000; // 1 minute minimum

// Client-side delay between price fetches
// Note: Server has its own 3-second rate limiter, so this is just for visual feedback
// Setting to 100ms keeps UI responsive while server handles actual rate limiting
export const PRICE_FETCH_DELAY_MS = 100;

// Rebalancing
export const MIN_ORDER_EUR = 75; // Minimum order to suggest
export const TRANSACTION_FEE_EUR = 9; // Assumed transaction cost

// Display
export const BASE_CURRENCY = 'EUR';

// Bands (defaults)
export const DEFAULT_RELATIVE_TOLERANCE = 10; // ±10% of target
