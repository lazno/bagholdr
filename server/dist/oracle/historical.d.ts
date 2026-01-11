/**
 * Historical Price Data Management
 *
 * Handles syncing and querying historical price data and dividend events.
 * Uses upsert logic for idempotent syncs.
 */
import type { DbClient } from '../db/client';
export interface SyncResult {
    ticker: string;
    candlesUpserted: number;
    dividendsUpserted: number;
    latestDate: string | null;
    error?: string;
}
export interface DailyPriceRecord {
    date: string;
    open: number;
    high: number;
    low: number;
    close: number;
    adjClose: number;
    volume: number;
}
export interface IntradaySyncResult {
    ticker: string;
    candlesUpserted: number;
    candlesPurged: number;
    error?: string;
}
export interface IntradayPriceRecord {
    timestamp: number;
    open: number;
    high: number;
    low: number;
    close: number;
    volume: number;
}
/**
 * Sync historical data for a ticker from Yahoo Finance.
 * Fetches all available data (range=10y) and upserts to database.
 * Also updates ticker_metadata with sync timestamp.
 *
 * Uses batch inserts for performance (single transaction).
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @returns Sync statistics
 */
export declare function syncHistoricalData(db: DbClient, ticker: string): Promise<SyncResult>;
/**
 * Check if a ticker needs historical sync.
 * Returns true if:
 * - Never synced before
 * - Last sync was before today (in local timezone)
 */
export declare function needsHistoricalSync(db: DbClient, ticker: string): Promise<boolean>;
/**
 * Get list of tickers that need historical sync.
 * Only includes active tickers that haven't been synced today.
 */
export declare function getTickersNeedingSync(db: DbClient, tickers: string[]): Promise<string[]>;
/**
 * Ensure ticker_metadata entries exist for all given tickers.
 * Creates entries with isActive=true and no sync timestamps.
 * This allows getTickersNeedingSync to work correctly from the first run.
 */
export declare function ensureTickerMetadata(db: DbClient, tickers: string[]): Promise<number>;
/**
 * Get historical prices for a ticker.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @param startDate - Optional start date (YYYY-MM-DD), defaults to 1 year ago
 * @param endDate - Optional end date (YYYY-MM-DD), defaults to today
 * @returns Array of daily price records, sorted by date ascending
 */
export declare function getHistoricalPrices(db: DbClient, ticker: string, startDate?: string, endDate?: string): Promise<DailyPriceRecord[]>;
/**
 * Get dividend events for a ticker.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @param startDate - Optional start date filter
 * @returns Array of dividend events, sorted by date descending (most recent first)
 */
export declare function getDividendEvents(db: DbClient, ticker: string, startDate?: string): Promise<Array<{
    exDate: string;
    amount: number;
    currency: string;
}>>;
/**
 * Get ticker metadata (sync status).
 */
export declare function getTickerMetadata(db: DbClient, ticker: string): Promise<{
    lastDailyDate: string | null;
    lastSyncedAt: Date | null;
    isActive: boolean;
} | null>;
/**
 * Sync intraday data for a ticker from Yahoo Finance.
 * Fetches 5-day data with 5-minute intervals and upserts to database.
 * Also purges data older than 5 days to keep the table manageable.
 *
 * Uses batch inserts for performance (single transaction).
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @returns Sync statistics
 */
export declare function syncIntradayData(db: DbClient, ticker: string): Promise<IntradaySyncResult>;
/**
 * Get intraday prices for a ticker from the database.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @returns Array of intraday price records, sorted by timestamp ascending
 */
export declare function getIntradayPrices(db: DbClient, ticker: string): Promise<IntradayPriceRecord[]>;
/**
 * Check if a ticker needs intraday sync.
 * Returns true if:
 * - Never synced before
 * - Last sync was more than 5 minutes ago
 */
export declare function needsIntradaySync(db: DbClient, ticker: string): Promise<boolean>;
/**
 * Get list of tickers that need intraday sync.
 * Only includes active tickers that haven't been synced in the last 5 minutes.
 */
export declare function getTickersNeedingIntradaySync(db: DbClient, tickers: string[]): Promise<string[]>;
