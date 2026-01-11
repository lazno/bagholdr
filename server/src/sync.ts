/**
 * Sync Module
 *
 * Manages background sync jobs for prices and historical data.
 * Provides a lock to prevent concurrent syncs.
 */

import { eq, gt } from 'drizzle-orm';
import { db } from './db/client';
import { holdings, assets } from './db/schema';
import { syncHistoricalData, syncIntradayData, getTickersNeedingSync, getTickersNeedingIntradaySync, ensureTickerMetadata } from './oracle/historical';
import { getPrice } from './oracle/cache';
import { serverEvents, type SyncQueueItem } from './events';

// Sync lock - prevents concurrent syncs
let isSyncing = false;
// Unique ID for each sync job (for debugging)
let syncJobId = 0;

export function getSyncStatus(): { isSyncing: boolean } {
	return { isSyncing };
}

interface HeldAsset {
	ticker: string;
	isin: string;
	name: string;
}

/**
 * Get all Yahoo symbols for held assets with names
 */
async function getHeldAssets(): Promise<HeldAsset[]> {
	const holdingsWithAssets = await db
		.select({
			holding: holdings,
			asset: assets
		})
		.from(holdings)
		.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
		.where(gt(holdings.quantity, 0));

	return holdingsWithAssets
		.filter((h) => h.asset.yahooSymbol)
		.map((h) => ({
			ticker: h.asset.yahooSymbol!,
			isin: h.asset.isin,
			name: h.asset.name
		}));
}

/**
 * Price sync job - refreshes current prices and intraday data
 */
