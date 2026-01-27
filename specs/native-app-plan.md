# Native App Implementation Plan

Full-stack Dart rebuild of Bagholdr using **Flutter** (frontend) and **Serverpod** (backend). Feature-by-feature vertical slices with shared types.

> **Workflow**: See `ralph.md` for task selection and completion workflow.
> **Completed tasks**: See `native-app-completed.md` for archived completed tasks and research deliverables.

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

### Why UUID Primary Keys?

| Option Considered | Verdict |
|-------------------|---------|
| **Integer IDs** | Serverpod default, simpler, but less portable and requires server round-trip for ID generation. |
| **UUID v4** | Random, but poor index performance due to non-sequential nature. |
| **UUID v7** | ✅ Chosen. Lexicographically sortable (timestamp-based), good index performance, can generate IDs client-side. |

### Repository Strategy

Same repo, subfolder structure:
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

---

## Active Tasks

### NAPP-024: Port Price Oracle `[port]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-023b research complete)

**Tasks**:
- [x] Create price oracle service in Dart
- [x] Port Yahoo price fetching
- [x] Port rate limiting logic
- [x] Test: fetches correct prices

**Implementation note**: When updating an asset's `yahooSymbol`, auto-clear historical data for the old ticker (`DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata`). This prevents orphaned data accumulating in the database.

**Acceptance Criteria**:
- [x] Can fetch prices for known symbols
- [x] Rate limiting works

---

---

### NAPP-026: Research Directa Parser `[research]`

**Priority**: Medium | **Status**: `[x]`
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

**Deliverable**: Add "Directa Parser Summary" section to `native-app-completed.md`.

**Acceptance Criteria**:
- [ ] Parser logic documented

---

### NAPP-027: Port Directa Parser `[port]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-026 complete)

**Tasks**:
- [x] Create directa_parser.dart
- [x] Port CSV parsing logic
- [x] Port derive-holdings logic
- [x] Verify against TypeScript implementation (see below)

**Verification Strategy** (golden-source testing):
1. Dump all rows from the TypeScript SQLite `orders` table as JSON fixture
2. Dump the `holdings` table as expected output
3. Feed the same orders into the Dart `deriveHoldings()` and assert output matches exactly
4. Pay special attention to:
   - Commissions (quantity=0, adds to cost basis without changing position size)
   - Dual-currency: `totalNative = currencyAmount != 0 ? currencyAmount : amountEur`
   - Average cost proportional reduction on sells (both EUR and native tracks)

**Acceptance Criteria**:
- [x] Parses Directa CSV correctly
- [x] Holdings derived correctly
- [x] Dart `deriveHoldings()` output matches TypeScript SQLite `holdings` table exactly when fed the same orders

---

### NAPP-028: Import Endpoint `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-027 complete)

Backend-only. UI/automation TBD later.

**Tasks**:
- [x] Create ImportEndpoint with `importDirectaCsv(csvContent)`
- [x] Parse CSV using directa_parser.dart
- [x] Upsert orders to database (skips duplicates by orderReference)
- [x] Derive holdings using derive_holdings.dart
- [x] Return import result (orders imported, errors)
- [x] Write integration tests

**Acceptance Criteria**:
- [x] Endpoint accepts CSV string
- [x] Orders are persisted to database
- [x] Holdings are recalculated after import
- [x] Returns meaningful result (count, errors)

---

### NAPP-029: Settings `[implement]`

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None (NAPP-004 complete)

**Tasks**:
- [x] Create settings_screen.dart
- [x] Theme toggle (light/dark/system)
- [x] Privacy mode toggle (blur values)
- [x] Server URL configuration (for dev)
- [x] About/version info
- [x] Bottom navigation (Dashboard, Settings)
- [x] Move connection indicator to settings
- [x] Move portfolio selector next to time range bar

**Acceptance Criteria**:
- [ ] Settings persist across app restarts
- [x] Theme changes apply immediately

---

### NAPP-032: Edit Yahoo Symbol `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Allow user to edit the Yahoo symbol for an asset. Changing the symbol should clear historical price data for the old ticker.

**Backend**:
- [x] Add `updateYahooSymbol(assetId, newSymbol)` endpoint
- [x] Clear `DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata` for old symbol
- [x] Update asset record with new symbol

**Frontend**:
- [x] Wire up edit button in `_EditableFieldsSection`
- [x] Show text input dialog for new symbol
- [x] Call endpoint and refresh asset detail on success

