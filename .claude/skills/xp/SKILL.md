---
name: xp
description: Extreme Programming workflow orchestrator. Use when implementing features, adding functionality, or doing test-driven development. Coordinates planning, TDD, refactoring, and commits.
---

# Extreme Programming Workflow

## Overview

This skill orchestrates the full XP workflow for feature implementation. It uses reference documentation for interactive phases and delegates to agents for autonomous tasks.

## Getting Started

1. **Detect project type** from files in working directory
2. **Read the language skill** for the detected type:
   - `build.sbt` or `*.scala` → `scala-developer`
   - `build.gradle.kts` or `*.kt` → `kotlin-developer`
   - `Gemfile` or `*.rb` → `ruby-developer`
   - `tsconfig.json` or `package.json` with TypeScript deps → `typescript-developer`
   - `*.u` or `.unison/` → `unison-development`
3. **Check for project CLAUDE.md** — may contain project-specific guidance that supplements or overrides language defaults
4. **Begin with PLAN phase**

---

## The XP Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  📋 PLAN     → Discuss and break down the feature          │
│  🔴 DEVELOP  → TDD cycle (red-green)                       │
│  🔵 REFACTOR → Improve design (tests stay green)           │
│  🔍 REVIEW   → Autonomous code review (optional)           │
│  💾 COMMIT   → Save working state                          │
│  🔁 ITERATE  → Next task or feature complete               │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Planning (📋 PLAN)

**Goal:** Understand and decompose the feature before writing any code.

**Type:** Interactive (requires user discussion)

**Reference:** See `references/planning.md`

### Supporting Skills
- `glossary` — Define unfamiliar domain terms encountered during discussion

### Checkpoint
- [ ] Requirements understood
- [ ] Domain terms added to glossary
- [ ] Tasks broken into vertical slices
- [ ] First task agreed with user

---

## Phase 2: Development (🔴 DEVELOP)

**Goal:** Implement the task using strict TDD.

**Type:** Interactive (user sees tests and implementation)

**Reference:** See `references/development.md` + language skill

### The TDD Cycle
```
🔴 RED    → Write ONE failing test
🟢 GREEN  → Write MINIMUM code to pass
✅ VERIFY → Run all tests, confirm green
```

### Checkpoint
- [ ] Test written and failing
- [ ] Minimum code makes test pass
- [ ] All tests green

---

## Phase 3: Refactoring (🔵 REFACTOR)

**Goal:** Improve code design while keeping tests green.

**Type:** Interactive (user approves changes)

**Reference:** See `references/refactor.md`

### Checkpoint
- [ ] All tests pass before refactoring
- [ ] One transformation at a time
- [ ] All tests pass after each change
- [ ] **STOP** — Ask user if they want further changes

---

## Phase 4: Review (🔍 REVIEW) — Optional

**Goal:** Autonomous quality check before committing.

**Type:** Autonomous (runs in isolation)

**Invoke:** `code-reviewer` agent

### When to Use
- Before merging feature branches
- After significant refactoring
- When requested by user
- For complex or security-sensitive changes

### Agent: code-reviewer
- **Model:** Opus (thorough analysis)
- **Tools:** Read, Grep, Glob, Bash (read-only operations)
- **Skills:** bugmagnet (for test coverage gaps)
- **Output:** Structured findings report

### Checkpoint
- [ ] Review any 🔴 CRITICAL findings
- [ ] Address 🟡 WARNING  findings
- [ ] Note ℹ️ SUGGESTION findings for future
- [ ] Run `bugmagnet` if test gaps identified
- [ ] Look for code simplification with the code-simplifier agent

---

## Phase 5: Commit (💾 COMMIT)

**CONFIRM BEFORE PROCEEDING**

**Goal:** Save working state with clear, conventional commit message.

**Type:** Autonomous (generates message for approval)

**Invoke:** `commit-helper` agent

### When to Commit
- After each passing test (small commits)
- After completing a task
- After refactoring session
- Before switching branches

### Agent: commit-helper
- **Model:** Haiku (fast, cheap)
- **Tools:** Bash only (git commands)
- **Output:** Conventional commit message

### Checkpoint
- [ ] Changes staged
- [ ] Review suggested commit message
- [ ] Confirm or adjust message
- [ ] Commit created

---

## Phase 6: Iterate (🔁 ITERATE)

**Goal:** Continue until feature complete.

**Type:** Interactive (planning next steps with user)

1. Mark task as done
2. Review remaining tasks
3. Adjust plan if needed (new learnings)
4. Return to Phase 2 for next task
5. When all tasks complete → feature done

### Supporting Skills
- `vault` — Log significant learnings or decisions to project notes

### Checkpoint
- [ ] Task marked complete
- [ ] Learnings captured (if significant)
- [ ] Remaining tasks reviewed
- [ ] Next task selected or feature complete

---

## Announcing Phase Transitions

When switching phases, announce clearly:

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

## Component Summary

| Phase | Component | Type | User Interaction |
|-------|-----------|------|------------------|
| PLAN | `references/planning.md` | Reference | Discussion required |
| PLAN | `glossary` skill | Skill | Define terms |
| DEVELOP | `references/development.md` | Reference | Sees tests/code |
| DEVELOP | Language skill (detected in Getting Started) | Skill | Build/test commands |
| REFACTOR | `references/refactor.md` | Reference | Approves changes |
| REVIEW | `code-reviewer` agent | Agent | Reviews report, invokes bugmagnet |
| COMMIT | `commit-helper` agent | Agent | Confirms message |
| ITERATE | `vault` skill | Skill | Capture learnings |

---

## Core Principles (Always Apply)

These aren't arbitrary rules — each addresses a specific way that reasoning about software fails.

- **Communication first** — discuss before coding.
  *Why:* Most defects originate in misunderstanding, not in implementation. Surfacing hidden premises early is cheaper than discovering them in code. (→ Planning: enthymeme detection)

- **Small steps** — one task, one test, one change at a time.
  *Why:* When something breaks after a large change, you can't isolate the cause. Small steps preserve your ability to reason backwards from effect to cause — they keep your arguments **traceable.**

- **Continuous feedback** — tests run constantly.
  *Why:* A conclusion is only as strong as its weakest premise. Every test is a premise in the argument that your system works. Running them constantly ensures you know immediately when a premise fails, before you build further conclusions on top of it.

- **Simplicity** — implement only what's needed now.
  *Why:* Anticipating future needs is **inductive reasoning about unknown cases.** It's the most error-prone form of reasoning. Code for what you know; refactor when you learn more.

- **Courage** — refactor fearlessly (tests protect you).
  *Why:* Without tests, changing code requires trusting your mental model of the entire system. With tests, you have a **formal proof** that each expected behaviour still holds. Courage isn't recklessness — it's confidence grounded in evidence.

- **Quality gates** — review before merge, commit after green.
  *Why:* Self-review is unreliable because the same mind that wrote the code shares its blind spots. External review introduces a different perspective — the same reason Socratic dialogue works better than private contemplation.

- **Knowledge capture** — document learnings and domain terms.
  *Why:* Undocumented knowledge is an **unstated premise** in every future decision. When the person who holds that knowledge is unavailable, the argument collapses. Making knowledge explicit makes your team's collective reasoning auditable.
