# Bagholdr — Project Specification

## Overview

Bagholdr is a portfolio rebalancing web application. It helps users steer a portfolio of financial assets toward a target allocation by:

- Importing orders from CSV to derive current holdings
- Organizing assets into hierarchical "sleeves" with budget targets
- Defining rules (hard budgets + soft exposure limits)
- Fetching live prices and FX rates
- Visualizing allocations and rule compliance
- Suggesting rebalancing actions (buy/sell)

---

## Key Architectural Concept: Holdings vs Portfolios

**Holdings are global** — derived from CSV imports and updated over time. They represent the user's actual positions.

**Portfolios are configurations/strategies** — they reference the same global holdings but organize them differently with different sleeve structures and budget targets.

```
User Holdings (global, derived from imports)
├── Asset A: 100 shares
├── Asset B: 50 shares
└── Asset C: 200 shares

Portfolio "Conservative"         Portfolio "Aggressive"
├── Sleeve: Bonds 60%           ├── Sleeve: Growth 80%
│   └── Asset A                 │   ├── Asset B
├── Sleeve: Equities 40%        │   └── Asset C
│   └── Asset B                 └── Sleeve: Cash 20%
└── (Asset C unassigned)
                                [Unassigned: Asset A]
```

Both portfolios see the **same holdings quantities** but organize them differently. This allows comparing different strategies against the same underlying assets.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Frontend** | SvelteKit + Svelte 5 + Tailwind CSS |
| **Backend** | Hono (standalone Node.js server) |
| **API** | tRPC (end-to-end type safety) |
| **Database** | SQLite via Drizzle ORM |
| **Price Data** | Yahoo Finance REST API |
| **Language** | TypeScript (strict mode) |
| **Package Manager** | pnpm |

### Architecture

```
Frontend (SvelteKit @ :5173)  →  Backend (Hono @ :3001)  →  SQLite
                              ↘  WebSocket (:3002) for real-time updates
```

- **Frontend** (`src/`): SvelteKit app, uses `@trpc/client` to call backend
- **Backend** (`server/`): Standalone Hono server with tRPC routers, price oracle, cron jobs
- **Type sharing**: Frontend imports types from `server/src/` for end-to-end type safety

---

## Domain Model

### Asset

A financial instrument. Primary identifier is ISIN.

- **Types:** `stock`, `etf`, `bond`, `fund`, `commodity`, `other`
- **Key fields:** isin, ticker, name, assetType, currency
- **Metadata:** Optional structured data (holdings breakdown, sectors, factors) — for future LLM enrichment

### Holding

Derived from imported orders. Represents current position (quantity + total cost in EUR). Holdings are **global** — shared across all portfolios.

### Portfolio

A configuration/strategy that organizes global holdings into sleeves with budget targets. Each portfolio has:

- Its own sleeve structure
- Its own cash position (manually set, not derived from imports)
- Its own rules and band configuration

### Sleeve

Hierarchical grouping of assets for budget allocation.

**Rules:**

- Sleeves form a tree structure (arbitrary depth, typically shallow)
- All sibling sleeves' `budgetPercent` must sum to exactly 100%
- An asset belongs to exactly ONE sleeve per portfolio
- Same asset can be in different sleeves across different portfolios

### Unassigned Assets

Assets not assigned to any sleeve in a portfolio appear in an implicit "Unassigned" category. This is not a real sleeve — just a UI indicator prompting users to organize their assets.

### Cash Handling

Cash is **NOT a sleeve** — it's a separate portfolio attribute.

**Key principles:**

- Cash is manually set by user (not derived from imports)
- Cash does NOT participate in sleeve budget calculations
- Sleeve budgets sum to 100% of **invested value** (excluding cash)

**View Toggle:** Users can switch between "Invested Only" (default) and "Total Portfolio" views to see allocations with or without cash impact.

---

## Rules System

### Budget Rules (Hard Constraints)

Budget rules enforce allocation targets that **must sum to 100%** at each hierarchy level.

**Band Mechanism:** Bands define tolerance around targets using:

- Relative tolerance (default 20% of target)
- Absolute floor (minimum half-width, default 2pp)
- Absolute cap (maximum half-width, default 10pp)

Example: A 20% target with 20% relative tolerance = ±4pp = 16%–24% acceptable range

### Concentration Rules

Limit maximum allocation to single assets or asset types. Example: "No single stock > 5% of portfolio"

### Exposure Rules (Future)

Soft constraints for cross-cutting concerns (sectors, factors, themes). Unlike budget rules, exposures can overlap — an asset can contribute to multiple categories.

---

## Order Import

### CSV Format (Directa)

- First 10 lines: header/metadata
- Line 10: column headers
- Processes `Buy` and `Sell` transactions
- Ignores fees, taxes, dividends, wire transfers

### Import Flow

1. Parse CSV, extract account info
2. For each Buy/Sell: find or create Asset by ISIN
3. Store raw orders for audit trail
4. Derive holdings by aggregating all orders per ISIN

Orders are cumulative — current state is always derived from complete order history.

---

## Price Oracle

Uses Yahoo Finance REST API directly for:

- ISIN → ticker symbol resolution (with multi-exchange support)
- Current price fetching
- FX rate fetching (all values converted to EUR)

Prices are cached (default 6-hour TTL). Manual symbol override available for edge cases.

**Special case:** British pence (GBp) — divide by 100 when converting to GBP.

---

## Rebalancing

The rebalancing engine generates **informational suggestions only** — users execute trades at their broker.

**Constraints:**

- Whole shares only (no fractional)
- Minimum order size (~€75) to justify transaction fees
- Cash-aware (can only buy if cash available)
- Minimize transactions (prefer fewer, larger orders)

---

## Key Business Rules

1. Budgets sum to 100% at each sleeve hierarchy level
2. Assets belong to exactly one sleeve per portfolio
3. Same asset can be in different sleeves across portfolios
4. Holdings are global — derived from imports, shared across portfolios
5. Exposures can overlap — an asset contributes to multiple categories
6. Whole shares only — no fractional share support
7. All values displayed in EUR
8. Cash is explicit — user-managed per portfolio, not derived
9. Rebalancing is informational — suggestions only
10. Single user — no auth for v1

---

## Glossary

| Term | Definition |
|------|------------|
| **Portfolio** | A configuration/strategy that organizes holdings into sleeves with budget targets |
| **Asset** | A financial instrument identified by ISIN |
| **Holding** | Current position in an asset (quantity + cost basis), global across all portfolios |
| **Sleeve** | A hierarchical grouping of assets with a budget target, specific to a portfolio |
| **Budget** | Target allocation % that must sum to 100% among siblings |
| **Exposure** | Cross-cutting category (sector, factor, theme) that doesn't sum to 100% |
| **Band** | Tolerance range around a target allocation |
| **Rule** | Constraint defining acceptable allocation ranges |
| **Violation** | When actual allocation breaches rule bounds |
| **Rebalancing** | Suggested trades to restore target allocations (informational only) |
| **Oracle** | Service that fetches current prices and FX rates |
| **Unassigned** | Assets not yet assigned to any sleeve in a portfolio |

---

## Reference Files

| Directory | Purpose |
|-----------|---------|
| `directa/` | Reference CSV parser implementation (Gleam) and sample data |
| `yahoo/` | Reference Yahoo Finance API client (Gleam) |
| `jsonschema/` | Comprehensive asset metadata schema for future enrichment |
