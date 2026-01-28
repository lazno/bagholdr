# Native App - Completed Tasks

Archive of completed tasks from the Native App Implementation Plan.

> **Active plan**: See `native-app-plan.md` for pending tasks.

---

## Phase 0: Environment Setup

### NAPP-001: Development Environment Setup `[setup]` - DONE

Flutter 3.38.7, Dart 3.10.7, Android SDK 36.1.0, Serverpod CLI 3.2.3 installed and configured.

---

## Phase 1: Project Scaffolding

### NAPP-002: Initialize Serverpod Project `[implement]` - DONE

Scaffolded `native/bagholdr/`, Docker + Serverpod, start/stop scripts with --help, emulator + web screenshots, platform-aware server URL.

### NAPP-003: Mobile UI Exploration `[design]` - DONE

Decided: drawer navigation, light theme, single scrolling page layout, ring chart + detail panel for strategy, sleeve pills for filtering.

**Final Mockup**: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

### NAPP-004: Design System & Theme `[implement]` - DONE

Created theme.dart with seed-based ColorScheme, colors.dart with FinancialColors ThemeExtension + categoryPalette for dynamic categories, formatters.dart for currency/percent/XIRR formatting, theme toggle.

---

## Phase 2: Core Data Model

### NAPP-005: Portfolio Model `[implement]` - DONE

`portfolio.spy.yaml` with UUID v7 PK; fields: name, bandRelativeTolerance/Floor/Cap, createdAt/updatedAt.

### NAPP-006: Asset Model `[implement]` - DONE

`asset.spy.yaml` + `asset_type.spy.yaml` with UUID v7 PK and AssetType enum; fields: isin, ticker, name, description, assetType, currency, yahooSymbol, archived; unique index on isin.

### NAPP-007: Sleeve Model `[implement]` - DONE

`sleeve.spy.yaml` with UUID v7 PK; fields: portfolioId (UUID relation), parentSleeveId (UUID), name, budgetPercent, sortOrder, isCash; index on portfolioId.

### NAPP-008: Holding Model `[implement]` - DONE

`holding.spy.yaml` with UUID v7 PK; fields: assetId (UUID relation to assets), quantity, totalCostEur; unique index on assetId.

### NAPP-009: Order Model `[implement]` - DONE

`order.spy.yaml` with UUID v7 PK; fields: assetId (UUID relation to assets), orderDate, quantity, priceNative, totalNative, totalEur, currency, orderReference, importedAt; index on assetId.

### NAPP-010: DailyPrice Model `[implement]` - DONE

`daily_price.spy.yaml` with UUID v7 PK; fields: ticker, date (YYYY-MM-DD), open, high, low, close, adjClose, volume, currency, fetchedAt; unique composite index on ticker+date.

### NAPP-010a: SleeveAssets Model `[implement]` - DONE

`sleeve_asset.spy.yaml` with UUID v7 PK; fields: sleeveId, assetId (UUID relations); unique composite index for many-to-many relationship.

### NAPP-010b: GlobalCash Model `[implement]` - DONE

`global_cash.spy.yaml` with UUID v7 PK; fields: cashId, amountEur, updatedAt; unique index on cashId.

### NAPP-010c: PortfolioRules Model `[implement]` - DONE

`portfolio_rule.spy.yaml` with UUID v7 PK; fields: portfolioId (UUID relation), ruleType, name, config (JSON), enabled, createdAt; index on portfolioId.

### NAPP-010d: YahooSymbols Model `[implement]` - DONE

`yahoo_symbol.spy.yaml` with UUID v7 PK; fields: assetId (UUID relation), symbol, exchange, exchangeDisplay, quoteType, resolvedAt; indexes on assetId and symbol.

### NAPP-010e: PriceCache Model `[implement]` - DONE

`price_cache.spy.yaml` with UUID v7 PK; fields: ticker, priceNative, currency, priceEur, fetchedAt; unique index on ticker.

### NAPP-010f: FxCache Model `[implement]` - DONE

`fx_cache.spy.yaml` with UUID v7 PK; fields: pair, rate, fetchedAt; unique index on pair.

### NAPP-010g: DividendEvents Model `[implement]` - DONE

`dividend_event.spy.yaml` with UUID v7 PK; fields: ticker, exDate, amount, currency, fetchedAt; unique composite index on ticker+exDate.

### NAPP-010h: TickerMetadata Model `[implement]` - DONE

