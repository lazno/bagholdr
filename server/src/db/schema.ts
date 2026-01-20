import { sqliteTable, text, integer, real, primaryKey } from 'drizzle-orm/sqlite-core';

// =============================================================================
// GLOBAL TABLES (shared across all portfolios)
// =============================================================================

/**
 * Assets - Financial instruments identified by ISIN
 */
export const assets = sqliteTable('assets', {
	isin: text('isin').primaryKey(),
	ticker: text('ticker').notNull(), // Broker's ticker symbol (from import)
	name: text('name').notNull(),
	description: text('description'),
	assetType: text('asset_type', { enum: ['stock', 'etf', 'bond', 'fund', 'commodity', 'other'] }).notNull(),
	currency: text('currency').notNull(),
	metadata: text('metadata', { mode: 'json' }).$type<AssetMetadata | null>(),
	// Yahoo Finance symbol - resolved from ISIN, used for price fetching
	yahooSymbol: text('yahoo_symbol'),
	// Archived assets are excluded from all calculations and dashboard views
	archived: integer('archived', { mode: 'boolean' }).notNull().default(false)
});

/**
 * Orders - Raw imported orders from CSV (audit trail)
 * Global, not per-portfolio
 */
export const orders = sqliteTable('orders', {
	id: text('id').primaryKey(),
	assetIsin: text('asset_isin')
		.notNull()
		.references(() => assets.isin),
	orderDate: integer('order_date', { mode: 'timestamp' }).notNull(),
	quantity: real('quantity').notNull(), // Positive=buy, negative=sell
	priceNative: real('price_native').notNull(),
	totalNative: real('total_native').notNull(),
	totalEur: real('total_eur').notNull(),
	currency: text('currency').notNull(),
	orderReference: text('order_reference'),
	importedAt: integer('imported_at', { mode: 'timestamp' }).notNull()
});

/**
 * Holdings - Derived from orders, represents current positions
 * Global, not per-portfolio
 */
export const holdings = sqliteTable('holdings', {
	id: text('id').primaryKey(),
	assetIsin: text('asset_isin')
		.notNull()
		.references(() => assets.isin)
		.unique(),
	quantity: real('quantity').notNull(),
	totalCostEur: real('total_cost_eur').notNull()
});

/**
 * GlobalCash - Cash balance (global, like holdings)
 * Single row table storing total cash in EUR
 */
export const globalCash = sqliteTable('global_cash', {
	id: text('id').primaryKey().default('default'), // Always 'default' - single row
	amountEur: real('amount_eur').notNull().default(0),
	updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull()
});

// =============================================================================
// PORTFOLIO-SPECIFIC TABLES
// =============================================================================

/**
 * Portfolios - Configuration/strategy containers
 * Each portfolio organizes the same global holdings differently
 * Cash is now global (see globalCash table)
 */
export const portfolios = sqliteTable('portfolios', {
	id: text('id').primaryKey(),
	name: text('name').notNull(),
	// Band configuration (portfolio-level, applies to all sleeves)
	// See src/lib/utils/bands.ts for calculation details
	bandRelativeTolerance: real('band_relative_tolerance').notNull().default(20),
	bandAbsoluteFloor: real('band_absolute_floor').notNull().default(2),
	bandAbsoluteCap: real('band_absolute_cap').notNull().default(10),
	createdAt: integer('created_at', { mode: 'timestamp' }).notNull(),
	updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull()
});

/**
 * Sleeves - Hierarchical groupings of assets with budget targets
 * Portfolio-specific
 */
export const sleeves = sqliteTable('sleeves', {
	id: text('id').primaryKey(),
	portfolioId: text('portfolio_id')
		.notNull()
		.references(() => portfolios.id, { onDelete: 'cascade' }),
	parentSleeveId: text('parent_sleeve_id'), // null = root sleeve
	name: text('name').notNull(),
	budgetPercent: real('budget_percent').notNull(),
	sortOrder: integer('sort_order').notNull().default(0),
	isCash: integer('is_cash', { mode: 'boolean' }).notNull().default(false)
});

/**
 * SleeveAssets - Asset assignments to sleeves
 * An asset can be in different sleeves across different portfolios
 */
