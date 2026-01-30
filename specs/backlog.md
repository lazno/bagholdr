# Backlog

Tasks and improvements that don't fit into a current implementation plan. These are tracked here so they're not forgotten and can be prioritized into future work.

---

## How to Use

- Add items when you discover issues, technical debt, or improvement ideas during implementation
- Include enough context for a future LLM/developer to understand the issue
- When starting a new implementation plan, review this backlog for relevant items to include
- Move items to a plan file when they're ready to be implemented

---

## Items

### BACK-001: Timezone Handling for Global Deployment

**Category**: Technical Debt | **Priority**: Low | **Added**: 2026-01-20

**Context**: During NAPP-011 (Database Migration), we identified that PostgreSQL stores timestamps as `timestamp without time zone`. The current implementation stores UTC values, but the database schema doesn't enforce this.

**Current state**:
- Serverpod models use `DateTime` which maps to `timestamp without time zone`
- Import script converts Unix timestamps to UTC with `DateTime.fromMillisecondsSinceEpoch(..., isUtc: true)`
- No enforcement that all code writes UTC

**Risk**: If the app is deployed globally or becomes multi-user:
- Servers in different timezones could write local times instead of UTC
- Readers would misinterpret timestamps, causing incorrect date displays

**Recommended fix**:
1. Change Serverpod models to use `timestamp with time zone` (`timestamptz`) if supported
2. Or: Add a utility layer that enforces UTC on all DateTime writes
3. Store user timezone preference for display conversion
4. Add tests that verify timestamps are stored as UTC

**Related files**:
- `native/bagholdr/bagholdr_server/lib/src/models/*.spy.yaml` (all models with DateTime fields)
- `native/bagholdr/bagholdr_server/bin/import_migration.dart` (current UTC handling)

---

### BACK-002: Persist Settings Across App Restarts

**Category**: Feature | **Priority**: Low | **Added**: 2026-01-26

**Context**: NAPP-029 implemented the settings UI but values reset on app restart.

**Settings to persist**:
- Theme mode (light/dark/system)
- Privacy mode (hide balances)
- Server URL (if user-configurable)

**Recommended approach**:
- Use `shared_preferences` package for simple key-value storage
- Load settings in `main()` before `runApp()`
- Update ValueNotifiers with persisted values on startup

**Related files**:
- `native/bagholdr/bagholdr_flutter/lib/main.dart` (global ValueNotifiers)
- `native/bagholdr/bagholdr_flutter/lib/screens/settings_screen.dart`

---

### BACK-003: Asset Detail Page Improvements

**Category**: Feature/UX | **Priority**: Medium | **Added**: 2026-01-27

**Context**: The asset detail page shows various return metrics but is missing some investor-friendly information and could benefit from UI reorganization.

**Missing metrics to add**:

| Metric | Description | Date Range Aware? |
|--------|-------------|-------------------|
| **Total P/L** | Combined unrealized + realized P/L for the period (headline number) | Yes |
| **Dividends** | Dividend income received (not currently tracked) | Yes |
| **Fees** | Trading commissions shown separately (currently hidden in cost basis) | Yes |
| **Annualized Return** | For periods > 1 year, show annualized vs cumulative | Yes |

**UI reorganization suggestions**:
1. **Headline section**: Show Total P/L prominently (what investors care about most)
2. **Breakdown section**: Split into Unrealized P/L + Realized P/L + Dividends
3. **Performance section**: TWR, MWR, Total Return with clear period indicator
4. **Position section**: Value, Quantity, Cost Basis, Weight

**Live update status** (for reference):
- Currently live: Value, Unrealized P/L
- Static (refresh needed): Realized P/L, TWR, MWR, Total Return, Cost Basis

**Implementation notes**:
- Dividends require schema change to track dividend transactions
- Total P/L is a simple sum but should update live when unrealized updates
- Consider adding a "last updated" indicator for static metrics