**Acceptance Criteria**:
- [x] User can change Yahoo symbol from asset detail page
- [x] Old price data is cleared when symbol changes
- [x] New prices are fetched on next price refresh

---

### NAPP-034: Assign Asset to Sleeve `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Allow user to assign/reassign an asset to a sleeve.

**Backend**:
- [x] Add `assignAssetToSleeve(assetId, sleeveId)` endpoint (null sleeveId = unassign)
- [x] Update asset record

**Frontend**:
- [x] Wire up edit button in `_EditableFieldsSection`
- [x] Fetch available sleeves for picker
- [x] Show picker dialog with sleeve options + "Unassigned"
- [x] Call endpoint and refresh asset detail on success

**Acceptance Criteria**:
- [x] User can assign asset to a sleeve
- [x] User can unassign asset from sleeve
- [x] Dashboard sleeve grouping updates accordingly

---

### NAPP-036: Clear Price History `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

Clear all historical price data for an asset (useful when data is corrupted or wrong symbol was used).

**Backend**:
- [ ] Add `clearPriceHistory(assetId)` endpoint
- [ ] Delete `DailyPrice`, `IntradayPrice` records for asset
- [ ] Optionally clear `DividendEvent`, `TickerMetadata`

**Frontend**:
- [ ] Wire up "Clear price history" menu item
- [ ] Show confirmation dialog (destructive action)
- [ ] Call endpoint and show result

**Acceptance Criteria**:
- [ ] User can clear price history with confirmation
- [ ] Price data is removed from database
- [ ] Asset shows "no price data" state until next refresh

---

### NAPP-037: Archive Asset `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

Archive an asset to hide it from the main view (for sold positions or mistakes).

**Backend**:
- [ ] Add `archived` boolean field to Asset model
- [ ] Add `archiveAsset(assetId, archived)` endpoint
- [ ] Filter archived assets from holdings queries by default
- [ ] Create migration

**Frontend**:
- [ ] Wire up "Archive asset" menu item
- [ ] Show confirmation dialog
- [ ] Navigate back to dashboard on success (asset no longer visible)
- [ ] Consider: settings toggle to show archived assets

**Acceptance Criteria**:
- [ ] User can archive an asset
- [ ] Archived assets don't appear in dashboard
- [ ] (Optional) User can view/unarchive from settings or filter

---

### NAPP-038: Add Portfolio Weight to Asset Detail `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

Display the asset's weight as a percentage of the total portfolio value.

**Backend**:
- [ ] Add `weightPct` field to `AssetDetailResponse` (already may exist, verify)
- [ ] Calculate: `(asset value / portfolio total value) * 100`

**Frontend**:
- [ ] Display weight in position summary section
- [ ] Format as percentage (e.g., "12.5%")

**Acceptance Criteria**:
- [ ] Asset detail shows weight relative to total portfolio
- [ ] Weight updates when value changes

---

### NAPP-039: Asset Performance Chart with Order Events `[implement]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: None

Add an interactive TWR chart to the asset detail page, with buy/sell order markers overlaid.

**Backend**:
- [ ] Add `getAssetChartData(assetId, portfolioId, period)` endpoint
- [ ] Return time series of cumulative TWR for the asset (same date range logic as portfolio chart)
- [ ] Include order events in response: `{ date, orderType, quantity }`

**Frontend** (reuse ergonomics from `PortfolioChart`):
- [ ] Create `AssetPerformanceChart` widget
- [ ] X-axis: days-from-start with smart label intervals (same as portfolio chart)
- [ ] Y-axis: percentage (TWR), auto-scaled with padding
- [ ] Main line: cumulative TWR with gradient fill
- [ ] Order markers: scatter points or vertical lines at buy (green up arrow/dot) and sell (red down arrow/dot) dates
- [ ] Interactive: tap to see TWR value + date in tooltip
- [ ] When touching near an order marker, show order details in tooltip (type, quantity)
- [ ] Legend: "TWR" line + "Buy" / "Sell" markers

**UX considerations**:
- Chart should respect the selected time period from the TimeRangeBar
- Order markers only shown if they fall within the selected period
- If no TWR data available (new asset), show placeholder message

**Reference**: `lib/widgets/portfolio_chart.dart` for axis implementation and touch handling

**Acceptance Criteria**:
- [ ] Chart displays cumulative TWR for asset over selected period
- [ ] Buy/sell orders are visible as overlaid markers
- [ ] Touch interaction shows TWR value and date
- [ ] Touching order marker shows order details
- [ ] Same visual polish as portfolio chart

