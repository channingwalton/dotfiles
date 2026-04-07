---
name: software-development
description: Software development based on Extreme Programming (XP). Use it when implementing software features of any kind. Coordinates planning, TDD, refactoring, and commits.
---

# Software Development: Extreme Programming Workflow

## The Workflow

```
📋 PLAN     → Discuss and break down the feature
🔴 DEVELOP  → TDD cycle (red-green-refactor)
🔍 REVIEW   → Autonomous code review (optional)
💾 COMMIT   → Save working state
🔁 ITERATE  → Next task or feature complete
```

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

1. [ ] [Task description] — [acceptance criteria]
2. [ ] [Task description] — [acceptance criteria]

**Assumptions surfaced:** [key premises uncovered during clarify/falsify]
**First task:** [Task 1 description]
```

---

## Phase 2: Development (🔴 DEVELOP) — Interactive

Strict TDD: red → green → refactor. Use the appropriate language skill. See [development reference](references/development.md) for the full TDD cycle. When the current task's acceptance criteria are met and all tests pass, proceed to COMMIT or REVIEW.

One non-obvious point: "minimum code to pass" refers to behaviour and architecture, not to picking naive data structures. If the domain naturally maps to a `Map`, use a `Map` from the start — that's accurate modelling, not premature optimisation.

During the refactor step, actively hunt for code smells and apply standard techniques. See [refactor reference](references/refactor.md) for the full cycle and smell catalogue. After each refactoring step, **STOP** and ask the user if they want further refactoring.

---

## Phase 3: Review (🔍 REVIEW) — Optional, Autonomous

**Agent:** `code-reviewer` (Opus, read-only tools, uses `bugmagnet`)

Use before merging feature branches, after significant refactoring, for complex or security-sensitive changes, or when requested. Review findings, then look for simplification with the `code-simplifier` agent.

---

## Phase 4: Commit (💾 COMMIT) — Autonomous

**Skill:** `commit-commands:commit`

Before delegating: summarise what will be committed and ask the user to confirm. Commit after each completed task, refactoring session, or before switching branches.

---

## Phase 5: Iterate (🔁 ITERATE) — Interactive

1. Mark task as done
2. Review remaining tasks — adjust plan if needed
3. Return to Phase 2 for next task, or finish
4. Use `vault` skill to log significant learnings

---

## Phase Transitions

Announce clearly when switching:

```
📋 PLAN → Starting feature discussion
🔴 DEVELOP → Writing failing test for [behaviour]
🟢 DEVELOP → Making test pass
🔵 REFACTOR → Improving [aspect]
🔍 REVIEW → Delegating to code-reviewer agent
💾 COMMIT → Delegating to commit-commands:commit
🔁 ITERATE → Moving to next task
✅ COMPLETE → Feature done
```
