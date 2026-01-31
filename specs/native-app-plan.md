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

### NAPP-042: Strategy Page Redesign `[exploration]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

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

## Architecture: Account-Portfolio Model

These tasks implement the new data architecture where Accounts are import targets and Portfolios are analytical views that aggregate one or more accounts.

---

### NAPP-051: Virtual Accounts `[implement]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: NAPP-050

Virtual accounts for paper trading and hypothetical portfolio testing.

**Backend**:
- [ ] Account type enum: `real` | `virtual`
- [ ] Endpoint to add manual position to virtual account (asset, quantity, costBasis, date)
- [ ] Endpoint to edit/remove positions in virtual account
- [ ] Virtual accounts don't sync with any broker

**Frontend**:
- [ ] Create virtual account flow
- [ ] Add position form (search asset, enter quantity, cost, date)
- [ ] Edit/delete positions
- [ ] Virtual accounts clearly labeled in UI

**Acceptance Criteria**:
- [ ] User can create a virtual account
- [ ] User can add hypothetical positions manually
- [ ] Virtual account can be added to a portfolio
- [ ] Dashboard works with virtual accounts same as real

---

### NAPP-052: Account & Portfolio Management UI `[exploration]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: NAPP-050

Exploratory task to design where and how users manage accounts, portfolios, and sleeves.

**Questions to Answer**:
- Where does this live? (Settings, dedicated tab, portfolio selector dropdown?)
- Single management screen or separate screens per entity type?
- How to assign accounts to portfolios?
- How to manage sleeves within a portfolio?
- How to handle the "select portfolio" flow when creating new portfolio?

**Possible Approaches**:
1. Settings → Accounts, Settings → Portfolios (separate sections)
2. Dedicated "Manage" bottom nav tab
3. Portfolio selector → "Manage Portfolios..." option
4. Expand Strategy screen to include portfolio configuration

**Deliverable**: Mockups for 2-3 approaches, user decision, then implementation spec.

**Acceptance Criteria**:
- [ ] User research / mockups created
- [ ] Approach selected
- [ ] Implementation tasks created

---

### NAPP-053: XIRR Benchmark Comparison `[implement]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: None

Compare portfolio XIRR against benchmark using same cash flows.

**Concept**: "What if I had put the same money into SPY at the same times?"

**Backend**:
- [ ] Endpoint: `getBenchmarkComparison(portfolioId, benchmarkSymbol, period)`
- [ ] Fetch user's actual cash flow history (deposits/withdrawals derived from orders)
- [ ] Simulate: apply same cash flows to benchmark asset
- [ ] Calculate XIRR for both
- [ ] Return comparison result

**Frontend**:
- [ ] Decide where this lives (dashboard card? dedicated section? separate screen?)
- [ ] Benchmark selector (SPY, QQQ, MSCI World, custom)
- [ ] Show comparison: "Your XIRR: +12%, SPY XIRR: +15%"
- [ ] Visual: side-by-side or delta display

**Acceptance Criteria**:
- [ ] User can compare their XIRR to a benchmark
- [ ] Same cash flow timing applied to benchmark
- [ ] Clear visualization of outperformance/underperformance

---

### NAPP-054: TWR Benchmark Comparison `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

Compare portfolio TWR against benchmark TWR.

**Concept**: Neutralize cash flows, compare pure investment performance.

**Backend**:
- [ ] Calculate portfolio TWR (may already exist)
- [ ] Fetch benchmark TWR for same period
- [ ] Return comparison

**Frontend**:
- [ ] Display alongside or near XIRR benchmark
- [ ] Explain difference: "TWR removes timing luck, XIRR includes it"

**Acceptance Criteria**:
- [ ] User can see TWR vs benchmark TWR
- [ ] Clear explanation of what TWR measures

---

## Monte Carlo Projections

Forward-looking probabilistic simulations that show the range of possible outcomes, not just a single expected value. Useful for risk visualization and goal planning.

---

### NAPP-055: Single Asset Monte Carlo Projection `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None

Monte Carlo simulation for individual assets, displayed on the Asset Detail page.

#### Concept

