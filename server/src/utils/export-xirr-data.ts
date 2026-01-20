/**
 * Export XIRR Data for Google Sheets Verification
 *
 * Run with: npx tsx server/src/utils/export-xirr-data.ts
 *
 * Outputs CSV-formatted data for:
 * 1. Each individual asset
 * 2. Each sleeve
 * 3. Whole portfolio
 */

import Database from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dbPath = path.resolve(__dirname, '../../bagholdr.db');

const db = new Database(dbPath);
const today = new Date().toISOString().split('T')[0];

// Get all assets with current values
const assets = db.prepare(`
  SELECT
    a.isin,
    a.ticker,
    a.name,
    h.quantity,
    p.price_eur,
    h.quantity * p.price_eur as current_value
  FROM assets a
  JOIN holdings h ON a.isin = h.asset_isin
  JOIN price_cache p ON a.yahoo_symbol = p.ticker
  WHERE h.quantity > 0
  ORDER BY current_value DESC
`).all() as Array<{
  isin: string;
  ticker: string;
  name: string;
  quantity: number;
  price_eur: number;
  current_value: number;
}>;

// Get sleeve assignments
const sleeveAssets = db.prepare(`
  SELECT
    sa.asset_isin,
    sa.sleeve_id,
    s.name as sleeve_name
  FROM sleeve_assets sa
  JOIN sleeves s ON sa.sleeve_id = s.id
`).all() as Array<{
  asset_isin: string;
  sleeve_id: string;
  sleeve_name: string;
}>;

const assetToSleeve = new Map<string, { id: string; name: string }>();
for (const sa of sleeveAssets) {
  assetToSleeve.set(sa.asset_isin, { id: sa.sleeve_id, name: sa.sleeve_name });
}

// Get all orders
const orders = db.prepare(`
  SELECT
    asset_isin,
    date(order_date, 'unixepoch') as date,
    quantity,
    total_eur
  FROM orders
  WHERE quantity != 0
  ORDER BY order_date
`).all() as Array<{
  asset_isin: string;
  date: string;
  quantity: number;
  total_eur: number;
}>;

// Get sleeves
const sleeves = db.prepare(`
  SELECT id, name FROM sleeves ORDER BY name
`).all() as Array<{ id: string; name: string }>;

// ============================================================
// SECTION 1: PER-ASSET XIRR DATA
// ============================================================

console.log('='.repeat(80));
console.log('SECTION 1: PER-ASSET XIRR DATA');
console.log('='.repeat(80));
console.log('');
console.log('Copy each asset\'s data to Google Sheets, then use =XIRR(A:A, B:B)');
console.log('');

for (const asset of assets) {
  const assetOrders = orders.filter(o => o.asset_isin === asset.isin);
  if (assetOrders.length === 0) continue;

  const sleeve = assetToSleeve.get(asset.isin);

  console.log('-'.repeat(80));
  console.log(`ASSET: ${asset.ticker} (${asset.name})`);
  console.log(`Sleeve: ${sleeve?.name || 'Unassigned'}`);
  console.log(`Current Value: €${asset.current_value.toFixed(2)}`);
  console.log('');
  console.log('Amount\tDate\tDescription');

  let totalCashIn = 0;
  for (const order of assetOrders) {
    // For XIRR: buys are negative (money out), sells are positive (money in)
    const amount = order.quantity > 0 ? -order.total_eur : order.total_eur;
    const type = order.quantity > 0 ? 'BUY' : 'SELL';
    console.log(`${amount.toFixed(2)}\t${order.date}\t${type}`);
    totalCashIn += order.quantity > 0 ? order.total_eur : -order.total_eur;
  }

  // End value (positive - money received if you "sold")
  console.log(`${asset.current_value.toFixed(2)}\t${today}\tEND VALUE`);

  const profit = asset.current_value - totalCashIn;
  console.log('');
  console.log(`Total Invested: €${totalCashIn.toFixed(2)}`);
  console.log(`Current Value: €${asset.current_value.toFixed(2)}`);
  console.log(`Profit: €${profit.toFixed(2)} (${((profit / totalCashIn) * 100).toFixed(1)}%)`);
  console.log('');
}

// ============================================================
// SECTION 2: PER-SLEEVE XIRR DATA
// ============================================================

console.log('');
console.log('='.repeat(80));
console.log('SECTION 2: PER-SLEEVE XIRR DATA');
console.log('='.repeat(80));
console.log('');