`ticker_metadata.spy.yaml` with UUID v7 PK; fields: ticker, lastDailyDate, lastSyncedAt, lastIntradaySyncedAt, isActive; unique index on ticker.

### NAPP-010i: IntradayPrices Model `[implement]` - DONE

`intraday_price.spy.yaml` with UUID v7 PK; fields: ticker, timestamp, open, high, low, close, volume, currency, fetchedAt; unique composite index on ticker+timestamp.

### NAPP-011: Database Migration `[implement]` - DONE

Serverpod migration for all 15 tables; TypeScript export script; Dart import script; migrated 2 portfolios, 28 assets, 5 sleeves, 20 holdings, 161 orders, 40190 daily prices; all FK relationships verified.

---

## Phase 3: Features (Vertical Slices)

### NAPP-012: Portfolio List Endpoint `[implement]` - DONE

`portfolio_endpoint.dart` with getPortfolios() returning all portfolios ordered by name.

### NAPP-013: Portfolio Selector Component `[implement]` - DONE

`widgets/portfolio_selector.dart` - dropdown with bottom sheet for portfolio selection, matches mockup header design.

### NAPP-013a: Time Range Bar Component `[implement]` - DONE

`widgets/time_range_bar.dart` - 6 equal-width period buttons with TimePeriod enum, active/inactive styling matching mockup, default 1Y selection.

### NAPP-013b: Hero Value Display Component `[implement]` - DONE

`hero_value_display.dart` - displays invested value, MWR % (green/red), TWR % (grey), absolute return, cash, total; supports hideBalances mode; 6 tests passing.

### NAPP-013c: Issues Bar Component `[implement]` - DONE

`issues_bar.dart` - collapsible yellow bar with badge count, expand/collapse animation, issue items with colored dots and action text; 11 unit tests; integrated into dashboard; verified on web and mobile.

### NAPP-014: Research Valuation Logic `[research]` - DONE

Documented 3 endpoints: getPortfolioValuation, getChartData, getHistoricalReturns; core calculations: portfolio value, cost basis via Average Cost Method, MWR/XIRR returns, recursive sleeve totals, band evaluation; 5 helper functions to port; edge cases documented; XIRR dependency identified.

### NAPP-015: Port Valuation Endpoint `[port]` - DONE

Ported from TypeScript: portfolio value, cost basis via Average Cost Method, asset valuations, sleeve allocations, MWR/TWR calculations, band evaluation; returns PortfolioValuation with all fields.

**Known issues**:
- 1M has 1-day comparison date difference vs TypeScript
- ALL period missing from response (needs debugging)

### NAPP-017: Holdings Endpoint `[implement]` - DONE

`holdings_endpoint.dart` - getHoldings() with pagination, sleeve/search filtering, MWR/TWR per asset; HoldingResponse with all required fields; 7 unit tests.

### NAPP-018: Holdings/Assets List UI `[implement]` - DONE

`assets_section.dart` - section header with title/count badge, search bar, horizontally scrollable 3-column table with Asset/Performance/Weight columns, pagination button; 16 unit tests.

### NAPP-020: Sleeves Endpoint `[implement]` - DONE

`sleeves_endpoint.dart` - getSleeveTree() returning SleeveTreeResponse with hierarchical SleeveNode tree; calculates allocation percentages, drift status, MWR/TWR per sleeve; 11 unit tests; end-to-end tested.

### NAPP-021: Sleeves/Strategy UI `[implement]` - DONE

`ring_chart.dart` - two concentric donut rings with sleeve hierarchy; `sleeve_detail_panel.dart` - shows selected sleeve details with allocation metrics; `sleeve_pills.dart` - horizontal scrollable pills; selection syncs across all three widgets.

### NAPP-022: Issues Endpoint `[implement]` - DONE

`issues_endpoint.dart` - getIssues() returning IssuesResponse with Issue list; detects over/under allocation drift, stale prices (24h threshold), sync status; 15 unit tests; end-to-end tested.

### NAPP-023: Chart Feature `[implement]` - DONE

Portfolio value chart for Hero section with fl_chart; area chart with gradient fill, value line (green) and cost basis line (dashed grey); getPortfolioHistory() endpoint; period selector integration.

### NAPP-023b: Research Yahoo Price Oracle `[research]` - DONE

Documented Yahoo Finance API integration: Search endpoint for ISIN→ticker resolution, Chart endpoint for prices; rate limiter with 2s delay for ~1800 req/hr; cache.ts for TTL-based price/FX caching; historical.ts for daily/intraday sync; 20+ functions identified for porting.

