/**
 * Price Cache
 *
 * Caches price data and FX rates in SQLite.
 * TTL-based invalidation.
 */

import { eq, lt } from 'drizzle-orm';
import type { DbClient } from '$lib/server/db/client';
import { priceCache, fxCache } from '$lib/server/db/schema';
import { PRICE_CACHE_TTL_MS } from '$lib/server/config';
import { fetchPriceInEur, fetchFxRate } from './yahoo';

export interface CachedPrice {
	ticker: string;
	priceNative: number;
	currency: string;
	priceEur: number;
	fetchedAt: Date;
	fromCache: boolean;
}

export interface CachedFxRate {
	pair: string;
	rate: number;
	fetchedAt: Date;
	fromCache: boolean;
}

/**
 * Check if a cached entry is still valid
 */
function isValid(fetchedAt: Date): boolean {
	const age = Date.now() - fetchedAt.getTime();
	return age < PRICE_CACHE_TTL_MS;
}

/**
 * Get price from cache or fetch from Yahoo
 * 
 * @param db - Database client
 * @param isin - Asset ISIN (used for symbol resolution if needed)
 * @param yahooSymbol - Yahoo Finance symbol (if known); if null, will resolve from ISIN
 * @param forceRefresh - If true, bypass cache and fetch fresh data from Yahoo
 */
export async function getPrice(
	db: DbClient,
	isin: string,
	yahooSymbol: string | null,
	forceRefresh = false
): Promise<CachedPrice> {
	// If no Yahoo symbol, we need to resolve it first
	if (!yahooSymbol) {
		throw new Error(`No Yahoo symbol set for ISIN ${isin}. Resolve symbols first.`);
	}

	// Check cache first (unless forcing refresh)
	if (!forceRefresh) {
		const [cached] = await db
			.select()
			.from(priceCache)
			.where(eq(priceCache.ticker, yahooSymbol))
			.limit(1);

		if (cached && isValid(cached.fetchedAt)) {
			return {
				...cached,
				fromCache: true
			};
		}
	}

	// Fetch fresh data using Yahoo symbol
	const fresh = await fetchPriceInEur(isin, yahooSymbol);
	const now = new Date();

	// Upsert cache
	await db
		.insert(priceCache)
		.values({
			ticker: yahooSymbol,
			priceNative: fresh.priceNative,
			currency: fresh.currency,
			priceEur: fresh.priceEur,
			fetchedAt: now
		})
		.onConflictDoUpdate({
			target: priceCache.ticker,
			set: {
				priceNative: fresh.priceNative,
				currency: fresh.currency,
				priceEur: fresh.priceEur,
				fetchedAt: now
			}
		});

	return {
		ticker: yahooSymbol,
		priceNative: fresh.priceNative,
		currency: fresh.currency,
		priceEur: fresh.priceEur,
		fetchedAt: now,
		fromCache: false
	};
}

/**
 * Get FX rate from cache or fetch from Yahoo
 */
export async function getFxRate(
	db: DbClient,
	from: string,
	to: string
): Promise<CachedFxRate> {
	const pair = `${from.toUpperCase()}${to.toUpperCase()}`;

	// Same currency
	if (from.toUpperCase() === to.toUpperCase()) {
		return {
			pair,
			rate: 1,
			fetchedAt: new Date(),
			fromCache: false
		};
	}

	// Check cache
	const [cached] = await db
		.select()
		.from(fxCache)
		.where(eq(fxCache.pair, pair))
		.limit(1);

	if (cached && isValid(cached.fetchedAt)) {
		return {
			...cached,
			fromCache: true
		};
	}

	// Fetch fresh rate
	const rate = await fetchFxRate(from, to);
	const now = new Date();

	// Upsert cache
	await db
		.insert(fxCache)
		.values({
			pair,
			rate,
			fetchedAt: now
		})
		.onConflictDoUpdate({
			target: fxCache.pair,
			set: {
				rate,
				fetchedAt: now
			}
		});

	return {
		pair,
		rate,
		fetchedAt: now,
		fromCache: false
	};
}

/**
 * Clear expired cache entries
 */
export async function clearExpiredCache(db: DbClient): Promise<{
	pricesCleared: number;
	fxCleared: number;
}> {
	const expiryDate = new Date(Date.now() - PRICE_CACHE_TTL_MS);

	const priceResult = await db
		.delete(priceCache)
		.where(lt(priceCache.fetchedAt, expiryDate));

	const fxResult = await db
		.delete(fxCache)
		.where(lt(fxCache.fetchedAt, expiryDate));

	return {
		pricesCleared: priceResult.changes ?? 0,
		fxCleared: fxResult.changes ?? 0
	};
}

/**
 * Clear all cache
 */
export async function clearAllCache(db: DbClient): Promise<void> {
	await db.delete(priceCache);
	await db.delete(fxCache);
}
