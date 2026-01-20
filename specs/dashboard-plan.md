# Dashboard Implementation Plan

This document contains discrete implementation tasks for the dashboard feature. Each task is a **vertical slice** - delivering end-to-end functionality from UI to data layer.

## How to Use This Plan

1. Pick the highest-priority unblocked task
2. Complete the task following its acceptance criteria
3. Mark the task as done
4. Add any new tasks discovered during implementation

---

## Task Status Legend

- `[ ]` - Not started
- `[~]` - In progress
- `[x]` - Done
- `[blocked]` - Blocked by another task

---

## Phase 1: Foundation

### DASH-001: Route and Layout Skeleton

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Create the dashboard route with the full layout structure using mock data.

**Deliverables**:
- New route at `src/routes/dashboard-v2/+page.svelte`
- Complete layout matching mockup (all sections present)
- Hardcoded mock data - no API calls yet
- Basic styling to match mockup structure

**Sections to include**:
1. Top section: Invested, Return (with period buttons), Cash, Total Value
2. Issues bar (with sample issues)
3. Main grid: Chart placeholder + Sleeves panel
4. Assets table with sample data

**Reference**: `specs/mockups/dashboard/mockup-chart-minimal.html`

**Acceptance Criteria**:
- [x] Route loads at `/dashboard-v2`
- [x] All sections visible and positioned correctly
- [x] Period buttons toggle (update local state, mock values)
- [x] Sleeves show hierarchy with indentation
- [x] Assets table renders with columns
- [x] Issues bar displays sample chips

**Notes**: This establishes the visual structure. All data is fake. We'll wire up real data in subsequent tasks.

**Completed**: 2026-01-12

---

### DASH-002: Portfolio Selector and Context

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-001

Add portfolio selection and establish the data loading pattern.

**Deliverables**:
- Portfolio dropdown (hidden if only one portfolio)
- tRPC query to fetch portfolio list
- Selected portfolio stored in reactive state
- Loading/error states for the page

**API needed**: Use existing `portfolios.list` or similar

**Acceptance Criteria**:
- [x] Dropdown shows available portfolios
- [x] Dropdown hidden when only one portfolio exists
- [x] Selected portfolio ID available to child sections
- [x] Loading spinner while fetching
- [x] Error message on failure

**Completed**: 2026-01-12

---

## Phase 2: Core Sections (Vertical Slices)

### DASH-003: Top Section with Real Data

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-002

Wire up the top stats section with real portfolio data.

**Deliverables**:
- Extended `valuation.getPortfolioValuation` with `totalCostBasisEur` and `lastSyncAt`
- Connect UI to real data
- Period selector switches displayed return values ("Total" works, others show "--" pending historical data)
- Sync status shows last sync time from price cache

**Implementation Notes**:
- Added `totalCostBasisEur` to valuation response (sum of all cost basis)
- Added `lastSyncAt` to valuation response (max fetchedAt from priceCache)
- Frontend calculates Total Return: `(investedValueEur - totalCostBasisEur) / totalCostBasisEur * 100`
- Historical period returns (Today, 1W, 1M, YTD, 1Y) require historical portfolio value calculation (future task)

**Acceptance Criteria**:
- [x] Invested, Cash, Total Value show real numbers
- [x] Return values update when period changes
- [x] Sync time displayed (or "Never" if null)
- [x] Handles zero holdings gracefully

**Completed**: 2026-01-12

---

### DASH-004: Sleeves Panel with Real Data

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-002

Wire up the sleeves panel with real allocation data.

**Deliverables**:
- tRPC endpoint or extend existing valuation router
- Sleeves displayed in hierarchy order
- Allocation, target, and status badge shown
- Click handler sets filter state (no filtering yet)

**API Shape**:
```typescript
{
  sleeves: Array<{
    id: string;
    name: string;
    parentId: string | null;
    depth: number;
    value: number;
    actualPercent: number;
    targetPercent: number;
    bandStatus: 'ok' | 'warning' | 'over' | 'under';
    deviation: number;
  }>;
}
```

**Acceptance Criteria**:
- [x] Sleeves load from API
- [x] Hierarchy displayed with indentation and `└`
- [x] Status badges show correct colors
- [x] Click highlights row and stores selected sleeve ID

**Completed**: 2026-01-12

---

### DASH-005: Assets Table with Real Data

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-002

Wire up the assets table with real holdings data.

**Deliverables**:
- tRPC endpoint for holdings with metrics
- Table displays all columns
- Sorting by column header click
- Default sort: Value descending

**API Shape**:
```typescript
{
  holdings: Array<{
    id: string;
    ticker: string;
    name: string;
    sleeveId: string | null;
    sleeveName: string | null;
    quantity: number;
    value: number;
    weight: number;
    returnPercent: number;
  }>;
}
```

