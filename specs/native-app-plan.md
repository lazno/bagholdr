# Native App Implementation Plan

Full-stack Dart rebuild of Bagholdr using **Flutter** (frontend) and **Serverpod** (backend). Feature-by-feature vertical slices with shared types.

> **Workflow**: See `ralph.md` for task selection and completion workflow.

### Task Types

| Type | Description |
|------|-------------|
| `[setup]` | Environment/tooling setup (human-assisted) |
| `[research]` | Read & understand existing code (no code changes) |
| `[design]` | Make decisions, create mockups |
| `[implement]` | Write new code from scratch |
| `[port]` | Translate existing TypeScript to Dart |

### Task Status

`[ ]` Not started · `[~]` In progress · `[x]` Done · `[blocked]` Waiting on dependency

---

## Decision Log

### Why Full-Stack Dart?

| Option Considered | Verdict |
|-------------------|---------|
| **Flutter + Keep Hono** | Faster start, but lose type safety at API boundary. Two languages to maintain. |
| **Flutter + Serverpod Mini** | No PostgreSQL needed, but no built-in persistence - would need manual SQLite integration. |
| **Flutter + Serverpod (full)** | ✅ Chosen. Shared types, one language, built-in ORM. PostgreSQL overhead acceptable. |

### Why Serverpod?

- Auto-generates type-safe Flutter client from backend definitions
- Built-in ORM, caching, WebSocket/streaming support
- Made for Flutter, by Flutter developers
- One language (Dart) everywhere

### Why UUID Primary Keys?

| Option Considered | Verdict |
|-------------------|---------|
| **Integer IDs** | Serverpod default, simpler, but less portable and requires server round-trip for ID generation. |
| **UUID v4** | Random, but poor index performance due to non-sequential nature. |
| **UUID v7** | ✅ Chosen. Lexicographically sortable (timestamp-based), good index performance, can generate IDs client-side. |

**Syntax in model files**:
```yaml
fields:
  id: UuidValue?, defaultPersist=random_v7
  foreignKeyId: UuidValue, relation(parent=other_table)
```

**Benefits**:
- Generate IDs client-side without server round-trip
- Better for distributed systems
- Portable across databases
- UUID v7 maintains good index performance (unlike v4)

### Why PostgreSQL (not SQLite)?