**Related files**:
- `native/bagholdr/bagholdr_flutter/lib/screens/asset_detail_screen.dart`
- `native/bagholdr/bagholdr_server/lib/src/services/asset_returns_calculator.dart`
- `native/bagholdr/bagholdr_server/lib/src/models/asset_detail_response.spy.yaml`

---

### BACK-004: Minimizable Asset Detail Page (Exploration)

**Category**: UX Exploration | **Priority**: Low | **Added**: 2026-01-27

**Context**: Currently, tapping an asset opens a full-screen detail page via standard `Navigator.push()`. This blocks viewing the dashboard or comparing the asset with other holdings.

**Idea**: Implement YouTube-style minimizable detail view:
1. User taps an asset → detail page slides up (or pushes as normal)
2. User can drag/swipe down → detail minimizes to a compact bar at the bottom
3. Minimized bar shows key info (name, value, P/L) and remains interactive
4. The underlying screen (dashboard, asset list) is revealed and fully usable
5. User can tap minimized bar → expands back to full detail
6. User can swipe away → closes the detail view entirely

**Use cases to explore**:
- Compare one asset's performance against portfolio totals
- Quick-glance at multiple assets without full navigation back-and-forth
- Keep an asset "pinned" while browsing other holdings

**Open questions**:
- Is this actually useful for a portfolio app, or overengineered?
- What info should the minimized bar show?
- How does this interact with bottom navigation?
- Should multiple assets be minimizable (like browser tabs) or just one?

**Technical approach (if pursued)**:
- Use a custom route/overlay rather than standard navigation
- Look at packages like `miniplayer` or build custom with `DraggableScrollableSheet`
- The minimized state could use a `BottomSheet` or custom positioned widget
- Need to handle interaction with existing bottom nav bar

**Reference**: YouTube iOS/Android app video minimization behavior

**Related files**:
- `native/bagholdr/bagholdr_flutter/lib/screens/asset_detail_screen.dart`
- `native/bagholdr/bagholdr_flutter/lib/screens/portfolio_list_screen.dart` (navigation trigger at line 590)

---

### BACK-005: Root-Level npm Scripts for Native App Commands

**Category**: DX | **Priority**: Medium | **Added**: 2026-01-27

**Context**: Running Flutter, Serverpod, and Dart commands requires changing to subdirectories. This is error-prone and not ergonomic.

**Goal**: Enable all commands to run from repo root via `pnpm <command>`.

**Commands to add to root `package.json`**:

```json
{
  // Native orchestration (wrap existing bash scripts)
  "native:start": "./native/scripts/start.sh",
  "native:start:web": "./native/scripts/start.sh --web",
  "native:start:all": "./native/scripts/start.sh --all",
  "native:hotreload": "./native/scripts/start-with-hotreload.sh",
  "native:dev": "./native/scripts/dev.sh",
  "native:stop": "./native/scripts/stop.sh",
  "native:stop:all": "./native/scripts/stop.sh --all",

  // Serverpod server
  "server:test": "cd native/bagholdr/bagholdr_server && dart test",
  "server:test:unit": "cd native/bagholdr/bagholdr_server && dart test test/unit",
  "server:test:integration": "cd native/bagholdr/bagholdr_server && dart test test/integration",
  "server:generate": "cd native/bagholdr/bagholdr_server && \"$HOME/.pub-cache/bin/serverpod\" generate",
  "server:migrate:create": "cd native/bagholdr/bagholdr_server && \"$HOME/.pub-cache/bin/serverpod\" create-migration",
  "server:analyze": "cd native/bagholdr/bagholdr_server && dart analyze",

  // Flutter
  "flutter:test": "cd native/bagholdr/bagholdr_flutter && flutter test",
  "flutter:analyze": "cd native/bagholdr/bagholdr_flutter && flutter analyze",
  "flutter:run:web": "cd native/bagholdr/bagholdr_flutter && flutter run -d chrome --web-port=3001",
  "flutter:run:emulator": "cd native/bagholdr/bagholdr_flutter && flutter run -d emulator-5554",
  "flutter:build:web": "cd native/bagholdr/bagholdr_flutter && flutter build web --wasm",

  // Combined
  "test:all": "pnpm test && pnpm server:test && pnpm flutter:test",
  "test:native": "pnpm server:test && pnpm flutter:test"
}
```

