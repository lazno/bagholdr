/**
 * Export SQLite data to JSON for migration to Serverpod/PostgreSQL
 *
 * Run: npx tsx src/migration/export-to-json.ts
 * Output: migration-export.json
 */

import Database from 'better-sqlite3';
import { writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DB_PATH = join(__dirname, '../../bagholdr.db');
const OUTPUT_PATH = join(__dirname, '../../migration-export.json');

interface MigrationExport {
	exportedAt: string;
	tables: {
		portfolios: PortfolioRow[];
		assets: AssetRow[];
		sleeves: SleeveRow[];
		holdings: HoldingRow[];
		orders: OrderRow[];
		sleeveAssets: SleeveAssetRow[];
		globalCash: GlobalCashRow[];
		dailyPrices: DailyPriceRow[];
		yahooSymbols: YahooSymbolRow[];
		portfolioRules: PortfolioRuleRow[];
		priceCache: PriceCacheRow[];
		fxCache: FxCacheRow[];
		tickerMetadata: TickerMetadataRow[];
		dividendEvents: DividendEventRow[];
		intradayPrices: IntradayPriceRow[];
	};
	counts: Record<string, number>;
}

// Row types matching SQLite schema
interface PortfolioRow {
	id: string;
	name: string;
	band_relative_tolerance: number;
	band_absolute_floor: number;
	band_absolute_cap: number;
	created_at: number; // Unix timestamp
	updated_at: number;
}

interface AssetRow {
	isin: string;
	ticker: string;
	name: string;
	description: string | null;
	asset_type: string;
	currency: string;
	metadata: string | null; // JSON string
	yahoo_symbol: string | null;
	archived: number; // 0 or 1
}

interface SleeveRow {
	id: string;
	portfolio_id: string;
	parent_sleeve_id: string | null;
	name: string;
	budget_percent: number;
	sort_order: number;
	is_cash: number; // 0 or 1
}

interface HoldingRow {
	id: string;
	asset_isin: string;
	quantity: number;
	total_cost_eur: number;
}

interface OrderRow {
	id: string;
	asset_isin: string;
	order_date: number; // Unix timestamp
	quantity: number;
	price_native: number;
	total_native: number;
	total_eur: number;
	currency: string;
	order_reference: string | null;
	imported_at: number; // Unix timestamp
}

interface SleeveAssetRow {
	sleeve_id: string;
	asset_isin: string;
}

interface GlobalCashRow {
	id: string;
	amount_eur: number;
	updated_at: number; // Unix timestamp
}

interface DailyPriceRow {
	id: string;
	ticker: string;
	date: string; // YYYY-MM-DD
	open: number;
	high: number;
	low: number;
	close: number;
	adj_close: number;
	volume: number;
	currency: string;
	fetched_at: number; // Unix timestamp
}

interface YahooSymbolRow {
	id: string;
	asset_isin: string;
	symbol: string;
	exchange: string | null;
	exchange_display: string | null;
	quote_type: string | null;
	resolved_at: number; // Unix timestamp
}

interface PortfolioRuleRow {
	id: string;
	portfolio_id: string;
	rule_type: string;
	name: string;
	config: string; // JSON string
	enabled: number; // 0 or 1
	created_at: number; // Unix timestamp
}

interface PriceCacheRow {
	ticker: string;
	price_native: number;
	currency: string;
	price_eur: number;
	fetched_at: number; // Unix timestamp
}

interface FxCacheRow {
	pair: string;
	rate: number;
	fetched_at: number; // Unix timestamp
}

interface TickerMetadataRow {
	ticker: string;
	last_daily_date: string | null;
	last_synced_at: number | null;
	last_intraday_synced_at: number | null;
	is_active: number; // 0 or 1
}

interface DividendEventRow {
	id: string;
	ticker: string;
	ex_date: string;
	amount: number;
	currency: string;
	fetched_at: number; // Unix timestamp
}

interface IntradayPriceRow {
	id: string;
	ticker: string;
	timestamp: number;
	open: number;
	high: number;
	low: number;
	close: number;
	volume: number;
	currency: string;
	fetched_at: number; // Unix timestamp
}

function main() {
	console.log('Opening SQLite database:', DB_PATH);
	const db = new Database(DB_PATH, { readonly: true });

	const exportData: MigrationExport = {
		exportedAt: new Date().toISOString(),
		tables: {
			portfolios: [],
			assets: [],
			sleeves: [],
			holdings: [],
			orders: [],
			sleeveAssets: [],
			globalCash: [],
			dailyPrices: [],
			yahooSymbols: [],
			portfolioRules: [],
			priceCache: [],
			fxCache: [],
			tickerMetadata: [],
			dividendEvents: [],
			intradayPrices: []
		},
		counts: {}
	};

	// Export each table
	const tableQueries: [keyof MigrationExport['tables'], string][] = [
		['portfolios', 'SELECT * FROM portfolios'],
		['assets', 'SELECT * FROM assets'],
		['sleeves', 'SELECT * FROM sleeves ORDER BY portfolio_id, sort_order'],
		['holdings', 'SELECT * FROM holdings'],
		['orders', 'SELECT * FROM orders ORDER BY order_date'],
		['sleeveAssets', 'SELECT * FROM sleeve_assets'],
		['globalCash', 'SELECT * FROM global_cash'],
		['dailyPrices', 'SELECT * FROM daily_prices'],
		['yahooSymbols', 'SELECT * FROM yahoo_symbols'],
		['portfolioRules', 'SELECT * FROM portfolio_rules'],
		['priceCache', 'SELECT * FROM price_cache'],
		['fxCache', 'SELECT * FROM fx_cache'],
		['tickerMetadata', 'SELECT * FROM ticker_metadata'],
		['dividendEvents', 'SELECT * FROM dividend_events'],
		['intradayPrices', 'SELECT * FROM intraday_prices']
	];

	for (const [tableName, query] of tableQueries) {
		try {
			const rows = db.prepare(query).all();
			(exportData.tables[tableName] as unknown[]) = rows;
			exportData.counts[tableName] = rows.length;
			console.log(`  ${tableName}: ${rows.length} rows`);
		} catch (error) {
			console.log(`  ${tableName}: table does not exist or is empty`);
			exportData.counts[tableName] = 0;
		}
	}

	db.close();

	// Write to file
	console.log('\nWriting to:', OUTPUT_PATH);
	writeFileSync(OUTPUT_PATH, JSON.stringify(exportData, null, 2));

	console.log('\nExport complete!');
	console.log('Summary:');
	for (const [table, count] of Object.entries(exportData.counts)) {
		console.log(`  ${table}: ${count}`);
	}
}

main();
