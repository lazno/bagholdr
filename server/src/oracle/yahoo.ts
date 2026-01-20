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

import { YAHOO_SEARCH_URL, YAHOO_CHART_URL } from '../config';
import { yahooRateLimiter } from './rateLimiter';

// =============================================================================
// Types
// =============================================================================

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
	date: string; // YYYY-MM-DD
	open: number;
	high: number;
	low: number;
	close: number;
	adjClose: number;
	volume: number;
}

export interface YahooDividend {
	exDate: string; // YYYY-MM-DD
	amount: number;
}

export interface YahooHistoricalData {
	candles: YahooCandle[];
	dividends: YahooDividend[];
	currency: string;
}

export interface YahooIntradayCandle {
	timestamp: number; // Unix timestamp in seconds
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

export class YahooFinanceError extends Error {
	constructor(
		message: string,
		public readonly code: string
	) {
		super(message);
		this.name = 'YahooFinanceError';
	}
}

// =============================================================================
// Internal Helpers
// =============================================================================

/**
 * Rate-limited fetch wrapper
 */
async function rateLimitedFetch(url: string): Promise<Response> {
	return yahooRateLimiter.enqueue(async () => {
		const response = await fetch(url, {
			headers: {
				'User-Agent': 'Bagholdr/1.0',
				Accept: 'application/json'
			}
		});
		return response;
	});
}

/**
 * Convert Unix timestamp (seconds) to YYYY-MM-DD string
 */
function timestampToDate(timestamp: number): string {
	const date = new Date(timestamp * 1000);
	return date.toISOString().split('T')[0];
}

// =============================================================================
// Symbol Resolution
// =============================================================================

/**
 * Resolve ISIN to all available Yahoo Finance symbols
 * Returns all exchanges where this ISIN is available
 */
export async function fetchAllSymbolsFromIsin(isin: string): Promise<YahooSearchResult[]> {
	const url = `${YAHOO_SEARCH_URL}?q=${encodeURIComponent(isin)}&newsCount=0&listsCount=0&quotesCount=20&quotesQueryId=tss_match_phrase_query`;

	const response = await rateLimitedFetch(url);

	if (response.status === 403) {
		throw new YahooFinanceError('Rate limited by Yahoo Finance', 'RATE_LIMITED');
	}

	if (!response.ok) {
		throw new YahooFinanceError(
			`HTTP error fetching symbol: ${response.status}`,
			'HTTP_ERROR'
		);
	}

	const data = await response.json();

	if (!data.quotes || data.quotes.length === 0) {
		throw new YahooFinanceError(`No symbol found for ISIN: ${isin}`, 'NOT_FOUND');
	}

	return data.quotes.map((q: Record<string, unknown>) => ({
		symbol: q.symbol as string,
		exchange: q.exchange as string | undefined,
		exchangeDisplay: q.exchDisp as string | undefined,
		quoteType: q.quoteType as string | undefined,
		shortname: q.shortname as string | undefined
	}));
}

/**
 * Resolve ISIN to Yahoo Finance ticker symbol (first/best match)
 */
export async function fetchSymbolFromIsin(isin: string): Promise<string> {
	const symbols = await fetchAllSymbolsFromIsin(isin);
	return symbols[0].symbol;
}

// =============================================================================
// Current Price
// =============================================================================

/**
 * Fetch current price data for a ticker symbol
 */
export async function fetchPriceData(symbol: string): Promise<YahooPriceInfo> {
	const url = `${YAHOO_CHART_URL}/${encodeURIComponent(symbol)}`;

	const response = await rateLimitedFetch(url);

	if (response.status === 403) {
		throw new YahooFinanceError('Rate limited by Yahoo Finance', 'RATE_LIMITED');
	}

	if (!response.ok) {
		throw new YahooFinanceError(
			`HTTP error fetching price: ${response.status}`,
			'HTTP_ERROR'
		);
	}

	const data = await response.json();

	if (!data.chart?.result?.[0]?.meta) {
		throw new YahooFinanceError(`No price data found for: ${symbol}`, 'NOT_FOUND');
	}

	const meta = data.chart.result[0].meta;

	return {
		price: meta.regularMarketPrice,
		currency: meta.currency,
		instrumentType: meta.instrumentType ?? 'unknown',
		timestamp: new Date()
	};
}

// =============================================================================
// Historical Data
// =============================================================================

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
export async function fetchHistoricalData(
	symbol: string,
	range: '1y' | '5y' | '10y' | 'max' = '10y'
): Promise<YahooHistoricalData> {
	// Fetch daily candles with dividend events
	const url = `${YAHOO_CHART_URL}/${encodeURIComponent(symbol)}?interval=1d&range=${range}&events=div`;

	const response = await rateLimitedFetch(url);

	if (response.status === 403) {
		throw new YahooFinanceError('Rate limited by Yahoo Finance', 'RATE_LIMITED');
	}

	if (response.status === 404) {
		throw new YahooFinanceError(`Ticker not found: ${symbol}`, 'NOT_FOUND');
	}

	if (!response.ok) {
		throw new YahooFinanceError(
			`HTTP error fetching historical data: ${response.status}`,
			'HTTP_ERROR'
		);
	}

	const data = await response.json();

	if (!data.chart?.result?.[0]) {
		throw new YahooFinanceError(`No historical data found for: ${symbol}`, 'NOT_FOUND');
	}

	const result = data.chart.result[0];
	const meta = result.meta;

	// Warn if Yahoo returned a different granularity than requested (1d)
	const actualGranularity = meta.dataGranularity;
	if (actualGranularity && actualGranularity !== '1d') {
		console.warn(
			`[Yahoo] ${symbol}: Requested daily data but got ${actualGranularity} granularity. ` +
				`Consider using a shorter range (current: ${range}). Got ${result.timestamp?.length ?? 0} data points.`
		);
	}

	const timestamps: number[] = result.timestamp ?? [];
	const quote = result.indicators?.quote?.[0] ?? {};
	const adjClose = result.indicators?.adjclose?.[0]?.adjclose ?? [];
	const events = result.events ?? {};

	// Parse candles
	const candles: YahooCandle[] = [];
	for (let i = 0; i < timestamps.length; i++) {
		// Skip if any required value is null/undefined
		if (
			quote.open?.[i] == null ||
			quote.high?.[i] == null ||
			quote.low?.[i] == null ||
			quote.close?.[i] == null ||
			adjClose[i] == null
		) {
			continue;
		}

		candles.push({
			date: timestampToDate(timestamps[i]),
			open: quote.open[i],
			high: quote.high[i],
			low: quote.low[i],
			close: quote.close[i],
			adjClose: adjClose[i],
			volume: quote.volume?.[i] ?? 0
		});
	}

	// Parse dividends
	const dividends: YahooDividend[] = [];
	if (events.dividends) {
		for (const [timestamp, div] of Object.entries(events.dividends)) {
			const dividend = div as { amount?: number; date?: number };
			if (dividend.amount != null) {
				dividends.push({
					exDate: timestampToDate(parseInt(timestamp)),
					amount: dividend.amount
				});
			}
		}
	}

	// Sort dividends by date
	dividends.sort((a, b) => a.exDate.localeCompare(b.exDate));

	return {
		candles,
		dividends,
		currency: meta.currency ?? 'USD'
	};
}

/**
 * Fetch intraday price data (5-minute intervals) for a ticker symbol
 *
 * @param symbol - Yahoo Finance ticker symbol
 * @param range - Time range: '1d', '5d' (default: '5d' for 5 days of data)
 * @returns Intraday candles with timestamps
 */
export async function fetchIntradayData(
	symbol: string,
	range: '1d' | '5d' = '5d'
): Promise<YahooIntradayData> {
	// Fetch 5-minute candles
	const url = `${YAHOO_CHART_URL}/${encodeURIComponent(symbol)}?interval=5m&range=${range}&includePrePost=false`;

	const response = await rateLimitedFetch(url);

	if (response.status === 403) {
		throw new YahooFinanceError('Rate limited by Yahoo Finance', 'RATE_LIMITED');
	}

	if (response.status === 404) {
		throw new YahooFinanceError(`Ticker not found: ${symbol}`, 'NOT_FOUND');
	}

	if (!response.ok) {
		throw new YahooFinanceError(
			`HTTP error fetching intraday data: ${response.status}`,
			'HTTP_ERROR'
		);
	}

	const data = await response.json();

	if (!data.chart?.result?.[0]) {
		throw new YahooFinanceError(`No intraday data found for: ${symbol}`, 'NOT_FOUND');
	}

	const result = data.chart.result[0];
	const meta = result.meta;
	const timestamps: number[] = result.timestamp ?? [];
	const quote = result.indicators?.quote?.[0] ?? {};

	// Parse candles
	const candles: YahooIntradayCandle[] = [];
	for (let i = 0; i < timestamps.length; i++) {
		// Skip if any required value is null/undefined
		if (
			quote.open?.[i] == null ||
			quote.high?.[i] == null ||
			quote.low?.[i] == null ||
			quote.close?.[i] == null
		) {
			continue;
		}

		candles.push({
			timestamp: timestamps[i],
			open: quote.open[i],
			high: quote.high[i],
			low: quote.low[i],
			close: quote.close[i],
			volume: quote.volume?.[i] ?? 0
		});
	}

	return {
		candles,
		currency: meta.currency ?? 'USD'
	};
}

// =============================================================================
// FX Rates
// =============================================================================

/**
 * Fetch FX rate from one currency to another
 * Uses Yahoo Finance forex pairs (e.g., USDEUR=X)
 */
export async function fetchFxRate(from: string, to: string): Promise<number> {
	// Normalize currency codes
	const fromUpper = from.toUpperCase();
	const toUpper = to.toUpperCase();

	// If same currency, rate is 1
	if (fromUpper === toUpper) {
		return 1;
	}

	// Handle GBp (pence) -> GBP conversion
	const actualFrom = fromUpper === 'GBP' ? 'GBP' : fromUpper;

	const symbol = `${actualFrom}${toUpper}=X`;
	const priceInfo = await fetchPriceData(symbol);

	let rate = priceInfo.price;

	// Special handling for GBp (British pence)
	// Yahoo returns the rate for GBP, but prices might be in pence
	if (from.toLowerCase() === 'gbp' && from !== 'GBP') {
		// Original was lowercase 'gbp' meaning pence
		rate = rate / 100;
	}

	return rate;
}

/**
 * Adjust conversion rate for special cases like GBp (pence)
 */
export function adjustConversionRate(currency: string, rate: number): number {
	// GBp (pence) - prices are in pence but FX is for pounds
	if (currency === 'GBp') {
		return rate / 100;
	}
	return rate;
}

// =============================================================================
// Convenience Functions
// =============================================================================

/**
 * Fetch price in EUR for an asset
 * Handles ISIN resolution and FX conversion
 */
export async function fetchPriceInEur(isin: string, knownTicker?: string): Promise<{
	ticker: string;
	priceNative: number;
	currency: string;
	priceEur: number;
	instrumentType: string;
}> {
	// Resolve ISIN to ticker if not provided
	const ticker = knownTicker ?? (await fetchSymbolFromIsin(isin));

	// Fetch price in native currency
	const priceInfo = await fetchPriceData(ticker);

	// Convert to EUR if needed
	let priceEur: number;
	if (priceInfo.currency === 'EUR') {
		priceEur = priceInfo.price;
	} else {
		const fxRate = await fetchFxRate(priceInfo.currency, 'EUR');
		const adjustedRate = adjustConversionRate(priceInfo.currency, fxRate);
		priceEur = priceInfo.price * adjustedRate;
	}

	return {
		ticker,
		priceNative: priceInfo.price,
		currency: priceInfo.currency,
		priceEur,
		instrumentType: priceInfo.instrumentType
	};
}
