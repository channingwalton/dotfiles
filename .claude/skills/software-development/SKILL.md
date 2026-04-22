---
name: software-development
description: Software development based on Extreme Programming (XP). Use it when implementing software features of any kind. Coordinates planning, TDD, refactoring, and commits.
---

# Software Development: Extreme Programming Workflow

## The Workflow

```
📋 PLAN     → Discuss and break down the feature
🔴 DEVELOP  → TDD cycle (red → green → refactor → review)
💾 COMMIT   → Save working state
🔁 ITERATE  → Next task or proceed to complete
✅ COMPLETE → Suggest retrospective
```

The DEVELOP cycle is a task's Definition of Done: **no task is complete until the review step passes**. Review is inside the cycle, not after it.

---

## Phase 1: Planning (📋 PLAN) — Interactive

Understand and decompose the feature before writing any code. Use `glossary` skill for unfamiliar domain terms.

Follow this sequence: **DISCUSS → CLARIFY → SLICE → FALSIFY → CONFIRM**. See [planning reference](references/planning.md) for detailed steps and examples.

### CLARIFY — Surface Hidden Premises

Requirements are arguments in disguise — stated conclusions resting on unstated premises. Restate the requirement as "Given [premises], then [conclusion]" and ask what premises are missing. Challenge assumptions — especially those that feel obvious. **STOP** until questions are answered.

### SLICE — Break Into Tasks

Tasks must be **vertical** (end-to-end functionality), **small** (one TDD cycle), **ordered** (dependency first, then value), and **testable** (clear acceptance criteria). Slice by behaviour, not by implementation layer.

### FALSIFY — Test Your Understanding

Ask: "What scenario would prove this understanding wrong?" If you can't think of one, that's a warning sign — not a green light.

### CONFIRM — Agree on Plan

Summarise, present ordered task list, **STOP** — explicitly agree on the first task.

### Planning Output Format

```
## Tasks for [Feature]

1. [ ] [Task description] — [acceptance criteria] — DoD: new tests for new behaviour + all tests green + fix-loop clean
2. [ ] [Task description] — [acceptance criteria] — DoD: new tests for new behaviour + all tests green + fix-loop clean

**Assumptions surfaced:** [key premises uncovered during clarify/falsify]
**First task:** [Task 1 description]
```

The Definition of Done is identical for every task. A task cannot be ticked without it.

---

## Phase 2: Development (🔴 DEVELOP) — Interactive

Each task runs a four-step cycle. All four steps must complete before the task is done.

### Step 1: 🔴 Red — Failing Test

Write a failing test for the next behaviour. Use the appropriate language skill. See [development reference](references/development.md).

### Step 2: 🟢 Green — Make It Pass

Minimum code to pass. "Minimum" refers to behaviour and architecture, not naive data structures — if the domain naturally maps to a `Map`, use a `Map` from the start.

**Surgical:** touch only what the test requires. Match existing style. No drive-by edits to adjacent code, comments, or formatting. Every changed line should trace to the failing test. Broader cleanup belongs in Refactor.

**Public signature changes:** if you change a public function signature, read every caller before calling green. Compile-passing is not enough — see [development reference](references/development.md) `✅ VERIFY`.

### Step 3: 🔵 Refactor

Clean up while the domain is fresh and tests are green. Anything goes — restructure, rename, dedupe, reshape abstractions. See [refactor reference](references/refactor.md). After each refactoring step, **STOP** and ask the user if they want further refactoring.

**Public signature changes:** same rule as Green — after a signature change, read every caller. Refactor is where this most often bites.

### Step 4: 🔍 Review — Fix-Loop

**Not optional.** Only skip for pure non-code edits (comments, docs-only changes) and state the skip explicitly.

1. **Delegate to the `fix-loop` skill** — runs code-reviewer → fixer until critical findings resolve (or the iteration cap hits). The reviewer's remit includes simplification opportunities, so fresh-eyes cleanup happens here.
2. **If unresolved critical findings or test regressions remain:** stop and surface to the user. The task is not done.

**Scope touches new behaviour without new tests** is a critical finding, not a suggestion — even when sibling code lacks tests. Precedent is not permission.

Only after step 4 passes is the task complete. Proceed to COMMIT.

---

## Phase 3: Commit (💾 COMMIT) — Autonomous

**Skill:** `commit-commands:commit`

Before delegating: summarise what will be committed and ask the user to confirm.

---

## Phase 4: Iterate (🔁 ITERATE) — Interactive

1. Mark task as done (only if step 4 of DEVELOP passed)
2. Run `/compact` — the task is committed, so per-task churn (test output, fixer diffs, file reads) is safe to drop. Keeps context lean across a multi-task feature.
3. Review remaining tasks — adjust plan if needed
4. Use `vault` skill to log significant learnings
5. Return to Phase 2 for next task, or proceed to Phase 5 if no tasks remain

---

## Phase 5: Complete (✅ COMPLETE) — Interactive

Feature done, all tasks committed. Before closing out:

**Suggest a retrospective.** Ask the user if they'd like to run the `retrospective` skill to surface gaps in this workflow and propose edits. This is the final step — do not skip it.

---

## Phase Transitions

Announce clearly when switching:

```
📋 PLAN → Starting feature discussion
🔴 DEVELOP → Writing failing test for [behaviour]
🟢 DEVELOP → Making test pass
🔵 REFACTOR → Improving [aspect]
🔍 REVIEW → Delegating to fix-loop
💾 COMMIT → Delegating to commit-commands:commit
🔁 ITERATE → Compacting, then moving to next task
✅ COMPLETE → Feature done
```
