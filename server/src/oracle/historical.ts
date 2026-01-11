/**
 * Historical Price Data Management
 *
 * Handles syncing and querying historical price data and dividend events.
 * Uses upsert logic for idempotent syncs.
 */

import { eq, and, gte, lte, desc, lt, sql } from 'drizzle-orm';
import type { DbClient } from '../db/client';
import { dailyPrices, dividendEvents, tickerMetadata, intradayPrices } from '../db/schema';
import { fetchHistoricalData, fetchIntradayData, YahooFinanceError } from './yahoo';

// =============================================================================
// Types
// =============================================================================

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

// =============================================================================
// Sync Functions
// =============================================================================

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
export async function syncHistoricalData(
	db: DbClient,
	ticker: string
): Promise<SyncResult> {
	const now = new Date();

	try {
		// Fetch from Yahoo (10y range ensures daily granularity; 'max' returns monthly for older instruments)
		const data = await fetchHistoricalData(ticker, '10y');

		let latestDate: string | null = null;

		// Find latest date
		for (const candle of data.candles) {
			if (!latestDate || candle.date > latestDate) {
				latestDate = candle.date;
			}
		}

		// Batch upsert candles - SQLite handles this efficiently
		// Process in chunks to avoid SQL statement size limits
		const BATCH_SIZE = 100;

		for (let i = 0; i < data.candles.length; i += BATCH_SIZE) {
			const batch = data.candles.slice(i, i + BATCH_SIZE);
			const values = batch.map(candle => ({
				id: `${ticker}_${candle.date}`,
				ticker,
				date: candle.date,
				open: candle.open,
				high: candle.high,
				low: candle.low,
				close: candle.close,
				adjClose: candle.adjClose,
				volume: candle.volume,
				currency: data.currency,
				fetchedAt: now
			}));

			await db
				.insert(dailyPrices)
				.values(values)
				.onConflictDoUpdate({
					target: dailyPrices.id,
					set: {
						open: sql`excluded.open`,
						high: sql`excluded.high`,
						low: sql`excluded.low`,
						close: sql`excluded.close`,
						adjClose: sql`excluded.adj_close`,
						volume: sql`excluded.volume`,
						currency: sql`excluded.currency`,
						fetchedAt: now
					}
				});
		}

		// Batch upsert dividends
		if (data.dividends.length > 0) {
			for (let i = 0; i < data.dividends.length; i += BATCH_SIZE) {
				const batch = data.dividends.slice(i, i + BATCH_SIZE);
				const values = batch.map(dividend => ({
					id: `${ticker}_${dividend.exDate}`,
					ticker,
					exDate: dividend.exDate,
					amount: dividend.amount,
					currency: data.currency,
					fetchedAt: now
				}));

				await db
					.insert(dividendEvents)
					.values(values)
					.onConflictDoUpdate({
						target: dividendEvents.id,
						set: {
							amount: sql`excluded.amount`,
							currency: sql`excluded.currency`,
							fetchedAt: now
						}
					});
			}
		}

		// Update ticker metadata
		await db
			.insert(tickerMetadata)
			.values({
				ticker,
				lastDailyDate: latestDate,
				lastSyncedAt: now,
				isActive: true
			})
			.onConflictDoUpdate({
				target: tickerMetadata.ticker,
				set: {
					lastDailyDate: latestDate,
					lastSyncedAt: now,
					isActive: true
				}
			});

		return {
			ticker,
			candlesUpserted: data.candles.length,
			dividendsUpserted: data.dividends.length,
			latestDate
		};
	} catch (err) {
		// Mark ticker as inactive if not found
		if (err instanceof YahooFinanceError && err.code === 'NOT_FOUND') {
			await db
				.insert(tickerMetadata)
				.values({
					ticker,
					isActive: false,
					lastSyncedAt: now
				})
				.onConflictDoUpdate({
					target: tickerMetadata.ticker,
					set: {
						isActive: false,
						lastSyncedAt: now
					}
				});
		}

		return {
			ticker,
			candlesUpserted: 0,
			dividendsUpserted: 0,
			latestDate: null,
			error: err instanceof Error ? err.message : 'Unknown error'
		};
	}
}

/**
 * Check if a ticker needs historical sync.
 * Returns true if:
 * - Never synced before
 * - Last sync was before today (in local timezone)
 */
export async function needsHistoricalSync(
	db: DbClient,
	ticker: string
): Promise<boolean> {
	const [meta] = await db
		.select()
		.from(tickerMetadata)
		.where(eq(tickerMetadata.ticker, ticker))
		.limit(1);

	if (!meta || !meta.lastSyncedAt) {
		return true;
	}

	// Check if last sync was today
	const today = new Date().toISOString().split('T')[0];
	const lastSyncDate = meta.lastSyncedAt.toISOString().split('T')[0];

	return lastSyncDate < today;
}