for (const sleeve of sleeves) {
  // Get all assets in this sleeve
  const sleeveAssetIsins = Array.from(assetToSleeve.entries())
    .filter(([_, s]) => s.id === sleeve.id)
    .map(([isin, _]) => isin);

  if (sleeveAssetIsins.length === 0) continue;

  // Get orders for these assets
  const sleeveOrders = orders
    .filter(o => sleeveAssetIsins.includes(o.asset_isin))
    .sort((a, b) => a.date.localeCompare(b.date));

  if (sleeveOrders.length === 0) continue;

  // Get current value for this sleeve
  const sleeveValue = assets
    .filter(a => sleeveAssetIsins.includes(a.isin))
    .reduce((sum, a) => sum + a.current_value, 0);

  // Get assets in sleeve
  const sleeveAssetTickers = assets
    .filter(a => sleeveAssetIsins.includes(a.isin))
    .map(a => a.ticker);

  console.log('-'.repeat(80));
  console.log(`SLEEVE: ${sleeve.name}`);
  console.log(`Assets: ${sleeveAssetTickers.join(', ')}`);
  console.log(`Current Value: €${sleeveValue.toFixed(2)}`);
  console.log('');
  console.log('Amount\tDate\tDescription');

  // Group orders by date for cleaner output
  const ordersByDate = new Map<string, number>();
  for (const order of sleeveOrders) {
    const amount = order.quantity > 0 ? -order.total_eur : order.total_eur;
    ordersByDate.set(order.date, (ordersByDate.get(order.date) || 0) + amount);
  }

  let totalCashIn = 0;
  for (const [date, amount] of Array.from(ordersByDate.entries()).sort()) {
    const type = amount < 0 ? 'NET BUY' : 'NET SELL';
    console.log(`${amount.toFixed(2)}\t${date}\t${type}`);
    totalCashIn -= amount; // Negate back to get cash in
  }

  // End value
  console.log(`${sleeveValue.toFixed(2)}\t${today}\tEND VALUE`);

  const profit = sleeveValue - totalCashIn;
  console.log('');
  console.log(`Total Invested: €${totalCashIn.toFixed(2)}`);
  console.log(`Current Value: €${sleeveValue.toFixed(2)}`);
  console.log(`Profit: €${profit.toFixed(2)} (${((profit / totalCashIn) * 100).toFixed(1)}%)`);
  console.log('');
}

// ============================================================
// SECTION 3: WHOLE PORTFOLIO XIRR DATA
// ============================================================

console.log('');
console.log('='.repeat(80));
console.log('SECTION 3: WHOLE PORTFOLIO XIRR DATA');
console.log('='.repeat(80));
console.log('');

// Group all orders by date
const portfolioOrdersByDate = new Map<string, number>();
for (const order of orders) {
  const amount = order.quantity > 0 ? -order.total_eur : order.total_eur;
  portfolioOrdersByDate.set(order.date, (portfolioOrdersByDate.get(order.date) || 0) + amount);
}

const portfolioValue = assets.reduce((sum, a) => sum + a.current_value, 0);

console.log(`Total Portfolio Value: €${portfolioValue.toFixed(2)}`);
console.log(`Number of Assets: ${assets.length}`);
console.log('');
console.log('Amount\tDate\tDescription');

let portfolioCashIn = 0;
for (const [date, amount] of Array.from(portfolioOrdersByDate.entries()).sort()) {
  const type = amount < 0 ? 'NET BUY' : 'NET SELL';
  console.log(`${amount.toFixed(2)}\t${date}\t${type}`);
  portfolioCashIn -= amount;
}

// End value
console.log(`${portfolioValue.toFixed(2)}\t${today}\tEND VALUE`);

const portfolioProfit = portfolioValue - portfolioCashIn;
console.log('');
console.log(`Total Invested: €${portfolioCashIn.toFixed(2)}`);
console.log(`Current Value: €${portfolioValue.toFixed(2)}`);
console.log(`Profit: €${portfolioProfit.toFixed(2)} (${((portfolioProfit / portfolioCashIn) * 100).toFixed(1)}%)`);

// ============================================================
// SECTION 4: COPY-PASTE FORMAT FOR GOOGLE SHEETS
// ============================================================

console.log('');
console.log('='.repeat(80));
console.log('SECTION 4: GOOGLE SHEETS COPY-PASTE FORMAT (Portfolio)');
console.log('='.repeat(80));
console.log('');
console.log('Copy the data below (Amount and Date columns) directly into Google Sheets:');
console.log('Then use formula: =XIRR(A:A, B:B)');
console.log('');
console.log('Amount\tDate');

for (const [date, amount] of Array.from(portfolioOrdersByDate.entries()).sort()) {
  console.log(`${amount.toFixed(2)}\t${date}`);
}
console.log(`${portfolioValue.toFixed(2)}\t${today}`);

console.log('');
console.log('Expected XIRR result: ~15.1% (annualized)');

db.close();
