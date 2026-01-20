# Directa Sync Implementation Plan

This document contains discrete implementation tasks for the automated Directa SIM order sync feature. Each task is a **vertical slice** - delivering end-to-end functionality.

## How to Use This Plan

1. Pick the highest-priority unblocked task
2. Complete the task following its acceptance criteria
3. Mark the task as done
4. Add any new tasks discovered during implementation

---

## Task Status Legend

- `[ ]` - Not started
- `[~]` - In progress
- `[x]` - Done
- `[blocked]` - Blocked by another task

---

## Architecture

Decided architecture after security analysis:

```
┌─────────────────────────────────────────────────────┐
│  You (phone)                                        │
│  └── Telegram: "/sync"                              │
└─────────────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────┐
│  Telegram servers                                   │
└─────────────────────────────────────────────────────┘
                    │
                    ▼ (long-polling getUpdates)
┌─────────────────────────────────────────────────────┐
│  Raspberry Pi (home network)                        │
│  ├── Telegram bot (receives /sync command)          │
│  ├── Playwright automation (Directa login + export) │
│  ├── Gmail IMAP (OTP extraction)                    │
│  ├── Bitwarden CLI (credential storage)             │
│  └── Pushes orders to Hetzner via HTTPS             │
└─────────────────────────────────────────────────────┘
                    │
                    ▼ POST /api/import/orders (Bearer token)
┌─────────────────────────────────────────────────────┐
│  Hetzner VPS                                        │
│  ├── Dart backend (Serverpod)                       │
│  ├── Portfolio database                             │
│  └── Web UI                                         │
└─────────────────────────────────────────────────────┘
```

### Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Trigger mechanism | Telegram bot | Simple, no custom infra, built-in push notifications |
| Credential storage | Bitwarden CLI on Pi | Credentials never leave hardware you own |
| Sync agent hosting | Raspberry Pi at home | Secrets stay local, not on cloud VPS |
| Backend hosting | Hetzner VPS | Public-facing app, no sensitive credentials |
| Home IP privacy | Exposed to Telegram only | Acceptable trade-off; Telegram is large/untargeted |
| Pi → Hetzner auth | Bearer token | Token stored in Bitwarden, revocable |
| Gmail access | App Password via IMAP | Limited scope, doesn't expose main password |

---

## Phase 1: Requirements & Design

### DSYNC-001: Design Document - Requirements Engineering

**Priority**: High | **Status**: `[~]`
**Blocked by**: None

Conduct requirements gathering for automated Directa SIM order sync feature.

**Background**:
Currently, importing orders from Directa SIM requires manually:
1. Logging into Directa's web interface (with email OTP)
2. Navigating to the orders section
3. Setting date filters
4. Exporting CSV
5. Uploading to the portfolio app

This is tedious, especially on mobile. The goal is to automate this with a Telegram command.

**Questions & Answers**:

| # | Question | Answer |
|---|----------|--------|
| 1 | Trigger mechanism | Telegram bot `/sync` command |
| 2 | Date range | TBD |
| 3 | Duplicate handling | TBD - existing parser may handle this |
| 4 | Error handling | TBD |
| 5 | Feedback UX | Telegram replies (progress + result) |
| 6 | Credential storage | Bitwarden CLI on Raspberry Pi |
| 7 | OTP email parsing | TBD - need to inspect actual email |
| 8 | Directa UI selectors | TBD - need to inspect actual UI |
| 9 | Session persistence | TBD - investigate if cookies reduce OTP frequency |
| 10 | Rate limits | TBD |
| 11 | Multi-portfolio | No - single account |
| 12 | Audit trail | TBD |
| 13 | Hosting | Split: Pi (sync agent) + Hetzner (backend) |
| 14 | Testing | TBD |

**Remaining Deliverables**:
- [ ] Answer remaining TBD questions
- [ ] Create `specs/directa-sync-spec.md` with full design
- [ ] Stakeholder approval

---

## Phase 2: Infrastructure

### DSYNC-002: Telegram Bot Setup

**Priority**: High | **Status**: `[ ]`
**Blocked by**: None

Create and configure the Telegram bot.

**Tasks**:
- [ ] Create bot via @BotFather
- [ ] Record bot token
- [ ] Store bot token in Bitwarden
- [ ] Configure bot commands (`/sync`, `/status`)
- [ ] Note your Telegram user ID for auth whitelist