/**
 * Get list of tickers that need historical sync.
 * Only includes active tickers that haven't been synced today.
 */
export async function getTickersNeedingSync(
	db: DbClient,
	tickers: string[]
): Promise<string[]> {
	const today = new Date().toISOString().split('T')[0];
	const needsSync: string[] = [];

	for (const ticker of tickers) {
		const [meta] = await db
			.select()
			.from(tickerMetadata)
			.where(eq(tickerMetadata.ticker, ticker))
			.limit(1);

		// Needs sync if: no metadata, inactive marked as active again, or not synced today
		if (!meta) {
			needsSync.push(ticker);
		} else if (meta.isActive) {
			const lastSyncDate = meta.lastSyncedAt?.toISOString().split('T')[0];
			if (!lastSyncDate || lastSyncDate < today) {
				needsSync.push(ticker);
			}
		}
	}

	return needsSync;
}

/**
 * Ensure ticker_metadata entries exist for all given tickers.
 * Creates entries with isActive=true and no sync timestamps.
 * This allows getTickersNeedingSync to work correctly from the first run.
 */
export async function ensureTickerMetadata(
	db: DbClient,
	tickers: string[]
): Promise<number> {
	let created = 0;

	for (const ticker of tickers) {
		const result = await db
			.insert(tickerMetadata)
			.values({
				ticker,
				isActive: true
			})
			.onConflictDoNothing();

		if (result.changes && result.changes > 0) {
			created++;
		}
	}

	return created;
}

// =============================================================================
// Query Functions
// =============================================================================

/**
 * Get historical prices for a ticker.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @param startDate - Optional start date (YYYY-MM-DD), defaults to 1 year ago
 * @param endDate - Optional end date (YYYY-MM-DD), defaults to today
 * @returns Array of daily price records, sorted by date ascending
 */
export async function getHistoricalPrices(
	db: DbClient,
	ticker: string,
	startDate?: string,
	endDate?: string
): Promise<DailyPriceRecord[]> {
	// Default to 1 year range if not specified
	const end = endDate ?? new Date().toISOString().split('T')[0];
	const start = startDate ?? (() => {
		const d = new Date();
		d.setFullYear(d.getFullYear() - 1);
		return d.toISOString().split('T')[0];
	})();

	const results = await db
		.select({
			date: dailyPrices.date,
			open: dailyPrices.open,
			high: dailyPrices.high,
			low: dailyPrices.low,
			close: dailyPrices.close,
			adjClose: dailyPrices.adjClose,
			volume: dailyPrices.volume
		})
		.from(dailyPrices)
		.where(
			and(
				eq(dailyPrices.ticker, ticker),
				gte(dailyPrices.date, start),
				lte(dailyPrices.date, end)
			)
		)
		.orderBy(dailyPrices.date);

	return results;
}

/**
 * Get dividend events for a ticker.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @param startDate - Optional start date filter
 * @returns Array of dividend events, sorted by date descending (most recent first)
 */
export async function getDividendEvents(
	db: DbClient,
	ticker: string,
	startDate?: string
): Promise<Array<{ exDate: string; amount: number; currency: string }>> {
	let query = db
		.select({
			exDate: dividendEvents.exDate,
			amount: dividendEvents.amount,
			currency: dividendEvents.currency
		})
		.from(dividendEvents)
		.where(eq(dividendEvents.ticker, ticker));

	if (startDate) {
		query = db
			.select({
				exDate: dividendEvents.exDate,
				amount: dividendEvents.amount,
				currency: dividendEvents.currency
			})
			.from(dividendEvents)
			.where(
				and(
					eq(dividendEvents.ticker, ticker),
					gte(dividendEvents.exDate, startDate)
				)
			);
	}

	const results = await query.orderBy(desc(dividendEvents.exDate));
	return results;
}

/**
 * Get ticker metadata (sync status).
 */
export async function getTickerMetadata(
	db: DbClient,
	ticker: string
): Promise<{
	lastDailyDate: string | null;
	lastSyncedAt: Date | null;
	isActive: boolean;
} | null> {
	const [meta] = await db
		.select()
		.from(tickerMetadata)
		.where(eq(tickerMetadata.ticker, ticker))
		.limit(1);

	if (!meta) return null;

	return {
		lastDailyDate: meta.lastDailyDate,
		lastSyncedAt: meta.lastSyncedAt,
		isActive: meta.isActive
	};
}