---

### NAPP-040: Move Strategy Section to Dedicated Page `[implement]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Move the Strategy section to a dedicated page AS-IS. Preserve all current functionality but remove the asset filtering behavior. This is a stepping stone before future redesign.

**What to preserve**:
- Two-ring pie chart with animations
- Sleeve selection → shows stats panel (slide animation)
- Sleeve pills for quick selection
- Time range selector (same as dashboard)
- Portfolio picker (same as dashboard)

**What to remove/change**:
- Clicking a sleeve NO LONGER filters assets on dashboard
- No assets displayed on this page (pure strategy visualization)

**Tasks**:
- [x] Create `strategy_screen.dart`
- [x] Move `StrategySectionV2` content to new screen
- [x] Add TimeRangeBar and portfolio selector
- [x] Add navigation to Strategy page (bottom nav tab)
- [x] Remove `StrategySectionV2` from `portfolio_list_screen.dart`
- [x] Remove `onSleeveSelected` callback that was filtering dashboard assets

**Acceptance Criteria**:
- [x] Strategy page shows pie chart with full current functionality
- [x] Time period and portfolio can be selected on Strategy page
- [x] Dashboard no longer shows the pie chart
- [x] Sleeve selection on Strategy page does NOT affect dashboard

---

### NAPP-041: Dashboard Asset Filter `[implement]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: NAPP-040

Add a compact, extensible filter to the dashboard for filtering the assets list. Initial implementation filters by sleeve, but design should accommodate future filter types.

**NOT pills** - need a more scalable UX pattern.

**Design ideas to explore**:
- Filter bar with dropdown/popover for each filter type
- Single "Filter" button that opens a sheet with all filter options
- Inline chips that appear when filters are active (showing active state)
- Segmented control or tab-style for primary filter (sleeve)

**Potential future filter extensions**:
- Asset type (ETF, Stock, Bond, etc.)
- Geographic exposure (if tracked)
- Sector/industry
- Performance (gainers/losers)
- Holding period (short-term vs long-term)

**Requirements**:
- [ ] Compact - minimal vertical space when no filter active
- [ ] Extensible - architecture allows adding new filter types
- [ ] Clear active state - obvious what filters are applied
- [ ] Quick to use - minimal taps to filter
- [ ] Easy to clear - one tap to reset all filters

**Tasks**:
- [ ] Design filter UX (mockup or prototype)
- [ ] Implement sleeve filter as first filter type
- [ ] Show active filter indicator
- [ ] Wire up to holdings query (sleeveId parameter already exists)

**Related files**:
- `lib/screens/portfolio_list_screen.dart` - dashboard layout
- `lib/widgets/assets_section.dart` - assets list that will be filtered

**Acceptance Criteria**:
- [ ] Dashboard has compact filter UI
- [ ] Can filter assets by sleeve
- [ ] Filter state is visually clear
- [ ] Design accommodates future filter types

---

### NAPP-042: Strategy Page Redesign `[exploration]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: NAPP-040

**This is an exploratory task.** The Strategy page (created in NAPP-040) needs a complete redesign. Everything is open for reconsideration.

**Open questions**:
- What is the purpose of this page?
- Should it show assets? Which ones? How?
- How should sleeves be visualized? (pie chart? bars? treemap? list?)
- Should it include rebalancing suggestions?
- Should it allow sleeve management (create, edit, delete, assign assets)?
- Should it show allocation over time (historical)?
- Should it compare against benchmarks?
- Should it show drift analysis in more detail?

**Possible directions**:
1. **Rebalancing focus**: Show current vs target, suggest trades
2. **Analytics focus**: Performance by sleeve, attribution analysis
3. **Management focus**: CRUD for sleeves, drag-drop asset assignment
4. **Monitoring focus**: Drift alerts, allocation health

**Deliverable**: Before implementation, create mockups exploring 2-3 different directions and get user feedback.

**Acceptance Criteria**:
- [ ] Explore multiple design directions
- [ ] Create mockups for preferred approach
- [ ] Get user sign-off before implementation

---

---

### NAPP-101: Short Holding Period Indicator `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

When a sleeve or asset was acquired after the selected period's start date (e.g., user selects "1Y" but asset was bought 6 months ago), display a visual hint indicating the actual period.

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

## Phase 4: Polish & Release

### NAPP-030: App Icon & Splash Screen `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

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
