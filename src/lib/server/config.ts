/**
 * Server-only configuration constants
 * These use process.env and should NEVER be imported on the client
 */

// Database
export const DB_PATH = process.env.DB_PATH ?? 'financepal.db';

// Price oracle
export const PRICE_CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6 hours

// Yahoo Finance API
export const YAHOO_SEARCH_URL = 'https://query1.finance.yahoo.com/v1/finance/search';
export const YAHOO_CHART_URL = 'https://query1.finance.yahoo.com/v8/finance/chart';

// Yahoo Rate Limiting
// Yahoo has ~2000 requests/hour limit. 2 seconds = 30 requests/min = 1800/hour (still safe)
export const YAHOO_MIN_REQUEST_DELAY_MS = 2000;