### NAPP-024: Port Price Oracle `[port]` - DONE

Ported Yahoo Finance price oracle to Dart: `rate_limiter.dart` (queue-based singleton with 2s delay), `yahoo.dart` (symbol resolution, price/historical/intraday/FX fetching, GBp handling), `cache.dart` (TTL-based price/FX cache with Serverpod DB), `historical.dart` (daily/intraday sync, ticker metadata management). 17 unit tests + 6 integration tests against live Yahoo API.

### NAPP-100: Fix Performance Metrics Calculation `[implement]` - DONE

Fixed "short holding" detection for MWR/TWR calculations when assets/sleeves are acquired after comparison date.

### NAPP-016: Dashboard Screen Assembly & Polish `[implement]` - DONE

Fixed pie chart tap detection (center X offset when chart shrinks), details panel overflow for 100%→100% allocation (FittedBox), and chart state reset on portfolio switch (didUpdateWidget).

### NAPP-025: Real-time Prices (Serverpod Streaming) `[implement]` - DONE

Real-time price updates via Serverpod method streaming (WebSocket). PriceSyncService runs every 5 min: syncs current prices, historical candles, intraday data, and FX pair history for non-EUR currencies. PriceStreamEndpoint broadcasts updates to connected clients. Flutter PriceStreamProvider with auto-reconnect (10s delay), ConnectionIndicator widget, asset row highlight animation. Valuation endpoint uses date-specific historical FX rates for accurate TWR/chart calculations.

### NAPP-034: Assign Asset to Sleeve `[implement]` - DONE

Assign/unassign assets to sleeves from asset detail page. Backend: `getSleevesForPicker(portfolioId)` returns flat list with hierarchy depth, `assignAssetToSleeve(assetId, sleeveId)` handles assign/unassign. Frontend: `_SleevePickerDialog` with hierarchical list + "Unassigned" option, loading states, success feedback. 3 unit tests.

---

## Research Deliverables

### Valuation Logic Summary

**Formulas & concepts**: See [specs/calculus-spec.md](calculus-spec.md) for all financial calculations (cost basis, MWR/XIRR, bands, etc.)

**Source code**: `server/src/trpc/routers/valuation.ts`

#### Endpoints Ported

| Endpoint | Purpose | Powers |
|----------|---------|--------|
| `getPortfolioValuation` | Full valuation with sleeve hierarchy, band violations, health issues | Hero section, Strategy section |
| `getChartData` | Historical invested value + cost basis series (1m/3m/6m/1y/all) | Portfolio chart |
| `getHistoricalReturns` | MWR returns by period + per-asset returns | Return displays, asset list |

#### Response Types Ported

| Type | Key Fields |
|------|------------|
| `AssetValuation` | isin, ticker, name, quantity, priceEur, costBasisEur, valueEur, percentOfInvested |
| `SleeveAllocation` | sleeveId, sleeveName, parentSleeveId, budgetPercent, totalValueEur, actualPercentInvested, band, status, deltaPercent |
| `PortfolioValuation` | portfolioId, cashEur, investedValueEur, totalValueEur, totalCostBasisEur, sleeves[], bandConfig, violationCount, stalePriceAssets[], lastSyncAt |
| `ChartDataPoint` | date, investedValue, costBasis |
| `PeriodReturn` | period, currentValue, startValue, absoluteReturn, compoundedReturn, annualizedReturn, periodYears, netCashFlow |
| `AssetPeriodReturn` | isin, currentPrice, historicalPrice, compoundedReturn, annualizedReturn, isShortHolding |

#### Helper Functions Ported

| Function | Purpose |
|----------|---------|
| `calculateSleeveTotal` | Recursive sleeve value including descendants |
| `calculateMWR` | XIRR calculation with cash flows |
| `calculateTWR` | TWR calculation for portfolio performance |
| `formatPeriodLabel` | Format years as "1d", "2w", "3mo", "1.5y" |
| `calculateBand` / `evaluateStatus` | Band width and status calculation |

#### XIRR Implementation

Newton-Raphson algorithm ported to Dart. Solves for rate `r` where `Σ CFᵢ × (1+r)^(-tᵢ) = 0`.

---

### Yahoo Oracle Summary

**Source files**: `server/src/oracle/yahoo.ts`, `rateLimiter.ts`, `cache.ts`, `historical.ts`

#### API Endpoints Used

