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

## What Refactoring Actually Is

Refactoring is **improving an argument without changing its conclusion.** Your tests define what the code proves. Refactoring changes *how* it proves it — making the reasoning clearer, removing redundancy, strengthening the structure — while preserving the same result.

This is exactly what you do when you revise a written argument: you don't change your thesis, you make the supporting reasoning tighter and more transparent.

## Goals & Techniques

| Goal | Techniques |
|------|------------|
| Eliminate duplication | Extract method, extract variable, pull up method |
| Improve clarity | Rename, inline temp, introduce explaining variable |
| Simplify conditionals | Decompose conditional, consolidate conditional |
| Improve structure | Extract class, move method, replace inheritance with delegation |

## Code Smells as Reasoning Failures

Code smells aren't aesthetic preferences — each one maps to a way that reasoning about code becomes unreliable:

- **Duplication** — the same premise stated in multiple places. When one copy changes and the others don't, your argument becomes **internally contradictory.**
- **Long methods** — an argument with too many steps to hold in working memory. You lose the ability to verify whether the conclusion follows from the premises.
- **Large classes** — conflating multiple arguments into one. Hard to tell which premises support which conclusions.
- **Long parameter lists** — too many premises required to reach a conclusion. The more inputs, the more combinations to reason about, the more likely you'll miss a case.
- **Feature envy** — a method that reasons about another object's data more than its own. The premises are in the wrong place — the argument should live where its evidence lives.
- **Primitive obsession** — using raw values where a named concept would make the reasoning explicit. It's like writing a proof that uses "that number" instead of naming the variable.

## What Refactoring Is NOT

- Adding new features
- Fixing bugs (unless the fix is purely structural)
- Changing external APIs

If you're tempted to change behaviour during refactoring, that's a signal: write a test for the new behaviour first, return to the DEVELOP phase, then refactor.

## Announcing Changes

```
🔵 REFACTOR → [smell]: [transformation]
```

Examples:

- `🔵 REFACTOR → duplication: Extract method calculateTotal`
- `🔵 REFACTOR → long method: Split processOrder into validate and execute`

## Safety Checklist

Before starting:

- [ ] All tests pass
- [ ] Understand the code being refactored

After each change:

- [ ] Tests still pass
- [ ] Behaviour unchanged
- [ ] Code is clearer (not just different)
