/**
 * Dump orders and holdings from SQLite for golden-source testing
 * Usage: npx tsx scripts/dump-orders-holdings.ts
 */

import { drizzle } from 'drizzle-orm/better-sqlite3';
import Database from 'better-sqlite3';
import { orders, holdings } from '../src/db/schema';
import * as fs from 'fs';
import * as path from 'path';

const dbPath = path.join(import.meta.dirname, '../bagholdr.db');
const sqlite = new Database(dbPath);
const db = drizzle(sqlite);

async function main() {
	// Fetch all orders
	const allOrders = await db.select().from(orders);
	console.log(`Found ${allOrders.length} orders`);

	// Fetch all holdings
	const allHoldings = await db.select().from(holdings);
	console.log(`Found ${allHoldings.length} holdings`);

	// Format orders for Dart test
	const ordersForDart = allOrders.map((o) => ({
		assetIsin: o.assetIsin,
		orderDate: o.orderDate.toISOString(),
		quantity: o.quantity,
		totalEur: o.totalEur,
		totalNative: o.totalNative
	}));

	// Format holdings for comparison
	const holdingsForDart = allHoldings.map((h) => ({
		assetIsin: h.assetIsin,
		quantity: h.quantity,
		totalCostEur: h.totalCostEur
	}));

	// Sort for consistent comparison
	holdingsForDart.sort((a, b) => a.assetIsin.localeCompare(b.assetIsin));

	const output = {
		orders: ordersForDart,
		expectedHoldings: holdingsForDart
	};

	// Write to file
	const outputPath = path.join(
		import.meta.dirname,
		'../../native/bagholdr/bagholdr_server/test/fixtures/golden_source_orders_holdings.json'
	);

	// Ensure fixtures directory exists
	fs.mkdirSync(path.dirname(outputPath), { recursive: true });

	fs.writeFileSync(outputPath, JSON.stringify(output, null, 2));
	console.log(`Written to ${outputPath}`);

	// Also print summary
	console.log('\nOrders summary:');
	const ordersByIsin = new Map<string, number>();
	for (const o of allOrders) {
		ordersByIsin.set(o.assetIsin, (ordersByIsin.get(o.assetIsin) || 0) + 1);
	}
	for (const [isin, count] of ordersByIsin) {
		console.log(`  ${isin}: ${count} orders`);
	}

	console.log('\nHoldings summary:');
	for (const h of allHoldings) {
		console.log(`  ${h.assetIsin}: qty=${h.quantity}, costEur=${h.totalCostEur.toFixed(2)}`);
	}

	sqlite.close();
}

main().catch(console.error);
