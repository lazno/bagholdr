# AGENTS.md - Bagholdr

Guidelines for AI agents working on this codebase.

## Session Start

At the start of each new session, read `glossary.md` to familiarize yourself with project terminology and find relevant specification files for the current task.

## Project Overview

Bagholdr is a portfolio rebalancing web application built with:

- **Svelte 5** - Frontend (uses SvelteKit tooling for build)
- **Hono** - Backend server (`server/`)
- **tRPC** - End-to-end type-safe API (via `@hono/trpc-server`)
- **TypeScript** - Strict mode enabled
- **Drizzle ORM** - SQLite database
- **Tailwind CSS** - Styling
- **pnpm** - Package manager

See `project.md` for full specification.

## Build & Development Commands

### Frontend (`/`)

```bash
pnpm install          # Install dependencies
pnpm dev              # Development server
pnpm build            # Build for production
pnpm preview          # Preview production build
pnpm check            # Type checking (svelte-check)
```

### Backend (`server/`)

```bash
pnpm dev              # Development server (tsx watch)
pnpm build            # Build for production (tsc)
pnpm start            # Run production build
pnpm db:generate      # Generate migrations from schema changes
pnpm db:migrate       # Run migrations
pnpm db:studio        # Open Drizzle Studio
```

## Code Style Guidelines

### TypeScript

- Strict mode enabled - no `any` types, explicit return types on exports
- Use `type` for object shapes, `interface` for extendable contracts
- Use branded types for domain identifiers (ISIN, portfolio IDs)

### Naming Conventions

- **Files**: `kebab-case.ts`, `PascalCase.svelte` for components
- **Variables/functions**: `camelCase`
- **Types/interfaces**: `PascalCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Database tables**: `snake_case`

### Imports

- Use `$lib` alias for `src/lib` imports
- Group imports: external deps, then `$lib`, then relative
- Use type-only imports where applicable

### General Patterns

- Svelte components: use `<script lang="ts">`, props at top
- tRPC: use Zod for validation, keep procedures thin
- Error handling: use `TRPCError` with appropriate codes
- Tailwind: use utilities, extract patterns to components

## Testing

- Test files: `*.test.ts` or `*.spec.ts`
- Use Vitest
- Test business logic in utils, not UI components
- Mock external services

## Creating Mockups

- mockups are generated under specs/mockups/{specname}/
- example: when creating mockups for specs/dashboard-spec.md then the mockups should be spec/mockups/dashboard/mockup-{desc}.md
- desc is a placeholder for 1 to 3 keywords that describe what this mockup is all about and distinguishes it from the other mockups in the same folder
- mockups are simple clickdummies, rather low fidelity unless requested otherwhise
- use the same colors/styling for all mockups of the same feature, so its a fair comparison
- be mindful of keeping a good data to ink ratio
- after creating mockups, provide the user with links so he can open it in the browser

## Maintaining the Glossary

When writing a new design document or specification in the `specs/` folder, update `glossary.md` with:

- New keywords and concepts introduced in the spec
- Brief descriptions of each term
- Link to the spec file for detailed context

This keeps the glossary current and helps future sessions quickly understand project concepts.