export const sleeveAssets = sqliteTable(
	'sleeve_assets',
	{
		sleeveId: text('sleeve_id')
			.notNull()
			.references(() => sleeves.id, { onDelete: 'cascade' }),
		assetIsin: text('asset_isin')
			.notNull()
			.references(() => assets.isin)
	},
	(table) => [primaryKey({ columns: [table.sleeveId, table.assetIsin] })]
);

/**
 * PortfolioRules - Flexible rule system for portfolio constraints
 * Each rule has a type and JSON config for type-specific settings
 *
 * Rule types:
 * - concentration_limit: No single asset (optionally filtered by assetType) > X%
 *   Config: { maxPercent: number, assetTypes?: ('stock' | 'etf' | 'bond' | 'fund' | 'other')[] }
 *
 * Future rule types could include:
 * - sector_limit: No single sector > X%
 * - region_limit: No single region > X%
 * - min_diversification: Must have at least N assets
 */
export const portfolioRules = sqliteTable('portfolio_rules', {
	id: text('id').primaryKey(),
	portfolioId: text('portfolio_id')
		.notNull()
		.references(() => portfolios.id, { onDelete: 'cascade' }),
	ruleType: text('rule_type').notNull(), // 'concentration_limit', etc.
	name: text('name').notNull(), // User-friendly name, e.g., "Single stock limit"
	config: text('config', { mode: 'json' }).$type<PortfolioRuleConfig>().notNull(),
	enabled: integer('enabled', { mode: 'boolean' }).notNull().default(true),
	createdAt: integer('created_at', { mode: 'timestamp' }).notNull()
});

// =============================================================================
// YAHOO FINANCE SYMBOL RESOLUTION
// =============================================================================

/**
 * YahooSymbols - All available Yahoo Finance symbols for an ISIN
 * Yahoo search returns multiple exchanges; we store all and let user pick preferred
 */
export const yahooSymbols = sqliteTable('yahoo_symbols', {
	id: text('id').primaryKey(),
	assetIsin: text('asset_isin')
		.notNull()
		.references(() => assets.isin, { onDelete: 'cascade' }),
	symbol: text('symbol').notNull(), // e.g., "WGLD.MI", "WGLD.L"
	exchange: text('exchange'), // e.g., "MIL", "LSE"
	exchangeDisplay: text('exchange_display'), // e.g., "Milan Stock Exchange"
	quoteType: text('quote_type'), // e.g., "ETF", "EQUITY"
	resolvedAt: integer('resolved_at', { mode: 'timestamp' }).notNull()
});

// =============================================================================
// CACHE TABLES
// =============================================================================

/**
 * PriceCache - Cached price data from Yahoo Finance
 */
export const priceCache = sqliteTable('price_cache', {
	ticker: text('ticker').primaryKey(),
	priceNative: real('price_native').notNull(),
	currency: text('currency').notNull(),
	priceEur: real('price_eur').notNull(),
	fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});

/**
 * FxCache - Cached FX rates
 */
export const fxCache = sqliteTable('fx_cache', {
	pair: text('pair').primaryKey(), // e.g., "USDEUR"
	rate: real('rate').notNull(),
	fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});

// =============================================================================
// HISTORICAL PRICE DATA
// =============================================================================

/**
 * DailyPrices - Historical daily OHLCV data from Yahoo Finance
 * Used for charting and performance calculations
 */
export const dailyPrices = sqliteTable('daily_prices', {
	id: text('id').primaryKey(), // `${ticker}_${YYYY-MM-DD}`
	ticker: text('ticker').notNull(), // Yahoo symbol
	date: text('date').notNull(), // YYYY-MM-DD format
	open: real('open').notNull(),
	high: real('high').notNull(),
	low: real('low').notNull(),
	close: real('close').notNull(),
	adjClose: real('adj_close').notNull(),
	volume: integer('volume').notNull(),
	currency: text('currency').notNull(),
	fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});

/**
 * DividendEvents - Dividend payouts from Yahoo Finance
 * Track dividend history for notification and analysis
 */
