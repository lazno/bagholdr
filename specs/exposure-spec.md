# Exposure Analysis Design Specification

## Overview

The Exposure feature provides portfolio diversification analysis across multiple dimensions (sector, industry, country, market cap). It fetches metadata from Yahoo Finance, supports ETF look-through, and enables rule-based exposure limits.

### Design Goals

- **Diversification insight**: Answer "where is my money exposed?" at portfolio, sleeve, and sub-sleeve levels
- **ETF transparency**: Look through ETFs to show true underlying exposure
- **Actionable rules**: Set exposure limits and surface violations
- **Low maintenance**: Weekly metadata refresh, manual override capability

### Key Concepts

| Term | Definition |
|------|------------|
| Exposure | Percentage of portfolio/sleeve value allocated to a category (sector, country, etc.) |
| Exposure dimension | A classification axis: sector, industry, country, market cap |
| Look-through | Distributing ETF value across its underlying sector/country breakdown |
| Exposure rule | Portfolio-level constraint (e.g., "no sector > 25%") |

---

## Scope

### Exposure Dimensions

| Dimension | Source | Example Values |
|-----------|--------|----------------|
| Sector | Yahoo Finance | Technology, Healthcare, Financials, Consumer Cyclical, etc. |
| Industry | Yahoo Finance | Software, Biotechnology, Banks, Auto Manufacturers, etc. |
| Country | Yahoo Finance | United States, Germany, Japan, China, etc. |
| Market Cap | Yahoo Finance | Large Cap, Mid Cap, Small Cap, Micro Cap |

### What's Included

- Individual stocks: Use Yahoo-provided metadata directly
- ETFs: Look-through using Yahoo's sector/country breakdown
- Cash: Shown as its own category (consistent with sleeve handling)
- Unknown/Other: Category for uncategorizable portions

### What's Excluded (v1)

- Bonds, commodities, crypto (future consideration)
- Multi-level ETF look-through (ETF holding ETF)
- Real-time exposure updates (uses last sync data)

### Explicitly Out of Scope: Sector Performance

**Decision**: The Exposure page does NOT show performance metrics (returns) by sector/dimension.

**Why not?**

1. **Precision problem with ETFs**: We only know current ETF sector weights, not historical. If VWCE is 25% Tech today, we don't know if it was 20% or 30% six months ago. Attributing performance to sectors requires data we don't have.

2. **Approximation error is significant**: Using static weights (current breakdown applied to historical period) can produce 20-50% error in attribution when sector weights drifted or sectors diverged in performance.

3. **Doesn't drive decisions**: Even if precise, "Tech returned +18%" doesn't tell you what to do next. Past sector performance doesn't predict future returns. It's trivia, not signal.

4. **Professionals don't use approximate attribution**: Real performance attribution requires daily holdings data, proper time-weighting, and factor models. Our approximation would be a toy version that could mislead users.

**What IS decision-driving** (and IS in scope):
- "Tech is 38% of my portfolio" → actionable (rebalance or not)
- "Tech exceeds my 25% rule" → actionable (violation to fix)
- "Tech exposure is drifting up" → actionable (trend to watch)

**Where performance lives instead**:
- **Dashboard**: Portfolio and sleeve performance (already implemented)
- **Dashboard**: Benchmark comparison (future - see DASH-025)

This keeps the Exposure page focused: **composition and rules**, not returns.

---

## Data Model

### Asset Metadata

New fields on assets table (or separate `asset_metadata` table):

```
Asset Metadata:
├── sector: string | null          # "Technology"
├── industry: string | null        # "Software—Infrastructure"
├── country: string | null         # "United States"
├── marketCap: string | null       # "Large Cap"
├── metadataUpdatedAt: timestamp   # Last successful fetch
├── metadataSource: string         # "yahoo" | "manual"
└── isEtf: boolean                 # Determines look-through behavior
```

### ETF Holdings Data

For ETFs, additional structured data:

```
ETF Breakdown:
├── sectorBreakdown: { [sector: string]: number }    # { "Technology": 25.5, "Healthcare": 18.2, ... }
├── countryBreakdown: { [country: string]: number }  # { "United States": 62.0, "Japan": 8.5, ... }
├── topHoldings: [                                   # Top 10 holdings
│     { symbol: string, name: string, weight: number },
│     ...
│   ]
└── holdingsUpdatedAt: timestamp
```

**Storage**: JSON column on assets table or separate `etf_breakdown` table.

### Manual Overrides