| Endpoint | URL | Purpose |
|----------|-----|---------|
| Search | `https://query1.finance.yahoo.com/v1/finance/search` | ISIN to ticker symbol resolution |
| Chart | `https://query1.finance.yahoo.com/v8/finance/chart/{symbol}` | Price data (current, historical, intraday) |

#### Rate Limiting Strategy

- **Global singleton** `YahooRateLimiter` class ensures all requests go through one queue
- **Sequential processing** with minimum 2-second delay between requests
- **Throughput**: ~30 requests/min = 1800/hour

#### Functions to Port

**From yahoo.ts**:
- `fetchAllSymbolsFromIsin(isin)` - Resolve ISIN to all available Yahoo symbols
- `fetchSymbolFromIsin(isin)` - Resolve ISIN to best Yahoo symbol
- `fetchPriceData(symbol)` - Fetch current price
- `fetchHistoricalData(symbol, range)` - Fetch daily candles + dividends
- `fetchIntradayData(symbol, range)` - Fetch 5-minute candles
- `fetchFxRate(from, to)` - Fetch FX rate via forex pairs
- `fetchPriceInEur(isin, knownTicker?)` - Convenience: fetch + convert to EUR

**From rateLimiter.ts**:
- `YahooRateLimiter` - Queue-based rate limiter with configurable delay

**From cache.ts**:
- `getPrice(db, isin, yahooSymbol, forceRefresh?)` - Get price from cache or fetch fresh
- `getFxRate(db, from, to)` - Get FX rate from cache or fetch fresh

**From historical.ts**:
- `syncHistoricalData(db, ticker)` - Fetch 10y daily data, upsert to DB
- `syncIntradayData(db, ticker)` - Fetch 5d 5-minute data
- `needsHistoricalSync(db, ticker)` - Check if daily sync needed

#### Special Cases

1. **GBp (British pence)**: Prices from Yahoo are in pence, but FX rates are for GBP. Divide by 100 when currency is 'GBp'.
2. **Historical granularity**: Using range='10y' ensures daily granularity.
3. **Intraday data retention**: Prices older than 5 days are automatically purged during sync.

---

### NAPP-026: Research Directa Parser `[research]` - DONE

Documented Directa CSV format, field mapping, holdings derivation logic.

#### Directa CSV Format

- **Header**: First 10 lines are metadata. Line 1 contains account name (`ACCOUNT : C6766 Lazzeri Norbert`). Line 10 is the column header row.
- **Data**: Starts at line 11. Each row has 12 comma-separated fields. Quoted fields are supported.
- **Date format**: `DD-MM-YYYY` (Italian format), converted to ISO `YYYY-MM-DD` during parsing.
- **Numbers**: Period as decimal separator (not European comma format).

#### CSV Columns (12 fields)

| # | Field | Maps to |
|---|-------|---------|
| 0 | Transaction date (DD-MM-YYYY) | `transactionDate` (converted to ISO) |
| 1 | Value date | Ignored |
| 2 | Transaction type | `transactionType` (Buy/Sell/Commissions kept, rest skipped) |
| 3 | Ticker | `ticker` |
| 4 | ISIN | `isin` (required for import) |
| 5 | Protocol | Ignored |
| 6 | Description | `name` (asset name) |
| 7 | Quantity | `quantity` (positive=buy, negative=sell, 0=commission) |
| 8 | Amount EUR | `amountEur` (stored as absolute value) |
| 9 | Currency amount | `currencyAmount` (stored as absolute value) |
| 10 | Currency | `currency` (defaults to EUR if empty) |
| 11 | Order reference | `orderReference` |

#### Transaction Types

Only 3 types are imported: `Buy`, `Sell`, `Commissions` (mapped to `Commission`). All other types (taxes, bond coupons, wire transfers, etc.) are skipped and counted in `skippedRows`.

#### Holdings Derivation (Average Cost Method)

Orders are grouped by ISIN and processed chronologically:

1. **Buy** (quantity > 0): Add quantity and cost to running totals
2. **Sell** (quantity < 0): Reduce cost basis proportionally — `costReduction = avgCostPerShare × soldQty`. Average cost per share does NOT change on sells.
3. **Commission** (quantity = 0): Add to cost basis without changing quantity

Only positions with remaining quantity > 0 are included in final holdings.

