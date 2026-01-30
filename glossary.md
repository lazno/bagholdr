# Glossary

This file serves as an index for LLMs to find detailed context about project concepts, features, and specifications.

## How to Use

When you encounter a keyword or concept and need more context, look it up here to find the relevant specification or documentation file.

---

## Index

### Dashboard & UI

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| dashboard | Main landing page showing portfolio metrics, sleeves, chart, and assets table | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| issues bar | Inline horizontal bar showing actionable health/allocation issues | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| sleeves panel | Panel showing sleeve hierarchy with allocation vs. target | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| assets table | Sortable table of holdings with sleeve filtering | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| invested value chart | Time series chart showing portfolio value vs. cost basis | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| return periods | Performance periods: Today, 1W, 1M, YTD, 1Y, Total (vs. cost) | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| privacy mode | Toggle to blur/hide currency values while keeping percentages visible | [specs/dashboard-spec.md](specs/dashboard-spec.md) |

### Financial Calculations

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| cost basis | Total amount paid to acquire holdings | [specs/calculus-spec.md](specs/calculus-spec.md) |
| invested value | Current market value of holdings (excludes cash) | [specs/calculus-spec.md](specs/calculus-spec.md) |
| total value | Invested value + cash | [specs/calculus-spec.md](specs/calculus-spec.md) |
| return | Difference between current value and comparison value (absolute or %) | [specs/calculus-spec.md](specs/calculus-spec.md) |
| TWR | Time-Weighted Return - measures investment performance, neutralizes cash flows (for benchmark comparison) | [specs/calculus-spec.md](specs/calculus-spec.md) |
| MWR | Money-Weighted Return (IRR) - measures actual rate of return accounting for when cash was invested | [specs/calculus-spec.md](specs/calculus-spec.md) |
| cash flow | Buy/sell orders that add/remove money from the portfolio | [specs/calculus-spec.md](specs/calculus-spec.md) |
| weight | Percentage of portfolio that an asset represents | [specs/calculus-spec.md](specs/calculus-spec.md) |
| allocation | Percentage of portfolio in a sleeve | [specs/calculus-spec.md](specs/calculus-spec.md) |
| deviation | Difference between actual and target allocation (in pp) | [specs/calculus-spec.md](specs/calculus-spec.md) |
| band | Acceptable range around target allocation | [specs/calculus-spec.md](specs/calculus-spec.md) |
| band status | Whether allocation is in-band, warning, or out-of-band | [specs/calculus-spec.md](specs/calculus-spec.md) |
| concentration | Single asset's percentage of portfolio | [specs/calculus-spec.md](specs/calculus-spec.md) |
| unrealized P/L | Current value minus cost basis (paper gain/loss) | [specs/calculus-spec.md](specs/calculus-spec.md) |

### Exposure Analysis

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| exposure | Percentage of portfolio value in a category (sector, country, etc.) | [specs/exposure-spec.md](specs/exposure-spec.md) |
| exposure dimension | Classification axis: sector, industry, country, market cap | [specs/exposure-spec.md](specs/exposure-spec.md) |
| ETF look-through | Distributing ETF value across its underlying sector/country breakdown | [specs/exposure-spec.md](specs/exposure-spec.md) |
| exposure rule | Portfolio constraint on maximum exposure to a category | [specs/exposure-spec.md](specs/exposure-spec.md) |
| asset metadata | Sector, industry, country, market cap data for an asset | [specs/exposure-spec.md](specs/exposure-spec.md) |
| ETF breakdown | Sector/country percentages and top holdings for an ETF | [specs/exposure-spec.md](specs/exposure-spec.md) |
| crumb | Yahoo Finance CSRF token required for API calls | [specs/exposure-spec.md](specs/exposure-spec.md) |

### Health Indicators

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| stale asset prices | Assets with prices older than threshold (e.g., 24h) | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| unassigned assets | Holdings not assigned to any sleeve | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| missing symbol | Assets without a Yahoo Finance symbol | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| allocation drift | Sleeves outside their target band | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| concentration violation | Assets exceeding concentration rule limits | [specs/dashboard-spec.md](specs/dashboard-spec.md) |
| exposure violation | Category exceeding exposure rule limit | [specs/exposure-spec.md](specs/exposure-spec.md) |

