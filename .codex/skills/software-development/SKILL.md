---
name: software-development
description: "Software development using an XP-style workflow. Use when implementing or changing code. Adapt planning depth to task size: for straightforward low-risk changes, compress planning to a brief assumptions check and proceed; for ambiguous, risky, or multi-step work, use explicit clarification, slicing, TDD, refactoring, and review."
---

# Software Development: Extreme Programming Workflow

## The Workflow

```
📋 PLAN            → Discuss and break down the feature
🔴 DEVELOP         → TDD cycle (red → green → refactor → review)
💾 COMMIT/PUBLISH  → Optional, when requested
🔁 ITERATE         → Next task or feature complete
```

The DEVELOP cycle is a task's Definition of Done: **no task is complete until the review step passes**. Review is inside the cycle, not after it.

## Phase 1: Planning (📋 PLAN) — Adaptive

Understand and decompose the feature before writing any code. Use `glossary` skill for unfamiliar domain terms.

Choose planning depth based on task shape:

- **Compressed plan** — for straightforward, low-risk, single-slice changes with clear requirements. Briefly restate the task, note any assumptions, name the first slice, then proceed.
- **Full plan** — for ambiguous, risky, multi-step, or domain-heavy work. Follow: **DISCUSS → CLARIFY → SLICE → FALSIFY → CONFIRM**. See [planning reference](references/planning.md) for detailed steps and examples.

### CLARIFY — Surface Hidden Premises

Requirements are arguments in disguise — stated conclusions resting on unstated premises. Restate the requirement as "Given [premises], then [conclusion]" and ask what premises are missing. Challenge assumptions — especially those that feel obvious. **STOP** only if unresolved ambiguity blocks safe implementation.

### SLICE — Break Into Tasks

Tasks must be **vertical** (end-to-end functionality), **small** (one TDD cycle), **ordered** (dependency first, then value), and **testable** (clear acceptance criteria). Slice by behaviour, not by implementation layer.

### FALSIFY — Test Your Understanding

Ask: "What scenario would prove this understanding wrong?" If you can't think of one, that's a warning sign — not a green light.

### CONFIRM — Agree on Plan

Summarise and present the ordered task list. For non-trivial work, **STOP** and explicitly agree on the first task. For compressed planning, announce the first task and proceed.

### Planning Output Format

```
## Tasks for [Feature]

1. [ ] [Task description] — [acceptance criteria] — DoD: tests green + fix-loop clean
2. [ ] [Task description] — [acceptance criteria] — DoD: tests green + fix-loop clean

**Assumptions surfaced:** [key premises uncovered during clarify/falsify]
**First task:** [Task 1 description]
```

The Definition of Done is identical for every task. A task cannot be ticked without it.

## Phase 2: Development (🔴 DEVELOP) — Interactive

Each task runs a four-step cycle. All four steps must complete before the task is done.

### Step 1: 🔴 Red — Failing Test

Write a failing test for the next behaviour. Use the appropriate language skill. See [development reference](references/development.md).

### Step 2: 🟢 Green — Make It Pass

Minimum code to pass. "Minimum" refers to behaviour and architecture, not naive data structures — if the domain naturally maps to a `Map`, use a `Map` from the start.

### Step 3: 🔵 Refactor

Clean up while the domain is fresh and tests are green. Anything goes — restructure, rename, dedupe, reshape abstractions. See [refactor reference](references/refactor.md). Run tests after each refactoring step. At the end of the refactor phase, summarise any meaningful cleanup. Ask before doing optional refactoring that goes beyond the current task's acceptance criteria.

### Step 4: 🔍 Review — Fix-Loop

**Not optional.** Only skip for pure non-code edits (comments, docs-only changes) and state the skip explicitly.

1. **Delegate to the `fix-loop` skill** — runs `code-reviewer` → `fixer` until critical findings resolve (or the iteration cap hits). The reviewer's remit includes simplification opportunities, so fresh-eyes cleanup happens here.
2. **If unresolved critical findings or test regressions remain:** stop and surface to the user. The task is not done.

Only after step 4 passes is the task complete. Then either continue to the next task or commit/publish if requested.

## Phase 3: Commit / Publish (💾 COMMIT) — Optional

Commit or publish only when the user asks for it or when the repo workflow clearly requires it.

- If the user wants the work published, use the `push` skill.
- If the user wants a local commit, summarise what will be saved and ask for confirmation before committing.
- Otherwise leave changes uncommitted and report the modified files, test status, and remaining tasks.

## Phase 4: Iterate (🔁 ITERATE) — Interactive

1. Mark task as done (only if step 4 of DEVELOP passed)
2. Keep context lean by dropping per-task churn from discussion once the task is committed
3. Review remaining tasks — adjust plan if needed
4. Return to Phase 2 for next task, or finish
5. Use `vault` skill to log significant learnings

## Phase Transitions

Announce clearly when switching:

```
📋 PLAN → Starting feature discussion
🔴 DEVELOP → Writing failing test for [behaviour]
🟢 DEVELOP → Making test pass
🔵 REFACTOR → Improving [aspect]
🔍 REVIEW → Delegating to fix-loop
💾 COMMIT → Saving or publishing work
🔁 ITERATE → Moving to next task
✅ COMPLETE → Feature done
```