**Example**: Buy 100 @ €10 (cost=€1000, avg=€10) → Buy 50 @ €14 (cost=€1700, qty=150, avg=€11.33) → Sell 75 (reduce cost by 75×€11.33=€850 → remaining cost=€850, qty=75, avg still €11.33)

#### Functions to Port

**From `directa-parser.ts`**:
- `parseDirectaCSV(content: String) → DirectaParseResult` - Main entry point
- `convertItalianDate(dateStr) → String?` - DD-MM-YYYY to YYYY-MM-DD
- `extractAccountName(headerLine) → String?` - Parse account from header
- `parseCSVLine(line) → List<String>` - Handle quoted CSV fields
- `parseNumber(value) → double` - String to number
- `isImportableTransaction(type) → bool` - Filter Buy/Sell/Commissions
- `mapTransactionType(type) → String` - Commissions → Commission

**From `derive-holdings.ts`**:
- `deriveHoldings(orders: List<Order>) → List<DerivedHolding>` - Average cost calculation
- `toNewHoldings(derived) → List<NewHolding>` - Convert to DB format (uses nanoid → use UUID v7 in Dart)

#### Types to Create

```dart
class DirectaRow {
  String transactionDate; // ISO
  String transactionType;
  String ticker;
  String isin;
  String name;
  int quantity;
  double amountEur;
  double currencyAmount;
  String currency;
  String orderReference;
}

class DirectaParseResult {
  String accountName;
  List<ParsedOrder> orders;
  int skippedRows;
  List<ParseError> errors;
}

class DerivedHolding {
  String assetIsin;
  double quantity;
  double totalCostEur;
  double totalCostNative;
}
```

---

### NAPP-102: Add Total Return % Metric `[implement]` - DONE

Added `totalReturn` field to holdings, sleeves, and period returns. Formula: `(currentValue + sellProceeds) / (buyCosts + fees) - 1`. Sub-period variant uses startValue + orders in period.

### NAPP-027: Port Directa Parser `[port]` - DONE

Ported Directa CSV parser and holdings derivation to Dart:
- `directa_parser.dart` - CSV parsing with Italian date conversion, quoted field handling, transaction type filtering (Buy/Sell/Commissions)
- `derive_holdings.dart` - Average Cost Method implementation for holdings derivation
- 45 unit tests + 2 golden-source integration tests
- Verified output matches TypeScript exactly against 161 real orders → 20 holdings

### NAPP-028: Import Endpoint `[implement]` - DONE

Created Serverpod endpoint for importing Directa CSV:
- `ImportEndpoint.importDirectaCsv(csvContent)` - parses CSV, creates assets, inserts orders, derives holdings
- Skips duplicate orders by `orderReference`
- Returns `ImportResult` with counts (ordersImported, assetsCreated, holdingsUpdated) and errors/warnings
- 9 integration tests verifying full database flow

### NAPP-029: Settings `[implement]` - DONE

Added bottom navigation and settings screen:
- `app_shell.dart` - Bottom navigation with Dashboard and Settings tabs
- `settings_screen.dart` - Theme toggle (light/dark/system), privacy mode, server URL, connection status, about
- Moved connection indicator from AppBar to Settings (cloud icons)
- Moved portfolio selector next to time range bar
- Global `hideBalances` ValueNotifier for privacy mode sync across screens

### NAPP-032: Edit Yahoo Symbol `[implement]` - DONE

Edit Yahoo symbol for assets from asset detail page:
- `updateYahooSymbol(assetId, newSymbol)` endpoint in `HoldingsEndpoint`
- Clears `DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata`, `PriceCache` for old symbol
- Text input dialog in asset detail screen with loading state
- 7 unit tests for `UpdateYahooSymbolResult` serialization

### NAPP-035: Refresh Asset Prices `[implement]` - DONE

Trigger price refresh for single asset from asset detail action menu:
- `refreshAssetPrices(assetId)` endpoint in `HoldingsEndpoint` - fetches fresh price via oracle with `forceRefresh: true`
- Returns `RefreshPriceResult` with success/error status, ticker, priceEur, currency, fetchedAt
- "Refresh prices" menu item in asset detail screen with loading state
- Success snackbar shows new price, error snackbar on failure
- 7 unit tests for `RefreshPriceResult` serialization

### NAPP-040: Move Strategy Section to Dedicated Page `[implement]` - DONE

