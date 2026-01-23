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

### NAPP-019: Asset Detail `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None (NAPP-018 complete)

**Tasks**:
- [ ] Extend holdings endpoint with `getAssetDetail()` or add to existing
- [ ] Create asset detail bottom sheet
- [ ] Show: full asset info, order history, key stats
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Asset detail shows complete information
- [ ] Order history is correct

---

### NAPP-024: Port Price Oracle `[port]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None (NAPP-023b research complete)

**Tasks**:
- [x] Create price oracle service in Dart
- [x] Port Yahoo price fetching
- [x] Port rate limiting logic
- [x] Test: fetches correct prices

**Implementation note**: When updating an asset's `yahooSymbol`, auto-clear historical data for the old ticker (`DailyPrice`, `IntradayPrice`, `DividendEvent`, `TickerMetadata`). This prevents orphaned data accumulating in the database.

**Acceptance Criteria**:
- [x] Can fetch prices for known symbols
- [x] Rate limiting works

---

---

### NAPP-026: Research Directa Parser `[research]`

**Priority**: Medium | **Status**: `[x]`
**Blocked by**: None

Understand existing import logic. **No code changes.**

**Files to read**:
- `server/src/import/directa-parser.ts`
- `server/src/import/derive-holdings.ts`

**Tasks**:
- [ ] Read directa-parser.ts
- [ ] Read derive-holdings.ts
- [ ] Document:
  - CSV format expected
  - Field mapping
  - How holdings are derived from orders
- [ ] List functions to port

**Deliverable**: Add "Directa Parser Summary" section to `native-app-completed.md`.

**Acceptance Criteria**:
- [ ] Parser logic documented

---

### NAPP-027: Port Directa Parser `[port]`

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: None (NAPP-026 complete)

**Tasks**:
- [ ] Create directa_parser.dart
- [ ] Port CSV parsing logic
- [ ] Port derive-holdings logic
- [ ] Test with sample CSV

**Acceptance Criteria**:
- [ ] Parses Directa CSV correctly
- [ ] Holdings derived correctly

---

### NAPP-028: Import UI `[implement]`

**Priority**: Medium | **Status**: `[blocked]`
**Blocked by**: NAPP-027

**Tasks**:
- [ ] Create ImportEndpoint with `importDirectaCsv()`
- [ ] Create import_screen.dart with file picker
- [ ] Upload progress indicator
- [ ] Results summary (orders imported, errors)
- [ ] Take screenshot to verify

**Acceptance Criteria**:
- [ ] Can upload Directa CSV
- [ ] Holdings update after import

---

### NAPP-029: Settings `[implement]`

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: None (NAPP-004 complete)

**Tasks**:
- [ ] Create settings_screen.dart
- [ ] Theme toggle (light/dark/system)
- [ ] Privacy mode toggle (blur values)
- [ ] Server URL configuration (for dev)
- [ ] About/version info

**Acceptance Criteria**:
- [ ] Settings persist across app restarts
- [ ] Theme changes apply immediately

---

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