When user overrides metadata:
- Set `metadataSource: "manual"`
- Yahoo sync skips assets with manual source (preserves user data)
- UI shows indicator that data is manually set
- Option to "reset to Yahoo data" clears override

---

## Yahoo Finance Integration

### Authentication Flow

Yahoo uses session-bound CSRF protection:

```
1. GET https://fc.yahoo.com
   → Extract cookies from response

2. GET https://query2.finance.yahoo.com/v1/test/getcrumb
   Headers: Cookie: <cookies from step 1>
   → Response body contains crumb string

3. All subsequent API calls:
   - Include cookies in header
   - Append &crumb=<crumb> to URL
```

**Session Management**:
- Store cookies + crumb in memory during sync session
- Refresh if request returns 401/403
- Single session per sync run (not per-request)

### API Endpoints

**Asset Profile** (individual stocks):
```
GET https://query2.finance.yahoo.com/v10/finance/quoteSummary/{symbol}
    ?modules=assetProfile,summaryDetail
    &crumb=<crumb>

Response includes:
- assetProfile.sector
- assetProfile.industry
- assetProfile.country
- summaryDetail.marketCap → derive cap category
```

**ETF Holdings**:
```
GET https://query2.finance.yahoo.com/v10/finance/quoteSummary/{symbol}
    ?modules=topHoldings,assetProfile
    &crumb=<crumb>

Response includes:
- topHoldings.holdings[] (top holdings with weights)
- topHoldings.sectorWeightings[] (sector breakdown)
- Additional call may be needed for country breakdown
```

### Market Cap Categories

Derive from `summaryDetail.marketCap` value:

| Market Cap (USD) | Category |
|------------------|----------|
| > $200B | Mega Cap |
| $10B - $200B | Large Cap |
| $2B - $10B | Mid Cap |
| $300M - $2B | Small Cap |
| < $300M | Micro Cap |

### Sync Behavior

**Trigger**: Runs as part of existing price sync flow.

**Freshness Check**: Skip fetch if `metadataUpdatedAt` < 7 days old.

**Error Handling**:
- Symbol not found: Mark asset, surface in Issues Bar
- Rate limited: Back off and retry, or defer to next sync
- Partial data: Store what's available, log missing fields

**Rate Limiting**: Yahoo has undocumented limits. Implement:
- Request delay (100-200ms between calls)
- Batch awareness (pause longer every N requests)
- Retry with exponential backoff on 429

---

## Exposure Calculation

### Basic Formula

For a single exposure dimension (e.g., sector):

```
Exposure(category) = Σ (asset_value × category_weight) / total_value

Where:
- asset_value: Current market value of holding
- category_weight: 1.0 for stocks, percentage for ETFs
- total_value: Portfolio/sleeve invested value (or total with cash)
```

### Stock Exposure

Individual stocks have 100% weight in their single category:

```
AAPL (€10,000, sector: Technology)
→ Contributes €10,000 to Technology exposure
```

### ETF Look-Through

ETFs distribute value across their sector breakdown:

```
VWCE (€50,000) with breakdown:
  Technology: 25%
  Healthcare: 15%
  Financials: 20%
  ...

→ Contributes:
  Technology: €12,500
  Healthcare: €7,500
  Financials: €10,000
  ...
```

### Handling Incomplete Data

**Stocks without metadata**: Categorized as "Unknown"