**Implementation Notes**:
- Holdings data sourced from existing `valuation.getPortfolioValuation` endpoint
- Data extracted from `sleeves[].directAssets` plus `unassignedAssets`
- Unassigned assets display with distinctive amber "Unassigned" tag
- Sorting implemented client-side with all columns sortable
- Return calculated as `(value - costBasis) / costBasis * 100`

**Acceptance Criteria**:
- [x] Holdings load from API
- [x] All columns display correctly
- [x] Column header click sorts table
- [x] Sort direction toggles on repeat click
- [x] Footer shows asset count

**Completed**: 2026-01-12

---

### DASH-006: Sleeve Filter Integration

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: DASH-004, DASH-005

Connect sleeve selection to assets table filtering.

**Deliverables**:
- Sleeve click filters assets table
- Toggle behavior (click again to clear)
- Parent sleeve includes children's assets
- Dropdown in table header syncs with selection
- "All Sleeves" option to clear filter

**Implementation Notes**:
- `selectedSleeveId` state shared between sleeve panel and dropdown (two-way binding)
- `filteredHoldings` reactive block filters holdings by sleeve ID
- Parent sleeve selection includes child sleeves via `parentId` lookup
- `toggleSleeveFilter()` toggles selection on second click

**Acceptance Criteria**:
- [x] Clicking sleeve filters table to that sleeve's assets
- [x] Clicking same sleeve clears filter
- [x] Parent sleeve shows parent + children assets
- [x] Dropdown and panel selection stay in sync
- [x] Footer updates: "Showing X of Y assets (Sleeve Name)"

**Completed**: 2026-01-12

---

### DASH-007: Issues Bar with Real Data

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: DASH-002

Wire up the issues bar with real health data.

**Deliverables**:
- tRPC endpoint for health issues
- Issues displayed as colored chips
- Click shows alert with details
- Bar hidden when no issues

**Issue Types**:
- Error (red): Missing Yahoo symbol
- Warning (yellow): Stale prices, Unassigned assets
- Allocation (purple): Drift, Concentration violations

**Implementation Notes**:
- Extended `valuation.getPortfolioValuation` with `missingSymbolAssets` and `stalePriceAssets`
- `missingSymbolAssets` contains holdings where `asset.yahooSymbol` is null
- `stalePriceAssets` contains assets with `fetchedAt` older than 24 hours
- Frontend `getIssues()` builds issue objects with `detail` and `action` fields for click handlers
- Issues bar correctly hides when empty (verified via Playwright screenshot)

**Acceptance Criteria**:
- [x] Issues load from API
- [x] Correct colors per issue type
- [x] Click shows details in alert/modal
- [x] Bar completely hidden when empty

**Completed**: 2026-01-12

---

### DASH-008: Invested Value Chart

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: DASH-002

Implement the historical value chart.

**Deliverables**:
- tRPC endpoint for chart data
- Line chart with Invested Value and Cost Basis lines
- Time range selector (1M, 3M, 6M, 1Y, All)
- Legend below chart

**API Shape**:
```typescript
{
  dataPoints: Array<{
    date: string;
    investedValue: number;
    costBasis: number;
  }>;
}
```

**Implementation Notes**:
- Created `getChartData` endpoint in `valuation` router
- Uses `orders` table to reconstruct historical positions at each date
- Queries `dailyPrices` for historical closing prices
- Calculates portfolio value and cost basis for each date with price data
- Frontend uses `lightweight-charts` library (TradingView)
- Chart respects privacy mode (hides Y-axis values when enabled)
- Loading and error states handled gracefully

**Acceptance Criteria**:
- [x] Chart renders with both lines
- [x] Time range buttons switch data
- [x] Legend shows line meanings
- [x] Handles sparse data gracefully

**Completed**: 2026-01-12

---

## Phase 3: Polish

### DASH-009: Real-Time Updates

**Priority**: Low | **Status**: `[x]`
**Blocked by**: DASH-003, DASH-005

Subscribe to WebSocket events for live updates.

**Deliverables**:
- Subscribe to `price_update`, `sync_complete` events
- Refresh data automatically on events
- Update sync time indicator

**Implementation Notes**:
- Integrated existing `serverEvents` store from `$lib/stores/serverEvents.ts`
- Connected to WebSocket on mount via `serverEvents.connect()`
- Watches `$recentlyUpdated` store (updated on each `price_update` event) with debouncing (500ms)
- Refreshes valuation and historical returns when any price updates
- Added CSS blink animation (`price-updated` class) to asset rows when their price is recently updated
- Sync status indicator shows connection status (green when connected, amber when disconnected)

**Acceptance Criteria**:
- [x] Dashboard refreshes after price sync
- [x] Sync time updates
- [x] No manual refresh needed
- [x] Asset rows blink briefly when their price updates
- [x] Top section metrics update automatically

**Completed**: 2026-01-13

---

### DASH-010: Responsive Layout

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: DASH-001 through DASH-008

Ensure dashboard works across screen sizes.

