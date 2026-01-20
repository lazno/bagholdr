# ralph.md - Agent Workflow

This file implements the [Ralph method](https://github.com/ghuntley/how-to-ralph-wiggum) for this repository. It controls how AI agents pick and complete tasks.

**Core principle**: One task at a time. Complete it. Commit. Stop.

---

## Workflow

### 1. Bootstrap

```
1. Read AGENTS.md (technical reference)
2. Read glossary.md (domain terminology)
3. Find the active plan (see below)
```

### 2. Find the Active Plan

Plans are task lists in `specs/` with status markers. Currently active:

| Plan | Description |
|------|-------------|
| `specs/native-app-plan.md` | Flutter + Serverpod native app rebuild |

### 3. Pick ONE Task

From the active plan:

1. Find the highest-priority **unblocked** task (status `[ ]`)
2. Verify no dependencies are incomplete
3. Mark it `[~]` (in progress)
4. **Work on this task only** - ignore other tasks

### 4. Complete the Task

Follow the task type workflow:

| Type | Approach |
|------|----------|
| `[setup]` | Human-assisted, wait for confirmation at each step |
| `[research]` | Read files, document findings, NO code changes |
| `[design]` | Analyze options, create mockups, document decisions |
| `[implement]` | Write code + tests, verify, screenshot if UI |
| `[port]` | Translate code, write tests, validate against reference |

### 5. Verify Completion

Before marking done, verify:

- [ ] All acceptance criteria in the task are checked off
- [ ] Quality standards from AGENTS.md are met:
  - Tests written and passing
  - Screenshots taken (if UI change)
  - Code style followed
- [ ] For `[port]` tasks: validated against TypeScript backend

### 6. Commit and Stop

```bash
git add -A
git commit -m "NAPP-XXX: Brief description"
```

Then mark the task `[x]` in the plan and **STOP**.

Do not start the next task. The next agent iteration will pick it up with fresh context.

---

## Task Status Legend

| Status | Meaning |
|--------|---------|
| `[ ]` | Not started |
| `[~]` | In progress |
| `[x]` | Done |
| `[blocked]` | Waiting on another task |

---

## Why This Works

- **Fresh context**: Each agent run starts clean, git is the memory
- **Small scope**: One task fits in one context window
- **Natural checkpoints**: Commits mark progress, tests verify correctness
- **No drift**: Agent can't go off-track working on multiple things

---

## Adding New Plans

When starting a new epic/project:

1. Create `specs/{project}-plan.md`
2. Add task list with status markers and acceptance criteria
3. Add to the "Active Plans" table above
