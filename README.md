# Bagholdr

A portfolio rebalancing web application for retail investors.

## Quick Start

```bash
nvm use
pnpm install

# Start both frontend and backend
pnpm dev                    # Frontend (localhost:5173)
cd server && pnpm dev       # Backend (localhost:3001)
```

## Architecture

```
Frontend (SvelteKit @ :5173)  →  Backend (Hono @ :3001)  →  SQLite
```

- **Frontend** (`src/`): SvelteKit app with tRPC client
- **Backend** (`server/`): Hono server with tRPC, Drizzle ORM, price oracle

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | SvelteKit, Svelte 5, Tailwind CSS 4 |
| Backend | Hono, tRPC, Drizzle ORM |
| Database | SQLite (better-sqlite3) |
| Language | TypeScript (strict) |
| Charts | lightweight-charts |
| Price Data | Yahoo Finance API |

## Commands

**Frontend** (root directory):
```bash
pnpm dev          # Start dev server
pnpm build        # Build for production
pnpm check        # Type check
```

**Backend** (`server/` directory):
```bash
pnpm dev          # Start dev server
pnpm build        # Build for production
pnpm db:generate  # Generate migrations
pnpm db:migrate   # Run migrations
pnpm db:studio    # Open Drizzle Studio
```

## Documentation

- `project.md` - Full project specification
- `AGENTS.md` - AI agent guidelines
- `glossary.md` - Domain terminology
