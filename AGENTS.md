# AGENTS.md - Bagholdr

Technical reference for AI agents working on this codebase.

## Commands

| Command | Action |
|---------|--------|
| `ralph` | Follow `ralph.md` - pick the next unblocked task and complete it |

---

## Session Start

At the start of each new session, read `glossary.md` to familiarize yourself with project terminology and find relevant specification files for the current task.

IMPORTANT: For Flutter UI tasks, run `./native/scripts/start-with-hotreload.sh` before starting implementation. This starts all services with hot reload active on both web and emulator.

## Project Overview

Bagholdr is a portfolio rebalancing application with two implementations:

**Web App (TypeScript)**:

- **Svelte 5** - Frontend (uses SvelteKit tooling for build)
- **Hono** - Backend server (`server/`)
- **tRPC** - End-to-end type-safe API (via `@hono/trpc-server`)
- **Drizzle ORM** - SQLite database
- **Tailwind CSS** - Styling

**Native App (Dart)**:

- **Flutter** - Cross-platform UI (`native/bagholdr/bagholdr_flutter`)
- **Serverpod** - Backend server (`native/bagholdr/bagholdr_server`)
- **PostgreSQL** - Database (via Docker)

See `project.md` for full specification.

---

## Quality Standards

These rules apply to ALL code changes in the repository.

### Testing

- All code changes must have tests
- Tests must pass before committing
- Run the appropriate test command for your changes:
  - TypeScript: `pnpm test` or `vitest`
  - Dart server: `cd native/bagholdr/bagholdr_server && dart test`
  - Flutter: `cd native/bagholdr/bagholdr_flutter && flutter test`

### Endpoint Testing (MANDATORY)

**Unit tests are NOT sufficient for endpoints.** ORM queries, type mismatches, and database issues only surface at runtime.

When implementing any API endpoint, you MUST perform an end-to-end test before marking the task complete:

1. Start the server with a real database
2. Call the endpoint and verify it returns the expected response

**Do NOT mark an endpoint task complete until you have verified it works end-to-end.**

### Code Quality

- No hardcoded colors in Flutter (use theme)
- No `any` types in TypeScript
- Explicit return types on exported functions

---

## Build & Development Commands

### Frontend - Svelte (`/`)

```bash
pnpm install          # Install dependencies
pnpm dev              # Development server (port 5173)
pnpm build            # Build for production
pnpm preview          # Preview production build
pnpm check            # Type checking (svelte-check)
```

### Backend - Hono (`server/`)

```bash
pnpm dev              # Development server (tsx watch, port 3000)
pnpm build            # Build for production (tsc)
pnpm start            # Run production build
pnpm db:generate      # Generate migrations from schema changes
pnpm db:migrate       # Run migrations
pnpm db:studio        # Open Drizzle Studio
```

### Native - Flutter (`native/bagholdr/bagholdr_flutter`)

```bash
# Start everything with hot reload (RECOMMENDED for UI work)
./native/scripts/start-with-hotreload.sh

# Stop everything
./native/scripts/stop.sh --all

# Manual startup (if needed)
./native/scripts/start.sh --web --emulator        # Start services without hot reload
./native/scripts/start.sh --web                   # Web only

# Manual Flutter commands
cd native/bagholdr/bagholdr_flutter
flutter run -d chrome --web-port=3001             # Run web
flutter run -d emulator-5554                      # Run on emulator
flutter test                                      # Run tests
```

### Native - Serverpod (`native/bagholdr/bagholdr_server`)

```bash
# Start database
docker compose up -d

# Run server with migrations
dart bin/main.dart --apply-migrations

# Code generation (after changing model YAML files)
"$HOME/.pub-cache/bin/serverpod" generate

# Create migration (after adding/changing models)
"$HOME/.pub-cache/bin/serverpod" create-migration

# Run tests
dart test

# Reset database (destructive!)
docker compose down -v && docker compose up -d
```

**Important**: Do NOT modify global PATH for Serverpod CLI. Always use the full path.

---

## Screenshots (Svelte Web App)

Both servers must be running (`pnpm dev` + `cd server && pnpm dev`).

```bash
pnpm screenshot <path> [name]

# Examples
pnpm screenshot /                     # saves as tests/screenshots/home.png
pnpm screenshot /portfolios/1 detail  # saves as tests/screenshots/detail.png
```

Screenshots are saved to `tests/screenshots/` (gitignored).

---

## Code Style

### TypeScript

- Strict mode enabled - no `any` types, explicit return types on exports
- Use `type` for object shapes, `interface` for extendable contracts
- Use branded types for domain identifiers (ISIN, portfolio IDs)
- Test files: `*.test.ts` or `*.spec.ts`
- Use Vitest for testing

### Dart/Flutter

- **ALWAYS use theme-aware colors** - no exceptions unless explicitly stated otherwise:

  ```dart
  // BAD - never do this
  color: Color(0xFF111111)
  color: Color(0xFFFFFBEB)  // Even "nice" colors break in dark mode

  // GOOD - use theme colors
  color: Theme.of(context).colorScheme.surface
  color: context.financialColors.issueBarBackground
  ```

  This applies to ALL colors: backgrounds, borders, text, icons, everything. Hardcoded colors break dark mode.