**Deliverables**:
- Desktop: Chart + Sleeves side by side
- Tablet: Stack vertically
- Mobile: Single column, possibly card layout for assets

**Acceptance Criteria**:
- [ ] Usable at 1200px+ (desktop)
- [ ] Usable at 768-1199px (tablet)
- [ ] Usable below 768px (mobile)

---

## Discovered Tasks

### DASH-011: Historical Portfolio Value Calculation

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Implement historical portfolio value calculation for period returns (Today, 1W, 1M, YTD, 1Y).

**Deliverables**:
- Utility function to calculate portfolio value at a historical date
- Use orders history to determine quantities held on each date
- Look up prices from `dailyPrices` or use nearest available date
- Integrate with dashboard to replace "--" with real values

**Background**:
Currently the Top Section only shows Total Return (vs cost basis). Other periods require calculating what the portfolio value was on historical dates, which needs:
1. Reconstructing quantities held on that date (from order history)
2. Finding prices on that date (from dailyPrices table)
3. Computing the aggregate portfolio value

**Implementation Notes**:
- Created `getHistoricalReturns` endpoint in valuation router
- Reuses position snapshot logic from `getChartData`
- Uses 5-day lookback for price data to handle weekends/holidays
- Frontend calls endpoint on portfolio selection and updates return display
- Uses priceCache for current value (consistency with header) and dailyPrices for historical

**Acceptance Criteria**:
- [x] Calculate portfolio value for any historical date
- [x] Handle missing price data gracefully (use nearest available)
- [x] Returns for Today, 1W, 1M, YTD, 1Y show real values

**Completed**: 2026-01-12

---

### DASH-012: Privacy Mode Toggle

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: DASH-003, DASH-004, DASH-005

Add a toggle to hide currency values for screen sharing or privacy.

**Deliverables**:
- Eye icon toggle button in top-right area (near sync status)
- `privacyMode` reactive state stored in `localStorage`
- CSS class or utility to blur/hide currency values
- Apply hiding to all monetary amounts across dashboard

**Elements to Hide** (when privacy mode enabled):
- Top section: Invested, Return (EUR amount), Cash, Total Value
- Sleeves panel: Value column (EUR)
- Assets table: Value column (EUR)
- Chart: Y-axis labels and tooltip values

**Elements to Keep Visible**:
- Return percentages (e.g., +9.4%)
- Allocation percentages (72% / 70%)
- Deviation badges (+2pp, -1pp, ok)
- Weight percentages
- Asset return percentages
- Quantities

**Implementation Notes**:
- Overlay approach: original value stays in DOM (preserves layout), placeholder overlays with `position: absolute`
- Placeholder uses `•••••` with subtle 2px blur for visual polish
- Must use inline `{#if}` blocks (not helper functions) for Svelte reactivity
- Toggle icon: `EyeIcon` (visible) / `EyeOffIcon` (hidden) - inline SVG
- Read initial state from `localStorage` on mount
- Persist state changes to `localStorage`

**Acceptance Criteria**:
- [x] Toggle button visible in top-right area
- [x] Clicking toggle hides all currency values
- [x] Clicking again reveals values
- [x] Percentage values remain visible when hidden
- [x] State persists across page refresh
- [x] Smooth visual transition (blur or fade)

**Completed**: 2026-01-12

---

### DASH-013: Time-Weighted Return (TWR) for Period Returns

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-011

Replace naive return calculation with Time-Weighted Return (TWR) to accurately measure portfolio performance when cash flows (purchases/sales) occur.

**Background**:
The current implementation (DASH-011) calculates period returns as:
```
Return = (Current Value - Historical Value) / Historical Value
```

This is misleading when purchases/sales occur during the period. For example:
- Portfolio value 30 days ago: €86k
- User deposits €19k and buys shares
- Portfolio value today: €111k
- Naive calculation: +29% (wrong - includes new deposits as "gains")

**What is TWR?**
Time-Weighted Return neutralizes the impact of cash flows by:
1. Breaking the period into sub-periods at each cash flow
2. Calculating return for each sub-period
3. Geometrically linking the sub-period returns

Formula:
```
TWR = [(1 + R1) × (1 + R2) × ... × (1 + Rn)] - 1

Where Ri = (Ending Value before cash flow - Beginning Value) / Beginning Value
```

**Deliverables**:
- Utility function to calculate TWR for any date range
- Detect cash flow dates from orders table
- Calculate sub-period returns between cash flows
- Update `getHistoricalReturns` endpoint to use TWR
- Update `calculus-spec.md` with TWR formula and explanation

**Implementation Notes**:
- Cash flows are detected from `orders` table (buys = inflow, sells = outflow)
- Commissions (qty = 0) are excluded as they're not external cash flows
- Portfolio value before cash flow uses previous day's closing price
- After cash flow, new base = previous value + cash flow amount
- TWR result includes `usedTWR` flag and `cashFlowCount` for transparency
- Both absolute and percentage returns use TWR for consistency: `absoluteReturn = comparisonValue × TWR`