Answer: "What could this asset be worth in 10 years?" with a probability distribution, not a single number.

```
AAPL - 10 Year Projection
━━━━━━━━━━━━━━━━━━━━━━━━━━
Current value: €15,000

              Projected Value
10th %ile:    €8,200   (-45%)   ← rough scenario
50th %ile:    €32,000  (+113%)  ← median outcome
90th %ile:    €98,000  (+553%)  ← optimistic scenario

[Fan chart visualization]
```

#### Model Parameters

| Parameter | Source | Notes |
|-----------|--------|-------|
| Expected return | Historical mean from DailyPrice + dividend yield from DividendEvent | Use at least 1 year of data; fallback to asset class average (10%) if insufficient |
| Volatility | Standard deviation of daily returns × √252 (annualized) | Calculate from DailyPrice history |
| Distribution | Student's t with df=5 | Captures fat tails - extreme events more likely than normal distribution |
| Dividend yield | Sum of dividends / current price | Add to expected return for total return |

**Why Student's t-distribution?**
Normal distribution underestimates crashes. A t-distribution with 5 degrees of freedom has fatter tails, matching empirical stock return distributions. One parameter change, much more realistic.

#### Algorithm

```
inputs:
  current_value: float
  expected_annual_return: float  # e.g., 0.10 for 10%
  annual_volatility: float       # e.g., 0.28 for 28%
  years: int                     # e.g., 10
  num_simulations: int           # e.g., 10,000

for each simulation:
  value = current_value
  for each year:
    # Draw from t-distribution (fatter tails than normal)
    random_return = t_distribution(df=5) * volatility + expected_return
    value = value * (1 + random_return)
  record final_value

output:
  percentiles: [10th, 25th, 50th, 75th, 90th]
  fan_chart_data: time series of percentile bands
```

#### Data Requirements

| Need | Have It? | Table/Source |
|------|----------|--------------|
| Current value | ✓ | Holding.quantity × PriceCache.priceEur |
| Historical prices | ✓ | DailyPrice (need 1+ year) |
| Dividends | ✓ | DividendEvent table |
| Calculate volatility | Implement | std dev of ln(price[t]/price[t-1]) |

#### Backend

**Endpoint**: `getAssetProjection(assetId, years, percentiles)`

- [ ] Calculate historical annualized return from DailyPrice
- [ ] Calculate annualized volatility from daily returns
- [ ] Add dividend yield to expected return
- [ ] Run Monte Carlo simulation (10,000 iterations)
- [ ] Return percentile outcomes + fan chart data points

**Response model**:
```yaml
class: AssetProjectionResult
fields:
  assetId: UuidValue
  currentValue: double
  years: int
  expectedReturn: double      # annual, used in simulation
  volatility: double          # annual, used in simulation
  percentiles: List<ProjectionPercentile>  # 10th, 25th, 50th, 75th, 90th
  fanChartData: List<FanChartPoint>        # yearly percentile bands for chart
  dataQuality: String         # 'good' | 'limited' | 'insufficient'

class: ProjectionPercentile
fields:
  percentile: int             # 10, 25, 50, 75, 90
  value: double               # projected value
  totalReturn: double         # percentage return

class: FanChartPoint
fields:
  year: int
  p10: double
  p25: double
  p50: double
  p75: double
  p90: double
```

#### Frontend

**Location**: Asset Detail page, new "Projection" section or tab

- [ ] Projection summary card showing key percentiles
- [ ] Fan chart visualization (wedge shape expanding over time)
- [ ] Period selector: 5Y, 10Y, 20Y
- [ ] Show data quality indicator if limited history
- [ ] Tooltip explaining what percentiles mean

**Fan chart design**:
```
Value
  ↑
  │         ╱ 90th
  │       ╱
  │     ╱─── 50th (median line)
  │   ╱
  │ ╱ 10th
  └──────────────→ Years
     0  5  10
```

#### Edge Cases

- **Insufficient data**: < 1 year of prices → show warning, use asset class defaults
- **High volatility assets**: Cap volatility at reasonable maximum (e.g., 80%)
- **Negative expected return**: Allow it (some assets do have negative drift)
- **Very small positions**: Still show projection, useful for "what if I had more"