- Use `FinancialColors` extension for gains/losses:

  ```dart
  final colors = Theme.of(context).extension<FinancialColors>()!;
  color: colors.positive  // green for gains
  color: colors.negative  // red for losses
  ```

- Formatters in `lib/utils/formatters.dart`:

  ```dart
  formatCurrency(1234.56)        // €1,234.56
  formatCurrencyCompact(113482)  // €113k
  formatPercent(0.1234)          // +12.34%
  formatSignedCurrency(1234)     // +€1,234
  ```

### Naming Conventions

| Context | Convention | Example |
|---------|------------|---------|
| TypeScript files | kebab-case | `derive-holdings.ts` |
| Svelte components | PascalCase | `PortfolioCard.svelte` |
| Dart files | snake_case | `portfolio_selector.dart` |
| Variables/functions | camelCase | `calculateReturns` |
| Types/interfaces | PascalCase | `Portfolio`, `HoldingResponse` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| Database tables | snake_case | `daily_prices` |

### Imports

- TypeScript: Use `$lib` alias for `src/lib` imports
- Group: external deps → internal aliases → relative
- Use type-only imports where applicable

---

## Common Patterns

### Serverpod Endpoint

```dart
// lib/src/endpoints/portfolio_endpoint.dart
import 'package:serverpod/serverpod.dart';

class PortfolioEndpoint extends Endpoint {
  Future<List<Portfolio>> getPortfolios(Session session) async {
    return await Portfolio.db.find(session);
  }
}
```

### Flutter Screen (with Riverpod)

Screens use Riverpod for state management. Use `ConsumerWidget` for stateless screens or `ConsumerStatefulWidget` when you need local state (e.g., scroll controllers, focus nodes).

```dart
class PortfolioListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PortfolioListScreen> createState() => _PortfolioListScreenState();
}

class _PortfolioListScreenState extends ConsumerState<PortfolioListScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch providers - UI rebuilds when data changes
    final holdings = ref.watch(holdingsProvider(HoldingsParams(...)));
    final valuation = ref.watch(portfolioValuationProvider(portfolioId));

    return holdings.when(
      data: (data) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Error: $e'),
    );
  }
}
```

### Riverpod Mutations with Invalidation

When mutating data, use functions from `lib/providers/mutations.dart` that invalidate all affected providers:

```dart
// In a screen/widget:
final success = await archiveAsset(ref, assetId, portfolioId, true);
// All related providers are automatically invalidated:
// - holdingsProvider, portfolioValuationProvider, archivedAssetsProvider, etc.

// Or for sleeve assignment:
await assignAssetToSleeve(ref, assetId, portfolioId, sleeveId);
// Invalidates: assetDetailProvider, sleeveTreeProvider, holdingsProvider, etc.
```

**Key principle**: Always pass `portfolioId` to mutations and invalidate specific provider instances. Invalidating the whole family (e.g., `ref.invalidate(holdingsProvider)`) clears ALL cached instances, but invalidating with a param (e.g., `ref.invalidate(portfolioValuationProvider(portfolioId))`) only refreshes that specific instance.

### Provider Files

| File | Providers |
|------|-----------|
| `client_provider.dart` | `clientProvider` - Serverpod client |
| `app_providers.dart` | `themeModeProvider`, `hideBalancesProvider`, `selectedPortfolioIdProvider` |
| `holdings_providers.dart` | `holdingsProvider(HoldingsParams)` |
| `valuation_providers.dart` | `portfolioValuationProvider(portfolioId)`, `chartDataProvider(ChartDataParams)`, `historicalReturnsProvider(portfolioId)` |
| `sleeve_providers.dart` | `sleeveTreeProvider(SleeveTreeParams)` |
| `asset_providers.dart` | `assetDetailProvider(AssetDetailParams)`, `archivedAssetsProvider(portfolioId)` |
| `issues_providers.dart` | `issuesProvider(portfolioId)` |
| `mutations.dart` | `archiveAsset()`, `assignAssetToSleeve()`, `updateYahooSymbol()`, `updateAssetType()`, `refreshAssetPrices()`, `clearPriceHistory()` |

### tRPC Procedure

```typescript
export const assetsRouter = router({
  list: publicProcedure
    .input(z.object({ portfolioId: z.string() }))
    .query(async ({ input }) => {
      return await db.select().from(assets).where(eq(assets.portfolioId, input.portfolioId));
    }),
});
```

---

## Troubleshooting

### "serverpod: command not found"

Use full path (do NOT modify global PATH):

```bash
"$HOME/.pub-cache/bin/serverpod" generate
```

### Database connection failed

Ensure Docker is running:

```bash
cd native/bagholdr/bagholdr_server
docker compose up -d
docker compose logs
```

### Flutter web not connecting to Serverpod

Check that Serverpod is running on port 8080 and CORS is configured.

### Generated code out of sync

Regenerate after model changes:

```bash
"$HOME/.pub-cache/bin/serverpod" generate
```

### Hot reload not working

Make sure Flutter is running in debug mode and fswatch is installed:

```bash
brew install fswatch
```

---

## Creating Mockups

- Save to `specs/mockups/{specname}/mockup-{desc}.html`
- Use consistent colors/styling across mockups for the same feature
- Keep good data-to-ink ratio
- Provide browser links after creating mockups

## Maintaining the Glossary

When writing specs in `specs/`, update `glossary.md` with new terms and link to the spec file.