**Acceptance Criteria**:
- [x] TWR calculation utility implemented
- [x] Period returns account for cash flows correctly
- [x] Returns match expected values when purchases occur mid-period
- [x] `calculus-spec.md` updated with TWR documentation
- [x] Edge cases handled (no cash flows, multiple same-day flows)

**Completed**: 2026-01-12

---

### DASH-015: Switch to MWR with Annualized + Compounded Display

**Priority**: High | **Status**: `[x]`
**Blocked by**: DASH-013

Replace all return calculations with Money-Weighted Return (MWR), showing both compounded and annualized forms. This gives users their actual rate of return in a mathematically correct way.

**Background**:

TWR and MWR answer different questions:
- **TWR**: "How did the investment perform?" (ignores cash flow timing) → for benchmarks
- **MWR**: "What return did I earn on my money?" (accounts for cash flow timing) → for users

**Two Forms of MWR**:
| Form | What it shows | Example |
|------|---------------|---------|
| **Annualized MWR** | Rate of return per year | 8.5% p.a. |
| **Compounded MWR** | Total return over the period | 33.4% |

Relationship: `Compounded = (1 + Annualized)^years - 1`

**What is MWR?**

MWR (also called XIRR - Extended Internal Rate of Return) finds the constant annual rate of return that would produce the actual profit, given when money was added/removed.

Formula: Solve for `r` (annual rate) in:
```
Starting Value × (1+r)^t + Σ CashFlow_i × (1+r)^(t-t_i) = Ending Value

Where:
- t = total time period (in years)
- t_i = time of each cash flow (in years from start)
- CashFlow_i = amount of each deposit (+) or withdrawal (-)
```

**Example**:
- Jan 1: Start with €100k
- Jul 1: Add €20k
- Dec 31: End with €130k
- Profit: €10k

MWR calculation:
- Find annual rate r where: €100k×(1+r) + €20k×(1+r)^0.5 = €130k
- Solution: r ≈ 8.5% (annualized)
- Compounded over 1 year: 8.5%

Compare to:
- TWR: ~17% (market performance, ignores that €20k was added late)
- Simple: 10% (€10k/€100k, ignores the €20k entirely)
- MWR: 8.5% p.a. (actual rate of return)

**Key Changes**:

1. **Rename "Total" to "All"** - It's now just another period (since inception), not a different calculation
2. **Show both compounded and annualized MWR** - Format: `+33.4% (+8.5% p.a.)`
3. **All periods use same calculation** - MWR via XIRR
4. **Assets follow selected period** - With fallback to inception if held shorter

**Deliverables**:
- [x] Create XIRR calculation utility using a library
- [x] Replace TWR with MWR in `getHistoricalReturns` endpoint
- [x] Return both annualized and compounded MWR values
- [x] Rename "Total" period to "All" in UI
- [x] Update absolute return calculation: `Profit = Current - Start - Net Deposits`
- [x] Keep TWR implementation available for future benchmark feature
- [x] Update `calculus-spec.md` with MWR formulas

