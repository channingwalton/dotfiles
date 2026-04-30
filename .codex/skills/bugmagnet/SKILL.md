---
name: bugmagnet
description: Discover edge cases and test coverage gaps through systematic analysis. Use when analysing test coverage, finding bugs, hunting for edge cases, reviewing code for robustness, or when code-reviewer identifies test gaps. Also use when the user says things like "what could go wrong", "is this well tested", "find holes in my tests", "what am I missing", or asks about edge cases for any function or module.
---

# BugMagnet

Systematic test coverage analysis and bug discovery. Based on [gojko/bugmagnet-ai-assistant](https://github.com/gojko/bugmagnet-ai-assistant).

## Workflow

```
🔍 ANALYSE  → Understand code and existing tests
📊 GAP      → Identify missing coverage using edge-cases.md
✍️ WRITE    → Implement tests iteratively
🔬 ADVANCED → Deep edge case exploration (optional)
📋 SUMMARY  → Document findings and bugs
```

**Interactive mode (default):** STOP and wait for user confirmation between phases.
**Autonomous mode:** When invoked by another agent (e.g. code-reviewer), skip all STOP points and proceed automatically. Present the full summary at the end.

---

## Key Rules

These override default behaviour:

- **DO NOT FIX bugs** — only document them. Create a skipped test with: brief description, root cause, code location, expected vs actual, proposed fix. Explore surrounding territory (bugs cluster).
- **Maximum 3 attempts per test** — if a test won't stabilise after 3 tries, document and move on.
- **In autonomous mode, implement all high-priority tests** without waiting for user selection.

## Gap Analysis

Use [edge-cases.md](references/edge-cases.md) as the primary checklist. Categorise gaps as **High** (core, errors, boundaries) → **Medium** (interactions, state) → **Low** (rare, performance). In interactive mode, ask the user which to implement.

## Advanced Coverage (🔬 ADVANCED)

Create separate test suite: "bugmagnet session \<date\>"

Work through [edge-cases.md](references/edge-cases.md) comprehensively.

## Summary Format

```markdown
## Test Coverage Summary

**Tests Added:** X total (Y passing, Z skipped/bugs)

**Bugs Discovered:**
1. Bug name — file:line — root cause — proposed fix
```

## Reference Files

- [Edge Case Checklist](references/edge-cases.md)
