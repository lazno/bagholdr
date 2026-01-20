# Dashboard Design Specification

## Overview

The dashboard is the **main landing page** of Bagholdr, designed for daily use. It provides a comprehensive view of portfolio health, sleeve balance status, and asset performance at a glance.

### Design Goals

- **Daily driver**: Optimized for quick scanning and identifying what needs attention
- **Information density**: Show meaningful data without overwhelming
- **Live updates**: React to price sync events via tRPC subscriptions
- **Responsive**: Support desktop, tablet, and mobile (challenging for financial data—requires careful consideration)

### Reference Mockup

See [specs/mockups/dashboard/mockup-chart-minimal.html](mockups/dashboard/mockup-chart-minimal.html) for the approved visual design.

---

## Scope

### Single Portfolio Context

- Display one portfolio at a time
- **Portfolio selector**: Dropdown to switch portfolios
- **Auto-hide selector**: If only one portfolio exists, hide the selector entirely

### Privacy Mode

A toggle to hide sensitive currency values for screen sharing, presentations, or public use.

**Toggle Location**: Icon button in top-right area near sync status (eye icon: open = visible, closed = hidden)

**What Gets Hidden** (replaced with `•••••` or CSS blur):
- Invested amount (EUR)
- Return amount (EUR)
- Cash balance (EUR)
- Total value (EUR)
- Sleeve values (EUR) in sleeves panel
- Asset values (EUR) in assets table
- Chart Y-axis values and tooltips

**What Stays Visible**:
- Return percentage (e.g., +9.4%)
- Allocation percentages (e.g., 72% / 70%)
- Deviation badges (+2pp, -1pp, ok)
- Weight percentages in assets table
- Asset return percentages
- Quantities (number of shares)
- All non-monetary information (names, tickers, sleeves, dates)

**Persistence**: State stored in `localStorage` so preference survives page refresh.

**Visual Treatment**: Use CSS `filter: blur(8px)` on hidden values for a subtle, reversible effect. Alternative: replace text with `•••••` placeholder.

---

## Core Sections

### 1. Top Section (Stats Row)

**Purpose**: Show key portfolio metrics in a single scannable row.

**Layout** (left to right):
1. **Invested** (prominent, large) - Total cost basis of all holdings
2. **Return** with period selector - Return amount and percentage
3. **Cash** (secondary) - Cash balance waiting to be invested
4. **Total Value** (secondary) - Current market value of holdings

**Return Period Selector**:
Inline button group next to return values. Available periods:
- **Today** - since previous close
- **1W** - last 7 days
- **1M** - last 30 days
- **YTD** - since Dec 31 of previous year
- **1Y** - last 365 days
- **All** (default) - since first investment

The label updates dynamically: "Today", "1W", "1M", "YTD", "1Y", "All".

All periods use MWR calculation showing both compounded return and annualized rate.

**Layout constraint**: The return data (label + value + percentage) has a fixed minimum width so the period buttons don't shift when values change.

**Sync Status**: Small indicator in top-right showing last sync time (e.g., "Synced 2 min ago").

---

### 2. Issues Bar

**Purpose**: Show actionable issues inline, always visible.

**Location**: Below the top section, above the main content grid.

**Design**: Horizontal bar with issue chips. Each chip is clickable and shows:
- Issue type indicator (colored dot)
- Brief description
- Arrow icon indicating it's actionable

**Issue Types**:

| Type | Style | Example |
|------|-------|---------|
| Error | Red chip | "EXAMPLE.MI missing symbol" |
| Warning | Yellow chip | "3 stale prices", "2 unassigned" |
| Allocation | Purple chip | "Core +2pp over", "Satellite -2pp under", "NVDA >5% concentration" |

**Behavior**: Clicking an issue shows details and suggested action (alert/modal for now, could be navigation later).

**Empty State**: Hide the entire bar when no issues exist.

---

### 3. Main Content Grid

Two-column layout: Chart (left, larger) + Sleeves (right, narrower).

#### 3a. Invested Value Chart

**Purpose**: Visualize portfolio value over time.

