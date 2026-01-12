# Dashboard Design Specification

## Overview

The dashboard is the **main landing page** of FinancePal v2, designed for daily use. It provides a comprehensive view of portfolio health, sleeve balance status, and asset performance at a glance.

### Design Goals

- **Daily driver**: Optimized for quick scanning and identifying what needs attention
- **Information density**: Show meaningful data without overwhelming
- **Live updates**: React to price sync events via tRPC subscriptions
- **Responsive**: Support desktop, tablet, and mobile (challenging for financial data—requires careful consideration)

---

## Scope

### Single Portfolio Context

- Display one portfolio at a time
- **Portfolio selector**: Dropdown or similar control to switch portfolios
- **Auto-hide selector**: If only one portfolio exists, hide the selector entirely and display that portfolio directly

---

## Core Sections

### 1. Portfolio Header

**Purpose**: Establish context and show top-level portfolio metrics.

**Contents**:
- Portfolio name
- Total portfolio value (EUR)
- Overall performance for selected time period (% and absolute EUR)
- Last sync timestamp

**Time Period Selector**:
Available periods for performance calculation:
- **Today**
- **1 Week (1W)**
- **1 Month (1M)**
- **Year-to-Date (YTD)**
- **1 Year (1Y)**
- **vs. Cost Basis** (comparison to average purchase price)

> **Note**: "vs. Cost Basis" is likely the most important period for the user. Consider making it the default or giving it visual prominence.

---

### 2. Sleeve Balance Overview

**Purpose**: Show all sleeves with their allocation status relative to target bands.

**Data per Sleeve**:
- Sleeve name
- Target allocation (%)
- Actual allocation (%)
- Deviation from target (e.g., "+3.2pp" or "-1.5pp")
- Band status (visual indicator: in-band, warning, out-of-band)
- **Aggregated performance**: Return for all assets in this sleeve AND its children (% and EUR)

**Band Calculation Reminder**:
Bands use the formula: `halfWidth = clamp(target * relativeTolerance / 100, absoluteFloor, absoluteCap)`
- Relative tolerance: ±X% of target
- Absolute floor: Minimum half-width in percentage points
- Absolute cap: Maximum half-width in percentage points

**Visual Status Indicators**:
- **In-band** (green): Actual is within tolerance band
- **Warning** (yellow/amber): Approaching band edge (e.g., within 20% of boundary)
- **Out-of-band** (red): Actual exceeds tolerance band

**Hierarchy Handling**:
Sleeves are hierarchical (parent/child relationships). Children should NOT be hidden behind expand/collapse—all sleeves visible.

#### Experimental: Visualization Approaches

> **This section requires experimentation.** Implement multiple approaches and evaluate which works best.

**Option A: Flat List**
- Simple table or card list
- Sort options: by name, by deviation, by performance
- Pros: Familiar, easy to scan, works well on mobile
- Cons: Loses hierarchical context

**Option B: Tree View**
- Indented list showing parent-child relationships
- Visual connectors between levels
- Pros: Shows hierarchy clearly
- Cons: Can get deep/complex, harder on mobile

**Option C: Treemap**
- Area-based visualization where size = actual allocation
- Color = band status (green/yellow/red) or performance
- Nested rectangles for hierarchy
- Pros: Immediate visual impact, shows proportions
- Cons: Small sleeves hard to see, labels can be challenging

**Recommendation (UX Expert Opinion)**:
Start with **Option A (Flat List)** as the default—it's the most reliable and accessible. Implement **Option C (Treemap)** as an alternative view toggle for users who want visual proportion insight. Tree view is lower priority unless users specifically request hierarchy visibility.

---

### 3. Asset Performance Section

**Purpose**: Display performance metrics for individual assets with flexible filtering.

**Filtering Capability**:
- **Global view**: All assets in the portfolio
- **Sleeve-filtered view**: Only assets belonging to a specific sleeve (and its children)