Moved Strategy section from Dashboard to dedicated page with bottom navigation:
- `strategy_screen.dart` - Dedicated page with StrategySectionV2, portfolio selector, time range bar
- Added Strategy tab to bottom navigation (pie chart icon)
- Removed Strategy section from Dashboard (portfolio_list_screen.dart)
- Removed sleeve filtering from Dashboard assets - sleeve selection is now local to Strategy page
- Dashboard shows hero values, chart, and assets list only

### NAPP-019: Asset Detail `[implement]` - DONE

Full-screen asset detail page with comprehensive information:
- `getAssetDetail(assetId, portfolioId, period)` endpoint in `HoldingsEndpoint`
- Asset info: name, ISIN, type badge
- Position summary: value, quantity, unrealized P/L, realized P/L, TWR, MWR, cost basis, total return
- Editable fields: Yahoo symbol, asset type, sleeve assignment
- Order history: full list with date, type, quantity, price, total
- Actions menu: refresh prices, clear history (stub), archive (stub)
- Live price updates via SSE subscription

### NAPP-043: Bottom Navigation Visual Separation `[implement]` - DONE

Added top border to bottom navigation bar for visual separation from content:
- Wrapped `NavigationBar` in `Container` with top border decoration
- Used `colorScheme.outlineVariant` for theme-adaptive border color

### NAPP-033: Edit Asset Type `[implement]` - DONE

Edit asset type (ETF, Stock, Bond, etc.) from asset detail page:
- `updateAssetType(assetId, newType)` endpoint in `HoldingsEndpoint`
- Validates type against `AssetType` enum values
- Picker dialog with all 6 asset type options
- Loading state and success feedback
- 4 unit tests for `UpdateAssetTypeResult` serialization
- 7 integration tests verifying end-to-end endpoint functionality

### NAPP-038: Add Portfolio Weight to Asset Detail `[implement]` - DONE

Display asset's portfolio weight in position summary:
- Backend already had `weight` field in `AssetDetailResponse` (value / total portfolio * 100)
- Added weight display next to share count: "15 shares · 12.50% of portfolio"
- Weight updates live with price changes

### NAPP-043: Remove Page Titles from Main Screens `[implement]` - DONE

Removed redundant AppBars from Dashboard, Strategy, and Settings screens:
- Page names already shown in bottom navigation, no need for title bars
- Removed privacy mode buttons from Dashboard/Strategy (accessible via Settings)
- Added SafeArea wrappers to ensure proper spacing on notched devices
- Asset detail screen still has AppBar (shows dynamic asset name + action menu)

### NAPP-044: Fix Search Box Focus Behavior `[implement]` - DONE

Fixed keyboard auto-opening when returning to dashboard from asset detail:
- Wrapped dashboard body in `GestureDetector` with `HitTestBehavior.translucent` to dismiss keyboard on tap outside search
- Added managed `FocusNode` to search bar, unfocus in `.then()` after `Navigator.push()` returns to prevent Flutter's focus restoration from reopening keyboard

### NAPP-036: Clear Price History `[implement]` - DONE

Clear all historical price data for an asset (useful when data is corrupted or wrong symbol was used):
- `clearPriceHistory(assetId)` endpoint in `HoldingsEndpoint` - deletes all price data for asset's Yahoo symbol
- Clears `DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata`, `PriceCache` records
- Returns `ClearPriceHistoryResult` with counts of cleared records
- "Clear price history" menu item in asset detail screen with confirmation dialog
- 4 unit tests for result serialization, 3 integration tests for end-to-end verification

### NAPP-045: Configurable Server URL `[implement]` - DONE

Make server URL configurable from Settings page:
- Added `shared_preferences` dependency for persistent storage
- Created `AppSettings` service to manage server URL with validation
- Edit dialog in Settings with URL validation (http/https scheme, valid host)
- Shows current URL as "(default)" or "(custom)" in subtitle
- "Reset to default" option when custom URL is set
- Shows "restart required" message after changes
- 10 unit tests for URL validation

### NAPP-045b: Server URL Setup Screen for Production Builds `[implement]` - DONE

For App Store builds, show setup screen on first launch since there's no sensible default URL:
- Added `SetupServerUrlScreen` shown when `REQUIRE_SERVER_CONFIG=true` and no URL configured
- `initializeClient()` helper allows client recreation without app restart
- Settings dialog now shows current URL, reinitializes client and resets app on save
- Removed confusing "default URL" concept from user-facing UI
- 7 widget tests for setup screen, 2 unit tests for new AppSettings properties
- Build with `flutter build apk --dart-define=REQUIRE_SERVER_CONFIG=true` for production
