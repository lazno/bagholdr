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

### NAPP-100: Fix Performance Metrics Calculation `[implement]` - DONE

Fixed "short holding" detection for MWR/TWR calculations when assets/sleeves are acquired after comparison date.

### NAPP-016: Dashboard Screen Assembly & Polish `[implement]` - DONE

Fixed pie chart tap detection (center X offset when chart shrinks), details panel overflow for 100%→100% allocation (FittedBox), and chart state reset on portfolio switch (didUpdateWidget).

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
