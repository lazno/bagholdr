# Code Review Plan - Bagholdr

## Overview

Full codebase review to improve readability, enforce standards, eliminate spaghetti code, and keep files manageable. After completion, update CLAUDE.md with standards and automated checks.

**Scope**: ~200 source files (~13k lines TypeScript + ~3k lines Dart)

**Order**: Flutter/Dart first, then TypeScript/Svelte

---

## Phase 1: Flutter/Dart - Critical Files

These files have multiple concerns mixed together and need splitting.

| File | Lines | Action |
|------|-------|--------|
| `lib/screens/asset_detail_screen.dart` | 1,242 | Extract dialogs to separate files |
| `lib/widgets/strategy_section_v2.dart` | 985 | Extract gesture/animation logic to utils |
| `lib/screens/portfolio_list_screen.dart` | 535 | Remove debug prints, add error handling |
| `lib/widgets/portfolio_chart.dart` | 763 | Extract tooltip logic, document constants |
| `lib/widgets/ring_chart.dart` | 529 | Consolidate geometry with strategy_section |
| `lib/widgets/assets_section.dart` | 598 | Extract table responsiveness logic |

---

## Phase 2: Flutter/Dart - Code Quality

- Remove ~140 lines of `debugPrint()` in `portfolio_list_screen.dart`
- Create shared chart geometry utilities (duplicated between ring_chart and strategy_section)
- Extract magic numbers to constants
- Add error handling to async operations (currently silent failures)
- Clean up TextEditingController disposal in dialogs

---

## Phase 3: TypeScript Backend

| File | Lines | Action |
|------|-------|--------|
| `server/src/trpc/routers/valuation.ts` | 1,811 | Split into: valuation.ts, returns.ts, chart-data.ts |
| `server/src/trpc/routers/oracle.ts` | 987 | Split: price fetching vs symbol resolution vs sync |

---

## Phase 4: Svelte Frontend

| File | Lines | Action |
|------|-------|--------|
| `src/routes/assets/+page.svelte` | 1,517 | Extract: AssetTable, EditAssetModal, ChartModal, BulkActionBar |
| `src/routes/dashboard-v2/+page.svelte` | 1,313 | Extract: DashboardChart, HoldingsTable, IssuesPanel |
| `src/routes/portfolios/[id]/sleeves/+page.svelte` | 917 | Extract: SleeveTree, DragDropHandler |

---

## Phase 5: TypeScript Code Quality

- Remove `any` casts in `dashboard-v2/+page.svelte` (lines 232, 522)
- Create shared chart utilities (duplicated between assets and dashboard)
- Standardize error handling pattern

---

## Phase 6: Performance (Optional)

- `valuation.ts:277` - Fetches ALL orders then filters in-memory
- `valuation.ts:281-319` - Rebuilds cost basis on every request

---

## Phase 7: Update CLAUDE.md + Automated Checks

### New rules to add:

```markdown
### File Size Limits
- Maximum 400 lines per file (soft limit)
- Maximum 600 lines per file (hard limit - must split)
- Extract modals/dialogs to separate files

### Component Extraction Rules
- Svelte: Extract reusable UI into `src/lib/components/`
- Flutter: Keep widgets focused on single responsibility
- Shared logic goes in `utils/` directories

### Automated Quality Gates
- Run `flutter analyze` before committing Dart code
- Run `pnpm check` before committing TypeScript
- No `debugPrint()` in production (use logger if needed)
- No `any` types in TypeScript
```

### Pre-commit validation:
- Add `flutter analyze` check to Dart workflow
- Existing `pnpm check` for TypeScript

---

## Execution Approach

Work through phases sequentially. Each phase = one commit/PR.

**For each file refactor:**
1. Read the file fully
2. Identify extraction opportunities
3. Create new files for extracted code
4. Update imports
5. Run tests/analyze
6. Commit

---

## Verification

**Flutter/Dart phases:**
```bash
cd native/bagholdr/bagholdr_flutter && flutter analyze && flutter test
```

**TypeScript phases:**
```bash
pnpm check && pnpm test
```

---

## Success Criteria

- [ ] No file exceeds 600 lines
- [ ] No `any` types in TypeScript
- [ ] No `debugPrint()` in Dart production code
- [ ] Shared utilities for duplicated code
- [ ] CLAUDE.md updated with file size limits and quality gates
- [ ] All tests passing
- [ ] `flutter analyze` and `pnpm check` pass clean