**Asset Data**:
- Asset name / ticker
- ISIN
- Current price
- Quantity held
- Current value (EUR)
- Performance for selected time period (% and absolute EUR)
- Cost basis (average purchase price)
- Unrealized P/L

**Statistical Views**:

> **This section requires experimentation.** Start with a sensible subset and expand based on feedback.

**Initial stat views (pick 3-4 for v1)**:
1. **All Assets**: Complete list, sortable by various columns
2. **Top Gainers**: Best performing assets (by % return)
3. **Top Losers**: Worst performing assets (by % return)
4. **Largest Positions**: Assets with highest current value

**Future consideration**:
- Top movers (largest absolute change today)
- Biggest contributors (weighted impact on portfolio return)
- Recently added (new positions)

**UX Recommendation**:
Use a **tab or toggle bar** to switch between stat views. Each view shows a table/list with relevant sorting. The sleeve filter should persist across view changes.

---

### 4. Health Panel

**Purpose**: Dedicated section for portfolio health indicators and warnings.

**Location**: Dedicated section (not inline with other components) to allow adjustable detail level.

**Health Indicators**:

| Indicator | Description | Severity |
|-----------|-------------|----------|
| **Stale Price Data** | Assets with prices older than threshold (e.g., >24h) | Warning |
| **Unassigned Assets** | Holdings not assigned to any sleeve in this portfolio | Warning |
| **Missing Yahoo Symbols** | Assets without a Yahoo symbol (can't fetch prices) | Error |
| **Empty Sleeves** | Sleeves with 0% actual allocation (no assets assigned) | Info |
| **Sync Errors** | Failed Yahoo Finance fetches | Error |

**Display Approach**:
- Show count/badge when collapsed (e.g., "3 issues")
- Expandable to show full details
- Group by severity (Errors → Warnings → Info)
- Each item should identify the affected asset/sleeve

**Empty State**: When no health issues exist, show a positive confirmation (e.g., "All systems healthy" with a checkmark).

---

## Performance Metrics

### Time Periods

| Period | Calculation |
|--------|-------------|
| Today | Current value vs. previous close |
| 1W | Current value vs. value 7 days ago |
| 1M | Current value vs. value 30 days ago |
| YTD | Current value vs. value on Dec 31 of previous year |
| 1Y | Current value vs. value 365 days ago |
| vs. Cost | Current value vs. total cost basis (average purchase price × quantity) |

### Metrics Displayed

**Priority for v1**:
1. **Percentage return**: (Current - Previous) / Previous × 100
2. **Absolute return**: Current - Previous (in EUR)

**Future iterations**:
- Benchmark comparison
- Dividend income (separate line)
- Time-weighted vs. money-weighted returns

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

> **This section requires experimentation.** The overall layout arrangement needs iteration.

### Proposed Default Layout (Desktop)

```
┌─────────────────────────────────────────────────────────────┐
│  [Portfolio Selector]                    [Time Period: ▼]   │
├─────────────────────────────────────────────────────────────┤
│  PORTFOLIO HEADER                                           │
│  Total Value: €XXX,XXX    Performance: +X.XX% (+€X,XXX)     │
│  Last sync: X minutes ago                                   │
├─────────────────────────────────────────────────────────────┤
│                           │                                 │
│   SLEEVE BALANCE          │   HEALTH PANEL                  │
│   OVERVIEW                │   [3 issues]                    │
│                           │   ├─ 1 Error                    │
│   ┌─────┬─────┬─────┐    │   └─ 2 Warnings                 │
│   │Sleeve│Sleeve│... │    │                                 │
│   └─────┴─────┴─────┘    │                                 │
│                           │                                 │
├───────────────────────────┴─────────────────────────────────┤
│  ASSET PERFORMANCE                          [Filter: All ▼] │
│  [All Assets] [Top Gainers] [Top Losers] [Largest]          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Asset table/list                                     │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Responsive Considerations

**Tablet (768px - 1024px)**:
- Stack health panel below sleeve overview
- Reduce column count in asset table
- Consider horizontal scroll for tables

**Mobile (<768px)**:
- Single column layout
- Collapsible sections
- Sleeve visualization: flat list only (treemap not practical)
- Asset table: card-based layout instead of table
- Time period selector: compact dropdown or bottom sheet

**Challenge Areas**:
- Financial tables with many columns are inherently difficult on mobile
- Consider which columns are essential vs. hideable
- Progressive disclosure: show summary, tap for details

---

## Interactions

### Current Scope (v1)

- **Read-only**: No edit operations from dashboard
- **Sleeve filter**: Click/select a sleeve to filter asset view
- **Time period toggle**: Switch between performance periods
- **Stat view toggle**: Switch between asset statistical views
- **Health panel expand/collapse**: Show/hide detailed health info

### Click Behavior (UX Recommendation)

When clicking a sleeve or asset:
- **Sleeve click**: Filter the asset section to show only assets in that sleeve
- **Asset click**: For now, no action (future: navigate to asset detail or show modal)

This keeps the dashboard focused as a "command center" without navigation fragmentation.

### Future Considerations

- Links to detail pages (sleeve editor, asset management)
- Quick actions (trigger sync, etc.)
- Drill-down modals for deeper analysis

---

## Data Requirements

### API Queries Needed

1. **Portfolio list**: For selector (with asset/sleeve counts)
2. **Portfolio detail**: Band settings, rules
3. **Sleeves with allocation**: Target, actual, band status, aggregated performance
4. **Holdings with prices**: Current value, cost basis, performance by period
5. **Health checks**: Stale prices, unassigned, missing symbols, empty sleeves, sync errors

### Computed Values

- Sleeve aggregated performance (sum of child assets + nested sleeves)
- Band status (apply band formula)
- Performance for each time period
- Health issue counts by severity

---

## Open Questions

1. **Default time period**: Should "vs. Cost Basis" be the default, or let user set preference?
2. **Sleeve visualization default**: Start with list or treemap?
3. **Asset table pagination**: Show all assets or paginate? Virtual scroll for large lists?
4. **Performance caching**: Cache computed performance values or calculate on-demand?
5. **Sleeve click behavior**: Filter only, or also highlight the sleeve in the overview?

---

## Implementation Phases

### Phase 1: Foundation
- Portfolio selector (with auto-hide logic)
- Portfolio header with total value and basic performance
- Time period selector
- Basic sleeve list with allocation and band status

### Phase 2: Asset Section
- Asset table with all holdings
- Sleeve filter functionality
- Stat view tabs (all, gainers, losers, largest)
- Sortable columns

### Phase 3: Health Panel
- Health indicator calculations
- Dedicated health section with expand/collapse
- Severity grouping

### Phase 4: Polish & Real-Time
- tRPC subscription integration
- Live price update animations
- Responsive layout refinements

### Phase 5: Experimentation
- Alternative sleeve visualizations (treemap)
- Layout variations
- User preference persistence

---

## Technical Notes

### Existing Infrastructure to Leverage

- `valuation` tRPC router: Sleeve allocations, band calculations
- `holdings` tRPC router: Position data
- `oracle` tRPC router: Price data, sync status
- `serverEvents` store: WebSocket subscriptions
- `bands.ts` utility: Band calculation logic
- `lightweight-charts`: Available for future charting needs

### New Components Needed

- `DashboardPage.svelte`: Main page component
- `PortfolioSelector.svelte`: Dropdown with auto-hide
- `SleeveOverview.svelte`: Sleeve balance visualization
- `AssetPerformance.svelte`: Asset table with filters
- `HealthPanel.svelte`: Health indicators section
- `TimePeriodSelector.svelte`: Period toggle control

---

## Success Criteria

The dashboard succeeds if:

1. User can assess portfolio health in <10 seconds
2. Out-of-band sleeves are immediately visible
3. Performance data is accurate and updates in real-time
4. Works acceptably on mobile (even if simplified)
5. No performance issues with typical portfolio sizes (50-200 assets)