export const dividendEvents = sqliteTable('dividend_events', {
	id: text('id').primaryKey(), // `${ticker}_${YYYY-MM-DD}`
	ticker: text('ticker').notNull(), // Yahoo symbol
	exDate: text('ex_date').notNull(), // YYYY-MM-DD (date you must own by)
	amount: real('amount').notNull(),
	currency: text('currency').notNull(),
	fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});

/**
 * TickerMetadata - Sync state tracking per ticker
 * Used to determine when historical data needs refresh
 */
export const tickerMetadata = sqliteTable('ticker_metadata', {
	ticker: text('ticker').primaryKey(), // Yahoo symbol
	lastDailyDate: text('last_daily_date'), // YYYY-MM-DD of most recent daily candle
	lastSyncedAt: integer('last_synced_at', { mode: 'timestamp' }), // When we last fetched daily data from Yahoo
	lastIntradaySyncedAt: integer('last_intraday_synced_at', { mode: 'timestamp' }), // When we last fetched intraday data
	isActive: integer('is_active', { mode: 'boolean' }).notNull().default(true)
});

/**
 * IntradayPrices - 5-minute interval OHLCV data from Yahoo Finance
 * Stores last 5 days of intraday data for detailed charting
 * Older data is automatically purged during sync
 */
export const intradayPrices = sqliteTable('intraday_prices', {
	id: text('id').primaryKey(), // `${ticker}_${timestamp}` where timestamp is Unix seconds
	ticker: text('ticker').notNull(), // Yahoo symbol
	timestamp: integer('timestamp').notNull(), // Unix timestamp in seconds
	open: real('open').notNull(),
	high: real('high').notNull(),
	low: real('low').notNull(),
	close: real('close').notNull(),
	volume: integer('volume').notNull(),
	currency: text('currency').notNull(),
	fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});

// =============================================================================
// TYPE DEFINITIONS
// =============================================================================

export type AssetMetadata = {
	holdings?: Array<{ isin?: string; name: string; weight: number }>;
	sectors?: Array<{ name: string; weight: number }>;
	factors?: Array<{ name: string; score: number }>;
};

// Asset type enum (matches schema)
export type AssetType = 'stock' | 'etf' | 'bond' | 'fund' | 'commodity' | 'other';

// Portfolio rule config types
export type ConcentrationLimitConfig = {
	maxPercent: number;
	assetTypes?: AssetType[]; // If undefined/empty, applies to all assets
};

// Union type for all rule configs (extend as we add more rule types)
export type PortfolioRuleConfig = ConcentrationLimitConfig;

// Inferred types from schema
export type Asset = typeof assets.$inferSelect;
export type NewAsset = typeof assets.$inferInsert;
export type Order = typeof orders.$inferSelect;
export type NewOrder = typeof orders.$inferInsert;
export type Holding = typeof holdings.$inferSelect;
export type NewHolding = typeof holdings.$inferInsert;
export type Portfolio = typeof portfolios.$inferSelect;
export type NewPortfolio = typeof portfolios.$inferInsert;
export type Sleeve = typeof sleeves.$inferSelect;
export type NewSleeve = typeof sleeves.$inferInsert;
export type SleeveAsset = typeof sleeveAssets.$inferSelect;
export type NewSleeveAsset = typeof sleeveAssets.$inferInsert;
export type PortfolioRule = typeof portfolioRules.$inferSelect;
export type NewPortfolioRule = typeof portfolioRules.$inferInsert;
export type PriceCacheEntry = typeof priceCache.$inferSelect;
export type FxCacheEntry = typeof fxCache.$inferSelect;
export type YahooSymbol = typeof yahooSymbols.$inferSelect;
export type NewYahooSymbol = typeof yahooSymbols.$inferInsert;
export type DailyPrice = typeof dailyPrices.$inferSelect;
export type NewDailyPrice = typeof dailyPrices.$inferInsert;
export type DividendEvent = typeof dividendEvents.$inferSelect;
export type NewDividendEvent = typeof dividendEvents.$inferInsert;
export type TickerMeta = typeof tickerMetadata.$inferSelect;
export type NewTickerMeta = typeof tickerMetadata.$inferInsert;
export type IntradayPrice = typeof intradayPrices.$inferSelect;
export type NewIntradayPrice = typeof intradayPrices.$inferInsert;