#### Acceptance Criteria

- [ ] Asset detail shows Monte Carlo projection
- [ ] Uses fat-tailed distribution (t-distribution)
- [ ] Includes dividends in expected return
- [ ] Fan chart visualizes range of outcomes
- [ ] Clear explanation of what the percentiles mean
- [ ] Graceful handling of limited price history

---

### NAPP-056: Portfolio Monte Carlo Projection `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: NAPP-055

Monte Carlo simulation for the entire portfolio, accounting for correlations between asset classes.

#### Concept

Answer: "What could my portfolio be worth in 10 years?" with probability distribution.

Key difference from single-asset: Must account for **correlations** between holdings. Diversified portfolios have lower volatility than the weighted average of individual volatilities.

```
Portfolio - 10 Year Projection
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Current value: €150,000
Allocation: 60% stocks, 40% bonds

              Projected Value
10th %ile:    €142,000  (-5%)    ← bad scenario
50th %ile:    €320,000  (+113%)  ← median outcome
90th %ile:    €580,000  (+287%)  ← good scenario

Probability of reaching €500k: 38%
Probability of loss after 10y: 12%

[Fan chart visualization]
```

#### Why Asset-Class Level (Not Per-Asset)

**Problem with per-asset simulation:**
- Need correlation between ALL pairs of assets (20 assets = 190 pairs)
- Individual stock correlations are unstable year-to-year
- Need 3-5 years of overlapping data for reliable estimates
- Computationally expensive
- False precision - looks accurate but isn't

**Asset-class approach:**
- Group holdings into 4-6 classes
- Use well-documented historical parameters (decades of data)
- Stable, reliable, computationally cheap
- Standard practice in financial planning

#### Asset Class Taxonomy

| Asset Class | Maps From | ETF Proxy |
|-------------|-----------|-----------|
| US Stocks | Stock (US), ETF with US equity exposure | VTI, SPY |
| International Stocks | Stock (non-US), international ETFs | VXUS, VEA |
| Bonds | Bond, bond ETFs | BND, AGG |
| Commodities | Commodity ETFs, gold | GLD, GSG |
| Cash | Money market, cash holdings | - |
| Other | Anything unclassified | Use balanced params |

**Mapping logic**: Use combination of `Asset.assetType`, sector metadata, and ETF classification.

#### Published Parameters (Hardcoded)

Long-term historical data from academic research (Dimson-Marsh-Staunton, Ibbotson):

```dart
const assetClassParams = {
  'us_stocks':    (mean: 0.10, vol: 0.16),  // S&P 500 since 1926
  'intl_stocks':  (mean: 0.08, vol: 0.18),  // MSCI EAFE
  'bonds':        (mean: 0.05, vol: 0.06),  // Bloomberg Aggregate
  'commodities':  (mean: 0.04, vol: 0.18),  // GSCI
  'cash':         (mean: 0.02, vol: 0.01),  // T-bills
  'other':        (mean: 0.07, vol: 0.12),  // Balanced assumption
};
```

**Correlation matrix** (also hardcoded from research):

```
                US Stock  Intl    Bonds   Cmdty   Cash
US Stocks         1.00    0.75   -0.10    0.15    0.00
Intl Stocks       0.75    1.00   -0.05    0.20    0.00
Bonds            -0.10   -0.05    1.00   -0.10    0.20
Commodities       0.15    0.20   -0.10    1.00    0.00
Cash              0.00    0.00    0.20    0.00    1.00
```

**Source options for parameters:**
1. Hardcode from published research (simplest, recommended for MVP)
2. Calculate from ETF proxy prices (VTI, BND, etc.) using our DailyPrice data
3. Fetch from external API (Portfolio Visualizer, Quandl)

#### Algorithm