**Acceptance Criteria**:
- [ ] Bot exists and responds to /start
- [ ] Bot token securely stored

---

### DSYNC-003: Raspberry Pi Sync Agent Skeleton

**Priority**: High | **Status**: `[ ]`
**Blocked by**: DSYNC-002

Set up the basic sync agent on Raspberry Pi that responds to Telegram commands.

**Tasks**:
- [ ] Create new project/repo for sync agent
- [ ] Set up Bitwarden CLI access
- [ ] Implement Telegram bot long-polling
- [ ] Add user ID whitelist (only you can trigger)
- [ ] Implement `/sync` command stub (replies "Sync started...")
- [ ] Implement `/status` command (replies with agent health)

**Acceptance Criteria**:
- [ ] Bot responds to `/sync` from your user ID only
- [ ] Bot ignores commands from other users
- [ ] Agent runs as systemd service on Pi

---

### DSYNC-004: Hetzner Import API Endpoint

**Priority**: High | **Status**: `[ ]`
**Blocked by**: None

Add authenticated endpoint for Pi to push imported orders.

**Tasks**:
- [ ] Generate secure API token for Pi → Hetzner auth
- [ ] Store token in Bitwarden (Pi) and Hetzner env
- [ ] Create `POST /api/import/orders` endpoint
- [ ] Validate Bearer token
- [ ] Accept order payload, insert into database
- [ ] Return import summary (new/duplicate/error counts)

**Acceptance Criteria**:
- [ ] Endpoint rejects requests without valid token
- [ ] Endpoint accepts and imports valid order payload
- [ ] Existing directa-parser logic reused where possible

---

## Phase 3: Automation

### DSYNC-005: Gmail OTP Extraction

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: DSYNC-003

Implement Gmail IMAP integration to extract Directa OTP codes.

**Tasks**:
- [ ] Create Gmail App Password
- [ ] Store App Password in Bitwarden
- [ ] Implement IMAP connection
- [ ] Search for recent Directa OTP emails
- [ ] Parse OTP code from email body
- [ ] Handle "no OTP email found" timeout

**Acceptance Criteria**:
- [ ] Can extract OTP code from recent Directa email
- [ ] Timeout after configurable period if no email arrives

---

### DSYNC-006: Playwright Directa Automation

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: DSYNC-005

Implement browser automation for Directa login and CSV export.

**Tasks**:
- [ ] Install Playwright on Pi
- [ ] Implement login flow (username + password)
- [ ] Implement OTP entry (using DSYNC-005)
- [ ] Navigate to orders section
- [ ] Set date filters (since last sync or all)
- [ ] Trigger CSV export
- [ ] Download and parse CSV

**Acceptance Criteria**:
- [ ] Can log into Directa automatically
- [ ] Can export orders CSV
- [ ] Handles OTP flow end-to-end

---

### DSYNC-007: End-to-End Sync Flow

**Priority**: Medium | **Status**: `[ ]`
**Blocked by**: DSYNC-004, DSYNC-006

Wire everything together for complete sync flow.

**Tasks**:
- [ ] `/sync` triggers Playwright automation
- [ ] Parse exported CSV
- [ ] Push orders to Hetzner API
- [ ] Report results via Telegram (e.g., "✓ Imported 3 new orders")
- [ ] Handle and report errors gracefully

**Acceptance Criteria**:
- [ ] `/sync` command completes full flow
- [ ] Success/failure reported via Telegram
- [ ] Orders appear in portfolio app

---

## Phase 4: Hardening

### DSYNC-008: Error Handling & Retries

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: DSYNC-007

Robust error handling for production use.

**Tasks**:
- [ ] Retry logic for transient failures
- [ ] Timeout handling for each step
- [ ] Detailed error messages in Telegram
- [ ] Alert on repeated failures

---

### DSYNC-009: Audit Logging

**Priority**: Low | **Status**: `[ ]`
**Blocked by**: DSYNC-007

Log sync attempts for debugging.

**Tasks**:
- [ ] Log sync attempts with timestamp
- [ ] Optionally store raw CSVs
- [ ] `/logs` command to view recent sync history

---

## Completed Tasks

(none yet)

---

## Notes

- Stack: Node.js or Dart for sync agent (TBD based on Playwright support)
- IMAP for Gmail OTP extraction
- Existing CSV parser: `server/src/import/directa-parser.ts`
- Telegram bot library: node-telegram-bot-api or grammy (Node.js) / televerse (Dart)