### Data Model

| Keyword | Description | Location |
|---------|-------------|----------|
| portfolio | Configuration container with band settings and rules | server/src/db/schema.ts |
| sleeve | Hierarchical grouping with budget target | server/src/db/schema.ts |
| holding | Current position derived from orders | server/src/db/schema.ts |
| order | Raw imported trade from broker CSV | server/src/db/schema.ts |
| daily prices | Historical OHLCV data for charting | server/src/db/schema.ts |
| archived asset | Asset excluded from all calculations and dashboard views (data preserved, can be unarchived) | [specs/dashboard-plan.md](specs/dashboard-plan.md#dash-024-archive-assets-feature) |

### Broker Integration

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| Directa SIM | Italian online broker used for trading | [specs/directa-sync-plan.md](specs/directa-sync-plan.md) |
| Directa sync | Automated order import from Directa SIM via browser automation | [specs/directa-sync-plan.md](specs/directa-sync-plan.md) |
| OTP | One-Time Password sent via email for Directa login authentication | [specs/directa-sync-plan.md](specs/directa-sync-plan.md) |
| Directa parser | CSV parser for Directa order export format | server/src/import/directa-parser.ts |

### Account-Portfolio Architecture

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| account | Data source / import target (broker account or virtual). Orders and holdings belong to accounts. | [specs/native-app-plan.md](specs/native-app-plan.md#napp-050) |
| virtual account | Account with manually entered positions for paper trading / hypothetical testing | [specs/native-app-plan.md](specs/native-app-plan.md#napp-051) |
| portfolio-account relationship | Portfolios aggregate one or more accounts. Enables multi-broker views and strategy comparison. | [specs/native-app-plan.md](specs/native-app-plan.md#napp-050) |
| XIRR benchmark | Compare portfolio XIRR to benchmark using same cash flows | [specs/native-app-plan.md](specs/native-app-plan.md#napp-053) |
| TWR benchmark | Compare portfolio TWR to benchmark (neutralizes cash flow timing) | [specs/native-app-plan.md](specs/native-app-plan.md#napp-054) |
| Monte Carlo projection | Forward-looking simulation showing range of possible outcomes based on volatility | [specs/native-app-plan.md](specs/native-app-plan.md#napp-055) |
| fat tails | Extreme market events happen more often than normal distribution predicts; use t-distribution to model | [specs/native-app-plan.md](specs/native-app-plan.md#napp-055) |
| fan chart | Visualization showing percentile bands expanding over time (uncertainty grows) | [specs/native-app-plan.md](specs/native-app-plan.md#napp-055) |
| asset class parameters | Published historical return/volatility/correlation data for broad asset categories | [specs/native-app-plan.md](specs/native-app-plan.md#napp-056) |

### Native App / Mobile

| Keyword | Description | Spec File |
|---------|-------------|-----------|
| native app | Universal app (web + Android + iOS) rebuilt with Flutter + Serverpod | [specs/native-app-plan.md](specs/native-app-plan.md) |
| Flutter | Google's UI toolkit for building natively compiled apps from a single Dart codebase | [specs/native-app-plan.md](specs/native-app-plan.md) |
| Dart | Programming language used by Flutter and Serverpod | [specs/native-app-plan.md](specs/native-app-plan.md) |
| Serverpod | Dart backend framework with auto-generated type-safe Flutter client | [specs/native-app-plan.md](specs/native-app-plan.md) |
| full-stack Dart | Architecture using Dart for both frontend (Flutter) and backend (Serverpod) | [specs/native-app-plan.md](specs/native-app-plan.md) |
| syncfusion_flutter_charts | Feature-rich financial charting library for Flutter | [specs/native-app-plan.md](specs/native-app-plan.md) |
| fl_chart | Lightweight open-source charting library for Flutter | [specs/native-app-plan.md](specs/native-app-plan.md) |
| SSE | Server-Sent Events - used for real-time price updates from server to app | [specs/native-app-plan.md](specs/native-app-plan.md) |
| vertical slice | Development approach where each feature includes backend + frontend end-to-end | [specs/native-app-plan.md](specs/native-app-plan.md) |
| backlog | Tasks and technical debt that don't fit current plans, tracked for future work | [specs/backlog.md](specs/backlog.md) |
