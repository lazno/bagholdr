# FinancePal v2

A portfolio rebalancing web application for retail investors.

## Quick Start

```bash
# Use correct Node version
nvm use

# Install dependencies
pnpm install

# Start development server
pnpm dev

# Run type checking
pnpm check
```

## Documentation

- **`AGENTS.md`** (parent directory) - AI agent guidelines, code style, commands
- **`project.md`** (parent directory) - Full project specification
- **`drizzle.config.ts`** - Database configuration

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | SvelteKit |
| Language | TypeScript (strict) |
| API | tRPC |
| Database | SQLite via Drizzle ORM |
| Styling | Tailwind CSS v4 |
| Price Data | Yahoo Finance REST API |

## Project Structure

```
financepal/
├── src/
│   ├── app.d.ts                 # SvelteKit type declarations
│   ├── lib/
│   │   ├── server/              # Server-only code (never bundled to client)
│   │   │   ├── db/
│   │   │   │   ├── client.ts    # Drizzle database client
│   │   │   │   └── schema.ts    # Database schema (tables, types)
│   │   │   ├── import/
│   │   │   │   ├── directa-parser.ts    # CSV parsing for Directa broker
│   │   │   │   └── derive-holdings.ts   # Calculate holdings from orders
│   │   │   ├── oracle/
│   │   │   │   ├── yahoo.ts     # Yahoo Finance API client
│   │   │   │   └── cache.ts     # Price/FX caching with TTL
│   │   │   └── trpc/
│   │   │       ├── trpc.ts      # tRPC initialization
│   │   │       ├── context.ts   # Request context (db access)
│   │   │       ├── router.ts    # Main router (combines all routers)
│   │   │       └── routers/
│   │   │           ├── portfolios.ts  # Portfolio CRUD
│   │   │           ├── assets.ts      # Asset management
│   │   │           ├── holdings.ts    # Holdings queries
│   │   │           ├── sleeves.ts     # Sleeve CRUD, asset assignment
│   │   │           ├── valuation.ts   # Portfolio valuation & allocation
│   │   │           ├── oracle.ts      # Price fetching, Yahoo symbols
│   │   │           └── import.ts      # CSV import flow
│   │   ├── trpc/
│   │   │   └── client.ts        # tRPC client for frontend
│   │   └── utils/
│   │       ├── config.ts        # App constants (cache TTL, etc.)
│   │       └── bands.ts         # Tolerance band calculations
│   └── routes/
│       ├── +layout.svelte       # Root layout
│       ├── +page.svelte         # Dashboard (/)
│       ├── api/trpc/[...trpc]/
│       │   └── +server.ts       # tRPC HTTP endpoint
│       ├── assets/
│       │   └── +page.svelte     # Asset list, Yahoo symbol management
│       ├── import/
│       │   └── +page.svelte     # CSV upload flow
│       └── portfolios/
│           ├── new/
│           │   └── +page.svelte # Create portfolio
│           └── [id]/
│               ├── +page.svelte # Portfolio detail, settings
│               └── sleeves/
│                   └── +page.svelte # Sleeve management, allocation view
├── drizzle/                     # Migration files (auto-generated)
├── financepal.db                # SQLite database file
├── drizzle.config.ts            # Drizzle ORM config
├── svelte.config.js             # SvelteKit config
├── tailwind.config.js           # Tailwind config
└── package.json
```

## Database Schema

Key tables (see `src/lib/server/db/schema.ts` for full schema):

| Table | Purpose |
|-------|---------|
| `portfolios` | Portfolio configs with cash and band settings |
| `assets` | Financial instruments (ISIN, ticker, Yahoo symbol) |
| `orders` | Raw imported orders (audit trail) |
| `holdings` | Derived positions (quantity, cost basis) |
| `sleeves` | Hierarchical allocation buckets |
| `sleeve_assets` | Asset-to-sleeve assignments |
| `price_cache` | Cached prices from Yahoo |
| `fx_cache` | Cached FX rates |
| `yahoo_symbols` | Available Yahoo symbols per ISIN |

## Key Concepts

### Holdings vs Portfolios
- **Holdings are global** - derived from CSV imports, represent actual positions
- **Portfolios are configurations** - organize the same holdings differently with different sleeve structures

### Sleeves
- Hierarchical groupings with budget targets
- Budgets must sum to 100% at each level
- Assets assigned to one sleeve per portfolio

### Tolerance Bands
- Portfolio-level settings for allocation tolerance
- Relative tolerance (%) with absolute floor/cap (pp)
- Green = within band, Yellow = outside band

### Cash Toggle
- **Invested view**: Percentages relative to assigned holdings
- **Total view**: Percentages relative to holdings + cash

## Commands

```bash
pnpm dev          # Start dev server
pnpm build        # Build for production
pnpm preview      # Preview production build
pnpm check        # Type check
pnpm lint         # ESLint
pnpm format       # Prettier

# Database
pnpm db:generate  # Generate migrations
pnpm db:migrate   # Run migrations
pnpm db:push      # Push schema directly (dev)
pnpm db:studio    # Open Drizzle Studio
```

## API (tRPC)

All API calls go through tRPC. Main routers:

- `trpc.portfolios.*` - Portfolio CRUD
- `trpc.assets.*` - Asset management
- `trpc.holdings.*` - Holdings queries
- `trpc.sleeves.*` - Sleeve management
- `trpc.valuation.*` - Portfolio valuation
- `trpc.oracle.*` - Price fetching
- `trpc.import.*` - CSV import
