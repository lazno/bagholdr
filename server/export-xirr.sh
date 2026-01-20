#!/bin/bash
# Export XIRR data using sqlite3 CLI (no Node.js required)

DB="$(dirname "$0")/bagholdr.db"
TODAY=$(date +%Y-%m-%d)

echo "================================================================================"
echo "XIRR VERIFICATION DATA - $(date)"
echo "================================================================================"
echo ""

# Portfolio summary
echo "PORTFOLIO SUMMARY"
echo "-----------------"
sqlite3 -header -column "$DB" "
SELECT
  date(MIN(order_date), 'unixepoch') as first_order,
  date(MAX(order_date), 'unixepoch') as last_order,
  replace(printf('%.2f', SUM(CASE WHEN quantity > 0 THEN total_eur WHEN quantity < 0 THEN -total_eur ELSE 0 END)), '.', ',') as total_invested
FROM orders WHERE quantity != 0;
"

echo ""
echo "Current portfolio value:"
sqlite3 -header -column "$DB" "
SELECT replace(printf('%.2f', SUM(h.quantity * p.price_eur)), '.', ',') as current_value
FROM holdings h
JOIN assets a ON h.asset_isin = a.isin
JOIN price_cache p ON a.yahoo_symbol = p.ticker
WHERE h.quantity > 0;
"

echo ""
echo "================================================================================"
echo "GOOGLE SHEETS FORMAT - Copy below into columns A and B, then use =XIRR(A:A,B:B)"
echo "================================================================================"
echo ""
echo "Amount	Date"

sqlite3 -separator "	" "$DB" "
SELECT
  replace(printf('%.2f', -SUM(CASE WHEN quantity > 0 THEN total_eur WHEN quantity < 0 THEN -total_eur ELSE 0 END)), '.', ','),
  date(order_date, 'unixepoch')
FROM orders
WHERE quantity != 0
GROUP BY date(order_date, 'unixepoch')
ORDER BY date(order_date, 'unixepoch');
"

# End value
ENDVAL=$(sqlite3 "$DB" "SELECT replace(printf('%.2f', SUM(h.quantity * p.price_eur)), '.', ',') FROM holdings h JOIN assets a ON h.asset_isin = a.isin JOIN price_cache p ON a.yahoo_symbol = p.ticker WHERE h.quantity > 0;")
echo "$ENDVAL	$TODAY"

echo ""
echo "================================================================================"
echo "PER-ASSET DATA"
echo "================================================================================"

sqlite3 -header -column "$DB" "
SELECT
  a.ticker,
  replace(printf('%.2f', h.quantity * p.price_eur), '.', ',') as current_value,
  replace(printf('%.2f', SUM(CASE WHEN o.quantity > 0 THEN o.total_eur ELSE 0 END)), '.', ',') as total_bought,
  replace(printf('%.2f', h.quantity * p.price_eur - SUM(CASE WHEN o.quantity > 0 THEN o.total_eur WHEN o.quantity < 0 THEN -o.total_eur ELSE 0 END)), '.', ',') as profit
FROM holdings h
JOIN assets a ON h.asset_isin = a.isin
JOIN price_cache p ON a.yahoo_symbol = p.ticker
LEFT JOIN orders o ON o.asset_isin = a.isin AND o.quantity != 0
WHERE h.quantity > 0
GROUP BY a.isin
ORDER BY h.quantity * p.price_eur DESC;
"

echo ""
echo "================================================================================"
echo "PER-SLEEVE DATA"
echo "================================================================================"

sqlite3 -header -column "$DB" "
SELECT
  s.name as sleeve,
  replace(printf('%.2f', SUM(h.quantity * p.price_eur)), '.', ',') as current_value,
  COUNT(DISTINCT a.isin) as assets
FROM sleeves s
JOIN sleeve_assets sa ON s.id = sa.sleeve_id
JOIN assets a ON sa.asset_isin = a.isin
JOIN holdings h ON h.asset_isin = a.isin
JOIN price_cache p ON a.yahoo_symbol = p.ticker
WHERE h.quantity > 0
GROUP BY s.id
ORDER BY SUM(h.quantity * p.price_eur) DESC;
"
