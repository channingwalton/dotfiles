---
name: bugmagnet
description: Discover edge cases and test coverage gaps through systematic analysis. Use when analysing test coverage, finding bugs, hunting for edge cases, or when code-reviewer identifies test gaps.
---

# BugMagnet

Systematic test coverage analysis and bug discovery.

Based on [gojko/bugmagnet-ai-assistant](https://github.com/gojko/bugmagnet-ai-assistant).

## Workflow

```
🔍 ANALYSE  → Understand code and existing tests
📊 GAP      → Identify missing coverage
✍️ WRITE    → Implement tests iteratively
🔬 ADVANCED → Deep edge case exploration (optional)
📋 SUMMARY  → Document findings and bugs
```

**STOP and wait for user confirmation between phases.**

---

## Phase 1: Analysis (🔍 ANALYSE)

1. Detect language and testing conventions
2. Read implementation — public API, parameters, state, dependencies
3. Locate test file — if none exists, ask user about creating one
4. Run baseline coverage if tools available
5. Read existing tests — understand current coverage and patterns
6. Ask user: "Are there additional files I should review?"

**STOP** — Wait for user input.

---

## Phase 2: Gap Analysis (📊 GAP)

Evaluate missing coverage using [edge-cases.md](references/edge-cases.md):

- Boundary conditions, error paths, state transitions
- Complex interactions, domain-specific edge cases
- Violated domain constraints

Categorise: **High** (core, errors, boundaries) → **Medium** (interactions, state) → **Low** (rare, performance). Present analysis with specific examples.

**STOP** — Ask user which tests to implement.

---

## Phase 3: Test Implementation (✍️ WRITE)

For each test, highest priority first:

1. Write single test (or 2-3 related)
2. Name describes outcome: "returns X when Y", "throws error when Z"
3. Run immediately

**On failure:** test expectation wrong → update test. Bug discovered → create skipped test with documentation. Need more context → try 2 more variations.

**When bug found:** create minimal reproduction, explore surrounding territory (bugs cluster), document in skipped test — **DO NOT FIX, only document.** Include: brief description, root cause, code location, expected vs actual, proposed fix.

**Maximum 3 attempts per test** — document and move on.

**STOP** — Ask user if they want advanced coverage.

---

## Phase 4: Advanced Coverage (🔬 ADVANCED)

Create separate test suite: "bugmagnet session \<date\>"

Work through [edge-cases.md](references/edge-cases.md) comprehensively — complex interactions, error handling, numeric/date/string/collection edge cases, state transitions, domain-specific cases.

---

## Phase 5: Summary (📋 SUMMARY)

```markdown
## Test Coverage Summary

**Tests Added:** X total (Y passing, Z skipped/bugs)

**Bugs Discovered:**
1. Bug name — file:line — root cause — proposed fix
```

## Reference Files

- [Edge Case Checklist](references/edge-cases.md)
