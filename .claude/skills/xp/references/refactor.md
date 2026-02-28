# Refactor

## Core Rules (Non-Negotiable)

1. **NEVER change behaviour** — refactoring preserves existing functionality
2. **All tests must pass** before and after refactoring
3. **Small incremental changes** — one transformation at a time
4. **Run tests after every change** — catch regressions immediately

## The Refactor Cycle

```
✅ VERIFY   → Run all tests, confirm green state
🔍 ANALYSE  → Identify code smell or improvement opportunity
🔵 REFACTOR → Apply ONE transformation
✅ VERIFY   → Run all tests, confirm still green
🔁 REPEAT   → Continue until goal achieved
```

## What Refactoring Is

Refactoring is **improving an argument without changing its conclusion.** Tests define what the code proves. Refactoring changes *how* it proves it — clearer, less redundant, better structured — while preserving the same result.

Refactoring is NOT adding features, fixing bugs, or changing APIs. If you're tempted to change behaviour, write a test first and return to DEVELOP.

## Goals & Techniques

| Goal | Techniques |
|------|------------|
| Eliminate duplication | Extract method, extract variable, pull up method |
| Improve clarity | Rename, inline temp, introduce explaining variable |
| Simplify conditionals | Decompose conditional, consolidate conditional |
| Improve structure | Extract class, move method, replace inheritance with delegation |

## Code Smells as Reasoning Failures

Each smell maps to a way that reasoning about code becomes unreliable:

- **Duplication** — same premise in multiple places; when one changes, your argument becomes **internally contradictory**
- **Long methods** — too many steps to hold in working memory; you lose the ability to verify the conclusion follows
- **Large classes** — multiple arguments conflated; hard to tell which premises support which conclusions
- **Long parameter lists** — too many premises; more combinations to reason about, more missed cases
- **Feature envy** — premises in the wrong place; the argument should live where its evidence lives
- **Primitive obsession** — unnamed concepts; like a proof that uses "that number" instead of defining a variable

## Announcing Changes

```
🔵 REFACTOR → [smell]: [transformation]
```

## Safety Checklist

Before: all tests pass, understand the code. After each change: tests still pass, behaviour unchanged, code is clearer (not just different).
