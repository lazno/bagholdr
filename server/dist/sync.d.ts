/**
 * Sync Module
 *
 * Manages background sync jobs for prices and historical data.
 * Provides a lock to prevent concurrent syncs.
 */
export declare function getSyncStatus(): {
    isSyncing: boolean;
};
/**
 * Price sync job - refreshes current prices and intraday data
 */
export declare function runPriceSyncJob(): Promise<void>;
/**
 * Trigger price sync manually. Returns immediately, sync runs in background.
 * This also syncs historical and intraday data for assets that need it.
 */
export declare function triggerPriceSync(): {
    started: boolean;
    reason?: string;
};
