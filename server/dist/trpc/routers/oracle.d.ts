import { type ServerEvent } from '../../events';
export declare const oracleRouter: import("@trpc/server").TRPCBuiltRouter<{
    ctx: {
        db: import("drizzle-orm/better-sqlite3").BetterSQLite3Database<typeof import("../../db/schema")> & {
            $client: import("better-sqlite3").Database;
        };
    };
    meta: object;
    errorShape: import("@trpc/server").TRPCDefaultErrorShape;
    transformer: false;
}, import("@trpc/server").TRPCDecorateCreateRouterOptions<{
    /**
     * Get price for a single asset
     */
    getPrice: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: import("../../oracle/cache").CachedPrice;
        meta: object;
    }>;
    /**
     * Get prices for all held assets (quantity > 0)
     */
    getAllPrices: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            prices: {
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
            }[];
            totalValueEur: number;
            fetchedCount: number;
            cachedCount: number;
            errorCount: number;
        };
        meta: object;
    }>;
    /**
     * Refresh prices for all held assets (force fetch, ignore cache)
     * Auto-resolves Yahoo symbols if not set
     * Only refreshes assets with quantity > 0
     */
    refreshAllPrices: import("@trpc/server").TRPCMutationProcedure<{
        input: void;
        output: {
            successCount: number;
            errorCount: number;
            resolvedCount: number;
            errors: {
                isin: string;
                error: string;
            }[];
        };
        meta: object;
    }>;
    /**
     * Get FX rate
     */
    getFxRate: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            from: string;
            to: string;
        };
        output: import("../../oracle/cache").CachedFxRate;
        meta: object;
    }>;
    /**
     * Resolve all Yahoo symbols for an ISIN and store them
     * Returns all available symbols; auto-selects the first one if none selected
     */
    resolveYahooSymbols: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
        };
        output: {
            symbols: {
                symbol: string;
                exchange?: string;
                exchangeDisplay?: string;
                quoteType?: string;
                shortname?: string;
                id: `${string}-${string}-${string}-${string}-${string}`;
            }[];
            selectedSymbol: string;
        };
        meta: object;
    }>;
    /**
     * Get stored Yahoo symbols for an asset
     */
    getYahooSymbols: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: {
            selectedSymbol: string | null;
            symbols: {
                id: string;
                assetIsin: string;
                symbol: string;
                exchange: string | null;
                exchangeDisplay: string | null;
                quoteType: string | null;
                resolvedAt: Date;
            }[];
        };
        meta: object;
    }>;
    /**
     * Set the preferred Yahoo symbol for an asset
     */
    setYahooSymbol: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
            symbol: string | null;
        };
        output: {
            success: boolean;
        };
        meta: object;
    }>;
    /**
     * Get list of assets that need price refresh (stale or missing)
     * Only includes assets with holdings > 0
     */
    getStaleAssets: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            maxAgeMs?: number | undefined;
        } | undefined;
        output: {
            staleAssets: {
                isin: string;
                yahooSymbol: string;
                name: string;
                lastFetchedAt: Date | null;
                ageMs: number | null;
            }[];
            totalHeld: number;
        };
        meta: object;
    }>;
    /**
     * Refresh price for a single asset (used for staggered updates)
     * Always fetches fresh data from Yahoo (bypasses cache)
     */
    refreshSinglePrice: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
        };
        output: {
            success: boolean;
            isin: string;
            priceEur: number;
            fromCache: boolean;
            error?: undefined;
        } | {
            success: boolean;
            isin: string;
            error: string;
            priceEur?: undefined;
            fromCache?: undefined;
        };
        meta: object;
    }>;
    /**
     * Get cache status
     */
    getCacheStatus: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            pricesCached: number;
            fxRatesCached: number;
            prices: {
                ticker: string;
                fetchedAt: Date;
            }[];
            fxRates: {
                pair: string;
                fetchedAt: Date;
            }[];
        };
        meta: object;
    }>;
    /**
     * Clear expired cache entries
     */
    clearExpiredCache: import("@trpc/server").TRPCMutationProcedure<{
        input: void;
        output: {
            pricesCleared: number;
            fxCleared: number;
        };
        meta: object;
    }>;
    /**
     * Clear all historical data and reset sync state.
     * This forces a complete re-sync of all historical and intraday data.
     * Use this after fixing data corruption issues.
     */
    clearAllHistoricalData: import("@trpc/server").TRPCMutationProcedure<{
        input: void;
        output: {
            dailyPricesDeleted: number;
            intradayPricesDeleted: number;
            dividendsDeleted: number;
            message: string;
        };
        meta: object;
    }>;
    /**
     * Clear historical data for a single asset and reset its sync state.
     * Use this when changing the Yahoo symbol for an asset.
     */
    clearHistoricalDataForAsset: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
        };
        output: {
            dailyPricesDeleted: number;
            intradayPricesDeleted: number;
            dividendsDeleted: number;
            message: string;
            ticker?: undefined;
        } | {
            ticker: string;
            dailyPricesDeleted: number;
            intradayPricesDeleted: number;
            dividendsDeleted: number;
            message: string;
        };
        meta: object;
    }>;
    /**
     * Get historical prices for an asset (from cache).
     * Returns daily OHLCV data within the specified date range.
     */
    getHistoricalPrices: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
            startDate?: string | undefined;
            endDate?: string | undefined;
        };
        output: {
            isin: string;
            ticker: string;
            candles: import("../../oracle/historical").DailyPriceRecord[];
        };
        meta: object;
    }>;
    /**
     * Sync historical data for an asset from Yahoo Finance.
     * Fetches all available history (range=max) and stores in database.
     * Includes dividend events.
     */
    syncHistoricalData: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
        };
        output: {
            isin: string;
            ticker: string;
            candlesUpserted: number;
            dividendsUpserted: number;
            latestDate: string | null;
        };
        meta: object;
    }>;
    /**
     * Get dividend events for an asset.
     */
    getDividends: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
            startDate?: string | undefined;
        };
        output: {
            isin: string;
            dividends: never[];
            ticker?: undefined;
        } | {
            isin: string;
            ticker: string;
            dividends: {
                exDate: string;
                amount: number;
                currency: string;
            }[];
        };
        meta: object;
    }>;
    /**
     * Get list of tickers that need historical sync.
     * Returns tickers that haven't been synced today.
     * Also ensures ticker_metadata entries exist for all tickers.
     */
    getTickersNeedingHistoricalSync: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            tickers: {
                ticker: string;
                isin: string | null;
            }[];
            totalWithSymbol: number;
        };
        meta: object;
    }>;
    /**
     * Check if a specific asset needs historical sync.
     */
    needsHistoricalSync: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: {
            needsSync: boolean;
            reason: string;
        };
        meta: object;
    }>;
    /**
     * Get intraday prices for an asset (from cache).
     * Returns 5-minute interval data for the last 5 days.
     */
    getIntradayPrices: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: {
            isin: string;
            ticker: string;
            candles: import("../../oracle/historical").IntradayPriceRecord[];
        };
        meta: object;
    }>;
    /**
     * Sync intraday data for an asset from Yahoo Finance.
     * Fetches 5-day data with 5-minute intervals.
     * Purges data older than 5 days.
     */
    syncIntradayData: import("@trpc/server").TRPCMutationProcedure<{
        input: {
            isin: string;
        };
        output: {
            isin: string;
            ticker: string;
            candlesUpserted: number;
            candlesPurged: number;
        };
        meta: object;
    }>;
    /**
     * Check if a specific asset needs intraday sync.
     * Returns true if not synced in the last 5 minutes.
     */
    needsIntradaySync: import("@trpc/server").TRPCQueryProcedure<{
        input: {
            isin: string;
        };
        output: {
            needsSync: boolean;
            reason: string;
        };
        meta: object;
    }>;
    /**
     * Get list of tickers that need intraday sync.
     * Returns tickers that haven't been synced in the last 5 minutes.
     * Also ensures ticker_metadata entries exist for all tickers.
     */
    getTickersNeedingIntradaySync: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            tickers: {
                ticker: string;
                isin: string | null;
            }[];
            totalWithSymbol: number;
        };
        meta: object;
    }>;
    /**
     * Get current sync status
     */
    getSyncStatus: import("@trpc/server").TRPCQueryProcedure<{
        input: void;
        output: {
            isSyncing: boolean;
        };
        meta: object;
    }>;
    /**
     * Trigger a price sync job manually.
     * Returns immediately - sync runs in background.
     * Progress is pushed via WebSocket subscription.
     */
    triggerPriceSync: import("@trpc/server").TRPCMutationProcedure<{
        input: void;
        output: {
            started: boolean;
            reason?: string;
        };
        meta: object;
    }>;
    /**
     * Subscribe to real-time server events (price updates, sync progress).
     * Events are pushed when:
     * - A price is updated (from cron job or manual refresh)
     * - Sync job starts/progresses/completes
     */
    onEvent: import("node_modules/@trpc/server/dist/unstable-core-do-not-import.d-CjQPvBRI.mjs").LegacyObservableSubscriptionProcedure<{
        input: void;
        output: ServerEvent;
        meta: object;
    }>;
}>>;
