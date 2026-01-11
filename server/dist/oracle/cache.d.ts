/**
 * Price Cache
 *
 * Caches price data and FX rates in SQLite.
 * TTL-based invalidation.
 */
import type { DbClient } from '../db/client';
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
 * Get price from cache or fetch from Yahoo
 *
 * @param db - Database client
 * @param isin - Asset ISIN (used for symbol resolution if needed)
 * @param yahooSymbol - Yahoo Finance symbol (if known); if null, will resolve from ISIN
 * @param forceRefresh - If true, bypass cache and fetch fresh data from Yahoo
 */
export declare function getPrice(db: DbClient, isin: string, yahooSymbol: string | null, forceRefresh?: boolean): Promise<CachedPrice>;
/**
 * Get FX rate from cache or fetch from Yahoo
 */
export declare function getFxRate(db: DbClient, from: string, to: string): Promise<CachedFxRate>;
/**
 * Clear expired cache entries
 */
export declare function clearExpiredCache(db: DbClient): Promise<{
    pricesCleared: number;
    fxCleared: number;
}>;
/**
 * Clear all cache
 */
export declare function clearAllCache(db: DbClient): Promise<void>;
