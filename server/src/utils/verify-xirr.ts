/**
 * XIRR Verification Script
 *
 * Run with: npx tsx server/src/utils/verify-xirr.ts
 *
 * This script extracts the same data the dashboard uses and shows
 * the intermediate values so you can verify the XIRR calculation.
 */

import Database from 'better-sqlite3';
import xirr from 'xirr';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const dbPath = path.resolve(__dirname, '../../bagholdr.db');

console.log('='.repeat(60));
console.log('XIRR / MWR Verification Script');
console.log('='.repeat(60));
console.log(`Database: ${dbPath}\n`);

const db = new Database(dbPath);

// Get date range
const dateRange = db.prepare(`
  SELECT
    date(MIN(order_date), 'unixepoch') as first_order,
    date(MAX(order_date), 'unixepoch') as last_order
  FROM orders
`).get() as { first_order: string; last_order: string };

const today = new Date().toISOString().split('T')[0];
console.log(`Period: ${dateRange.first_order} → ${today}`);
console.log(`(Last order in DB: ${dateRange.last_order})\n`);

// Get cash flows by date (only buys and sells, not commissions)
const cashFlows = db.prepare(`
  SELECT
    date(order_date, 'unixepoch') as date,
    SUM(CASE
      WHEN quantity > 0 THEN total_eur
      WHEN quantity < 0 THEN -total_eur
      ELSE 0
    END) as amount
  FROM orders
  WHERE quantity != 0
  GROUP BY date(order_date, 'unixepoch')
  ORDER BY date
`).all() as Array<{ date: string; amount: number }>;

console.log('Cash Flows (Buys are positive, Sells are negative):');
console.log('-'.repeat(40));
let totalCashIn = 0;
for (const cf of cashFlows.slice(0, 10)) {
  console.log(`  ${cf.date}: €${cf.amount.toFixed(2)}`);
  totalCashIn += cf.amount;
}
if (cashFlows.length > 10) {
  console.log(`  ... and ${cashFlows.length - 10} more dates`);
  for (const cf of cashFlows.slice(10)) {
    totalCashIn += cf.amount;
  }
}
console.log('-'.repeat(40));
console.log(`Total Net Cash In: €${totalCashIn.toFixed(2)}\n`);

// Get current portfolio value from price cache (using price_eur which is already converted)
const currentValue = db.prepare(`
  SELECT SUM(h.quantity * p.price_eur) as total_value
  FROM holdings h
  JOIN assets a ON h.asset_isin = a.isin
  JOIN price_cache p ON a.yahoo_symbol = p.ticker
  WHERE h.quantity > 0
`).get() as { total_value: number };

console.log(`Current Portfolio Value: €${currentValue.total_value?.toFixed(2) || 'N/A'}`);

// For "All" period, start value is 0 (nothing before first order)
const startValue = 0;
const endValue = currentValue.total_value || 0;

console.log(`Start Value (before first order): €${startValue.toFixed(2)}`);
console.log(`End Value (today): €${endValue.toFixed(2)}\n`);

// Build XIRR transactions
console.log('XIRR Transactions:');
console.log('-'.repeat(40));

const transactions: Array<{ amount: number; when: Date }> = [];

// Starting value as initial outflow (if any)
if (startValue > 0) {
  transactions.push({
    amount: -startValue,
    when: new Date(dateRange.first_order)
  });
  console.log(`  ${dateRange.first_order}: -€${startValue.toFixed(2)} (start value)`);
}

// Cash flows: buys are negative (money out), sells are positive (money in)
for (const cf of cashFlows) {
  transactions.push({
    amount: -cf.amount, // Negate for XIRR convention
    when: new Date(cf.date)
  });
}
console.log(`  ... ${cashFlows.length} cash flow transactions`);

// Ending value as final inflow
transactions.push({
  amount: endValue,
  when: new Date(today)
});
console.log(`  ${today}: +€${endValue.toFixed(2)} (end value)`);
console.log('-'.repeat(40));

// Calculate period in years
const startDate = new Date(dateRange.first_order);
const endDate = new Date(today);
const periodMs = endDate.getTime() - startDate.getTime();
const periodYears = periodMs / (365.25 * 24 * 60 * 60 * 1000);

console.log(`\nPeriod: ${periodYears.toFixed(3)} years (${Math.round(periodYears * 12)} months)\n`);

// Calculate XIRR
try {
  const annualizedReturn = xirr(transactions);
  const compoundedReturn = Math.pow(1 + annualizedReturn, periodYears) - 1;

  console.log('='.repeat(60));
  console.log('XIRR RESULT:');
  console.log('='.repeat(60));
  console.log(`  Annualized Return: ${(annualizedReturn * 100).toFixed(2)}% p.a.`);
  console.log(`  Compounded Return: ${(compoundedReturn * 100).toFixed(2)}%`);
  console.log('');
  console.log('Verification:');
  console.log(`  (1 + ${(annualizedReturn * 100).toFixed(2)}%)^${periodYears.toFixed(3)} - 1`);
  console.log(`  = ${(compoundedReturn * 100).toFixed(2)}%`);
  console.log('');

  // Calculate absolute return
  const absoluteReturn = endValue - startValue - totalCashIn;
  console.log(`Absolute Return (Profit): €${absoluteReturn.toFixed(2)}`);
  console.log(`  = End Value (€${endValue.toFixed(2)})`);
  console.log(`  - Start Value (€${startValue.toFixed(2)})`);
  console.log(`  - Net Cash In (€${totalCashIn.toFixed(2)})`);

} catch (err) {
  console.log('XIRR failed to converge:', err);

  // Fallback: simple return
  const simpleReturn = (endValue - startValue - totalCashIn) / totalCashIn;
  console.log(`\nFallback - Simple Return: ${(simpleReturn * 100).toFixed(2)}%`);
}

console.log('\n' + '='.repeat(60));
console.log('To verify in Google Sheets/Excel:');
console.log('='.repeat(60));
console.log('1. Enter transactions in column A (amounts) and B (dates)');
console.log('2. Use =XIRR(A:A, B:B) to calculate');
console.log('3. The result should match the Annualized Return above');

db.close();