export async function runPriceSyncJob(): Promise<void> {
	if (isSyncing) {
		console.log('[PriceSync] Sync already in progress, skipping');
		return;
	}

	isSyncing = true;
	syncJobId++;
	const jobId = syncJobId;
	const startTime = Date.now();
	console.log(`[PriceSync #${jobId}] Starting price sync job...`);

	try {
		const heldAssets = await getHeldAssets();
		console.log(`[PriceSync #${jobId}] Found ${heldAssets.length} assets with Yahoo symbols`);

		if (heldAssets.length === 0) {
			console.log('[PriceSync] No assets to sync');
			isSyncing = false;
			return;
		}

		// Ensure ticker metadata exists
		const tickers = heldAssets.map((a) => a.ticker);
		await ensureTickerMetadata(db, tickers);

		// Get tickers needing intraday sync
		const needsIntradaySync = await getTickersNeedingIntradaySync(db, tickers);
		console.log(`[PriceSync #${jobId}] ${needsIntradaySync.length}/${tickers.length} tickers need intraday sync`);

		// Get tickers needing historical sync
		const needsHistoricalSync = await getTickersNeedingSync(db, tickers);
		console.log(`[PriceSync #${jobId}] ${needsHistoricalSync.length}/${tickers.length} tickers need historical sync`);

		// Build initial queue with sub-task status
		const queue: SyncQueueItem[] = heldAssets.map((a) => ({
			ticker: a.ticker,
			isin: a.isin,
			name: a.name,
			status: 'pending',
			subTasks: {
				price: 'pending',
				historical: needsHistoricalSync.includes(a.ticker) ? 'pending' : 'skipped',
				intraday: needsIntradaySync.includes(a.ticker) ? 'pending' : 'skipped'
			}
		}));

		// Emit the full queue
		serverEvents.emitSyncQueue({
			job: 'price',
			items: queue
		});

		let priceSuccessCount = 0;
		let priceErrorCount = 0;
		let intradaySuccessCount = 0;
		let intradayErrorCount = 0;
		let historicalSuccessCount = 0;
		let historicalErrorCount = 0;

		for (let i = 0; i < heldAssets.length; i++) {
			const { ticker, isin } = heldAssets[i];
			const needsHistorical = needsHistoricalSync.includes(ticker);
			const needsIntraday = needsIntradaySync.includes(ticker);

			// Mark item as syncing, start with price
			serverEvents.emitSyncItemUpdate({
				job: 'price',
				ticker,
				status: 'syncing',
				subTasks: { price: 'running' }
			});

			// Refresh current price
			let itemError: string | undefined;
			let priceStatus: 'done' | 'error' = 'done';
			try {
				const price = await getPrice(db, isin, ticker, true);
				priceSuccessCount++;

				// Emit price update event
				serverEvents.emitPriceUpdate({
					isin,
					ticker,
					priceEur: price.priceEur,
					currency: price.currency,
					fetchedAt: price.fetchedAt
				});
			} catch (err) {
				priceErrorCount++;
				priceStatus = 'error';
				itemError = err instanceof Error ? err.message : 'Unknown error';
				console.error(`[PriceSync #${jobId}] Failed to fetch price for ${ticker}:`, itemError);
			}

			// Update price status
			serverEvents.emitSyncItemUpdate({
				job: 'price',
				ticker,
				status: 'syncing',
				subTasks: { price: priceStatus }
			});

			// Sync historical data if needed (missing or outdated)
			let historicalStatus: 'done' | 'error' | 'skipped' = needsHistorical ? 'done' : 'skipped';
			if (needsHistorical) {
				serverEvents.emitSyncItemUpdate({
					job: 'price',
					ticker,
					status: 'syncing',
					subTasks: { historical: 'running' }
				});

				try {
					const result = await syncHistoricalData(db, ticker);
					if (result.error) {
						historicalErrorCount++;
						historicalStatus = 'error';
						console.error(`[PriceSync #${jobId}] Historical sync error for ${ticker}: ${result.error}`);
					} else {
						historicalSuccessCount++;
						console.log(`[PriceSync #${jobId}] Historical sync for ${ticker}: ${result.candlesUpserted} candles, ${result.dividendsUpserted} dividends`);
					}
				} catch (err) {
					historicalErrorCount++;
					historicalStatus = 'error';
					console.error(`[PriceSync #${jobId}] Failed historical sync for ${ticker}:`, err instanceof Error ? err.message : err);
				}

				serverEvents.emitSyncItemUpdate({
					job: 'price',
					ticker,
					status: 'syncing',
					subTasks: { historical: historicalStatus }
				});
			}

			// Sync intraday if needed
			let intradayStatus: 'done' | 'error' | 'skipped' = needsIntraday ? 'done' : 'skipped';
			if (needsIntraday) {
				serverEvents.emitSyncItemUpdate({
					job: 'price',
					ticker,
					status: 'syncing',
					subTasks: { intraday: 'running' }
				});

				try {
					const result = await syncIntradayData(db, ticker);
					if (result.error) {
						intradayErrorCount++;
						intradayStatus = 'error';
						console.error(`[PriceSync #${jobId}] Intraday sync error for ${ticker}: ${result.error}`);
					} else {
						intradaySuccessCount++;
					}
				} catch (err) {
					intradayErrorCount++;
					intradayStatus = 'error';
					console.error(`[PriceSync #${jobId}] Failed intraday sync for ${ticker}:`, err instanceof Error ? err.message : err);
				}

				serverEvents.emitSyncItemUpdate({
					job: 'price',
					ticker,
					status: 'syncing',
					subTasks: { intraday: intradayStatus }
				});
			}

			// Mark item as done or error (error if price failed)
			serverEvents.emitSyncItemUpdate({
				job: 'price',
				ticker,
				status: itemError ? 'error' : 'done',
				error: itemError
			});
		}

		const duration = Date.now() - startTime;
		console.log(`[PriceSync #${jobId}] Completed in ${(duration / 1000).toFixed(1)}s - Prices: ${priceSuccessCount}/${heldAssets.length} ok, ${priceErrorCount} errors. Historical: ${historicalSuccessCount}/${needsHistoricalSync.length} ok, ${historicalErrorCount} errors. Intraday: ${intradaySuccessCount}/${needsIntradaySync.length} ok, ${intradayErrorCount} errors.`);

		// Emit sync complete event
		serverEvents.emitSyncComplete({
			job: 'price',
			successCount: priceSuccessCount,
			errorCount: priceErrorCount,
			durationMs: duration
		});
	} catch (err) {
		console.error('[PriceSync] Job failed:', err);
	} finally {
		isSyncing = false;
	}
}

/**
 * Trigger price sync manually. Returns immediately, sync runs in background.
 * This also syncs historical and intraday data for assets that need it.
 */
export function triggerPriceSync(): { started: boolean; reason?: string } {
	console.log(`[PriceSync] triggerPriceSync called, isSyncing=${isSyncing}`);
	if (isSyncing) {
		console.log('[PriceSync] Rejecting - sync already in progress');
		return { started: false, reason: 'Sync already in progress' };
	}
	// Run async in background - lock is set synchronously at start of runPriceSyncJob
	runPriceSyncJob().catch((err) => {
		console.error('[PriceSync] Job failed:', err);
	});
	return { started: true };
}
