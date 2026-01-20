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