// =============================================================================
// Intraday Functions
// =============================================================================

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
export async function syncIntradayData(
	db: DbClient,
	ticker: string
): Promise<IntradaySyncResult> {
	const now = new Date();

	try {
		// Fetch 5-day intraday data from Yahoo
		const data = await fetchIntradayData(ticker, '5d');

		// Batch upsert candles - process in chunks
		const BATCH_SIZE = 100;

		for (let i = 0; i < data.candles.length; i += BATCH_SIZE) {
			const batch = data.candles.slice(i, i + BATCH_SIZE);
			const values = batch.map(candle => ({
				id: `${ticker}_${candle.timestamp}`,
				ticker,
				timestamp: candle.timestamp,
				open: candle.open,
				high: candle.high,
				low: candle.low,
				close: candle.close,
				volume: candle.volume,
				currency: data.currency,
				fetchedAt: now
			}));

			await db
				.insert(intradayPrices)
				.values(values)
				.onConflictDoUpdate({
					target: intradayPrices.id,
					set: {
						open: sql`excluded.open`,
						high: sql`excluded.high`,
						low: sql`excluded.low`,
						close: sql`excluded.close`,
						volume: sql`excluded.volume`,
						currency: sql`excluded.currency`,
						fetchedAt: now
					}
				});
		}

		// Purge data older than 5 days
		const fiveDaysAgo = Math.floor((now.getTime() - 5 * 24 * 60 * 60 * 1000) / 1000);
		const purgeResult = await db
			.delete(intradayPrices)
			.where(
				and(
					eq(intradayPrices.ticker, ticker),
					lt(intradayPrices.timestamp, fiveDaysAgo)
				)
			);

		// Update ticker metadata with intraday sync time
		await db
			.insert(tickerMetadata)
			.values({
				ticker,
				lastIntradaySyncedAt: now,
				isActive: true
			})
			.onConflictDoUpdate({
				target: tickerMetadata.ticker,
				set: {
					lastIntradaySyncedAt: now,
					isActive: true
				}
			});

		return {
			ticker,
			candlesUpserted: data.candles.length,
			candlesPurged: purgeResult.changes ?? 0
		};
	} catch (err) {
		return {
			ticker,
			candlesUpserted: 0,
			candlesPurged: 0,
			error: err instanceof Error ? err.message : 'Unknown error'
		};
	}
}

/**
 * Get intraday prices for a ticker from the database.
 *
 * @param db - Database client
 * @param ticker - Yahoo Finance ticker symbol
 * @returns Array of intraday price records, sorted by timestamp ascending
 */
export async function getIntradayPrices(
	db: DbClient,
	ticker: string
): Promise<IntradayPriceRecord[]> {
	const results = await db
		.select({
			timestamp: intradayPrices.timestamp,
			open: intradayPrices.open,
			high: intradayPrices.high,
			low: intradayPrices.low,
			close: intradayPrices.close,
			volume: intradayPrices.volume
		})
		.from(intradayPrices)
		.where(eq(intradayPrices.ticker, ticker))
		.orderBy(intradayPrices.timestamp);

	return results;
}

/**
 * Check if a ticker needs intraday sync.
 * Returns true if:
 * - Never synced before
 * - Last sync was more than 5 minutes ago
 */
export async function needsIntradaySync(
	db: DbClient,
	ticker: string
): Promise<boolean> {
	const [meta] = await db
		.select()
		.from(tickerMetadata)
		.where(eq(tickerMetadata.ticker, ticker))
		.limit(1);

	if (!meta || !meta.lastIntradaySyncedAt) {
		return true;
	}

	// Check if last intraday sync was more than 5 minutes ago
	const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
	return meta.lastIntradaySyncedAt < fiveMinutesAgo;
}

/**
 * Get list of tickers that need intraday sync.
 * Only includes active tickers that haven't been synced in the last 5 minutes.
 */
export async function getTickersNeedingIntradaySync(
	db: DbClient,
	tickers: string[]
): Promise<string[]> {
	const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
	const needsSync: string[] = [];

	for (const ticker of tickers) {
		const [meta] = await db
			.select()
			.from(tickerMetadata)
			.where(eq(tickerMetadata.ticker, ticker))
			.limit(1);

		// Needs sync if: no metadata, or not synced in last 5 minutes
		if (!meta) {
			needsSync.push(ticker);
		} else if (meta.isActive) {
			if (!meta.lastIntradaySyncedAt || meta.lastIntradaySyncedAt < fiveMinutesAgo) {
				needsSync.push(ticker);
			}
		}
	}

	return needsSync;
}
