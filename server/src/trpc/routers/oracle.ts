import { z } from 'zod';
import { TRPCError } from '@trpc/server';
import { observable } from '@trpc/server/observable';
import { router, publicProcedure } from '../trpc';
import { serverEvents, type ServerEvent } from '../../events';
import { triggerPriceSync, getSyncStatus } from '../../sync';
import { assets, holdings, priceCache, fxCache, yahooSymbols, dailyPrices, intradayPrices, dividendEvents, tickerMetadata } from '../../db/schema';
import { getPrice, getFxRate, clearExpiredCache, clearAllCache } from '../../oracle/cache';
import { fetchAllSymbolsFromIsin, YahooFinanceError } from '../../oracle/yahoo';
import {
	syncHistoricalData,
	getHistoricalPrices,
	getDividendEvents,
	getTickersNeedingSync,
	needsHistoricalSync,
	syncIntradayData,
	getIntradayPrices,
	needsIntradaySync,
	getTickersNeedingIntradaySync,
	ensureTickerMetadata
} from '../../oracle/historical';
import { eq, gt } from 'drizzle-orm';
import { randomUUID } from 'crypto';
import { PRICE_CACHE_TTL_MS } from '../../config';

export const oracleRouter = router({
	/**
	 * Get price for a single asset
	 */
	getPrice: publicProcedure
		.input(z.object({ isin: z.string() }))
		.query(async ({ ctx, input }) => {
			// Get asset to find Yahoo symbol
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: `No Yahoo symbol set for ${asset.name}. Resolve symbols first.`
				});
			}

			try {
				const price = await getPrice(ctx.db, input.isin, asset.yahooSymbol);
				return price;
			} catch (err) {
				if (err instanceof YahooFinanceError) {
					throw new TRPCError({
						code: 'INTERNAL_SERVER_ERROR',
						message: err.message
					});
				}
				throw err;
			}
		}),

	/**
	 * Get prices for all held assets (quantity > 0)
	 */
	getAllPrices: publicProcedure.query(async ({ ctx }) => {
		// Get all holdings with their assets (only those with quantity > 0)
		const holdingsWithAssets = await ctx.db
			.select({
				holding: holdings,
				asset: assets
			})
			.from(holdings)
			.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
			.where(gt(holdings.quantity, 0));

		const results: Array<{
			isin: string;
			ticker: string;
			yahooSymbol: string | null;
			name: string;
			quantity: number;
			priceEur: number;
			valueEur: number;
			currency: string;
			fromCache: boolean;
			fetchedAt: Date | null;
			error?: string;
		}> = [];

		for (const row of holdingsWithAssets) {
			// Skip if no Yahoo symbol set
			if (!row.asset.yahooSymbol) {
				results.push({
					isin: row.asset.isin,
					ticker: row.asset.ticker,
					yahooSymbol: null,
					name: row.asset.name,
					quantity: row.holding.quantity,
					priceEur: 0,
					valueEur: 0,
					currency: 'EUR',
					fromCache: false,
					fetchedAt: null,
					error: 'No Yahoo symbol set'
				});
				continue;
			}

			try {
				const price = await getPrice(ctx.db, row.asset.isin, row.asset.yahooSymbol);
				results.push({
					isin: row.asset.isin,
					ticker: row.asset.ticker,
					yahooSymbol: row.asset.yahooSymbol,
					name: row.asset.name,
					quantity: row.holding.quantity,
					priceEur: price.priceEur,
					valueEur: price.priceEur * row.holding.quantity,
					currency: price.currency,
					fromCache: price.fromCache,
					fetchedAt: price.fetchedAt
				});
			} catch (err) {
				results.push({
					isin: row.asset.isin,
					ticker: row.asset.ticker,
					yahooSymbol: row.asset.yahooSymbol,
					name: row.asset.name,
					quantity: row.holding.quantity,
					priceEur: 0,
					valueEur: 0,
					currency: 'EUR',
					fromCache: false,
					fetchedAt: null,
					error: err instanceof Error ? err.message : 'Unknown error'
				});
			}
		}

		const totalValueEur = results.reduce((sum, r) => sum + r.valueEur, 0);

		return {
			prices: results,
			totalValueEur,
			fetchedCount: results.filter((r) => !r.fromCache && !r.error).length,
			cachedCount: results.filter((r) => r.fromCache).length,
			errorCount: results.filter((r) => r.error).length
		};
	}),

	/**
	 * Refresh prices for all held assets (force fetch, ignore cache)
	 * Auto-resolves Yahoo symbols if not set
	 * Only refreshes assets with quantity > 0
	 */
	refreshAllPrices: publicProcedure.mutation(async ({ ctx }) => {
		// Clear price cache first
		await clearAllCache(ctx.db);

		// Get all holdings with their assets (only those with quantity > 0)
		const holdingsWithAssets = await ctx.db
			.select({
				holding: holdings,
				asset: assets
			})
			.from(holdings)
			.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
			.where(gt(holdings.quantity, 0));

		let successCount = 0;
		let errorCount = 0;
		let resolvedCount = 0;
		const errors: Array<{ isin: string; error: string }> = [];

		for (const row of holdingsWithAssets) {
			let yahooSymbol = row.asset.yahooSymbol;

			// Auto-resolve Yahoo symbol if not set
			if (!yahooSymbol) {
				try {
					const symbols = await fetchAllSymbolsFromIsin(row.asset.isin);
					if (symbols.length > 0) {
						yahooSymbol = symbols[0].symbol;

						// Store all symbols
						const now = new Date();
						for (const s of symbols) {
							await ctx.db.insert(yahooSymbols).values({
								id: randomUUID(),
								assetIsin: row.asset.isin,
								symbol: s.symbol,
								exchange: s.exchange,
								exchangeDisplay: s.exchangeDisplay,
								quoteType: s.quoteType,
								resolvedAt: now
							}).onConflictDoNothing();
						}

						// Set the first symbol as preferred
						await ctx.db
							.update(assets)
							.set({ yahooSymbol })
							.where(eq(assets.isin, row.asset.isin));

						resolvedCount++;
					}
				} catch (err) {
					errorCount++;
					errors.push({
						isin: row.asset.isin,
						error: `Failed to resolve symbol: ${err instanceof Error ? err.message : 'Unknown error'}`
					});
					continue;
				}
			}

			// Still no symbol after trying to resolve
			if (!yahooSymbol) {
				errorCount++;
				errors.push({
					isin: row.asset.isin,
					error: 'Could not resolve Yahoo symbol'
				});
				continue;
			}

			// Fetch price
			try {
				await getPrice(ctx.db, row.asset.isin, yahooSymbol);
				successCount++;
			} catch (err) {
				errorCount++;
				errors.push({
					isin: row.asset.isin,
					error: err instanceof Error ? err.message : 'Unknown error'
				});
			}
		}

		return {
			successCount,
			errorCount,
			resolvedCount,
			errors
		};
	}),

	/**
	 * Get FX rate
	 */
	getFxRate: publicProcedure
		.input(z.object({ from: z.string(), to: z.string() }))
		.query(async ({ ctx, input }) => {
			try {
				return await getFxRate(ctx.db, input.from, input.to);
			} catch (err) {
				if (err instanceof YahooFinanceError) {
					throw new TRPCError({
						code: 'INTERNAL_SERVER_ERROR',
						message: err.message
					});
				}
				throw err;
			}
		}),

	/**
	 * Resolve all Yahoo symbols for an ISIN and store them
	 * Returns all available symbols; auto-selects the first one if none selected
	 */
	resolveYahooSymbols: publicProcedure
		.input(z.object({ isin: z.string() }))
		.mutation(async ({ ctx, input }) => {
			// Get the asset
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			try {
				// Fetch all symbols from Yahoo
				const symbols = await fetchAllSymbolsFromIsin(input.isin);

				// Clear existing symbols for this ISIN
				await ctx.db.delete(yahooSymbols).where(eq(yahooSymbols.assetIsin, input.isin));

				// Insert all new symbols
				const now = new Date();
				const insertedSymbols = await Promise.all(
					symbols.map(async (s) => {
						const id = randomUUID();
						await ctx.db.insert(yahooSymbols).values({
							id,
							assetIsin: input.isin,
							symbol: s.symbol,
							exchange: s.exchange,
							exchangeDisplay: s.exchangeDisplay,
							quoteType: s.quoteType,
							resolvedAt: now
						});
						return { id, ...s };
					})
				);

				// Auto-select first symbol if none is currently selected
				if (!asset.yahooSymbol && symbols.length > 0) {
					await ctx.db
						.update(assets)
						.set({ yahooSymbol: symbols[0].symbol })
						.where(eq(assets.isin, input.isin));
				}

				return {
					symbols: insertedSymbols,
					selectedSymbol: asset.yahooSymbol ?? symbols[0]?.symbol ?? null
				};
			} catch (err) {
				if (err instanceof YahooFinanceError) {
					throw new TRPCError({
						code: 'INTERNAL_SERVER_ERROR',
						message: err.message
					});
				}
				throw err;
			}
		}),

	/**
	 * Get stored Yahoo symbols for an asset
	 */
	getYahooSymbols: publicProcedure
		.input(z.object({ isin: z.string() }))
		.query(async ({ ctx, input }) => {
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			const symbols = await ctx.db
				.select()
				.from(yahooSymbols)
				.where(eq(yahooSymbols.assetIsin, input.isin));

			return {
				selectedSymbol: asset.yahooSymbol,
				symbols
			};
		}),

	/**
	 * Set the preferred Yahoo symbol for an asset
	 */
	setYahooSymbol: publicProcedure
		.input(z.object({
			isin: z.string(),
			symbol: z.string().nullable() // null to clear
		}))
		.mutation(async ({ ctx, input }) => {
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			await ctx.db
				.update(assets)
				.set({ yahooSymbol: input.symbol })
				.where(eq(assets.isin, input.isin));

			// Clear price cache for this symbol so next fetch uses new symbol
			if (asset.yahooSymbol) {
				await ctx.db.delete(priceCache).where(eq(priceCache.ticker, asset.yahooSymbol));
			}

			return { success: true };
		}),

	/**
	 * Get list of assets that need price refresh (stale or missing)
	 * Only includes assets with holdings > 0
	 */
	getStaleAssets: publicProcedure
		.input(z.object({
			maxAgeMs: z.number().optional()
		}).optional())
		.query(async ({ ctx, input }) => {
			const maxAge = input?.maxAgeMs ?? PRICE_CACHE_TTL_MS;

			// Get holdings with assets that have yahoo symbols and quantity > 0
			const holdingsWithAssets = await ctx.db
				.select({
					holding: holdings,
					asset: assets
				})
				.from(holdings)
				.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
				.where(gt(holdings.quantity, 0));

			// Get all cached prices
			const cached = await ctx.db.select().from(priceCache);
			const cacheMap = new Map(cached.map(c => [c.ticker, c]));

			const now = Date.now();
			const staleAssets: Array<{
				isin: string;
				yahooSymbol: string;
				name: string;
				lastFetchedAt: Date | null;
				ageMs: number | null;
			}> = [];

			for (const row of holdingsWithAssets) {
				if (!row.asset.yahooSymbol) continue;

				const cachedPrice = cacheMap.get(row.asset.yahooSymbol);
				const isStale = !cachedPrice || (now - cachedPrice.fetchedAt.getTime()) > maxAge;

				if (isStale) {
					staleAssets.push({
						isin: row.asset.isin,
						yahooSymbol: row.asset.yahooSymbol,
						name: row.asset.name,
						lastFetchedAt: cachedPrice?.fetchedAt ?? null,
						ageMs: cachedPrice ? now - cachedPrice.fetchedAt.getTime() : null
					});
				}
			}

			return {
				staleAssets,
				totalHeld: holdingsWithAssets.filter(h => h.asset.yahooSymbol).length
			};
		}),

	/**
	 * Refresh price for a single asset (used for staggered updates)
	 * Always fetches fresh data from Yahoo (bypasses cache)
	 */
	refreshSinglePrice: publicProcedure
		.input(z.object({ isin: z.string() }))
		.mutation(async ({ ctx, input }) => {
			const [row] = await ctx.db
				.select({
					holding: holdings,
					asset: assets
				})
				.from(holdings)
				.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!row) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!row.asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: 'No Yahoo symbol set for this asset'
				});
			}

			try {
				// Force refresh - bypass cache and fetch from Yahoo
				const price = await getPrice(ctx.db, row.asset.isin, row.asset.yahooSymbol, true);
				return {
					success: true,
					isin: row.asset.isin,
					priceEur: price.priceEur,
					fromCache: price.fromCache
				};
			} catch (err) {
				return {
					success: false,
					isin: row.asset.isin,
					error: err instanceof Error ? err.message : 'Unknown error'
				};
			}
		}),

	/**
	 * Get cache status
	 */
	getCacheStatus: publicProcedure.query(async ({ ctx }) => {
		const prices = await ctx.db.select().from(priceCache);
		const fx = await ctx.db.select().from(fxCache);

		return {
			pricesCached: prices.length,
			fxRatesCached: fx.length,
			prices: prices.map((p) => ({
				ticker: p.ticker,
				fetchedAt: p.fetchedAt
			})),
			fxRates: fx.map((f) => ({
				pair: f.pair,
				fetchedAt: f.fetchedAt
			}))
		};
	}),

	/**
	 * Clear expired cache entries
	 */
	clearExpiredCache: publicProcedure.mutation(async ({ ctx }) => {
		return await clearExpiredCache(ctx.db);
	}),

	/**
	 * Clear all historical data and reset sync state.
	 * This forces a complete re-sync of all historical and intraday data.
	 * Use this after fixing data corruption issues.
	 */
	clearAllHistoricalData: publicProcedure.mutation(async ({ ctx }) => {
		// Delete all historical price data
		const dailyResult = await ctx.db.delete(dailyPrices);
		const intradayResult = await ctx.db.delete(intradayPrices);
		const dividendResult = await ctx.db.delete(dividendEvents);

		// Reset ticker metadata (clear sync timestamps but keep entries)
		await ctx.db.delete(tickerMetadata);

		return {
			dailyPricesDeleted: dailyResult.changes ?? 0,
			intradayPricesDeleted: intradayResult.changes ?? 0,
			dividendsDeleted: dividendResult.changes ?? 0,
			message: 'All historical data cleared. Next sync will fetch fresh data.'
		};
	}),

	/**
	 * Clear historical data for a single asset and reset its sync state.
	 * Use this when changing the Yahoo symbol for an asset.
	 */
	clearHistoricalDataForAsset: publicProcedure
		.input(z.object({ isin: z.string() }))
		.mutation(async ({ ctx, input }) => {
			// Look up the asset
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				return {
					dailyPricesDeleted: 0,
					intradayPricesDeleted: 0,
					dividendsDeleted: 0,
					message: 'No Yahoo symbol set for this asset. Nothing to clear.'
				};
			}

			const ticker = asset.yahooSymbol;

			// Delete historical data for this ticker
			const dailyResult = await ctx.db
				.delete(dailyPrices)
				.where(eq(dailyPrices.ticker, ticker));
			const intradayResult = await ctx.db
				.delete(intradayPrices)
				.where(eq(intradayPrices.ticker, ticker));
			const dividendResult = await ctx.db
				.delete(dividendEvents)
				.where(eq(dividendEvents.ticker, ticker));

			// Reset ticker metadata for this ticker
			await ctx.db
				.delete(tickerMetadata)
				.where(eq(tickerMetadata.ticker, ticker));

			return {
				ticker,
				dailyPricesDeleted: dailyResult.changes ?? 0,
				intradayPricesDeleted: intradayResult.changes ?? 0,
				dividendsDeleted: dividendResult.changes ?? 0,
				message: `Historical data cleared for ${ticker}. Next sync will fetch fresh data.`
			};
		}),

	// =========================================================================
	// Historical Price Data
	// =========================================================================

	/**
	 * Get historical prices for an asset (from cache).
	 * Returns daily OHLCV data within the specified date range.
	 */
	getHistoricalPrices: publicProcedure
		.input(
			z.object({
				isin: z.string(),
				startDate: z.string().optional(), // YYYY-MM-DD, defaults to 1 year ago
				endDate: z.string().optional() // YYYY-MM-DD, defaults to today
			})
		)
		.query(async ({ ctx, input }) => {
			// Look up Yahoo symbol from ISIN
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: 'No Yahoo symbol set for this asset'
				});
			}

			const candles = await getHistoricalPrices(
				ctx.db,
				asset.yahooSymbol,
				input.startDate,
				input.endDate
			);

			return {
				isin: input.isin,
				ticker: asset.yahooSymbol,
				candles
			};
		}),

	/**
	 * Sync historical data for an asset from Yahoo Finance.
	 * Fetches all available history (range=max) and stores in database.
	 * Includes dividend events.
	 */
	syncHistoricalData: publicProcedure
		.input(z.object({ isin: z.string() }))
		.mutation(async ({ ctx, input }) => {
			// Look up Yahoo symbol from ISIN
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: 'No Yahoo symbol set for this asset'
				});
			}

			const result = await syncHistoricalData(ctx.db, asset.yahooSymbol);

			if (result.error) {
				throw new TRPCError({
					code: 'INTERNAL_SERVER_ERROR',
					message: result.error
				});
			}

			return {
				isin: input.isin,
				ticker: asset.yahooSymbol,
				candlesUpserted: result.candlesUpserted,
				dividendsUpserted: result.dividendsUpserted,
				latestDate: result.latestDate
			};
		}),

	/**
	 * Get dividend events for an asset.
	 */
	getDividends: publicProcedure
		.input(
			z.object({
				isin: z.string(),
				startDate: z.string().optional() // YYYY-MM-DD filter
			})
		)
		.query(async ({ ctx, input }) => {
			// Look up Yahoo symbol from ISIN
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				return { isin: input.isin, dividends: [] };
			}

			const dividends = await getDividendEvents(
				ctx.db,
				asset.yahooSymbol,
				input.startDate
			);

			return {
				isin: input.isin,
				ticker: asset.yahooSymbol,
				dividends
			};
		}),

	/**
	 * Get list of tickers that need historical sync.
	 * Returns tickers that haven't been synced today.
	 * Also ensures ticker_metadata entries exist for all tickers.
	 */
	getTickersNeedingHistoricalSync: publicProcedure.query(async ({ ctx }) => {
		// Get all active holdings with Yahoo symbols
		const holdingsWithAssets = await ctx.db
			.select({
				holding: holdings,
				asset: assets
			})
			.from(holdings)
			.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
			.where(gt(holdings.quantity, 0));

		const tickers = holdingsWithAssets
			.map((h) => h.asset.yahooSymbol)
			.filter((t): t is string => t !== null);

		// Ensure ticker_metadata entries exist for all tickers
		// This ensures getTickersNeedingSync works correctly from the first run
		await ensureTickerMetadata(ctx.db, tickers);

		const needsSync = await getTickersNeedingSync(ctx.db, tickers);

		// Map back to ISINs for the client
		const tickerToIsin = new Map(
			holdingsWithAssets
				.filter((h) => h.asset.yahooSymbol)
				.map((h) => [h.asset.yahooSymbol!, h.asset.isin])
		);

		return {
			tickers: needsSync.map((ticker) => ({
				ticker,
				isin: tickerToIsin.get(ticker) ?? null
			})),
			totalWithSymbol: tickers.length
		};
	}),

	/**
	 * Check if a specific asset needs historical sync.
	 */
	needsHistoricalSync: publicProcedure
		.input(z.object({ isin: z.string() }))
		.query(async ({ ctx, input }) => {
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset || !asset.yahooSymbol) {
				return { needsSync: false, reason: 'No Yahoo symbol' };
			}

			const needs = await needsHistoricalSync(ctx.db, asset.yahooSymbol);
			return {
				needsSync: needs,
				reason: needs ? 'Not synced today' : 'Already synced today'
			};
		}),

	// =========================================================================
	// Intraday Price Data
	// =========================================================================

	/**
	 * Get intraday prices for an asset (from cache).
	 * Returns 5-minute interval data for the last 5 days.
	 */
	getIntradayPrices: publicProcedure
		.input(z.object({ isin: z.string() }))
		.query(async ({ ctx, input }) => {
			// Look up Yahoo symbol from ISIN
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: 'No Yahoo symbol set for this asset'
				});
			}

			const candles = await getIntradayPrices(ctx.db, asset.yahooSymbol);

			return {
				isin: input.isin,
				ticker: asset.yahooSymbol,
				candles
			};
		}),

	/**
	 * Sync intraday data for an asset from Yahoo Finance.
	 * Fetches 5-day data with 5-minute intervals.
	 * Purges data older than 5 days.
	 */
	syncIntradayData: publicProcedure
		.input(z.object({ isin: z.string() }))
		.mutation(async ({ ctx, input }) => {
			// Look up Yahoo symbol from ISIN
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset) {
				throw new TRPCError({ code: 'NOT_FOUND', message: 'Asset not found' });
			}

			if (!asset.yahooSymbol) {
				throw new TRPCError({
					code: 'PRECONDITION_FAILED',
					message: 'No Yahoo symbol set for this asset'
				});
			}

			const result = await syncIntradayData(ctx.db, asset.yahooSymbol);

			if (result.error) {
				throw new TRPCError({
					code: 'INTERNAL_SERVER_ERROR',
					message: result.error
				});
			}

			return {
				isin: input.isin,
				ticker: asset.yahooSymbol,
				candlesUpserted: result.candlesUpserted,
				candlesPurged: result.candlesPurged
			};
		}),

	/**
	 * Check if a specific asset needs intraday sync.
	 * Returns true if not synced in the last 5 minutes.
	 */
	needsIntradaySync: publicProcedure
		.input(z.object({ isin: z.string() }))
		.query(async ({ ctx, input }) => {
			const [asset] = await ctx.db
				.select()
				.from(assets)
				.where(eq(assets.isin, input.isin))
				.limit(1);

			if (!asset || !asset.yahooSymbol) {
				return { needsSync: false, reason: 'No Yahoo symbol' };
			}

			const needs = await needsIntradaySync(ctx.db, asset.yahooSymbol);
			return {
				needsSync: needs,
				reason: needs ? 'Not synced in last 5 minutes' : 'Recently synced'
			};
		}),

	/**
	 * Get list of tickers that need intraday sync.
	 * Returns tickers that haven't been synced in the last 5 minutes.
	 * Also ensures ticker_metadata entries exist for all tickers.
	 */
	getTickersNeedingIntradaySync: publicProcedure.query(async ({ ctx }) => {
		// Get all active holdings with Yahoo symbols
		const holdingsWithAssets = await ctx.db
			.select({
				holding: holdings,
				asset: assets
			})
			.from(holdings)
			.innerJoin(assets, eq(holdings.assetIsin, assets.isin))
			.where(gt(holdings.quantity, 0));

		const tickers = holdingsWithAssets
			.map((h) => h.asset.yahooSymbol)
			.filter((t): t is string => t !== null);

		// Ensure ticker_metadata entries exist for all tickers
		// This ensures getTickersNeedingIntradaySync works correctly from the first run
		await ensureTickerMetadata(ctx.db, tickers);

		const needsSync = await getTickersNeedingIntradaySync(ctx.db, tickers);

		// Map back to ISINs for the client
		const tickerToIsin = new Map(
			holdingsWithAssets
				.filter((h) => h.asset.yahooSymbol)
				.map((h) => [h.asset.yahooSymbol!, h.asset.isin])
		);

		return {
			tickers: needsSync.map((ticker) => ({
				ticker,
				isin: tickerToIsin.get(ticker) ?? null
			})),
			totalWithSymbol: tickers.length
		};
	}),

	// =========================================================================
	// Sync Control
	// =========================================================================

	/**
	 * Get current sync status
	 */
	getSyncStatus: publicProcedure.query(() => {
		return getSyncStatus();
	}),

	/**
	 * Trigger a price sync job manually.
	 * Returns immediately - sync runs in background.
	 * Progress is pushed via WebSocket subscription.
	 */
	triggerPriceSync: publicProcedure.mutation(() => {
		return triggerPriceSync();
	}),

	// =========================================================================
	// Real-time Subscriptions
	// =========================================================================

	/**
	 * Subscribe to real-time server events (price updates, sync progress).
	 * Events are pushed when:
	 * - A price is updated (from cron job or manual refresh)
	 * - Sync job starts/progresses/completes
	 */
	onEvent: publicProcedure.subscription(() => {
		return observable<ServerEvent>((emit) => {
			const unsubscribe = serverEvents.onEvent((event) => {
				emit.next(event);
			});

			return () => {
				unsubscribe();
			};
		});
	})
});