```
inputs:
  portfolio_weights: {asset_class: weight}  # e.g., {'us_stocks': 0.6, 'bonds': 0.4}
  current_value: float
  years: int
  num_simulations: int

# Get parameters
means = [params[class].mean for class in weights]
vols = [params[class].vol for class in weights]
corr_matrix = get_correlation_matrix(classes)

# Convert correlation to covariance matrix
cov_matrix = corr_to_cov(corr_matrix, vols)

for each simulation:
  value = current_value
  for each year:
    # Draw correlated returns for all asset classes
    class_returns = multivariate_t(means, cov_matrix, df=5)

    # Portfolio return is weighted sum
    portfolio_return = sum(weight * return for weight, return in zip(weights, class_returns))

    value = value * (1 + portfolio_return)

  record final_value

output:
  percentiles + fan_chart + goal_probabilities
```

#### Data Requirements

| Need | Have It? | Source |
|------|----------|--------|
| Holdings with values | ✓ | Holding + PriceCache |
| Asset class per holding | Partial | Need mapping logic from assetType/metadata |
| Class parameters | Hardcode | Published research |
| Correlation matrix | Hardcode | Published research |

**New data model addition:**
- Add `assetClass` field to Asset model, OR
- Create mapping function: `Asset → AssetClass` based on type/sector/geography

#### Backend

**Endpoint**: `getPortfolioProjection(portfolioId, years, percentiles, goals)`

- [ ] Aggregate holdings into asset class weights
- [ ] Apply published parameters (hardcoded)
- [ ] Run correlated Monte Carlo simulation
- [ ] Calculate goal probabilities (e.g., "chance of reaching €500k")
- [ ] Return percentiles + fan chart + goal results

**Response model**:
```yaml
class: PortfolioProjectionResult
fields:
  portfolioId: UuidValue
  currentValue: double
  years: int
  allocation: List<AllocationWeight>       # asset class breakdown used
  percentiles: List<ProjectionPercentile>
  fanChartData: List<FanChartPoint>
  goalProbabilities: List<GoalProbability>

class: AllocationWeight
fields:
  assetClass: String          # 'us_stocks', 'bonds', etc.
  weight: double              # 0.0 to 1.0
  expectedReturn: double      # used in simulation
  volatility: double          # used in simulation

class: GoalProbability
fields:
  targetValue: double         # e.g., 500000
  probability: double         # e.g., 0.38 (38% chance)
```

#### Frontend

**Location**: Dashboard or dedicated "Planning" section

- [ ] Projection summary with key percentiles
- [ ] Fan chart visualization
- [ ] Asset class breakdown showing what was used
- [ ] Goal calculator: "Enter target amount → see probability"
- [ ] Period selector: 5Y, 10Y, 20Y, 30Y
- [ ] "What if" mode: adjust allocation sliders, see impact on projection

**Goal calculator UX**:
```
┌─────────────────────────────────────┐
│ GOAL CALCULATOR                     │
├─────────────────────────────────────┤
│ Target: €[500,000]  By: [10] years  │
│                                     │
│ Probability of success: 38%         │
│ ████████░░░░░░░░░░░░                │
│                                     │
│ To reach 80% probability:           │
│ • Increase to €620k, OR             │
│ • Extend to 14 years, OR            │
│ • Shift to 80% stocks (higher risk) │
└─────────────────────────────────────┘
```

#### Simplification for MVP

Start with 3 asset classes only:
- Stocks (all equities) → 10% return, 16% vol
- Bonds (all fixed income) → 5% return, 6% vol
- Other → 7% return, 12% vol

Correlation: Stocks-Bonds = -0.10

Map based on existing `assetType`:
- Stock, ETF → Stocks
- Bond → Bonds
- Everything else → Other

Expand to full taxonomy later if users want granularity.

#### Edge Cases

- **Unclassified assets**: Map to "Other" with balanced parameters
- **100% single class**: Degrades to single-class simulation (no correlation benefit)
- **Empty portfolio**: Don't show projection
- **Very long horizons (30+ years)**: May want mean reversion, but keep simple for MVP

#### Acceptance Criteria

- [ ] Portfolio projection shows Monte Carlo results
- [ ] Uses asset class approach with published parameters
- [ ] Correlations reduce portfolio volatility appropriately
- [ ] Goal probability calculator works
- [ ] Fan chart visualizes range of outcomes
- [ ] Clear explanation of methodology and limitations
- [ ] Graceful handling of unclassified assets

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
