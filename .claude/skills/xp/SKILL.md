---
name: xp
description: Extreme Programming workflow orchestrator. Use when implementing features, adding functionality, or doing test-driven development. Coordinates planning, TDD, refactoring, and commits.
---

# Extreme Programming Workflow

## Getting Started

1. **Detect project type** from files in working directory (first match wins):
   - `build.sbt` or `*.scala` → `scala-developer`
   - `build.gradle.kts` or `*.kt` → `kotlin-developer`
   - `Gemfile` or `*.rb` → `ruby-developer`
   - `tsconfig.json` or `package.json` with TypeScript deps → `typescript-developer`
   - `*.u` or `.unison/` → `unison-development`
   - No match → proceed with language-agnostic TDD workflow using `devtool` commands
2. **Read the language skill** for the detected type
3. **Check for project CLAUDE.md** — may contain project-specific guidance that supplements or overrides language defaults
4. **Begin with PLAN phase**

---

## The XP Workflow

```
📋 PLAN     → Discuss and break down the feature
🔴 DEVELOP  → TDD cycle (red-green)
🔵 REFACTOR → Improve design (tests stay green)
🔍 REVIEW   → Autonomous code review (optional)
💾 COMMIT   → Save working state
🔁 ITERATE  → Next task or feature complete
```

---

## Phase 1: Planning (📋 PLAN) — Interactive

**Reference:** `references/planning.md`

Understand and decompose the feature before writing any code. Use `glossary` skill for unfamiliar domain terms.

---

## Phase 2: Development (🔴 DEVELOP) — Interactive

**Reference:** `references/development.md` + language skill

Implement the task using strict TDD: red → green → verify. When the current task's acceptance criteria are met and all tests pass, proceed to REFACTOR.

---

## Phase 3: Refactoring (🔵 REFACTOR) — Interactive

**Reference:** `references/refactor.md`

Improve code design while keeping tests green. **STOP** after changes — ask user if they want further refactoring.

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

---

## Core Principles (Always Apply)

These aren't arbitrary rules — each addresses a specific way that reasoning about software fails.

- **Communication first** — discuss before coding.
  *Why:* Most defects originate in misunderstanding, not in implementation. Surfacing hidden premises early is cheaper than discovering them in code. (→ Planning: enthymeme detection)

- **Small steps** — one task, one test, one change at a time.
  *Why:* When something breaks after a large change, you can't isolate the cause. Small steps preserve your ability to reason backwards from effect to cause — they keep your arguments **traceable.**

- **Continuous feedback** — tests run constantly.
  *Why:* A conclusion is only as strong as its weakest premise. Every test is a premise in the argument that your system works. Running them constantly ensures you know immediately when a premise fails, before you build further conclusions on top of it.

- **Simplicity** — don't add speculative features, but use the right tools for the job.
  *Why:* Anticipating future needs is **inductive reasoning about unknown cases** — avoid that. But simplicity doesn't mean naive. Choosing the natural data structure for a problem (e.g. a Map for key-value lookup) isn't over-engineering — it's modelling the domain correctly. The test is: "am I adding complexity to handle cases that don't exist yet?" If no, use the appropriate structure.

- **Courage** — refactor fearlessly (tests protect you).
  *Why:* Without tests, changing code requires trusting your mental model of the entire system. With tests, you have a **formal proof** that each expected behaviour still holds. Courage isn't recklessness — it's confidence grounded in evidence.

- **Quality gates** — review before merge, commit after green.
  *Why:* Self-review is unreliable because the same mind that wrote the code shares its blind spots. External review introduces a different perspective — the same reason Socratic dialogue works better than private contemplation.

- **Knowledge capture** — document learnings and domain terms.
  *Why:* Undocumented knowledge is an **unstated premise** in every future decision. When the person who holds that knowledge is unavailable, the argument collapses. Making knowledge explicit makes your team's collective reasoning auditable.