**Chart Elements**:
- **Invested line** (green, solid) - Current market value of holdings over time
- **Cost Basis line** (gray, dashed) - Cumulative cost basis over time
- **Benchmark line** (blue, dashed) - NOT IMPLEMENTED YET, placeholder for future

**Time Range Selector**: 1M, 3M, 6M, 1Y, All

**Legend**: Below the chart showing line meanings.

> **Note**: Benchmark comparison is not yet implemented. The UI shows the element but data is stubbed.

#### 3b. Sleeves Panel

**Purpose**: Show all sleeves with allocation status.

**Layout**: Flat list showing hierarchy via indentation.

**Data per Row**:
- Sleeve name (indented for children, with `└` prefix)
- Value (EUR)
- Actual allocation (%)
- Target allocation (%)
- Status badge: "+Xpp" (over, yellow), "-Xpp" (under, blue), "ok" (green)

**Interaction**:
- Click a sleeve to filter the assets table below
- Click the same sleeve again to clear the filter
- Selected sleeve gets highlighted background
- Parent sleeve click shows parent + all children assets

**Hierarchy Display**:
- Parent sleeves at normal indentation
- Child sleeves indented with subtle background and `└` prefix

---

### 4. Assets Table

**Purpose**: Display all assets with sortable columns and sleeve filtering.

**Table Columns**:
- Asset (ticker + name)
- Sleeve (tag showing which sleeve)
- Qty (quantity held)
- Value (current market value in EUR)
- Weight (% of portfolio)
- Return (% return, colored positive/negative)

**Sorting**:
- Click column header to sort
- Toggle ascending/descending on repeated click
- Default sort: by Value, descending (largest first)

**Filtering**:
- Sleeve dropdown to filter by sleeve
- Dropdown syncs with sleeve panel clicks
- "All Sleeves" option to show everything
- Parent sleeve filter includes all children

**Footer**: Shows "Showing X of Y assets" with optional sleeve name when filtered.

**Future Tabs** (not in v1):
- Top Gainers, Top Losers, Largest - deferred to later iteration
- For v1, just show "All Assets" with sorting

---

### Health Indicators (shown in Issues Bar)

The following health indicators are surfaced in the Issues Bar:

| Indicator | Type | Description |
|-----------|------|-------------|
| **Missing Yahoo Symbols** | Error | Assets without a Yahoo symbol (can't fetch prices) |
| **Stale Price Data** | Warning | Assets with prices older than threshold (e.g., >24h) |
| **Unassigned Assets** | Warning | Holdings not assigned to any sleeve in this portfolio |
| **Allocation Drift** | Allocation | Sleeves outside their target band |
| **Concentration Rules** | Allocation | Assets exceeding concentration limits |

---

## Performance Metrics

See [specs/calculus-spec.md](calculus-spec.md) for detailed calculation formulas.

### Return Calculation Methods

The dashboard uses **Money-Weighted Return (MWR)** via XIRR for all return calculations. This gives the user's actual rate of return, accounting for when money was added or removed.

**Why MWR over TWR?**
- **TWR (Time-Weighted Return)**: Measures investment *performance*, ignoring cash flows. Useful for comparing against benchmarks.
- **MWR (Money-Weighted Return)**: Measures the user's actual *rate of return* on their money. Answers "what % return did I earn?"

For a dashboard focused on "how am I doing?", MWR is the right metric. TWR is preserved in the codebase for future benchmark comparison features.

### Two Forms of MWR

| Form | What it shows | Example |
|------|---------------|---------|
| **Annualized MWR** | Rate of return per year | 8.5% p.a. |
| **Compounded MWR** | Total return over the period | 33.4% |

Relationship: `Compounded = (1 + Annualized)^years - 1`

The compounded MWR replaces the old "Total Return" concept. It's mathematically correct because it accounts for when money was invested.

### Period Definitions

| Period | Start Date | Displayed |
|--------|------------|-----------|
| Today | Previous trading day | MWR (compounded + annualized) |
| 1W | 7 calendar days ago | MWR (compounded + annualized) |
| 1M | 30 calendar days ago | MWR (compounded + annualized) |
| YTD | Dec 31 of previous year | MWR (compounded + annualized) |
| 1Y | 365 calendar days ago | MWR (compounded + annualized) |
| All | First investment | MWR (compounded + annualized) |

**Note**: "Total" is renamed to "All" to reflect it's just another time period (since inception), not a different calculation method.

### Displayed Values

- **Absolute return (EUR)**: Actual profit = Current Value - Starting Value - Net Deposits
- **Compounded MWR (%)**: Total return over the period (primary)
- **Annualized MWR (% p.a.)**: Rate per year (secondary, shown in smaller text)

**Display format example:**
```
+33.4%  (+8.5% p.a.)
```

### Asset-Level Returns

Individual assets show **MWR for the selected period**, with special handling:

**Normal case** (asset held longer than selected period):
- Calculate MWR over the selected period
- Example: 1Y selected, asset held for 2 years → show 1Y MWR

**Short holding case** (asset held shorter than selected period):
- Calculate MWR since inception of position
- Add visual indicator (e.g., clock icon or "6mo" badge) to show actual holding period
- Tooltip explains: "Held for 6 months"
- Example: 1Y selected, asset bought 6 months ago → show 6-month MWR with indicator

**Display format:**
```
+15.2%  (+32.1% p.a.)     ← normal, held > selected period
+8.3%   (+17.4% p.a.) 🕐  ← short holding, shows since inception
```

### Sleeve-Level Returns

Sleeves panel shows **MWR for the selected period**, treating each sleeve as a mini-portfolio:

- Calculation uses all buy/sell orders for assets in that sleeve
- Parent sleeves include child sleeve assets
- Same short-holding logic as assets (fallback to inception if sleeve is newer than period)

**Display in Sleeves Panel:**
```
Sleeve      Value     Actual/Target   Return
Core        €88,931   80% / 80%       +12.3%
Satellite   €22,310   20% / 20%       +8.7%
└ Growth    €15,200   14% / 15%       +15.2% 🕐
```

**Future** (not in v1): Benchmark comparison using TWR, dividend tracking.

---

## Real-Time Updates

### tRPC Subscriptions

The dashboard should subscribe to existing WebSocket events:

- **`price_update`**: Update displayed prices and recalculate performance in real-time
- **`sync_item_update`**: Show sync progress (optional: subtle indicator)
- **`sync_complete`**: Refresh all data after sync finishes

### Update Behavior

- Price changes should animate briefly to draw attention (subtle highlight/flash)
- Performance calculations update automatically as prices change
- Health panel updates if sync errors occur

---

## Layout Structure

### Desktop Layout (approved)

```
┌─────────────────────────────────────────────────────────────┐
│ TOP SECTION (white card)                                    │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ [Portfolio ▼]                          Synced 2 min ago │ │
│ ├─────────────────────────────────────────────────────────┤ │
│ │ INVESTED        RETURN [Today|1W|1M|YTD|1Y|Total]       │ │
│ │ EUR 45,030      Total Return                 Cash  Value│ │
│ │ (large)         +EUR 4,132  +9.4%           3,200 48,230│ │
│ └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ISSUES BAR (yellow, only shown if issues exist)             │
│ [⚠ 6 Issues] | [chip] [chip] [chip] [chip] ...              │
├─────────────────────────────────────────────────────────────┤
│ MAIN GRID                                                   │
│ ┌─────────────────────────────┬───────────────────────────┐ │
│ │ CHART (larger)              │ SLEEVES (narrower)        │ │
│ │ Invested Value              │ ┌───────────────────────┐ │ │
│ │ [1M|3M|6M|1Y|All]           │ │ Core     72% / 70%    │ │ │
│ │                             │ │ Satellite 28% / 30%   │ │ │
│ │  📈 Chart here              │ │ └ Growth  17% / 18%   │ │ │
│ │                             │ └───────────────────────┘ │ │
│ │ ── Invested  -- Cost  -- BM │                           │ │
│ └─────────────────────────────┴───────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ASSETS TABLE                                                │
│ [All Assets] [Gainers*] [Losers*] [Largest*]  [Sleeve ▼]   │
│ ┌───────────────────────────────────────────────────────┐   │
│ │ Asset           Sleeve   Qty    Value   Weight Return │   │
│ │ VWCE Vanguard   Core     45     5,130   10.6%  +12.4% │   │
│ │ ...                                                   │   │
│ └───────────────────────────────────────────────────────┘   │
│ Showing 20 of 20 assets                                     │
└─────────────────────────────────────────────────────────────┘

* Tabs marked with asterisk are future features, not in v1
```

### Responsive Considerations (future)

- Mobile: Single column, stacked layout
- Tablet: Chart and sleeves stack vertically
- Asset table: Consider card layout on small screens

---

## Interactions

### v1 Scope

- **Read-only**: No edit operations from dashboard
- **Sleeve click**: Filter assets table, toggle on/off
- **Sleeve dropdown**: Filter assets table, syncs with sleeve clicks
- **Return period buttons**: Switch displayed return period
- **Chart time range**: Switch chart display period
- **Column header click**: Sort assets table
- **Issue chip click**: Show issue details and suggested action
- **Privacy toggle**: Hide/show currency values

### Click Behaviors

| Element | Action |
|---------|--------|
| Sleeve row | Toggle filter for that sleeve (including children) |
| Sleeve dropdown | Set filter, sync with row highlight |
| Return period button | Update return label and values |
| Chart range button | Update chart time range |
| Table column header | Sort by that column, toggle asc/desc |
| Issue chip | Show alert with details and action path |
| Privacy toggle | Toggle blur/hide on all currency values, persist to localStorage |

### Future Considerations

- Asset row click: Navigate to asset detail
- Issue chip: Navigate to resolution flow
- Quick sync button

---

## Data Requirements

### API Endpoints Needed

1. **Portfolio list** - For dropdown selector
2. **Dashboard summary** - Aggregated data for top section:
   - Total invested (cost basis)
   - Total current value
   - Cash balance
   - Returns for all periods
3. **Sleeves with allocation** - For sleeves panel:
   - Hierarchy (parent/child)
   - Target %, actual %, deviation
   - Band status
   - Value in EUR
4. **Holdings with metrics** - For assets table:
   - Asset info (ticker, name, ISIN)
   - Sleeve assignment
   - Quantity, value, weight
   - Return %
5. **Health issues** - For issues bar:
   - Missing symbols
   - Stale prices
   - Unassigned assets
   - Allocation drift
   - Concentration violations
6. **Chart data** - Historical invested value:
   - Daily portfolio value over time
   - Cost basis over time

### Computed Values

See [specs/calculus-spec.md](calculus-spec.md) for formulas.

---

## Resolved Decisions

| Question | Decision |
|----------|----------|
| Default time period | "Total" (vs. cost basis) |
| Sleeve visualization | Flat list with indentation for hierarchy |
| Health display | Inline issues bar (not collapsible panel) |
| Sleeve click behavior | Filter + highlight row |
| Asset table tabs | Deferred - v1 shows all assets only |

---

## Implementation

See [specs/dashboard-plan.md](dashboard-plan.md) for the implementation plan with discrete tasks.

---

## Technical Notes

### Existing Infrastructure

- `valuation` tRPC router: Sleeve allocations, band calculations
- `holdings` tRPC router: Position data
- `oracle` tRPC router: Price data, sync status
- `serverEvents` store: WebSocket subscriptions
- `bands.ts` utility: Band calculation logic
- `dailyPrices` table: Historical price data for charts

### New Route

Dashboard will be implemented at a new route (e.g., `/dashboard-v2`) without touching existing pages. This allows parallel development and testing.

### Theming

Theming is NOT in scope for v1. The dashboard will use basic styling that works. Visual polish comes later.

---

## Success Criteria

1. User can assess portfolio health in <10 seconds
2. Out-of-band sleeves are immediately visible
3. Performance data is accurate
4. Sleeve filtering works correctly
5. No performance issues with typical portfolio sizes (50-200 assets)
