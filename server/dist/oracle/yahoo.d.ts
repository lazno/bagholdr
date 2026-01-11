/**
 * Yahoo Finance API Client
 *
 * Provides:
 * - ISIN to ticker symbol resolution
 * - Price fetching (current)
 * - Historical price fetching (daily candles)
 * - FX rate fetching
 * - Dividend event fetching
 *
 * All requests go through a global rate limiter to avoid hitting Yahoo's limits.
 */
export interface YahooPriceInfo {
    price: number;
    currency: string;
    instrumentType: string;
    timestamp: Date;
}
export interface YahooSearchResult {
    symbol: string;
    exchange?: string;
    exchangeDisplay?: string;
    quoteType?: string;
    shortname?: string;
}
export interface YahooCandle {
    date: string;
    open: number;
    high: number;
    low: number;
    close: number;
    adjClose: number;
    volume: number;
}
export interface YahooDividend {
    exDate: string;
    amount: number;
}
export interface YahooHistoricalData {
    candles: YahooCandle[];
    dividends: YahooDividend[];
    currency: string;
}
export interface YahooIntradayCandle {
    timestamp: number;
    open: number;
    high: number;
    low: number;
    close: number;
    volume: number;
}
export interface YahooIntradayData {
    candles: YahooIntradayCandle[];
    currency: string;
}
export declare class YahooFinanceError extends Error {
    readonly code: string;
    constructor(message: string, code: string);
}
/**
 * Resolve ISIN to all available Yahoo Finance symbols
 * Returns all exchanges where this ISIN is available
 */
export declare function fetchAllSymbolsFromIsin(isin: string): Promise<YahooSearchResult[]>;
/**
 * Resolve ISIN to Yahoo Finance ticker symbol (first/best match)
 */
export declare function fetchSymbolFromIsin(isin: string): Promise<string>;
/**
 * Fetch current price data for a ticker symbol
 */
export declare function fetchPriceData(symbol: string): Promise<YahooPriceInfo>;
/**
 * Fetch historical daily price data for a ticker symbol
 *
 * @param symbol - Yahoo Finance ticker symbol
 * @param range - Time range: '1y', '5y', '10y', or 'max' (default: '10y')
 *
 * Note: Yahoo automatically downsamples to monthly data for very long ranges.
 * Using '10y' instead of 'max' ensures we get daily granularity for most instruments.
 * If you need more history, use 'max' but be aware the granularity may be monthly.
 *
 * @returns Historical candles and dividend events
 */
export declare function fetchHistoricalData(symbol: string, range?: '1y' | '5y' | '10y' | 'max'): Promise<YahooHistoricalData>;
/**
 * Fetch intraday price data (5-minute intervals) for a ticker symbol
 *
 * @param symbol - Yahoo Finance ticker symbol
 * @param range - Time range: '1d', '5d' (default: '5d' for 5 days of data)
 * @returns Intraday candles with timestamps
 */
export declare function fetchIntradayData(symbol: string, range?: '1d' | '5d'): Promise<YahooIntradayData>;
/**
 * Fetch FX rate from one currency to another
 * Uses Yahoo Finance forex pairs (e.g., USDEUR=X)
 */
export declare function fetchFxRate(from: string, to: string): Promise<number>;
/**
 * Adjust conversion rate for special cases like GBp (pence)
 */
export declare function adjustConversionRate(currency: string, rate: number): number;
/**
 * Fetch price in EUR for an asset
 * Handles ISIN resolution and FX conversion
 */
export declare function fetchPriceInEur(isin: string, knownTicker?: string): Promise<{
    ticker: string;
    priceNative: number;
    currency: string;
    priceEur: number;
    instrumentType: string;
}>;