**Implementation Notes**:
- Use **XIRR** (not IRR) because cash flows happen on specific dates
- Use a library for XIRR calculation (don't hand-roll):
  - Option 1: `xirr` npm package
  - Option 2: `financial` npm package
- XIRR returns annualized rate directly
- Calculate compounded: `(1 + annualized)^years - 1`
- Handle edge case: no cash flows → simple return
- Handle edge case: very short period (< 1 day) → show simple return
- Handle edge case: XIRR fails to converge → fall back to simple return

**API Response Changes**:
```typescript
interface PeriodReturn {
  period: 'today' | '1w' | '1m' | 'ytd' | '1y' | 'all';
  currentValue: number;
  startValue: number;
  absoluteReturn: number;        // Profit (current - start - deposits)
  compoundedReturn: number;      // Total % return over period
  annualizedReturn: number;      // % per year (p.a.)
  periodYears: number;           // Length of period in years
  comparisonDate: string;
  netCashFlow: number;
  cashFlowCount: number;
}
```

**Assets Table**:

Assets show MWR for the **selected period**, with special handling for short holdings:

| Scenario | Behavior |
|----------|----------|
| Asset held ≥ selected period | Show MWR for selected period |
| Asset held < selected period | Show MWR since inception + visual indicator |

**Visual indicator for short holdings**:
- Small clock icon or badge showing actual holding period (e.g., "6mo")
- Tooltip: "Held for 6 months - showing return since purchase"

**Per-Asset Response**:
```typescript
interface AssetReturn {
  isin: string;
  compoundedReturn: number;
  annualizedReturn: number;
  periodYears: number;           // Actual period used (may be < selected if short holding)
  isShortHolding: boolean;       // True if using inception instead of selected period
  holdingPeriodLabel?: string;   // "6mo", "3mo", etc. if short holding
}
```

**Sleeves Panel**:

Sleeves also show MWR for the selected period, following the same logic as assets:

| Scenario | Behavior |
|----------|----------|
| Sleeve has assets held ≥ selected period | Show MWR for selected period |
| Sleeve inception < selected period | Show MWR since sleeve inception + indicator |

**Sleeve MWR Calculation**:
- Cash flows = all buy/sell orders for assets currently in that sleeve
- Treats the sleeve as a "mini portfolio"
- Same XIRR calculation as portfolio level
- Parent sleeves include child sleeve assets in calculation

**Per-Sleeve Response**:
```typescript
interface SleeveReturn {
  sleeveId: string;
  compoundedReturn: number;
  annualizedReturn: number;
  periodYears: number;
  isShortHolding: boolean;
  holdingPeriodLabel?: string;
}
```

**Display in Sleeves Panel**:
Add a return column showing compounded MWR:
```
Sleeve      Value     Actual/Target   Return
Core        €88,931   80% / 80%       +12.3%
Satellite   €22,310   20% / 20%       +8.7%
└ Growth    €15,200   14% / 15%       +15.2% 🕐
```

**Acceptance Criteria**:
- [x] XIRR library integrated for MWR calculation
- [x] All periods (Today, 1W, 1M, YTD, 1Y, All) use MWR
- [x] Both compounded and annualized returns displayed
- [x] "Total" renamed to "All" in period selector
- [x] Absolute return shows actual profit (subtracts deposits)
- [x] Assets show MWR for selected period
- [ ] Sleeves show MWR for selected period (deferred - separate task)
- [ ] Parent sleeves aggregate child sleeve assets for MWR (deferred)
- [x] Short holdings (assets) show inception MWR with visual indicator
- [x] TWR code preserved for future benchmark feature
- [x] `calculus-spec.md` updated with MWR documentation

**Completed**: 2026-01-12

---

### DASH-016: Fix Sleeve Hierarchy Display

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Fix incorrect parent-child relationship display in the sleeves panel. Currently, subsleeves of Satellite (Safe Haven and Growth) are incorrectly displayed with one appearing as a child of Core.

**Problem**:
- Safe Haven and Growth are both children of Satellite sleeve
- UI incorrectly shows one subsleeve under Core instead of Satellite
- Likely a bug in how `parentId` is resolved or how the hierarchy is sorted/rendered

**Root Cause**:
The sleeves were ordered by `sortOrder` from the database, but this didn't ensure children appeared directly after their parents. If Safe Haven (parent: Satellite) had a lower sortOrder than Satellite itself, it would appear after Core, visually looking like Core's child.

**Solution**:
Added `sortSleevesHierarchically()` helper function in `+page.svelte` that reorders sleeves so children always appear immediately after their parent:
1. Groups sleeves by parentId
2. Recursively traverses from root sleeves, adding each sleeve followed by its children
3. Ensures proper visual hierarchy regardless of database sortOrder

**Acceptance Criteria**:
- [x] Both Safe Haven and Growth display as children of Satellite
- [x] Hierarchy indentation is correct (parent at level 0, children at level 1)
- [x] `└` prefix appears only on actual child sleeves

**Completed**: 2026-01-13

---

### DASH-017: Add Decimal Precision to Sleeve Allocation Percentages

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Add one decimal place to sleeve allocation percentages to fix rounding inconsistencies. Currently, subsleeve percentages don't visually add up to their parent sleeve percentage due to integer rounding.

**Problem**:
- Sleeve percentages are displayed as integers (e.g., 20%, 15%, 5%)
- When subsleeves are displayed, rounding can make them appear inconsistent
- Example: Parent shows 20%, but children show 15% + 6% = 21% (rounding artifact)
- Users expect: subsleeve percentages should sum to parent percentage

**Solution**:
- Display percentages with one decimal place (e.g., 20.0%, 14.8%, 5.2%)
- Apply to both "actual" and "target" percentage columns
- This provides enough precision for the numbers to add up correctly

**Implementation Notes**:
- Removed `Math.round()` from sleeve mapping to preserve decimal precision
- Added `.toFixed(1)` formatting in display template for both actual and target percentages
- Example: Core shows 75.5%/75.0%, subsleeves Safe Haven (8.0%) + Growth (16.5%) = Satellite (24.5%)

**Acceptance Criteria**:
- [x] Allocation percentages show one decimal place (e.g., 72.3% / 70.0%)
- [x] Subsleeve percentages visually sum to parent percentage
- [x] Deviation badges remain as integer pp (e.g., +2pp) - no change needed

**Completed**: 2026-01-13

---

### DASH-018: Bulk Asset Type Assignment

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Add bulk editing capability to the assets page for assigning asset types to multiple assets at once.

**Background**:
Currently, users must edit each asset individually to change its type (stock, etf, bond, etc.). For portfolios with many assets, this is tedious. Bulk selection and assignment will significantly improve the workflow.

**Deliverables**:
- [x] Checkbox column in assets table for multi-select
- [x] "Select all" checkbox in header
- [x] Bulk action bar appears when assets are selected
- [x] Asset type dropdown in bulk action bar
- [x] Backend endpoint for bulk asset type update
- [x] Success/error feedback after bulk operation

**Implementation Notes**:
- Selected asset ISINs stored in reactive Set
- Bulk action bar fixed at bottom of screen when selection > 0
- Single tRPC mutation: `assets.bulkUpdateType({ isins: string[], assetType: string })`
- Row highlights in blue when selected
- Indeterminate checkbox state when some (not all) assets selected

**Acceptance Criteria**:
- [x] Can select multiple assets via checkboxes
- [x] Can select/deselect all with header checkbox
- [x] Bulk action bar shows count of selected assets
- [x] Can change asset type for all selected assets
- [x] Table updates after bulk operation
- [x] Selection clears after successful operation

**Completed**: 2026-01-13

---

### DASH-019: Remove Quantity Column from Assets Table

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Remove the quantity column from the assets table on the dashboard as it's not needed for the dashboard view.

**Background**:
The quantity column shows the number of shares held. For the dashboard's purpose of showing portfolio health and allocation, quantity is not essential information. Removing it simplifies the table and improves data density.

**Implementation Notes**:
- Removed 'quantity' from sortColumn type
- Removed Qty column header and sorting functionality
- Removed quantity data cell from each table row
- Table columns now: Asset, Sleeve, Value, Weight, Return

**Deliverables**:
- [x] Remove "Qty" column header from assets table
- [x] Remove quantity data cell from each row
- [x] Adjust table column widths if needed

**Acceptance Criteria**:
- [x] Assets table no longer shows quantity column
- [x] Table layout remains balanced and readable
- [x] No regressions in other table functionality (sorting, filtering)

**Completed**: 2026-01-13

---

### DASH-020: Align Sleeves Panel Styling with Assets Table

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Fix styling inconsistencies in the sleeves panel to match the assets table styling.

**Problems**:
1. Return percentages in sleeves panel are too close to the target allocation column (insufficient spacing)
2. Font size in sleeve rows is smaller than asset table rows
3. Overall row styling should be consistent between both cards

**Deliverables**:
- [x] Add proper spacing/gap between target allocation and return percentage columns
- [x] Increase font size in sleeve rows to match assets table (13px → 14px or match exactly)
- [x] Review and align padding, line-height, and other row styling

**Implementation Notes**:
- Changed grid gap from `gap-2` (8px) to `gap-3` (12px) for better column separation
- Adjusted column widths from `1fr_70px_100px_70px` to `1fr_75px_90px_80px` for better balance
- Removed `text-xs` from all sleeve cells - now use default 14px for parent rows
- Child rows use `text-[13px]` instead of `text-xs` (12px) for subtle but readable size reduction
- Changed return percentages from `font-medium` to `font-semibold` to match assets table styling

**Acceptance Criteria**:
- [x] Return percentages have clear visual separation from target allocation
- [x] Sleeve row font size matches assets table row font size
- [x] Both cards have consistent visual weight and readability
- [x] Verify with Playwright screenshot

**Completed**: 2026-01-13

---

### DASH-021: Stabilize Return Period Button Position

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Fix layout shift where return period buttons (Today, 1W, 1M, YTD, 1Y, All) move horizontally when switching between periods.

**Problem**:
When switching between periods (e.g., 1Y → All), the return values change (different EUR amounts, percentages). Since the value text has variable width, the period buttons shift position. This creates a jarring user experience.

**Root Cause**:
The return data section (label + EUR value + percentage) doesn't have a fixed width, so it expands/contracts based on content.

**Solution**:
Give the return data section a fixed minimum width so the period buttons remain in a stable position regardless of the displayed values.

**Implementation Notes**:
- Changed return data container from `min-w-[200px]` to fixed `w-[260px]` to ensure consistent width
- Added `tabular-nums` class to EUR value span for consistent digit widths
- Added `tabular-nums whitespace-nowrap` to percentage span to prevent line wrapping
- 260px provides enough room for large values like "+€111,000" and annualized returns like "(+53.0% p.a.)"

**Deliverables**:
- [x] Add fixed width to return data container (260px)
- [x] Ensure values use tabular-nums for consistent digit widths
- [x] Test with various value lengths (small vs large numbers, positive vs negative)

**Acceptance Criteria**:
- [x] Period buttons stay in the same position when switching between any periods
- [x] Layout looks balanced with both small and large return values
- [x] No text overflow or truncation issues

**Completed**: 2026-01-14

---

### DASH-022: Remove Non-Functional Asset Tabs

**Priority**: Low | **Status**: `[x]`
**Blocked by**: None

Remove the tab buttons from the assets card header since they are non-functional and redundant.

**Problem**:
The assets card has tabs for "All Assets", "Top Gainers", "Top Losers", "Largest" but they don't do anything. Since column header sorting is already implemented, these tabs are redundant for now.

**Reference**:
The dashboard spec notes these tabs are deferred to later iteration (v1 shows all assets only with sorting).

**Implementation Notes**:
- Removed all tab buttons (All Assets, Top Gainers, Top Losers, Largest)
- Replaced with simple "ASSETS" title matching the Sleeves card styling
- Sleeve filter dropdown preserved on the right side

**Deliverables**:
- [x] Remove the tabs container from assets card header
- [x] Keep the sleeve filter dropdown
- [x] Adjust header layout after removing tabs

**Acceptance Criteria**:
- [x] No tab buttons visible in assets card header
- [x] Sleeve filter dropdown still works
- [x] Header layout remains clean and balanced
- [x] Column header sorting continues to work

**Completed**: 2026-01-13

---

### DASH-023: Show Absolute Return (EUR) per Asset

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Add absolute return (EUR amount) to each asset row in the assets table, respecting the selected time period.

**Background**:
Currently the assets table shows return as a percentage only. Users also want to see the actual EUR profit/loss for each asset. The header already shows absolute return for the portfolio level - this extends that to individual assets.

**Requirements**:
- Display absolute return (EUR) alongside percentage return for each asset
- Respect the selected time period (Today, 1W, 1M, 6M, YTD, 1Y, All)
- For "All" period: `absoluteReturn = currentValue - costBasis`
- For other periods: Calculate profit over that specific period (accounting for any purchases/sales)

**Deliverables**:
- [x] Extend `getHistoricalReturns` API to include `absoluteReturn` per asset per period
- [x] Update assets table to display EUR return value
- [x] Ensure privacy mode hides the EUR value (percentage stays visible)
- [x] Handle edge cases: new positions, short holdings

**Display Format**:
New P/L column between Value and Return columns showing EUR amount:
```
P/L column: +2,941 (green)
Return column: +6.4% (+24% p.a.)
```

**API Changes**:
Extended `AssetPeriodReturn` type:
```typescript
interface AssetPeriodReturn {
  isin: string;
  ticker: string;
  absoluteReturn: number;      // NEW: EUR profit/loss for the period
  compoundedReturn: number;
  annualizedReturn: number;
  periodYears: number;
  isShortHolding: boolean;
  holdingPeriodLabel: string | null;
}
```

**Calculation Logic**:
- For "All" period: `absoluteReturn = currentValue - costBasis` (simple, no MWR needed)
- For other periods: `absoluteReturn = currentValue - historicalValue` (price-based)

**Implementation Notes**:
- Added `absoluteReturn` to `AssetPeriodReturn` interface in `valuation.ts`
- Backend calculates absolute return per asset per period
- Frontend displays P/L column with sorting support
- Privacy mode hides EUR values using same pattern as Value column (invisible + blur overlay)
- Column header shows "P/L" with sort indicator when sorted

**Acceptance Criteria**:
- [x] Each asset row shows EUR profit/loss
- [x] EUR value updates when period selector changes
- [x] Privacy mode hides EUR values, shows percentage only
- [x] Positive values green, negative values red
- [x] Short holdings show return since inception (with indicator)

**Completed**: 2026-01-14

---

### DASH-024: Archive Assets Feature

**Priority**: High | **Status**: `[x]`
**Blocked by**: None

Add ability to archive assets so they are completely excluded from all calculations and dashboard views. This is needed for assets that have been fully sold but lack historical price data (e.g., delisted or unavailable on Yahoo Finance), which otherwise distort chart values by falling back to cost basis.

**Problem**:
Assets without Yahoo Finance data use cost basis as fallback in historical calculations. For fully sold positions, this inflates historical chart values because the system can't determine actual historical prices.

**Solution**:
Allow users to archive assets. Archived assets:
- Remain in the `orders` table (data preserved)
- Remain in the `assets` table (can be unarchived)
- Are excluded from ALL calculations (valuation, chart, returns, allocations)
- Are excluded from dashboard views (top section, sleeves, assets table, issues bar)
- Show in the Assets management page with a visual "Archived" indicator (greyed out)

**Deliverables**:
- [x] Add `archived` boolean column to `assets` table (default: false)
- [x] Add migration for new column
- [x] Backend: Filter out archived assets in `getPortfolioValuation`
- [x] Backend: Filter out archived assets in `getChartData`
- [x] Backend: Filter out archived assets in `getHistoricalReturns`
- [x] Backend: When archiving an asset, remove its sleeve assignment (delete from `sleeveAssets`)
- [x] Backend: New endpoint `assets.setArchived({ isin: string, archived: boolean })`
- [x] Backend: Bulk endpoint `assets.bulkSetArchived({ isins: string[], archived: boolean })`
- [x] Frontend (Assets page): Add toggle/button to archive/unarchive individual assets
- [x] Frontend (Assets page): Grey out archived asset rows with "Archived" badge
- [x] Frontend (Assets page): Add "Archive" / "Unarchive" option to bulk action bar
- [x] Frontend (Assets page): Optional "Show archived" toggle to filter view

**Database Schema Change**:
```sql
ALTER TABLE assets ADD COLUMN archived INTEGER NOT NULL DEFAULT 0;
```

**API Endpoints**:
```typescript
// Toggle single asset
assets.setArchived({ isin: string, archived: boolean })

// Bulk toggle
assets.bulkSetArchived({ isins: string[], archived: boolean })
```

**Acceptance Criteria**:
- [x] Can archive an asset from the Assets page
- [x] Can bulk archive multiple assets
- [x] Archived assets show greyed out with "Archived" badge in Assets list
- [x] Archived assets are excluded from dashboard chart
- [x] Archived assets are excluded from top section metrics
- [x] Archived assets are excluded from sleeves panel
- [x] Archived assets are excluded from dashboard assets table
- [x] Archived assets are excluded from issues bar
- [x] Archiving an asset removes its sleeve assignment
- [x] Can unarchive an asset
- [x] Unarchiving does NOT restore sleeve assignment (must be manually reassigned)

**Completed**: 2026-01-14

---

## Completed Tasks

- **DASH-001**: Route and Layout Skeleton - 2026-01-12
- **DASH-002**: Portfolio Selector and Context - 2026-01-12
- **DASH-003**: Top Section with Real Data - 2026-01-12
- **DASH-004**: Sleeves Panel with Real Data - 2026-01-12
- **DASH-005**: Assets Table with Real Data - 2026-01-12
- **DASH-006**: Sleeve Filter Integration - 2026-01-12
- **DASH-007**: Issues Bar with Real Data - 2026-01-12
- **DASH-008**: Invested Value Chart - 2026-01-12
- **DASH-009**: Real-Time Updates - 2026-01-13
- **DASH-011**: Historical Portfolio Value Calculation - 2026-01-12
- **DASH-012**: Privacy Mode Toggle - 2026-01-12
- **DASH-013**: Time-Weighted Return (TWR) for Period Returns - 2026-01-12
- **DASH-014**: Per-Asset Period Returns in Assets Table - 2026-01-12
- **DASH-015**: Switch to MWR with Annualized + Compounded Display - 2026-01-12
- **DASH-016**: Fix Sleeve Hierarchy Display - 2026-01-13
- **DASH-017**: Add Decimal Precision to Sleeve Allocation Percentages - 2026-01-13
- **DASH-018**: Bulk Asset Type Assignment - 2026-01-13
- **DASH-019**: Remove Quantity Column from Assets Table - 2026-01-13
- **DASH-020**: Align Sleeves Panel Styling with Assets Table - 2026-01-13
- **DASH-021**: Stabilize Return Period Button Position - 2026-01-14
- **DASH-022**: Remove Non-Functional Asset Tabs - 2026-01-13
- **DASH-023**: Show Absolute Return (EUR) per Asset - 2026-01-14
- **DASH-024**: Archive Assets Feature - 2026-01-14

---

### DASH-025: Benchmark Comparison - Requirements Engineering

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: None

Conduct requirements gathering for benchmark comparison feature. This is a discovery task - no implementation yet.

**Background**:
Users want to know "Am I beating the market?" This requires comparing portfolio performance against a benchmark index (e.g., MSCI World, S&P 500). This is a professionally respected metric that drives real decisions.

**Deliverables**:
- [ ] Interview stakeholder to understand use cases and requirements
- [ ] Document answers to key questions (see below)
- [ ] Create `specs/benchmark-spec.md` with requirements
- [ ] Add implementation tasks to this plan based on findings

**Questions to Answer**:

1. **Scope**: Portfolio-level only, or also per-sleeve benchmarks?
2. **Default benchmark**: What should the default be? (MSCI World? S&P 500?)
3. **Custom benchmarks**: Can users pick their own benchmark per portfolio/sleeve?
4. **Time periods**: Same periods as returns (Today, 1W, 1M, YTD, 1Y, All)?
5. **Display location**: In the top section? Separate card? Both?
6. **Display format**: Just delta? Side-by-side values? Chart overlay?
7. **Historical chart**: Show benchmark line on the existing chart?
8. **Data source**: Yahoo Finance indices? Other source?
9. **TWR vs MWR**: Benchmark uses TWR (no cash flows). How to compare fairly with user's MWR?
10. **Edge cases**: What if benchmark data is unavailable for a date?

**Acceptance Criteria**:
- [ ] All questions above have documented answers
- [ ] `specs/benchmark-spec.md` created with clear requirements
- [ ] Implementation tasks added to dashboard plan
- [ ] Stakeholder has approved the spec

---

## Notes

- v1 excludes: theming, benchmark line, dividend tracking, top gainers/losers tabs
- Route is temporary (`/dashboard-v2`), replaces existing dashboard later
- Focus on functionality over visual polish
- API shapes in tasks are suggestions - discover actual needs while building UI