**ETFs with partial breakdown** (doesn't sum to 100%):
- Remaining percentage goes to "Other"
- Example: ETF breakdown sums to 85% → 15% is "Other"

**Display**:
```
Technology    35%
Healthcare    25%
Financials    20%
Other         15%  ← Includes unclassified portions
Cash           5%
```

### Aggregation Levels

**Portfolio Level**:
- All holdings across all sleeves
- Includes unassigned assets
- Cash shown separately

**Sleeve Level**:
- Holdings assigned to sleeve + all child sleeves
- Unassigned assets excluded
- Proportional cash (if sleeve has cash concept) or excluded

**Sub-Sleeve Level**:
- Same as sleeve, scoped to sub-sleeve + its children

---

## Exposure Rules

### Rule Model

Extends existing `portfolio_rules` table:

```typescript
type ExposureLimitConfig = {
  exposureDimension: 'sector' | 'industry' | 'country' | 'marketCap';
  category?: string;        // Specific category, or null for "any"
  maxPercent: number;       // Maximum allowed exposure (1-100)
};
```

**Rule Types**:

| Pattern | Config | Example |
|---------|--------|---------|
| Any category limit | `{ dimension: 'sector', category: null, maxPercent: 25 }` | No single sector > 25% |
| Specific category limit | `{ dimension: 'country', category: 'United States', maxPercent: 60 }` | US exposure ≤ 60% |

### Violation Detection

Checked during valuation calculation (same flow as concentration rules):

```typescript
interface ExposureViolation {
  ruleId: string;
  ruleName: string;
  exposureDimension: string;
  category: string;           // "Technology", "United States", etc.
  actualPercent: number;
  maxPercent: number;
}
```

**Algorithm**:
1. Load enabled exposure rules for portfolio
2. Calculate exposure breakdown for each dimension with rules
3. For each rule:
   - If `category` is null: check all categories against `maxPercent`
   - If `category` is specified: check only that category
4. Record violations where `actualPercent > maxPercent`

### Violation Display

**Issues Bar** (Dashboard):
- Chip style: Purple (same as allocation issues)
- Format: "Tech sector 32% > 25% limit"

**Exposure Page**:
- Highlight violating categories in red
- Show rule limit line on bar charts
- Violation details in expandable section

---

## Exposure Page

### Page Route

`/exposure` or `/portfolios/[id]/exposure`

### Visual Design

Follow the same look and feel as the dashboard. Reference [specs/mockups/dashboard/mockup-chart-minimal.html](mockups/dashboard/mockup-chart-minimal.html) for:

- **Typography**: Inter font, uppercase labels (11px, letter-spacing 0.5px), tabular-nums for values
- **Colors**: Slate palette (#f8fafc background, #1e293b text, #64748b secondary, #94a3b8 muted)
- **Cards**: White background, 1px #e2e8f0 border, 12px border-radius
- **Status colors**: Green (#16a34a) positive, red (#dc2626) negative, purple (#6366f1) allocation
- **Interactive states**: #f8fafc hover, #f1f5f9 selected
- **Spacing**: 24px container padding, 20px card padding, consistent gaps

### Visualization

**Decision: Pie charts**

After evaluating mockups (horizontal bars, treemaps, stacked bars, pie charts), pie charts were selected because:
- Each dimension always sums to 100%, making pie charts semantically correct
- Intuitive "parts of a whole" representation
- Familiar to users

Implementation:
- Donut-style with center showing item count (e.g., "9 sectors")
- Legend beside each chart with category names and percentages
- Violations highlighted in red
- Top 4-5 categories shown explicitly, remainder collapsed as "X more"

See mockups: `specs/mockups/exposure/mockup-analytical-pie.html`

### Page Structure

```
┌─────────────────────────────────────────────────────────────────┐
│ HEADER                                                          │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ [Portfolio ▼]     Exposure Analysis     [Refresh Metadata]  │ │
│ │                                                             │ │
│ │ Scope: [Portfolio] > Core > Growth    (breadcrumb)         │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ VIOLATIONS BAR (only if violations exist)                       │
│ [!] 2 exposure rules exceeded: [Tech 32% > 25%] [US 65% > 60%] │
├─────────────────────────────────────────────────────────────────┤
│ DIMENSION TABS                                                  │
│ [Sector] [Industry] [Country] [Market Cap]                      │
├─────────────────────────────────────────────────────────────────┤
│ EXPOSURE BREAKDOWN                                              │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │                                                             │ │
│ │  Technology      ████████████████████░░░░  32%  [!]        │ │
│ │  Healthcare      ██████████████░░░░░░░░░░  22%             │ │
│ │  Financials      ████████████░░░░░░░░░░░░  18%             │ │
│ │  Consumer        ████████░░░░░░░░░░░░░░░░  12%             │ │
│ │  Industrials     ██████░░░░░░░░░░░░░░░░░░   8%             │ │
│ │  Other           ████░░░░░░░░░░░░░░░░░░░░   5%             │ │
│ │  Cash            ██░░░░░░░░░░░░░░░░░░░░░░   3%             │ │
│ │                  └─────────────────────┘                   │ │
│ │                  Rule limit: 25% ─────┤                    │ │
│ │                                                             │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ SLEEVE TREE (sidebar or collapsible)                            │
│ ┌───────────────────────┐                                       │
│ │ ● Portfolio (all)     │  ← Click to view portfolio-level     │
│ │   ○ Core              │                                       │
│ │     ○ Bonds           │                                       │
│ │   ○ Satellite         │                                       │
│ │     ● Growth  ←selected                                       │
│ └───────────────────────┘                                       │
├─────────────────────────────────────────────────────────────────┤
│ ASSETS IN CATEGORY (shown when clicking a bar)                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Technology (32% of portfolio)                    [× close]  │ │
│ ├─────────────────────────────────────────────────────────────┤ │
│ │ Asset          Type    Value      Weight   Contribution     │ │
│ │ AAPL           Stock   €8,500     5.2%     5.2%            │ │
│ │ MSFT           Stock   €6,200     3.8%     3.8%            │ │
│ │ VWCE           ETF     €45,000    27.5%    6.9%  (25% Tech)│ │
│ │ ...                                                         │ │
│ └─────────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│ EXPOSURE RULES                                                  │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ Active Rules                               [+ Add Rule]     │ │
│ │ ┌─────────────────────────────────────────────────────────┐ │ │
│ │ │ ● Max sector exposure: 25%              [Edit] [Delete] │ │ │
│ │ │ ● Max US exposure: 60%                  [Edit] [Delete] │ │ │
│ │ └─────────────────────────────────────────────────────────┘ │ │
│ └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Interactions

| Element | Action |
|---------|--------|
| Portfolio dropdown | Switch portfolio context |
| Breadcrumb segment | Navigate to that scope level |
| Sleeve tree item | Change scope to that sleeve |
| Dimension tab | Switch exposure dimension view |
| Exposure bar | Show assets in that category (drill-down) |
| Violation chip | Scroll to violating category, expand details |
| Refresh button | Force metadata re-fetch (ignores 1-week cache) |
| Add Rule button | Open rule creation modal |

### Visualization Choice

**Decided: Pie charts** (see Visualization section above)

The ASCII diagram above uses horizontal bars as a placeholder for documentation purposes. Actual implementation will use pie/donut charts.

### Page Philosophy

The Exposure page is **analytical**, not actionable:
- Shows current exposure breakdown across dimensions
- Surfaces violations with clear "Fix →" link to Rebalancing page
- Supports drill-down for understanding (which assets contribute to a category)
- Does NOT suggest specific trades or fixes (that's the Rebalancing page's job)

**Expanded views** (accessible via links):
- **Dimension drill-down**: Full list with contributing assets table
- **Cross-analysis**: Sector × Country matrix showing intersections
- **Sleeve comparison**: Side-by-side exposure per sleeve
- **Exposure history**: Chart showing drift over time + events that caused changes

See mockups:
- `specs/mockups/exposure/mockup-analytical.html` (main view)
- `specs/mockups/exposure/mockup-analytical-expanded.html` (drill-down)
- `specs/mockups/exposure/mockup-analytical-cross.html` (cross-analysis)
- `specs/mockups/exposure/mockup-analytical-compare.html` (sleeve comparison)
- `specs/mockups/exposure/mockup-analytical-history.html` (temporal)

### Empty States

**No metadata**: "Metadata not yet fetched. Run sync or click Refresh."

**No holdings**: "No holdings in this sleeve."

**No violations**: Hide violations bar entirely.

---

## Data Requirements

### New API Endpoints

1. **Exposure breakdown**
   ```typescript
   exposure.getBreakdown({
     portfolioId: string,
     sleeveId?: string,      // null = portfolio level
     dimension: 'sector' | 'industry' | 'country' | 'marketCap'
   }) → {
     breakdown: { category: string, value: number, percent: number }[],
     totalValue: number,
     assetCount: number,
     unknownPercent: number
   }
   ```

2. **Assets by category**
   ```typescript
   exposure.getAssetsByCategory({
     portfolioId: string,
     sleeveId?: string,
     dimension: string,
     category: string
   }) → {
     assets: {
       isin: string,
       name: string,
       ticker: string,
       isEtf: boolean,
       value: number,
       portfolioWeight: number,
       categoryContribution: number,  // How much this asset contributes to the category
       etfCategoryWeight?: number     // For ETFs: the % of ETF in this category
     }[]
   }
   ```

3. **Exposure violations**
   - Extend existing `valuation.getPortfolioValuation` response
   - Add `exposureViolations: ExposureViolation[]`
   - Add `exposureViolationCount: number`

4. **Asset metadata management**
   ```typescript
   assets.updateMetadata({
     isin: string,
     sector?: string,
     industry?: string,
     country?: string,
     marketCap?: string,
     metadataSource: 'manual'
   })

   assets.resetMetadata({ isin: string })  // Clear manual override
   ```

5. **Exposure rules** (extend existing rules router)
   ```typescript
   rules.createExposureLimit({
     portfolioId: string,
     name: string,
     config: ExposureLimitConfig
   })
   ```

### Database Migrations

1. Add metadata columns to `assets` table (or create `asset_metadata`)
2. Add `etf_breakdown` table or JSON column
3. Extend `portfolio_rules.ruleType` to include `'exposure_limit'`

---

## Integration Points

### Issues Bar (Dashboard)

Exposure violations appear as purple chips:
- Format: "{Category} {actual}% > {limit}% limit"
- Clicking navigates to Exposure page with category highlighted

### Sync Flow

```
Existing sync flow:
  1. Fetch prices for all symbols
  2. Update daily prices
  3. [NEW] Fetch metadata if stale (> 7 days)
  4. [NEW] Fetch ETF breakdowns if stale
  5. Emit sync_complete event
```

### Navigation

- Add "Exposure" link to main navigation
- Link from dashboard Issues Bar violations
- Link from asset detail page (future)

### Rebalancing Integration

The Exposure page links to the Rebalancing page for action:
- "Fix in Rebalancing →" button in violations banner
- Individual "Fix →" links per violation
- Links pass context (e.g., `/rebalancing?focus=sector.technology`)

See `specs/rebalancing-spec.md` for the Rebalancing feature design.

---

## Implementation Phases

### Phase 1: Data Foundation
- [ ] Yahoo crumb/session authentication
- [ ] Asset metadata fetch (sector, industry, country, market cap)
- [ ] Database schema for metadata storage
- [ ] Manual override support
- [ ] Integrate into sync flow with 7-day freshness check

### Phase 2: ETF Look-Through
- [ ] ETF detection (via Yahoo or asset type flag)
- [ ] Fetch ETF sector/country breakdown
- [ ] Fetch top 10 holdings
- [ ] Store ETF breakdown data

### Phase 3: Exposure Calculation
- [ ] Exposure calculation engine
- [ ] Stock exposure (direct mapping)
- [ ] ETF look-through calculation
- [ ] Aggregation at portfolio/sleeve levels
- [ ] Handle unknown/other categories

### Phase 4: Exposure Page
- [ ] Page route and layout
- [ ] Dimension tabs (sector, industry, country, market cap)
- [ ] Horizontal bar chart visualization
- [ ] Sleeve tree navigation
- [ ] Category drill-down (assets list)

### Phase 5: Exposure Rules
- [ ] Rule data model (extend portfolio_rules)
- [ ] Rule CRUD operations
- [ ] Violation detection in valuation flow
- [ ] Display in Issues Bar
- [ ] Display on Exposure page

### Phase 6: Polish
- [ ] Loading states
- [ ] Error handling UI
- [ ] Refresh metadata button
- [ ] Violation highlighting
- [ ] Mobile responsiveness (future)

---

## Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Page name | "Exposure" - direct and descriptive |
| ETF look-through | Yes, enabled by default |
| Unknown holdings | Label as "Other/Unknown", include in totals |
| Top N holdings | Top 10 |
| Rule scope | Portfolio-level (like concentration rules) |
| Visualization | Pie charts (intuitive for 100% breakdowns) |
| Cash handling | Show as own category (like sleeves) |
| Metadata refresh | Weekly (7-day freshness check) |
| Visual design | Follow dashboard mockup styling |

---

## Glossary Updates

Add to `glossary.md`:

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| exposure | Percentage of portfolio value in a category (sector, country, etc.) | specs/exposure-spec.md |
| exposure dimension | Classification axis: sector, industry, country, market cap | specs/exposure-spec.md |
| ETF look-through | Distributing ETF value across its underlying breakdown | specs/exposure-spec.md |
| exposure rule | Portfolio constraint on maximum exposure to a category | specs/exposure-spec.md |
| asset metadata | Sector, industry, country, market cap data for an asset | specs/exposure-spec.md |
| crumb | Yahoo Finance CSRF token required for API calls | specs/exposure-spec.md |

---

## Success Criteria

1. User can see portfolio exposure breakdown by sector, industry, country, market cap
2. ETF holdings are properly distributed across categories (look-through works)
3. Sleeve-level exposure analysis works with proper hierarchy
4. Exposure rules can be created and violations are surfaced
5. Metadata syncs automatically with weekly freshness
6. Manual overrides persist and are clearly indicated
7. Unknown/uncategorized portions are transparently shown