**Also update**: `CLAUDE.md` - Document new commands in "Build & Development Commands" section.

**Verification**: After adding the scripts, verify each command works from the repo root. A command passes if it exits with code 0 (or expected non-zero for analysis with issues).

| Command | Success Criteria |
|---------|------------------|
| `pnpm server:test` | Exit 0, tests run |
| `pnpm flutter:test` | Exit 0, tests run |
| `pnpm server:generate` | Exit 0, no errors in output |
| `pnpm server:analyze` | Runs analysis (exit 0 if no issues) |
| `pnpm flutter:analyze` | Runs analysis (exit 0 if no issues) |
| `pnpm test:native` | Exit 0, both test suites run |

Skip orchestration script verification (`native:start`, `native:stop`) as these require interactive cleanup.

**Related files**:
- `package.json`
- `CLAUDE.md`
- `native/scripts/*.sh` (existing bash scripts to wrap)

---

### BACK-006: Fix Broken Flutter Widget Tests

**Category**: Bug/Testing | **Priority**: High | **Added**: 2026-01-30

**Context**: 21 Flutter widget tests are currently failing. These tests broke at some point during development and were not fixed.

**Failing test files**:
- `test/widgets/sleeve_pills_test.dart` (8 tests)
- `test/widgets/portfolio_chart_test.dart` (1 test)
- `test/widgets/ring_chart_test.dart` (6 tests)
- `test/widgets/strategy_section_test.dart` (6 tests)

**Root cause**: Unknown - likely the widgets were refactored but tests were not updated to match.

**Fix approach**:
1. Run each test file individually to see specific failures
2. Compare test expectations with current widget implementation
3. Either update tests to match new widget behavior, or fix widgets if behavior regressed
4. Ensure all 21 tests pass before marking complete

**Verification**:
```bash
cd native/bagholdr/bagholdr_flutter && flutter test
```
Must show 0 failures.

**Note**: This is blocking. No new features should be merged while tests are broken.

---

### BACK-007: Reliable Connection Indicator

**Category**: Bug/UX | **Priority**: Medium | **Added**: 2026-01-27

**Context**: The connection indicator on the settings page always shows "Connected" even when the connection may be unreliable. It marks as connected immediately after subscribing to the price stream, without verifying data actually flows.

**Current problems**:
1. Status set to "connected" immediately after creating stream subscription (before any data received)
2. No active health checking - only detects disconnection when stream errors or closes
3. Silent network failures (server unresponsive but connection not closed) go undetected
4. Price updates only arrive every ~5 minutes during syncs, so staleness detection alone won't work

**Recommended fix** (two parts):

**Part 1: Only mark connected after data received**
- Remove premature `_connectionStatus = ConnectionStatus.connected` in `_subscribe()`
- Keep status as `connecting` until first `_onPriceUpdate` is called

**Part 2: Server-side heartbeat**
- Add `isHeartbeat: bool?` field to `PriceUpdate` model
- Emit heartbeat every ~30 seconds from `PriceStreamEndpoint`
- Client ignores heartbeat for price storage but uses it to confirm connection
- Add staleness timer on client: if no data (including heartbeats) for 60s while "connected", mark disconnected and reconnect

**Files to modify**:
- `native/bagholdr/bagholdr_server/lib/src/models/price_update.spy.yaml`
- `native/bagholdr/bagholdr_server/lib/src/endpoints/price_stream_endpoint.dart`
- `native/bagholdr/bagholdr_flutter/lib/services/price_stream_provider.dart`

**Verification**:
1. Start app, verify indicator shows "Connecting" initially
2. Wait for heartbeat/data, verify it changes to "Connected"
3. Stop server, verify indicator changes to "Disconnected" within ~60 seconds

---
