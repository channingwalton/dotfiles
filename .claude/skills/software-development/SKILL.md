---
name: software-development
description: Software development based on Extreme Programming. Use it when implementing software features of any kind. Coordinates planning, TDD, refactoring, and commits.
---

# Software Development: Extreme Programming Workflow

## The XP Workflow

```
📋 PLAN     → Discuss and break down the feature
🔴 DEVELOP  → TDD cycle (red-green)
🔵 REFACTOR → Improve design (tests stay green)
🔍 REVIEW   → Autonomous code review (optional)
💾 COMMIT   → Save working state
🔁 ITERATE  → Next task or feature complete
```

## Core Principles

Communication first · Small steps · Continuous feedback · Simplicity · Courage · Quality gates · Knowledge capture

---

## Phase 1: Planning (📋 PLAN) — Interactive

Understand and decompose the feature before writing any code. Use `glossary` skill for unfamiliar domain terms.

### The Planning Cycle

```
💬 DISCUSS  → Understand the problem and expected behaviour
❓ CLARIFY  → Surface hidden premises, resolve ambiguities
✂️ SLICE    → Break into tasks
🧪 FALSIFY  → Ask "how would we know if we're wrong?"
📋 CONFIRM  → Summarise and agree on first task
```

### 💬 DISCUSS — Understand Requirements

1. What problem does this feature solve?
2. What is the expected behaviour?
3. What are the acceptance criteria?
4. Are there any constraints or dependencies?

### ❓ CLARIFY — Surface Hidden Premises

Requirements are arguments in disguise — stated conclusions resting on unstated premises. Restate the requirement as "Given [premises], then [conclusion]" and ask what premises are missing:

- **Who** — which actor triggers this, and do different actors expect different things?
- **When** — at what point in the process? What state must already exist?
- **Boundaries** — what counts as valid input? Smallest/largest/emptiest case?
- **Failure** — what happens when this *can't* work? Who finds out and how?
- **Definitions** — are we using the same words to mean the same things? (→ `glossary` skill)

Challenge assumptions — especially those that feel obvious. **STOP** until questions are answered.

**Example:**

> "Send a notification when a shift is unfilled"
>
> Hidden premises: What counts as "unfilled"? When is this checked? "Send" how? To whom? What if it fails?

### ✂️ SLICE — Break Into Tasks

Tasks must be **vertical** (end-to-end functionality), **small** (one TDD cycle), **ordered** (dependency first, then value), and **testable** (clear acceptance criteria).

```
✅ Good: "Add a book to the library" — clear input, output, testable
❌ Bad:  "Create the Book class" — implementation detail, no visible behaviour
```

### 🧪 FALSIFY — Test Your Understanding

1. **State what you believe** — "We understand the feature to mean X"
2. **Seek disconfirmation** — "What scenario would prove this wrong?"
3. **Check for gaps** — "Is there a case this plan doesn't handle?"
4. **Check ordering** — "Does any task depend on something unplanned?"

If you can't think of anything that would prove your understanding wrong, that's a warning sign — not a green light.

### 📋 CONFIRM — Agree on Plan

1. Summarise understanding back to user
2. Present ordered task list
3. **STOP** — Explicitly agree on the first task

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

Implement the task using strict TDD: red → green → verify. Use the appropriate language skill. When the current task's acceptance criteria are met and all tests pass, proceed to REFACTOR.

**NEVER write production code without a failing test first.**

### The TDD Cycle

```
🔴 RED    → Write ONE failing test
🟢 GREEN  → Write MINIMUM code to pass
✅ VERIFY → Run all tests, confirm green
```

### 🔴 RED — Write a Failing Test

1. Identify the next behaviour to implement
2. Write a test that specifies that behaviour
3. Run the test — it MUST fail
4. If it passes: **your model of the code is wrong.** Investigate before continuing.

### 🟢 GREEN — Make It Pass

1. Write the simplest code that makes the test pass — but choose appropriate data structures for the domain. A hard-coded value is fine as a first step; a `List` where a `Map` is the natural fit is not simplicity, it's a worse model.
2. Do not refactor yet
3. Run the test — it MUST pass

"Minimum" refers to behaviour and architecture, not to picking naive data structures. If the domain naturally maps to a `Map`, use a `Map` from the start — that's accurate modelling, not premature optimisation.

### ✅ VERIFY — Confirm Green State

Run ALL tests, not just the new one. A single failing test means the system is unsound, even if the new feature looks correct in isolation.

### Test Naming

Good test names are **claims** — propositions your code must make true:

```scala
// Good — states a claim
"return empty list when library has no books"
"return error when member not found"

// Bad — describes nothing
"test1"
"testGetBooks"
```

---

## Phase 3: Refactoring (🔵 REFACTOR) — Interactive

Improve code design while keeping tests green. **STOP** after changes — ask user if they want further refactoring.

**NEVER change behaviour** — refactoring preserves existing functionality. If you need to change behaviour, write a test first and return to DEVELOP.

### The Refactor Cycle

```
✅ VERIFY   → Run all tests, confirm green state
🔍 ANALYSE  → Identify code smell or improvement opportunity
🔵 REFACTOR → Apply ONE transformation
✅ VERIFY   → Run all tests, confirm still green
🔁 REPEAT   → Continue until goal achieved
```

### Goals & Techniques

| Goal | Techniques |
|------|------------|
| Eliminate duplication | Extract method, extract variable, pull up method |
| Improve clarity | Rename, inline temp, introduce explaining variable |
| Simplify conditionals | Decompose conditional, consolidate conditional |
| Improve structure | Extract class, move method, replace inheritance with delegation |

### Code Smells

- **Duplication** — same logic in multiple places; when one changes, they diverge
- **Long methods** — too many steps to hold in working memory
- **Large classes** — multiple responsibilities conflated
- **Long parameter lists** — too many inputs to reason about
- **Feature envy** — logic that belongs with data it accesses
- **Primitive obsession** — unnamed concepts that should be domain types

---

## Phase 4: Review (🔍 REVIEW) — Optional, Autonomous

**Agent:** `code-reviewer` (Opus, read-only tools, uses `bugmagnet`)

Use before merging feature branches, after significant refactoring, for complex or security-sensitive changes, or when requested. Review findings, then look for simplification with the `code-simplifier` agent.

---

## Phase 5: Commit (💾 COMMIT) — Autonomous

**Agent:** `commit-helper` (Haiku, bash only)

Before delegating: summarise what will be committed and ask the user to confirm. Commit after each completed task, refactoring session, or before switching branches.

---

## Phase 6: Iterate (🔁 ITERATE) — Interactive

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
💾 COMMIT → Delegating to commit-helper agent
🔁 ITERATE → Moving to next task
✅ COMPLETE → Feature done
```