Serverpod does not support SQLite ([GitHub discussion #1977](https://github.com/serverpod/serverpod/discussions/1977)). The architecture is prepared for multiple SQL databases, but only PostgreSQL is implemented. Serverpod Mini removes the database requirement entirely but provides no persistence - you'd have to wire up SQLite manually, losing the ORM benefits.

**Decision**: Accept PostgreSQL. Run it via Docker in development. The operational overhead is minimal for a self-hosted personal app.

### Repository Strategy

| Option | Verdict |
|--------|---------|
| **New repository** | Clean separation, but harder to reference existing code during porting. |
| **Same repo, subfolder** | ✅ Chosen. Keep everything together in `native/` subfolder. Easy to reference existing TypeScript code. Dart ecosystem stays isolated. |

**Resulting structure**:
```
backholdr/
├── server/              # Existing Hono backend (keep for validation)
├── src/                 # Existing Svelte frontend
├── native/              # New Flutter + Serverpod
│   ├── bagholdr_server/
│   ├── bagholdr_client/
│   └── bagholdr_flutter/
```

### Architecture

```
┌─────────────────────────────────────┐
│         Flutter App (Dart)          │
│    Auto-generated Serverpod client  │
│                                     │
│  ┌───────────┐ ┌───────────┐       │
│  │  Android  │ │    Web    │  iOS? │
│  └───────────┘ └───────────┘       │
└─────────────────────────────────────┘
                  │
                  │ Type-safe RPC + SSE
                  ▼
┌─────────────────────────────────────┐
│     Serverpod Backend (Dart)        │
│  - Portfolio, Asset, Sleeve models  │
│  - Valuation, Import endpoints      │
│  - SSE for real-time prices         │
│  - PostgreSQL via built-in ORM      │
└─────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│     PostgreSQL (Docker)             │
│  - docker compose up -d             │
│  - Data persists in Docker volume   │
└─────────────────────────────────────┘
```

### Visual Verification

Use Playwright screenshots for both Svelte and Flutter web (see `AGENTS.md` for commands).

**When to use Flutter integration tests**: Only for mobile-specific behavior (gestures, deep links, platform channels, app lifecycle). For most UI verification, web screenshots are sufficient since Flutter's rendering is nearly identical across platforms.

---

## Phase 0: Environment Setup

### NAPP-001: Development Environment Setup `[setup]`

**Priority**: Critical | **Status**: `[x]`
**Blocked by**: None

Set up everything needed for Flutter + Serverpod development from scratch.

**Prerequisites to install**:

```bash
# 1. Flutter SDK (includes Dart)
brew install --cask flutter

# 2. Android Studio (for Android SDK + emulator)
brew install --cask android-studio

# 3. Serverpod CLI
dart pub global activate serverpod_cli

# IMPORTANT: Add pub global bin to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# 4. Docker - ALREADY INSTALLED ✓
```

**Tasks**:
- [x] Install Flutter SDK via Homebrew
- [x] Verify Dart is available: `dart --version`
- [x] Install Android Studio + Android SDK
- [x] Create and launch Android emulator
- [x] Install Serverpod CLI
- [x] Add `~/.pub-cache/bin` to PATH
- [x] Install Docker Desktop (already done)
- [x] Run `flutter doctor` - fix any issues

**Acceptance Criteria**:
- [x] `flutter doctor` shows no errors (Xcode/iOS skipped intentionally)
- [x] Can run Flutter app on Android emulator
- [x] Can run Flutter app in Chrome (web)

---

## Phase 1: Project Scaffolding

### NAPP-002: Initialize Serverpod Project `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Create the Serverpod project inside the existing repository.

**Tasks**:
- [x] Create `native/` directory in repo root
- [x] Run `serverpod create bagholdr` inside `native/`
- [x] Verify PostgreSQL docker-compose.yml is generated
- [x] Configure linting (dart analyze)
- [x] Update root .gitignore for Dart/Flutter generated files
- [x] Test: `docker compose up -d` starts Postgres
- [x] Test: server connects to database
- [x] Test: Flutter app connects to server
- [x] Configure Flutter web to run on port 3001
- [x] Update `pnpm screenshot` script to support `--flutter` flag
- [x] Create `native/scripts/start.sh` for one-command startup (Docker + server + emulator)
- [x] Create `native/scripts/stop.sh` for teardown
- [x] Update screenshot script to support `--emulator` flag (via adb)
- [x] Test: Flutter app runs on Android emulator
- [x] Test: `pnpm screenshot home --emulator` captures emulator screenshot

**Acceptance Criteria**:
- [x] Project compiles without errors
- [x] Server starts and connects to DB
- [x] Flutter app connects to server
- [x] Hot reload works for both server and client
- [x] `pnpm screenshot / home --flutter` captures Flutter web screenshot
- [x] `./native/scripts/start.sh` starts everything with one command
- [x] `./native/scripts/stop.sh` tears everything down
- [x] Flutter app runs on Android emulator
- [x] `pnpm screenshot home --emulator` captures emulator screenshot

---

### NAPP-003: Mobile UI Exploration `[design]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Figure out how to display financial dashboard data on mobile before building. This is a design task — no code, just decisions.

**Final Mockup**: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

This mockup is the canonical reference for all dashboard UI implementation. Future LLMs should read this file to understand the exact layout, styling, and interactions.

**Design Decisions**:

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Navigation** | Drawer (hamburger) | Maximizes vertical space for dashboard content |
| **Theme** | Light | Clean, professional, good contrast for financial data |
| **Layout** | Single scrolling page | All key info visible without tab switching |
| **Strategy visibility** | Ring chart + detail panel | Shows allocation vs target at a glance, educates user about portfolio strategy |
| **Asset filtering** | Sleeve pills + hierarchical filter | Tap sleeve to filter assets, parent sleeves include children |

**Information Hierarchy** (top to bottom):
1. **Header**: Portfolio selector, hide balances toggle, sync status
2. **Time Range Bar**: Period selector affects all return calculations
3. **Hero Section**: Primary KPIs (invested value, cash, total, returns, chart)
4. **Strategy Section**: Issues, allocation ring chart, sleeve detail, sleeve pills
5. **Assets Section**: Searchable, filterable asset list

**Tasks**:
- [x] Review current dashboard-spec.md for required data
- [x] Sketch 2-3 mobile layout options (can be rough)
- [x] Decide on navigation pattern (bottom tabs vs drawer)
- [x] Decide on information hierarchy (what's visible first)
- [x] Create low-fi mockup of dashboard screen
- [x] Create low-fi mockup of assets list
- [x] Document decisions in this file

**Acceptance Criteria**:
- [x] Clear mobile layout plan documented
- [x] Navigation structure decided
- [x] Information hierarchy defined

---

### NAPP-004: Design System & Theme `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Establish visual foundation before building features.

---

#### Research Notes (January 2026)

**Flutter ecosystem status**:
- Flutter 3.38 (Nov 2025) with Dart 3.10 is current stable
- Material 3 is the default since Flutter 3.16
- Material/Cupertino packages are being decoupled into standalone pub.dev packages (Phase 1 underway, Phase 2-3 in 2026)
- Material 3 Expressive (M3E) coming in the new separate packages - not yet available

**Implications for this task**:
- Use built-in Material 3 widgets (Card, ElevatedButton, Text, etc.) - no custom wrappers needed
- Use `ColorScheme.fromSeed()` for automatic light/dark palette generation
- Typography and spacing come free with Material 3's `TextTheme` and design tokens
- Continue importing `package:flutter/material.dart` - the decoupling is backward-compatible

**References**:
- [Flutter Material/Cupertino Decoupling - GitHub #101479](https://github.com/flutter/flutter/issues/101479)
- [Material Design for Flutter](https://docs.flutter.dev/ui/design/material)
- [Flutter Theming Cookbook](https://docs.flutter.dev/cookbook/design/themes)

---

#### Implementation

**Files created**:
- `bagholdr_flutter/lib/theme/theme.dart` - Light/dark theme definitions
- `bagholdr_flutter/lib/theme/colors.dart` - Custom color extensions for financial UI
- `bagholdr_flutter/lib/utils/formatters.dart` - Number formatting utilities

**Tasks**:
- [x] Create `theme.dart` with light/dark `ThemeData` using `ColorScheme.fromSeed()`
- [x] Create `colors.dart` with `ThemeExtension` for financial colors (positive/negative, chart colors, issue indicators, `categoryPalette` for dynamic categories like sleeves)
- [x] Create `formatters.dart` with utilities:
  - `formatCurrency(double)` → `€1,234.56`
  - `formatCurrencyCompact(double)` → `€113k`
  - `formatPercent(double, {showSign})` → `+12.34%` / `-5.67%`
  - `formatSignedCurrency(double)` → `+€1,234` / `-€456`
- [x] Wire up theme switching in `main.dart` (light/dark/system)
- [x] Take screenshot to verify theming

**Skip** (use Material 3 built-ins instead):
- Custom AppCard, AppButton, AppText wrappers
- Custom typography scale (use `Theme.of(context).textTheme`)
- Custom spacing constants (use Material design tokens)

---

**Acceptance Criteria**:
- [x] Light and dark themes work correctly
- [x] Theme toggle switches between light/dark/system
- [x] Financial colors accessible via `Theme.of(context).extension<FinancialColors>()`
- [x] Numbers format correctly: `€1,234.56` / `+12.34%` / `€113k` / `-€456.78`

---

## Phase 2: Core Data Model

Models are created one at a time to keep tasks focused. Each model task creates a single Serverpod model YAML file.

### NAPP-005: Portfolio Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

**File**: `bagholdr_server/lib/src/models/portfolio.spy.yaml`

```yaml
class: Portfolio
table: portfolios
fields:
  name: String
  bandRelativeTolerance: double
  bandAbsoluteFloor: double
  bandAbsoluteCap: double
  createdAt: DateTime
  updatedAt: DateTime
```

**Note**: Fields match actual TypeScript schema in `server/src/db/schema.ts` (bandRelativeTolerance/Floor/Cap instead of warningBandPp/outOfBandPp).

**Tasks**:
- [x] Create portfolio.spy.yaml with fields matching TypeScript schema
- [x] Run `serverpod generate`
- [x] Verify generated Dart code compiles

**Acceptance Criteria**:
- [x] Model generates without errors
- [x] Can import Portfolio type in Flutter app

---

### NAPP-006: Asset Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-005 complete)

**Files**:
- `bagholdr_server/lib/src/models/asset.spy.yaml`
- `bagholdr_server/lib/src/models/asset_type.spy.yaml`

```yaml
### asset_type.spy.yaml
enum: AssetType
values:
  - stock
  - etf
  - bond
  - fund
  - commodity
  - other

### asset.spy.yaml
class: Asset
table: assets
fields:
  isin: String
  ticker: String
  name: String
  description: String?
  assetType: AssetType
  currency: String
  yahooSymbol: String?
  archived: bool
indexes:
  asset_isin_idx:
    fields: isin
    unique: true
```

**Note**: Fields match actual TypeScript schema in `server/src/db/schema.ts`. Includes `AssetType` enum for asset classification.

**Tasks**:
- [x] Create asset_type.spy.yaml enum
- [x] Create asset.spy.yaml with fields matching TypeScript schema
- [x] Run `serverpod generate`
- [x] Verify compilation

**Acceptance Criteria**:
- [x] Model generates without errors
- [x] Can import Asset and AssetType in Flutter app

---

### NAPP-007: Sleeve Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-006 complete)

**File**: `bagholdr_server/lib/src/models/sleeve.spy.yaml`

Reference existing schema in `server/src/db/schema.ts` for field names.

```yaml
class: Sleeve
table: sleeves
fields:
  portfolioId: int, relation(parent=portfolios)
  parentSleeveId: int?
  name: String
  budgetPercent: double
  sortOrder: int
  isCash: bool
indexes:
  sleeve_portfolio_idx:
    fields: portfolioId
```

**Tasks**:
- [x] Read existing sleeve schema from server/src/db/schema.ts
- [x] Create sleeve.spy.yaml with matching fields
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors
- [x] Supports parent reference for hierarchy

---

### NAPP-008: Holding Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-007 complete)

**File**: `bagholdr_server/lib/src/models/holding.spy.yaml`

Reference existing schema for fields.

**Schema** (from TypeScript):
```yaml
class: Holding
table: holdings
fields:
  assetId: int, relation(parent=assets)  # Maps to assetIsin via migration
  quantity: double
  totalCostEur: double
indexes:
  holding_asset_idx:
    fields: assetId
    unique: true
```

**Note**: The TypeScript schema uses `assetIsin` (text) as a foreign key to `assets.isin`. Serverpod uses integer IDs for relations, so we use `assetId` referencing the Asset's Serverpod ID. The data migration (NAPP-011) will handle mapping ISINs to Serverpod asset IDs.

**Tasks**:
- [x] Read existing holding schema
- [x] Create holding.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-009: Order Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-008 complete)

**File**: `bagholdr_server/lib/src/models/order.spy.yaml`

**Tasks**:
- [x] Read existing order schema
- [x] Create order.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010: DailyPrice Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-009 complete)

**File**: `bagholdr_server/lib/src/models/daily_price.spy.yaml`

**Tasks**:
- [x] Read existing daily price schema
- [x] Create daily_price.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010a: SleeveAssets Model `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: NAPP-007

Junction table linking sleeves to assets. Critical for dashboard functionality.

**File**: `bagholdr_server/lib/src/models/sleeve_asset.spy.yaml`

**Reference** (from `server/src/db/schema.ts`):
```typescript
export const sleeveAssets = sqliteTable(
  'sleeve_assets',
  {
    sleeveId: text('sleeve_id').references(() => sleeves.id),
    assetIsin: text('asset_isin').references(() => assets.isin)
  },
  (table) => [primaryKey({ columns: [table.sleeveId, table.assetIsin] })]
);
```

**Tasks**:
- [x] Create sleeve_asset.spy.yaml with composite key
- [x] Run `serverpod generate`
- [x] Verify compilation

**Acceptance Criteria**:
- [x] Model generates without errors
- [x] Supports many-to-many sleeve↔asset relationship

---

### NAPP-010b: GlobalCash Model `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Single-row table storing portfolio cash balance.

**File**: `bagholdr_server/lib/src/models/global_cash.spy.yaml`

**Reference**:
```typescript
export const globalCash = sqliteTable('global_cash', {
  id: text('id').primaryKey().default('default'),
  amountEur: real('amount_eur').notNull().default(0),
  updatedAt: integer('updated_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create global_cash.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010c: PortfolioRules Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: NAPP-005

Flexible rule system for portfolio constraints (concentration limits, etc.).

**File**: `bagholdr_server/lib/src/models/portfolio_rule.spy.yaml`

**Reference**:
```typescript
export const portfolioRules = sqliteTable('portfolio_rules', {
  id: text('id').primaryKey(),
  portfolioId: text('portfolio_id').references(() => portfolios.id),
  ruleType: text('rule_type').notNull(),
  name: text('name').notNull(),
  config: text('config', { mode: 'json' }),
  enabled: integer('enabled', { mode: 'boolean' }).default(true),
  createdAt: integer('created_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create portfolio_rule.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010d: YahooSymbols Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: NAPP-006

Stores all available Yahoo Finance symbols for an ISIN (multiple exchanges).

**File**: `bagholdr_server/lib/src/models/yahoo_symbol.spy.yaml`

**Reference**:
```typescript
export const yahooSymbols = sqliteTable('yahoo_symbols', {
  id: text('id').primaryKey(),
  assetIsin: text('asset_isin').references(() => assets.isin),
  symbol: text('symbol').notNull(),
  exchange: text('exchange'),
  exchangeDisplay: text('exchange_display'),
  quoteType: text('quote_type'),
  resolvedAt: integer('resolved_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create yahoo_symbol.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010e: PriceCache Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Cached current price data from Yahoo Finance.

**File**: `bagholdr_server/lib/src/models/price_cache.spy.yaml`

**Reference**:
```typescript
export const priceCache = sqliteTable('price_cache', {
  ticker: text('ticker').primaryKey(),
  priceNative: real('price_native').notNull(),
  currency: text('currency').notNull(),
  priceEur: real('price_eur').notNull(),
  fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create price_cache.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010f: FxCache Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Cached FX rates.

**File**: `bagholdr_server/lib/src/models/fx_cache.spy.yaml`

**Reference**:
```typescript
export const fxCache = sqliteTable('fx_cache', {
  pair: text('pair').primaryKey(), // e.g., "USDEUR"
  rate: real('rate').notNull(),
  fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create fx_cache.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010g: DividendEvents Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Dividend payout history from Yahoo Finance.

**File**: `bagholdr_server/lib/src/models/dividend_event.spy.yaml`

**Reference**:
```typescript
export const dividendEvents = sqliteTable('dividend_events', {
  id: text('id').primaryKey(), // `${ticker}_${YYYY-MM-DD}`
  ticker: text('ticker').notNull(),
  exDate: text('ex_date').notNull(), // YYYY-MM-DD
  amount: real('amount').notNull(),
  currency: text('currency').notNull(),
  fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create dividend_event.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010h: TickerMetadata Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Sync state tracking per ticker (when data was last fetched).

**File**: `bagholdr_server/lib/src/models/ticker_metadata.spy.yaml`

**Reference**:
```typescript
export const tickerMetadata = sqliteTable('ticker_metadata', {
  ticker: text('ticker').primaryKey(),
  lastDailyDate: text('last_daily_date'), // YYYY-MM-DD
  lastSyncedAt: integer('last_synced_at', { mode: 'timestamp' }),
  lastIntradaySyncedAt: integer('last_intraday_synced_at', { mode: 'timestamp' }),
  isActive: integer('is_active', { mode: 'boolean' }).default(true)
});
```

**Tasks**:
- [x] Create ticker_metadata.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-010i: IntradayPrices Model `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

5-minute interval OHLCV data for detailed charting (last 5 days).

**File**: `bagholdr_server/lib/src/models/intraday_price.spy.yaml`

**Reference**:
```typescript
export const intradayPrices = sqliteTable('intraday_prices', {
  id: text('id').primaryKey(), // `${ticker}_${timestamp}`
  ticker: text('ticker').notNull(),
  timestamp: integer('timestamp').notNull(), // Unix seconds
  open: real('open').notNull(),
  high: real('high').notNull(),
  low: real('low').notNull(),
  close: real('close').notNull(),
  volume: integer('volume').notNull(),
  currency: text('currency').notNull(),
  fetchedAt: integer('fetched_at', { mode: 'timestamp' }).notNull()
});
```

**Tasks**:
- [x] Create intraday_price.spy.yaml
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Model generates without errors

---

### NAPP-011: Database Migration `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-010a and NAPP-010b complete)

Create database tables and migrate existing data from SQLite to PostgreSQL.

---

#### Migration Notes

**Timestamp format**:
- SQLite stores timestamps as **Unix integers (seconds)**: `integer('...', { mode: 'timestamp' })`
- Convert to Dart DateTime: `DateTime.fromMillisecondsSinceEpoch(sqliteTimestamp * 1000)`

**ID format**:
- SQLite already uses **text UUIDs** for IDs (not integers): `id: text('id').primaryKey()`
- Migration generates new UUID v7s; maintain in-memory mapping during import for FK resolution

**Foreign key strategy**:
- `holdings.assetIsin` → lookup asset by ISIN, get new UUID
- `orders.assetIsin` → lookup asset by ISIN, get new UUID
- `sleeves.portfolioId` → lookup portfolio by old ID, get new UUID
- `sleeves.parentSleeveId` → lookup sleeve by old ID, get new UUID
- `sleeveAssets` → lookup both sleeve and asset by old IDs

**Import order** (respects FK dependencies):
1. `portfolios` (no deps)
2. `assets` (no deps)
3. `sleeves` (depends on portfolios, self-referential; has cascade delete on parentSleeveId)
4. `holdings` (depends on assets via ISIN)
5. `orders` (depends on assets via ISIN)
6. `sleeveAssets` (depends on sleeves and assets)
7. `globalCash` (no deps, single row)
8. `dailyPrices` (no FK, potentially large)
9. Cache tables (optional, can be rebuilt)

**New/nullable fields**:
- `Asset.metadata`: New field for ETF look-through data (holdings, sectors, factors). Will be `null` after migration - can be populated later via exposure analysis feature.

---

**Tasks**:
- [x] Run `serverpod create-migration`
- [x] Start server with `--apply-migrations`
- [x] Verify tables created in Postgres (test DB first)
- [x] Write data export script (SQLite → JSON) in TypeScript
- [x] Write data import script (JSON → Serverpod) in Dart
- [x] Run migration on test DB, verify integrity
- [x] Run migration on main DB
- [x] Verify data integrity (counts, spot checks)

**Acceptance Criteria**:
- [x] All tables exist in Postgres
- [x] Existing portfolio data migrated
- [x] Can query data via Serverpod ORM
- [x] Timestamps converted correctly
- [x] Foreign keys resolve correctly
- [x] SleeveAssets junction populated

---

## Phase 3: Features (Vertical Slices)

Features are split into smaller tasks: research → port (if applicable) → implement.

### NAPP-100: Fix Performance Metrics Calculation `[implement]`

**Priority**: 🔴 Critical | **Status**: `[x]`
**Blocked by**: None

Performance metrics (MWR, TWR, returns) for sleeves and assets are not being calculated accurately.

**Root Cause**: Missing "short holding" detection. When assets/sleeves are acquired AFTER the
comparison date (e.g., 1Y period selected but asset bought 6 months ago), the code returned
0/null instead of using the effective start date (first order date).

**Fix Applied**: Added short holding detection to both endpoints:
- `sleeves_endpoint.dart`: Detects if sleeve's first order is after comparison date, uses
  effective start date for MWR/TWR calculations
- `holdings_endpoint.dart`: Same logic for individual assets

**Affected Areas**:
- Sleeve-level MWR/TWR in sleeves endpoint (NAPP-020)
- Asset-level MWR/TWR in holdings endpoint (NAPP-017)
- Portfolio-level returns in valuation endpoint (NAPP-015)

**Tasks**:
- [x] Investigate current calculation discrepancies
- [x] Compare Dart calculations against TypeScript reference implementation
- [x] Fix sleeve performance metrics calculation
- [x] Fix asset performance metrics calculation
- [x] Add/update unit tests for edge cases
- [x] Validate against known correct values from TypeScript backend

**Acceptance Criteria**:
- [x] Sleeve MWR/TWR matches TypeScript implementation
- [x] Asset MWR/TWR matches TypeScript implementation
- [x] All existing tests pass
- [x] New regression tests added

---

### NAPP-101: Short Holding Period Indicator `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

When a sleeve or asset was acquired after the selected period's start date (e.g., user selects
"1Y" but asset was bought 6 months ago), display a visual hint indicating the actual period.

**Backend Changes**:
- [ ] Add `effectiveStartDate` field to sleeve response (SleeveNode)
- [ ] Add `effectiveStartDate` field to holdings response (HoldingResponse)
- [ ] Regenerate Serverpod client

**Frontend Changes**:
- [ ] Show indicator (asterisk, icon, or tooltip) when effectiveStartDate differs from period start
- [ ] Tooltip should explain: "Returns calculated from [date] (acquisition date)"

**Acceptance Criteria**:
- [ ] User can see when returns are for shorter period than selected
- [ ] Tooltip explains the actual date range used

---

### NAPP-012: Portfolio List Endpoint `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

**File**: `bagholdr_server/lib/src/endpoints/portfolio_endpoint.dart`

**Tasks**:
- [x] Create PortfolioEndpoint class
- [x] Add `getPortfolios()` method
- [x] Return list of portfolios from database
- [x] Run `serverpod generate` to update client

**Acceptance Criteria**:
- [x] Endpoint returns portfolio list
- [x] Client can call endpoint type-safely

---

### NAPP-013: Portfolio Selector Component `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-012 complete)

Build the portfolio selector dropdown for the dashboard header. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

**File**: `bagholdr_flutter/lib/widgets/portfolio_selector.dart`

**Design** (from mockup header):
```
┌─────────────────────────────────────────┐
│ ☰  Main Portfolio ▼          👁  🟢    │
└─────────────────────────────────────────┘
```

**Widget Interface**:
```dart
PortfolioSelector(
  portfolios: List<Portfolio>,
  selected: Portfolio,
  onChanged: (Portfolio) => void,
)
```

**Tasks**:
- [x] Create `PortfolioSelector` widget
- [x] Display current portfolio name + chevron (▼)
- [x] On tap, open bottom sheet with portfolio list
- [x] Portfolio list items show name + selection indicator
- [x] Selecting a portfolio calls `onChanged` and closes sheet
- [x] Match mockup styling (16px font, 600 weight)
- [x] Take screenshot to verify

**Acceptance Criteria**:
- [x] Widget matches mockup header design
- [x] Bottom sheet opens on tap
- [x] Selection works correctly
- [x] Screenshot verified

---

### NAPP-013a: Time Range Bar Component `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Build the sticky time range selector bar. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

**File**: `bagholdr_flutter/lib/widgets/time_range_bar.dart`

**Design** (from mockup):
```
┌─────────────────────────────────────────┐
│  1M   3M   6M   YTD  [1Y]  ALL         │
└─────────────────────────────────────────┘
```

**Widget Interface**:
```dart
enum TimePeriod { oneMonth, threeMonths, sixMonths, ytd, oneYear, all }

TimeRangeBar(
  selected: TimePeriod,
  onChanged: (TimePeriod) => void,
)
```

**Tasks**:
- [x] Create `TimeRangeBar` widget
- [x] 6 equal-width buttons: 1M, 3M, 6M, YTD, 1Y, ALL
- [x] Active button: dark background (#111), white text
- [x] Inactive buttons: grey background (#f3f4f6), grey text (#6b7280)
- [x] Sticky positioning (handled by parent)
- [x] Default selection: 1Y
- [x] Take screenshot to verify

**Acceptance Criteria**:
- [x] Widget matches mockup exactly
- [x] Selection state works correctly
- [x] Screenshot verified

---

### NAPP-013b: Hero Value Display Component `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-015 complete)

Build the value display portion of the hero section. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

**File**: `bagholdr_flutter/lib/widgets/hero_value_display.dart`

**Design** (MWR + TWR display):
```
┌─────────────────────────────────────────┐
│ INVESTED                    CASH        │
│ €113,482                    €6,452      │
│ +12.2%  +€12,348                        │
│ TWR +10.5%                  TOTAL       │
│                             €119,934    │
└─────────────────────────────────────────┘
```

**Return Display Strategy** (consistent across portfolio, sleeves, assets):
- **+12.2%** (big green/red): MWR compounded — your actual return on invested money
- **TWR +10.5%** (grey): Portfolio performance — ignores when you added/removed money

Showing both allows users to see if their timing helped or hurt them:
- If MWR > TWR: Good timing (added money before gains)
- If MWR < TWR: Poor timing (added money before losses)

**Widget Interface**:
```dart
HeroValueDisplay(
  investedValue: double,
  mwr: double,              // MWR compounded return (big number)
  twr: double?,             // TWR return (grey, nullable if calculation failed)
  returnAbs: double,        // Absolute return in €
  cashBalance: double,
  totalValue: double,
  hideBalances: bool,
)
```

**Tasks**:
- [x] Create `HeroValueDisplay` widget
- [x] Left column: INVESTED label, amount (28px bold)
- [x] Left column: MWR % (16px, green/red), absolute return € (13px, green/red)
- [x] Left column: TWR % (11px grey)
- [x] Right column: CASH label + value, TOTAL label + value (muted)
- [x] Color MWR/absolute return green/red based on sign
- [x] Support `hideBalances` mode (show ••••• for amounts)
- [x] Handle null TWR gracefully (hide or show "N/A")
- [x] Match mockup typography exactly
- [x] Take screenshot to verify

**Acceptance Criteria**:
- [x] Widget matches mockup exactly
- [x] Hide balances mode works
- [x] Screenshot verified

---

### NAPP-013c: Issues Bar Component `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-022 complete)

Build the collapsible issues bar. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

**File**: `bagholdr_flutter/lib/widgets/issues_bar.dart`

**Design** (from mockup):
```
Collapsed:
┌─────────────────────────────────────────┐
│ [4] Issues need attention            ▶  │
└─────────────────────────────────────────┘

Expanded:
┌─────────────────────────────────────────┐
│ [4] Issues need attention            ▼  │
├─────────────────────────────────────────┤
│ 🟠 Growth +5pp over target    Rebalance→│
│ 🔵 Bonds -3pp under target    Rebalance→│
│ 🟡 3 assets have stale prices  Refresh→ │
│ ⚫ Last sync: 2 hours ago         Sync→ │
└─────────────────────────────────────────┘
```

**Widget Interface**:
```dart
IssuesBar(
  issues: List<Issue>,
  onIssueTap: (Issue) => void,
)
```

**Tasks**:
- [x] Create `IssuesBar` widget
- [x] Yellow background (#fffbeb)
- [x] Collapsed: badge with count, text, chevron
- [x] Tap to expand/collapse with animation
- [x] Expanded: scrollable list (max 160px height)
- [x] Issue item: colored dot, text, action text
- [x] Match mockup colors exactly
- [x] Take screenshot of both states

**Acceptance Criteria**:
- [x] Widget matches mockup exactly
- [x] Expand/collapse animation works
- [x] Screenshot verified (both states)

---

### NAPP-014: Research Valuation Logic `[research]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Understand the existing valuation logic before porting. **No code changes — just documentation.**

**Files to read**:
- `server/src/trpc/routers/valuation.ts`
- `specs/calculus-spec.md`

**Tasks**:
- [x] Read valuation.ts thoroughly
- [x] Read calculus-spec.md for context
- [x] Document the key calculations:
  - How is portfolio value computed?
  - How are returns calculated for each period?
  - What's the cost basis calculation?
  - How does XIRR work?
- [x] List all helper functions that need porting
- [x] Note any edge cases or complex logic

**Deliverable**: Add a "Valuation Logic Summary" section to this file below.

**Acceptance Criteria**:
- [x] Valuation logic documented in this plan
- [x] All formulas/calculations listed
- [x] Clear porting checklist created

---

### NAPP-015: Port Valuation Endpoint `[port]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-014 complete)

Translate valuation logic from TypeScript to Dart. Powers the Hero section of the dashboard.

**References**:
- **Formulas**: [specs/calculus-spec.md](calculus-spec.md) — cost basis, MWR/XIRR, TWR, bands
- **Porting guide**: [Valuation Logic Summary](#valuation-logic-summary) — endpoints, types, helper functions
- **Source code**: `server/src/trpc/routers/valuation.ts`
- **Mockup**: [specs/mockups/native/interactive-w2-refined.html](mockups/native/interactive-w2-refined.html)

**File**: `bagholdr_server/lib/src/endpoints/valuation_endpoint.dart`

---

**Tasks**:
- [x] Create `ValuationEndpoint` class
- [x] Port `getPortfolioValuation` — sleeve hierarchy, band violations, health issues
- [x] Port `getHistoricalReturns` — MWR returns by period
- [x] Port `getChartData` — historical value + cost basis series
- [x] Port helper functions: `calculateSleeveTotal`, `calculateMWR`, `formatPeriodLabel`
- [x] Port or find XIRR implementation for Dart
- [x] Implement `calculateTWR` — Time-Weighted Return for portfolio performance (ignores cash flow timing)
- [x] Run `serverpod generate`
- [x] Validate against existing backend (same inputs → same outputs)

**Return Display Strategy**:
- **MWR (compounded)**: Big green/red number — user's actual return on their money
- **TWR**: Grey number — portfolio performance (ignores timing of deposits/withdrawals)
- Shows both so users can see if their timing helped or hurt them

**Acceptance Criteria**:
- [x] Returns correct portfolio value
- [x] MWR/XIRR matches existing app for most periods (today, 1W, 6M, YTD, 1Y)
- [ ] **Known issue**: 1M has 1-day comparison date difference vs TypeScript
- [ ] **Known issue**: ALL period missing from response (needs debugging)
- [x] TWR calculated correctly (unit tests pass)
- [x] Cost basis matches existing app (Average Cost Method)
- [x] Sleeve totals calculated recursively

---

### NAPP-016: Dashboard Screen Assembly `[implement]`

**Priority**: High | **Status**: `[blocked]`
**Blocked by**: NAPP-013, NAPP-013a, NAPP-013b, NAPP-013c, NAPP-018, NAPP-021, NAPP-023

Assemble all components into the complete dashboard screen. This task composes the reusable components built in prior tasks. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

The dashboard is a single scrolling page with these sections:
1. Header
2. Time Range Bar
3. Hero Section (Performance)
4. Strategy Section
5. Assets Section

---

#### 16.1 Header

**Layout**: Horizontal bar, white background, border-bottom

| Element | Data | Behavior |
|---------|------|----------|
| Hamburger icon | Static | Opens drawer navigation |
| Portfolio name + chevron | `portfolio.name` | Tap opens portfolio selector (bottom sheet) |
| Eye icon (👁) | Toggle state | Tap toggles "hide balances" mode |
| Status dot | Sync status | Green = synced, Yellow = syncing, Red = error |

**Hide Balances Mode**:
When enabled, replace all monetary values with `•••••`:
- Invested amount, Cash, Total
- Chart tooltip
- Ring center value
- Sleeve detail value
- Asset values and P/L

Percentages (returns, weights, allocations) remain visible.

---

#### 16.2 Time Range Bar

**Layout**: Sticky bar below header, 6 equal-width buttons

**Options**: `1M` | `3M` | `6M` | `YTD` | `1Y` | `ALL`

**Behavior**:
- Exactly one button active at a time (dark background, white text)
- Changing period updates ALL time-dependent values:
  - Hero section: return %, return €, XIRR
  - Chart: date range and data points
  - Strategy section: sleeve returns
  - Assets section: TWR and XIRR per asset

**Default**: `1Y`

---

#### 16.3 Hero Section (Performance)

**Layout**: White card with value display + chart

##### 16.3.1 Value Display

**Left column (primary)**:

| Element | Data | Format |
|---------|------|--------|
| Label | "INVESTED" | Uppercase, 11px, grey |
| Amount | Sum of all holding values | `€{amount}` with thousand separator, 28px bold |
| MWR % | MWR compounded for selected period | `+12.2%` or `-5.3%`, 16px, green/red |
| Return € | Absolute gain/loss | `+€12,348` or `-€5,200`, 13px, green/red |
| TWR | Portfolio performance (ignores timing) | `TWR +10.5%`, 11px grey |

**Return metrics explained** (consistent across portfolio, sleeves, assets):
- **MWR %**: Your actual return on invested money (big number, colored)
- **TWR**: Portfolio performance, ignores when you added/removed money (grey)

**Right column (secondary)**:

| Element | Data | Format |
|---------|------|--------|
| Cash label | "CASH" | Uppercase, 10px, light grey |
| Cash value | `portfolio.cashBalance` | `€{amount}`, 14px bold |
| Total label | "TOTAL" | Uppercase, 10px, light grey |
| Total value | Invested + Cash | `€{amount}`, 13px muted grey |

##### 16.3.2 Chart

**Type**: Area chart with gradient fill

**Dimensions**: Full width (extends beyond padding), 200px height

**Lines**:
1. **Value line** (solid green #22c55e, 2.5px): Portfolio value over time
2. **Cost basis line** (dashed grey #9ca3af, 1.5px): Total invested capital over time

**Tooltip**: Shows current value at chart end, positioned top-right

**X-axis labels**: Evenly spaced date labels based on period (e.g., Jan, Mar, May... for 1Y)

**Legend**: Centered below chart
- Solid green line = "Invested"
- Dashed grey line = "Cost basis"

**Data points**: Daily granularity for periods ≤1Y, weekly for ALL

---

#### 16.4 Strategy Section

**Layout**: White card containing issues bar, ring chart, detail panel, sleeve pills

##### 16.4.1 Issues Bar

**Layout**: Yellow warning banner, collapsible

**Collapsed state**:
- Yellow badge with issue count (e.g., "4")
- Text: "Issues need attention"
- Chevron (▶) indicating expandable

**Expanded state** (tap to toggle):
- Chevron rotates 90°
- Panel slides down showing issue list
- Max height 160px, scrollable if more issues

**Issue types**:

| Type | Dot color | Example text | Action |
|------|-----------|--------------|--------|
| Over allocation | Orange #f97316 | "Growth +5pp over target" | "Rebalance →" |
| Under allocation | Blue #3b82f6 | "Bonds -3pp under target" | "Rebalance →" |
| Stale prices | Amber #f59e0b | "3 assets have stale prices" | "Refresh →" |
| Sync status | Grey #9ca3af | "Last sync: 2 hours ago" | "Sync →" |

**Issue detection logic**:
- Over/under: sleeve actual% differs from target% by more than `portfolio.warningBandPp`
- Stale prices: asset price older than 24 hours
- Sync: time since last Directa import

##### 16.4.2 Ring Chart (Allocation Donut)

**Layout**: Centered, 180x180px wrapper

**Structure**: Two concentric rings showing sleeve hierarchy

| Ring | Radius | Stroke width | Content |
|------|--------|--------------|---------|
| Inner | 55px | 18px | Top-level sleeves (Core, Satellite) |
| Outer | 78px | 14px | Child sleeves (Equities, Bonds, Safe Haven, Growth) |

**Colors** (consistent across app):
- Core: #3b82f6 (blue)
- Equities: #60a5fa (light blue)
- Bonds: #93c5fd (lighter blue)
- Satellite: #f59e0b (amber)
- Safe Haven: #fbbf24 (yellow)
- Growth: #fcd34d (light yellow)

**Segment sizing**: Proportional to current allocation % (using stroke-dasharray)

**Center circle** (72px diameter):
- Shows value of selected sleeve: `€113k` (compact format for large numbers)
- Shows sleeve name below: "All Sleeves"
- When specific sleeve selected: shows hint "tap for all"
- Tap center → resets to "All Sleeves" view

**Interactions**:
- Tap segment → selects that sleeve
- Selected segment: increased stroke-width (24px)
- Non-related segments: dimmed (opacity 0.2)
- Related segments: parent includes children (e.g., selecting Core highlights Core + Equities + Bonds)

##### 16.4.3 Detail Panel

**Layout**: Below ring chart, shows details for selected sleeve

**"All Sleeves" view** (default):
- Minimal display: color bar, name, meta, value, return, XIRR
- No allocation metrics (Current/Target/Status hidden)

**Specific sleeve view**:
- Full display with allocation metrics

| Element | Data | Format |
|---------|------|--------|
| Color bar | Sleeve color | 4px wide, 44px tall vertical bar |
| Name | Sleeve name | 15px bold |
| Meta | Asset count | "12 assets" or "2 sleeves · 18 assets" |
| Value | Sleeve total value | `€{amount}`, 16px bold |
| MWR | MWR compounded for period | `+12.2%`, 12px, colored |
| TWR | TWR for period | `TWR +10.5%`, 11px grey |

**Allocation metrics row** (specific sleeve only):

| Metric | Data | Format |
|--------|------|--------|
| Current | Actual allocation % | `55%` |
| Target | Target allocation % | `55%` |
| Status | Drift assessment | "On target" (green), "+5pp" (orange), "-3pp" (blue) |

##### 16.4.4 Sleeve Pills

**Layout**: Horizontal scrollable row of pills

**Pills**: One for each sleeve + "All" pill at start

| Element | Content |
|---------|---------|
| All pill | "All" (no dot, no percentage) |
| Parent sleeves | Dot + Name + Target % (e.g., "Core 75%") |
| Child sleeves | Dot + Name (no percentage) |

**Interactions**:
- Tap pill → selects sleeve (same as tapping ring segment)
- Selected pill: white background, dark border
- Unselected pill: grey background, no border

**Scroll behavior**: Horizontal scroll if pills exceed viewport width

---

#### 16.5 Assets Section

See **NAPP-018** for detailed asset list specifications.

---

**Tasks**:
- [ ] Create `dashboard_screen.dart` with scroll layout
- [ ] Assemble Header: hamburger menu, `PortfolioSelector`, hide balances toggle, status dot
- [ ] Add `TimeRangeBar` (sticky below header)
- [ ] Add `HeroValueDisplay` + Hero chart (use fl_chart or syncfusion)
- [ ] Add `IssuesBar` component
- [ ] Add Strategy section: `RingChart`, `SleeveDetailPanel`, `SleevePills`
- [ ] Add `AssetsSection` component
- [ ] Wire up global state: selected portfolio, selected period, selected sleeve, hide balances
- [ ] Wire up data flow: period/sleeve changes trigger refetch of relevant data
- [ ] Take screenshot to verify against mockup

**Acceptance Criteria**:
- [ ] Dashboard assembles all components correctly
- [ ] All values display correctly from endpoints
- [ ] Period switching updates all time-dependent components
- [ ] Sleeve selection syncs across ring, pills, detail panel, and assets filter
- [ ] Hide balances toggle masks all monetary values
- [ ] Screenshot matches mockup

---

### NAPP-017: Holdings Endpoint `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: NAPP-015 (complete)

**File**: `bagholdr_server/lib/src/endpoints/holdings_endpoint.dart`

Returns holdings data for the Assets section. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| portfolioId | int | Portfolio to fetch holdings for |
| period | String | Time period for return calculations (1M, 3M, 6M, YTD, 1Y, ALL) |
| sleeveId | int? | Optional filter by sleeve (includes children) |
| search | String? | Optional search filter (symbol or name) |
| offset | int | Pagination offset (default 0) |
| limit | int | Page size (default 8) |

---

#### Response Schema

```dart
class HoldingResponse {
  String symbol;         // Asset symbol (e.g., "X.IUSQ")
  String name;           // Asset name
  double value;          // Current market value (quantity * price)
  double costBasis;      // Total cost basis
  double pl;             // Profit/Loss (value - costBasis)
  double weight;         // Portfolio weight % (value / total * 100)
  double mwr;            // MWR compounded return % for period (big number)
  double? twr;           // TWR return % for period (grey, nullable if failed)
  int sleeveId;          // Sleeve assignment
  String sleeveName;     // Sleeve name for display
}

class HoldingsListResponse {
  List<HoldingResponse> holdings;
  int totalCount;        // Total matching holdings (for pagination)
  int filteredCount;     // Count after search/sleeve filter
}
```

---

#### Calculation Notes

- **value**: `holding.quantity * latestPrice.close`
- **costBasis**: Sum of (order.quantity * order.price) for all buy orders, minus sold
- **pl**: `value - costBasis`
- **weight**: `value / portfolioTotalValue * 100`
- **mwr**: MWR compounded return (calculated via XIRR internally)
- **twr**: Time-weighted return (nullable if calculation failed)

---

**Tasks**:
- [x] Create `HoldingsEndpoint` class
- [x] Add `getHoldings()` method with all parameters
- [x] Implement value and cost basis calculations
- [x] Implement P/L calculation
- [x] Implement weight calculation
- [x] Implement MWR calculation for period (compounded)
- [x] Implement TWR calculation for period
- [x] Implement sleeve filtering (hierarchical)
- [x] Implement search filtering
- [x] Implement pagination
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Returns all required fields (including MWR, TWR)
- [x] P/L calculated correctly
- [x] MWR calculated correctly
- [x] TWR calculated correctly (nullable if failed)
- [x] Sleeve filter includes child sleeves
- [x] Pagination works correctly

---

### NAPP-018: Holdings/Assets List UI `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-017 complete)

The Assets section is embedded in the dashboard (NAPP-016), not a separate screen. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### 18.1 Section Header

| Element | Content |
|---------|---------|
| Title | "Assets" (13px bold) |
| Count badge | "{sleeve} · {count}" e.g., "All · 32" or "Equities · 12" |

---

#### 18.2 Search Bar

**Layout**: Full width input with search icon

**Behavior**:
- Filters assets by symbol OR name (case-insensitive substring match)
- Combines with sleeve filter (AND logic)
- Updates count badge to show filtered count
- Shows "No assets match your search" when empty result

---

#### 18.3 Asset Table

**Layout**: Horizontally scrollable table with 3 columns

**Scroll behavior**: Columns 1-2 fit within viewport (375px), column 3 (Weight) requires scroll to reveal. This matches the sleeve pills scroll pattern.

##### Column Headers

| Column | Header text | Width | Alignment |
|--------|-------------|-------|-----------|
| Asset | "ASSET" | flex (remaining) | left |
| Performance | "PERFORMANCE" | 115px | right |
| Weight | "WEIGHT" | 55px | right |

##### Asset Row

**Column 1: Asset**

| Element | Data | Format |
|---------|------|--------|
| Name | `asset.name` | 13px bold, black |
| Ticker | `asset.symbol` | 11px grey |
| Separator | "·" | Light grey dot |
| Value | Holding value | `€{amount}` 11px grey |

Layout: Name on top, then "Ticker · Value" on second line

**Column 2: Performance**

| Element | Data | Format |
|---------|------|--------|
| P/L | Profit/Loss € | `+€4,655` or `-€200`, 13px bold, green/red |
| MWR | MWR compounded | `+12.3%`, 10px, colored (green/red) |
| TWR | TWR for period | `TWR +10.5%`, 10px grey |

Layout: P/L on top, MWR below, TWR on third line

**Column 3: Weight**

| Element | Data | Format |
|---------|------|--------|
| Weight | Portfolio weight % | `37.5%`, 13px medium, dark grey |

---

#### 18.4 Sleeve Filtering

**Behavior**: When a sleeve is selected (via ring chart or pills):
- Filter assets to show only those belonging to the sleeve OR its children
- Hierarchical: selecting "Core" shows assets in Core + Equities + Bonds
- Update count badge to reflect filtered count

**Hierarchy** (from mockup):
```
Core → Equities, Bonds
Satellite → Safe Haven, Growth
```

---

#### 18.5 Pagination

**Initial load**: 8 assets

**"Show more assets" button**:
- Appears when filtered count > displayed count
- Loads 8 more assets on tap
- Hidden when all assets shown

---

#### 18.6 Data Requirements per Asset

| Field | Source | Description |
|-------|--------|-------------|
| symbol | `asset.symbol` | Ticker symbol (e.g., "X.IUSQ") |
| name | `asset.name` | Full name |
| value | `holding.quantity * latestPrice` | Current market value |
| pl | `value - costBasis` | Profit/loss in € |
| weight | `value / portfolioTotal * 100` | Portfolio weight % |
| twr | Calculated | Time-weighted return for selected period |
| xirr | Calculated | Annualized internal rate of return |
| sleeve | `holding.sleeveId` | Sleeve assignment for filtering |

---

**Tasks**:
- [ ] Create `assets_section.dart` widget (embedded in dashboard)
- [ ] Implement search bar with filter logic
- [ ] Implement horizontally scrollable table
- [ ] Implement asset row with 3 columns
- [ ] Implement sleeve filtering (hierarchical)
- [ ] Implement pagination ("Show more assets")
- [ ] Wire up to dashboard sleeve selection state
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Asset list displays correctly with all columns
- [ ] Search filters by symbol and name
- [ ] Sleeve selection filters assets hierarchically
- [ ] Horizontal scroll reveals Weight column
- [ ] Pagination loads more assets
- [ ] Screenshot matches mockup

---

### NAPP-019: Asset Detail `[implement]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-018

**Tasks**:
- [ ] Extend holdings endpoint with `getAssetDetail()` or add to existing
- [ ] Create asset detail bottom sheet
- [ ] Show: full asset info, order history, key stats
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Asset detail shows complete information
- [ ] Order history is correct

---

### NAPP-020: Sleeves Endpoint `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-015 complete)

**File**: `bagholdr_server/lib/src/endpoints/sleeves_endpoint.dart`

Returns sleeve hierarchy with allocation data for the Strategy section. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| portfolioId | int | Portfolio ID |
| period | String | Time period for return calculations |

---

#### Response Schema

```dart
class SleeveTreeResponse {
  List<SleeveNode> sleeves;
  double totalValue;     // Total portfolio value (for "All" view)
  double totalMwr;       // Portfolio MWR compounded for period (big number)
  double? totalTwr;      // Portfolio TWR for period (grey, nullable if failed)
  int totalAssetCount;   // Total assets across all sleeves
}

class SleeveNode {
  int id;
  String name;
  int? parentId;         // null for top-level sleeves
  String color;          // Hex color (e.g., "#3b82f6")

  // Allocation
  double targetPct;      // Target allocation %
  double currentPct;     // Actual allocation %
  double driftPp;        // Difference in percentage points
  String driftStatus;    // "ok", "over", "under"

  // Values
  double value;          // Total value in this sleeve
  double mwr;            // MWR compounded for period (big number)
  double? twr;           // TWR for period (grey, nullable if failed)

  // Counts
  int assetCount;        // Direct assets in sleeve
  int childSleeveCount;  // Number of child sleeves

  // Hierarchy (for tree rendering)
  List<SleeveNode>? children;
}
```

---

#### Color Mapping

| Sleeve | Color |
|--------|-------|
| Core | #3b82f6 |
| Equities | #60a5fa |
| Bonds | #93c5fd |
| Satellite | #f59e0b |
| Safe Haven | #fbbf24 |
| Growth | #fcd34d |

Colors should be stored in the sleeve table or derived from a consistent mapping.

---

#### Drift Calculation

```
driftPp = currentPct - targetPct
driftStatus =
  if abs(driftPp) <= warningBandPp then "ok"
  else if driftPp > 0 then "over"
  else "under"
```

---

**Tasks**:
- [x] Create `SleevesEndpoint` class
- [x] Add `getSleeveTree()` method
- [x] Build hierarchical structure from flat sleeve list
- [x] Calculate current allocation % per sleeve
- [x] Calculate drift vs target
- [x] Calculate MWR per sleeve for period (compounded)
- [x] Calculate TWR per sleeve for period (nullable if failed)
- [x] Include asset counts
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Returns correct hierarchy
- [x] Allocation percentages sum correctly
- [x] Drift calculated correctly against portfolio bands
- [x] MWR and TWR calculated correctly for each sleeve
- [x] Colors assigned correctly

---

### NAPP-021: Sleeves/Strategy UI `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-020 complete)

The Strategy section is embedded in the dashboard (NAPP-016). This task covers the sleeve-specific widgets. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### 21.1 Ring Chart Widget

**File**: `ring_chart.dart`

A custom widget rendering two concentric donut rings.

**Props**:
- `sleeves`: List of sleeve data with values and colors
- `selectedSleeveId`: Currently selected sleeve (null = all)
- `onSleeveSelected`: Callback when segment tapped

**Rendering**:
- Use CustomPainter or SVG for rings
- Inner ring (r=55): top-level sleeves
- Outer ring (r=78): child sleeves
- Segment arc length proportional to current allocation %

**State handling**:
- Selected segment: thicker stroke (24px vs 18px/14px)
- Related segments: normal opacity
- Unrelated segments: opacity 0.2

**Center content**:
- Compact value (€113k format for values > 1000)
- Sleeve name
- "tap for all" hint when not showing all

---

#### 21.2 Sleeve Detail Panel Widget

**File**: `sleeve_detail_panel.dart`

**Props**:
- `sleeve`: Selected sleeve data (or null for "all")
- `isAllView`: Boolean for minimal vs full view

**All view layout**:
```
[color bar] [name        ] [value    ]
           [meta        ] [return   ]
                          [(xirr)   ]
```

**Specific sleeve layout** (adds metrics row):
```
[color bar] [name        ] [value    ]
           [meta        ] [return   ]
                          [(xirr)   ]
─────────────────────────────────────
[Current]    [Target]      [Status  ]
  55%          55%        On target
```

---

#### 21.3 Sleeve Pills Widget

**File**: `sleeve_pills.dart`

**Props**:
- `sleeves`: List of sleeves with hierarchy info
- `selectedSleeveId`: Currently selected (null = all)
- `onSleeveSelected`: Callback

**Rendering order**:
1. "All" pill (always first)
2. Top-level sleeves with target % (Core 75%, Satellite 25%)
3. Child sleeves without % (Equities, Bonds, Safe Haven, Growth)

**Pill styling**:
- Unselected: grey background (#f3f4f6), no border
- Selected: white background, dark border (#374151)
- Color dot: 8x8px rounded square matching sleeve color

---

#### 21.4 Data Requirements

Endpoint should return sleeve tree with:

| Field | Description |
|-------|-------------|
| id | Sleeve ID |
| name | Display name |
| parentId | Parent sleeve ID (null for top-level) |
| color | Hex color code |
| targetPct | Target allocation % |
| currentPct | Actual allocation % |
| value | Total value in sleeve |
| return | TWR for selected period |
| xirr | Annualized return |
| assetCount | Number of assets |
| childSleeveCount | Number of child sleeves |

---

**Tasks**:
- [x] Create `ring_chart.dart` custom widget
- [x] Create `sleeve_detail_panel.dart` widget
- [x] Create `sleeve_pills.dart` widget
- [x] Implement selection synchronization across all three
- [x] Add color constants for sleeve colors
- [x] Take screenshot to verify

**Acceptance Criteria**:
- [x] Ring chart renders correct proportions
- [x] Tapping segment selects sleeve
- [x] Selection syncs across ring, pills, detail panel
- [x] Dimming works for unrelated segments
- [x] Detail panel shows correct data
- [x] Screenshot matches mockup

---

### NAPP-022: Issues Endpoint `[implement]`

**Priority**: High | **Status**: `[x]`
**Blocked by**: None (NAPP-020 complete)

**File**: `bagholdr_server/lib/src/endpoints/issues_endpoint.dart`

The Issues endpoint detects portfolio problems and returns them for display in the dashboard issues bar. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### Issue Types

| Type | Detection Logic | Severity |
|------|-----------------|----------|
| `over_allocation` | Sleeve actual% > target% + warningBandPp | warning |
| `under_allocation` | Sleeve actual% < target% - warningBandPp | warning |
| `stale_price` | Asset's latest price older than 24 hours | warning |
| `sync_status` | Time since last Directa import > threshold | info |

---

#### Response Schema

```dart
class Issue {
  String type;           // 'over_allocation', 'under_allocation', 'stale_price', 'sync_status'
  String severity;       // 'warning', 'info'
  String message;        // Human-readable message
  String? sleeveId;      // For allocation issues
  String? assetId;       // For stale price issues
  double? driftPp;       // Percentage points of drift (for allocation)
}

class IssuesResponse {
  List<Issue> issues;
  int totalCount;
}
```

---

#### Message Formats

| Type | Message format |
|------|----------------|
| over_allocation | "{sleeve} +{drift}pp over target" |
| under_allocation | "{sleeve} -{drift}pp under target" |
| stale_price | "{count} assets have stale prices" |
| sync_status | "Last sync: {duration} ago" |

---

**Tasks**:
- [x] Create `IssuesEndpoint` class
- [x] Implement allocation drift detection using portfolio band settings
- [x] Implement stale price detection (24h threshold)
- [x] Implement sync status check
- [x] Return sorted by severity (warnings first)
- [x] Run `serverpod generate`

**Acceptance Criteria**:
- [x] Returns correct issues for test portfolio
- [x] Allocation drift calculated correctly
- [x] Stale prices detected correctly
- [x] Messages formatted correctly

---

### NAPP-023: Chart Feature `[implement]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-016

Portfolio value chart for the Hero section. Reference mockup: [`specs/mockups/native/interactive-w2-refined.html`](mockups/native/interactive-w2-refined.html)

---

#### Chart Specifications

| Property | Value |
|----------|-------|
| Type | Area chart with gradient fill |
| Height | 200px |
| Width | Full viewport (extends past padding) |
| Library | fl_chart or syncfusion_flutter_charts |

---

#### Data Lines

| Line | Color | Style | Data |
|------|-------|-------|------|
| Value | #22c55e (green) | Solid 2.5px | Portfolio value over time |
| Cost basis | #9ca3af (grey) | Dashed 1.5px | Cumulative invested amount |

---

#### Area Fill

Green gradient from top (#22c55e, 35% opacity) to bottom (2% opacity)

---

#### Endpoint: `getPortfolioHistory`

**Request**:
| Parameter | Type | Description |
|-----------|------|-------------|
| portfolioId | int | Portfolio ID |
| period | String | 1M, 3M, 6M, YTD, 1Y, ALL |

**Response**:
```dart
class PortfolioHistoryResponse {
  List<HistoryPoint> points;
  double minValue;
  double maxValue;
}

class HistoryPoint {
  DateTime date;
  double value;      // Portfolio value on this date
  double costBasis;  // Cumulative cost basis on this date
}
```

**Granularity**:
- 1M, 3M, 6M, YTD, 1Y: Daily points
- ALL: Weekly points (to limit data size)

---

#### Visual Elements

| Element | Description |
|---------|-------------|
| Grid lines | Horizontal lines at 25%, 50%, 75% of value range |
| Tooltip | Shows current value in top-right corner (e.g., "€113.5k") |
| X-axis labels | Evenly spaced date labels (Jan, Mar, May... for 1Y) |
| Legend | Below chart: "Invested" (green line), "Cost basis" (dashed) |

---

**Tasks**:
- [ ] Add `getPortfolioHistory()` to valuation endpoint
- [ ] Calculate daily portfolio values for date range
- [ ] Calculate daily cost basis for date range
- [ ] Create chart widget with fl_chart or syncfusion
- [ ] Implement gradient fill
- [ ] Implement dashed line for cost basis
- [ ] Add tooltip overlay
- [ ] Add x-axis date labels
- [ ] Add legend
- [ ] Wire up to period selector
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Chart renders correct data for each period
- [ ] Value line and cost basis line display correctly
- [ ] Gradient fill looks correct
- [ ] Period changes update chart data
- [ ] Screenshot matches mockup

---

### NAPP-023: Research Yahoo Price Oracle `[research]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Understand existing price fetching logic. **No code changes.**

**Files to read**:
- `server/src/oracle/yahoo.ts`

**Tasks**:
- [x] Read yahoo.ts
- [x] Document:
  - How are prices fetched?
  - What API/scraping is used?
  - Rate limiting strategy?
  - Error handling?
- [x] List functions to port

**Deliverable**: Add "Yahoo Oracle Summary" section below.

**Acceptance Criteria**:
- [x] Price oracle logic documented

---

### NAPP-024: Port Price Oracle `[port]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-023

**Tasks**:
- [ ] Create price oracle service in Dart
- [ ] Port Yahoo price fetching
- [ ] Port rate limiting logic
- [ ] Test: fetches correct prices

**Implementation note**: When updating an asset's `yahooSymbol`, auto-clear historical data for the old ticker (`DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata`). This prevents orphaned data accumulating in the database.

**Acceptance Criteria**:
- [ ] Can fetch prices for known symbols
- [ ] Rate limiting works

---

### NAPP-025: Real-time Prices (SSE) `[implement]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-024

**Tasks**:
- [ ] Create SSE endpoint for price streaming
- [ ] Broadcast price updates to connected clients
- [ ] Flutter: SSE client with auto-reconnect
- [ ] Update displayed values when prices change
- [ ] Visual indicator when prices are live/stale

**Acceptance Criteria**:
- [ ] Prices update in real-time
- [ ] Reconnection works

---

### NAPP-026: Research Directa Parser `[research]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: None

Understand existing import logic. **No code changes.**

**Files to read**:
- `server/src/import/directa-parser.ts`
- `server/src/import/derive-holdings.ts`

**Tasks**:
- [ ] Read directa-parser.ts
- [ ] Read derive-holdings.ts
- [ ] Document:
  - CSV format expected
  - Field mapping
  - How holdings are derived from orders
- [ ] List functions to port

**Deliverable**: Add "Directa Parser Summary" section below.

**Acceptance Criteria**:
- [ ] Parser logic documented

---

### NAPP-027: Port Directa Parser `[port]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-026

**Tasks**:
- [ ] Create directa_parser.dart
- [ ] Port CSV parsing logic
- [ ] Port derive-holdings logic
- [ ] Test with sample CSV

**Acceptance Criteria**:
- [ ] Parses Directa CSV correctly
- [ ] Holdings derived correctly

---

### NAPP-028: Import UI `[implement]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-027

**Tasks**:
- [ ] Create ImportEndpoint with `importDirectaCsv()`
- [ ] Create import_screen.dart with file picker
- [ ] Upload progress indicator
- [ ] Results summary (orders imported, errors)
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Can upload Directa CSV
- [ ] Holdings update after import

---

### NAPP-029: Settings `[implement]`

**Priority**: Low | **Status**: `[blocked]`
**Blocked by**: NAPP-004

**Tasks**:
- [ ] Create settings_screen.dart
- [ ] Theme toggle (light/dark/system)
- [ ] Privacy mode toggle (blur values)
- [ ] Server URL configuration (for dev)
- [ ] About/version info

**Acceptance Criteria**:
- [ ] Settings persist across app restarts
- [ ] Theme changes apply immediately

---

## Phase 4: Polish & Release

### NAPP-030: App Icon & Splash Screen `[implement]`

**Priority**: Low | **Status**: `[blocked]`
**Blocked by**: NAPP-016

**Tasks**:
- [ ] Design app icon (or use placeholder)
- [ ] Configure adaptive icon for Android
- [ ] Configure splash screen
- [ ] Test on multiple device sizes

**Acceptance Criteria**:
- [ ] App icon looks good in launcher
- [ ] Splash screen displays on startup

---

### NAPP-031: Build & Distribution `[implement]`

**Priority**: Low | **Status**: `[blocked]`
**Blocked by**: NAPP-030

**Tasks**:
- [ ] Configure Android signing keys
- [ ] Build release APK
- [ ] Test release build on real device
- [ ] Set up web deployment
- [ ] Document release process

**Acceptance Criteria**:
- [ ] Signed APK installs on real device
- [ ] Web build works
- [ ] Release process documented

---

## Research Deliverables

_These sections are filled in by research tasks._

### Valuation Logic Summary

**Formulas & concepts**: See [specs/calculus-spec.md](calculus-spec.md) for all financial calculations (cost basis, MWR/XIRR, bands, etc.)

**Source code**: `server/src/trpc/routers/valuation.ts`

---

#### Endpoints to Port

| Endpoint | Purpose | Powers |
|----------|---------|--------|
| `getPortfolioValuation` | Full valuation with sleeve hierarchy, band violations, health issues | Hero section, Strategy section |
| `getChartData` | Historical invested value + cost basis series (1m/3m/6m/1y/all) | Portfolio chart |
| `getHistoricalReturns` | MWR returns by period + per-asset returns | Return displays, asset list |

---

#### Response Types to Port

| Type | Key Fields |
|------|------------|
| `AssetValuation` | isin, ticker, name, quantity, priceEur, costBasisEur, valueEur, percentOfInvested |
| `SleeveAllocation` | sleeveId, sleeveName, parentSleeveId, budgetPercent, totalValueEur, actualPercentInvested, band, status, deltaPercent |
| `PortfolioValuation` | portfolioId, cashEur, investedValueEur, totalValueEur, totalCostBasisEur, sleeves[], bandConfig, violationCount, stalePriceAssets[], lastSyncAt |
| `ChartDataPoint` | date, investedValue, costBasis |
| `PeriodReturn` | period, currentValue, startValue, absoluteReturn, compoundedReturn, annualizedReturn, periodYears, netCashFlow |
| `AssetPeriodReturn` | isin, currentPrice, historicalPrice, compoundedReturn, annualizedReturn, isShortHolding |

---

#### Helper Functions to Port

| Function | Location | Purpose |
|----------|----------|---------|
| `calculateSleeveTotal` | valuation.ts:198 | Recursive sleeve value including descendants |
| `calculateMWR` | valuation.ts:1683 | XIRR calculation with cash flows |
| `calculateTWR` | returns.dart | TWR calculation for portfolio performance (shown alongside MWR) |
| `formatPeriodLabel` | valuation.ts:1805 | Format years as "1d", "2w", "3mo", "1.5y" |
| `calculateBand` / `evaluateStatus` | utils/bands.ts | Band width and status calculation |

---

#### XIRR Dependency

TypeScript uses the `xirr` npm package. For Dart, either:
1. Port the Newton-Raphson algorithm (~50 lines)
2. Find a Dart package (e.g., `financial` on pub.dev)

The algorithm solves for rate `r` where `Σ CFᵢ × (1+r)^(-tᵢ) = 0`.

### Yahoo Oracle Summary

**Source files**: `server/src/oracle/yahoo.ts`, `rateLimiter.ts`, `cache.ts`, `historical.ts`

---

#### API Endpoints Used

| Endpoint | URL | Purpose |
|----------|-----|---------|
| Search | `https://query1.finance.yahoo.com/v1/finance/search` | ISIN to ticker symbol resolution |
| Chart | `https://query1.finance.yahoo.com/v8/finance/chart/{symbol}` | Price data (current, historical, intraday) |

**Request headers**: `User-Agent: Bagholdr/1.0`, `Accept: application/json`

---

#### Rate Limiting Strategy

- **Global singleton** `YahooRateLimiter` class ensures all requests go through one queue
- **Sequential processing** with minimum 2-second delay between requests (`YAHOO_MIN_REQUEST_DELAY_MS`)
- **Throughput**: ~30 requests/min = 1800/hour (Yahoo's unofficial limit is ~2000/hour)
- **Queue-based**: Requests are enqueued and processed in order, with timing logged

---

#### Error Handling

Custom `YahooFinanceError` class with error codes:

| Code | Trigger | Action |
|------|---------|--------|
| `RATE_LIMITED` | HTTP 403 | Caller should back off |
| `HTTP_ERROR` | Other HTTP errors | Propagate to caller |
| `NOT_FOUND` | Missing data or 404 | Mark ticker as inactive in `ticker_metadata` |

---

#### Data Types

| Type | Fields | Description |
|------|--------|-------------|
| `YahooPriceInfo` | price, currency, instrumentType, timestamp | Current price response |
| `YahooSearchResult` | symbol, exchange, exchangeDisplay, quoteType, shortname | ISIN resolution result |
| `YahooCandle` | date, open, high, low, close, adjClose, volume | Daily OHLCV |
| `YahooIntradayCandle` | timestamp, open, high, low, close, volume | 5-minute OHLCV |
| `YahooDividend` | exDate, amount | Dividend event |
| `YahooHistoricalData` | candles[], dividends[], currency | Full historical response |

---

#### Functions to Port

**From yahoo.ts** (core API calls):

| Function | Purpose | Notes |
|----------|---------|-------|
| `fetchAllSymbolsFromIsin(isin)` | Resolve ISIN to all available Yahoo symbols | Returns all exchanges |
| `fetchSymbolFromIsin(isin)` | Resolve ISIN to best Yahoo symbol | Returns first match |
| `fetchPriceData(symbol)` | Fetch current price | Returns YahooPriceInfo |
| `fetchHistoricalData(symbol, range)` | Fetch daily candles + dividends | range: '1y', '5y', '10y', 'max' |
| `fetchIntradayData(symbol, range)` | Fetch 5-minute candles | range: '1d', '5d' |
| `fetchFxRate(from, to)` | Fetch FX rate via forex pairs | e.g., USDEUR=X |
| `fetchPriceInEur(isin, knownTicker?)` | Convenience: fetch + convert to EUR | Handles FX automatically |
| `adjustConversionRate(currency, rate)` | Handle GBp (pence) conversion | Divides by 100 for GBp |

**From rateLimiter.ts**:

| Class/Function | Purpose |
|----------------|---------|
| `YahooRateLimiter` | Queue-based rate limiter with configurable delay |
| `enqueue<T>(execute)` | Add request to queue, returns Promise<T> |

**From cache.ts** (DB caching layer):

| Function | Purpose |
|----------|---------|
| `getPrice(db, isin, yahooSymbol, forceRefresh?)` | Get price from cache or fetch fresh |
| `getFxRate(db, from, to)` | Get FX rate from cache or fetch fresh |
| `clearExpiredCache(db)` | Remove entries older than TTL (6 hours) |
| `clearAllCache(db)` | Wipe all cached data |

**From historical.ts** (historical data sync):

| Function | Purpose |
|----------|---------|
| `syncHistoricalData(db, ticker)` | Fetch 10y daily data, upsert to DB |
| `syncIntradayData(db, ticker)` | Fetch 5d 5-minute data, upsert + purge old |
| `needsHistoricalSync(db, ticker)` | Check if daily sync needed (not synced today) |
| `needsIntradaySync(db, ticker)` | Check if intraday sync needed (>5 min ago) |
| `getTickersNeedingSync(db, tickers)` | Filter to tickers needing daily sync |
| `getTickersNeedingIntradaySync(db, tickers)` | Filter to tickers needing intraday sync |
| `getHistoricalPrices(db, ticker, start?, end?)` | Query daily prices from DB |
| `getIntradayPrices(db, ticker)` | Query intraday prices from DB |
| `getDividendEvents(db, ticker, start?)` | Query dividends from DB |
| `getTickerMetadata(db, ticker)` | Get sync status for ticker |
| `ensureTickerMetadata(db, tickers)` | Create metadata entries if missing |

---

#### Special Cases

1. **GBp (British pence)**: Prices from Yahoo are in pence, but FX rates are for GBP. The `adjustConversionRate()` function divides by 100 when currency is 'GBp'.

2. **Historical granularity**: Using range='10y' ensures daily granularity. Using 'max' may return monthly data for very old instruments. A warning is logged if Yahoo returns different granularity than requested.

3. **Intraday data retention**: Intraday prices older than 5 days are automatically purged during sync.

4. **Batch inserts**: Historical sync processes candles in batches of 100 to avoid SQL statement size limits.

### Directa Parser Summary

_(To be completed by NAPP-026)_

---

## Completed Tasks

- **NAPP-001**: Development Environment Setup (Flutter 3.38.7, Dart 3.10.7, Android SDK 36.1.0, Serverpod CLI 3.2.3)
- **NAPP-002**: Initialize Serverpod Project (scaffolded native/bagholdr/, Docker + Serverpod, start/stop scripts with --help, emulator + web screenshots, platform-aware server URL)
- **NAPP-003**: Mobile UI Exploration (drawer navigation, light theme, single scrolling page layout, ring chart + detail panel for strategy, sleeve pills for filtering)
- **NAPP-004**: Design System & Theme (theme.dart with seed-based ColorScheme, colors.dart with FinancialColors ThemeExtension + categoryPalette for dynamic categories, formatters.dart for currency/percent/XIRR formatting, theme toggle)
- **NAPP-005**: Portfolio Model (portfolio.spy.yaml with UUID v7 PK; fields: name, bandRelativeTolerance/Floor/Cap, createdAt/updatedAt)
- **NAPP-006**: Asset Model (asset.spy.yaml + asset_type.spy.yaml with UUID v7 PK and AssetType enum; fields: isin, ticker, name, description, assetType, currency, yahooSymbol, archived; unique index on isin)
- **NAPP-007**: Sleeve Model (sleeve.spy.yaml with UUID v7 PK; fields: portfolioId (UUID relation), parentSleeveId (UUID), name, budgetPercent, sortOrder, isCash; index on portfolioId)
- **NAPP-008**: Holding Model (holding.spy.yaml with UUID v7 PK; fields: assetId (UUID relation to assets), quantity, totalCostEur; unique index on assetId)
- **NAPP-009**: Order Model (order.spy.yaml with UUID v7 PK; fields: assetId (UUID relation to assets), orderDate, quantity, priceNative, totalNative, totalEur, currency, orderReference, importedAt; index on assetId)
- **NAPP-010**: DailyPrice Model (daily_price.spy.yaml with UUID v7 PK; fields: ticker, date (YYYY-MM-DD), open, high, low, close, adjClose, volume, currency, fetchedAt; unique composite index on ticker+date)
- **NAPP-010a**: SleeveAssets Model (sleeve_asset.spy.yaml with UUID v7 PK; fields: sleeveId, assetId (UUID relations); unique composite index on sleeveId+assetId for many-to-many relationship)
- **NAPP-010b**: GlobalCash Model (global_cash.spy.yaml with UUID v7 PK; fields: cashId, amountEur, updatedAt; unique index on cashId)
- **NAPP-010c**: PortfolioRules Model (portfolio_rule.spy.yaml with UUID v7 PK; fields: portfolioId (UUID relation), ruleType, name, config (JSON), enabled, createdAt; index on portfolioId)
- **NAPP-010d**: YahooSymbols Model (yahoo_symbol.spy.yaml with UUID v7 PK; fields: assetId (UUID relation), symbol, exchange, exchangeDisplay, quoteType, resolvedAt; indexes on assetId and symbol)
- **NAPP-010e**: PriceCache Model (price_cache.spy.yaml with UUID v7 PK; fields: ticker, priceNative, currency, priceEur, fetchedAt; unique index on ticker)
- **NAPP-010f**: FxCache Model (fx_cache.spy.yaml with UUID v7 PK; fields: pair, rate, fetchedAt; unique index on pair)
- **NAPP-010g**: DividendEvents Model (dividend_event.spy.yaml with UUID v7 PK; fields: ticker, exDate, amount, currency, fetchedAt; unique composite index on ticker+exDate)
- **NAPP-010h**: TickerMetadata Model (ticker_metadata.spy.yaml with UUID v7 PK; fields: ticker, lastDailyDate, lastSyncedAt, lastIntradaySyncedAt, isActive; unique index on ticker)
- **NAPP-010i**: IntradayPrices Model (intraday_price.spy.yaml with UUID v7 PK; fields: ticker, timestamp, open, high, low, close, volume, currency, fetchedAt; unique composite index on ticker+timestamp)
- **NAPP-011**: Database Migration (Serverpod migration for all 15 tables; TypeScript export script `server/src/migration/export-to-json.ts`; Dart import script `bin/import_migration.dart`; migrated 2 portfolios, 28 assets, 5 sleeves, 20 holdings, 161 orders, 40190 daily prices; all FK relationships verified)
- **NAPP-012**: Portfolio List Endpoint (portfolio_endpoint.dart with getPortfolios() returning all portfolios ordered by name; client generated with type-safe portfolio.getPortfolios() method)
- **NAPP-013**: Portfolio Selector Component (widgets/portfolio_selector.dart - dropdown with bottom sheet for portfolio selection, matches mockup header design)
- **NAPP-013a**: Time Range Bar Component (widgets/time_range_bar.dart - 6 equal-width period buttons with TimePeriod enum, active/inactive styling matching mockup, default 1Y selection)
- **NAPP-014**: Research Valuation Logic (documented 3 endpoints: getPortfolioValuation, getChartData, getHistoricalReturns; core calculations: portfolio value, cost basis via Average Cost Method, MWR/XIRR returns, recursive sleeve totals, band evaluation; 5 helper functions to port; edge cases documented; XIRR dependency identified)
- **NAPP-013b**: Hero Value Display Component (hero_value_display.dart - displays invested value, MWR % (green/red), TWR % (grey), absolute return, cash, total; supports hideBalances mode; 6 tests passing)
- **NAPP-015**: Valuation Endpoint (ported from TypeScript: portfolio value, cost basis via Average Cost Method, asset valuations, sleeve allocations, MWR/TWR calculations, band evaluation; returns PortfolioValuation with all fields; includes known issues documentation)
- **NAPP-017**: Holdings Endpoint (holdings_endpoint.dart - getHoldings() with pagination, sleeve/search filtering, MWR/TWR per asset; HoldingResponse with symbol/name/isin/value/costBasis/pl/weight/mwr/twr/sleeveId/sleeveName/assetId/quantity; 7 unit tests)
- **NAPP-018**: Holdings/Assets List UI (assets_section.dart - section header with title/count badge, search bar, horizontally scrollable 3-column table with Asset/Performance/Weight columns, asset rows with name/symbol/value/P&L/MWR/TWR/weight, pagination button, wired to dashboard; 16 unit tests)
- **NAPP-020**: Sleeves Endpoint (sleeves_endpoint.dart - getSleeveTree() returning SleeveTreeResponse with hierarchical SleeveNode tree; calculates allocation percentages, drift status (ok/over/under), MWR/TWR per sleeve for period, asset counts; color mapping; 11 unit tests; end-to-end tested)
- **NAPP-022**: Issues Endpoint (issues_endpoint.dart - getIssues() returning IssuesResponse with Issue list; detects over/under allocation drift using portfolio band settings, stale prices (24h threshold), sync status (last import time); issues sorted by severity (warnings first); 15 unit tests; end-to-end tested)
- **NAPP-013c**: Issues Bar Component (issues_bar.dart - collapsible yellow bar with badge count, expand/collapse animation, issue items with colored dots and action text; 11 unit tests; integrated into dashboard; verified on web and mobile)
- **NAPP-021**: Sleeves/Strategy UI (ring_chart.dart - two concentric donut rings with sleeve hierarchy; sleeve_detail_panel.dart - shows selected sleeve details with allocation metrics; sleeve_pills.dart - horizontal scrollable pills for sleeve selection; selection syncs across all three widgets)
- **NAPP-023**: Research Yahoo Price Oracle (documented Yahoo Finance API integration: Search endpoint for ISIN→ticker resolution, Chart endpoint for prices; rate limiter with 2s delay for ~1800 req/hr; cache.ts for TTL-based price/FX caching; historical.ts for daily/intraday sync with batch upserts; GBp handling; 20+ functions identified for porting)

---

## Notes

### Serverpod Resources
- [Serverpod Documentation](https://docs.serverpod.dev/)
- [Serverpod GitHub](https://github.com/serverpod/serverpod)
- [Flutter + Serverpod Tutorial](https://docs.serverpod.dev/tutorials)

### Flutter Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/) - for additional state management if needed
- [fl_chart](https://pub.dev/packages/fl_chart)
- [syncfusion_flutter_charts](https://pub.dev/packages/syncfusion_flutter_charts)

### Code Style
- Feature-first folder structure
- Small files, single responsibility
- Extract widgets early
- Consistent naming: `*_screen.dart`, `*_endpoint.dart`

### Validation Strategy
- Compare values between old Hono backend and new Serverpod backend
- Use same test portfolio for both
- Verify: totals, returns, allocations match
