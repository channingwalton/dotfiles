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

## What Refactoring Is NOT

Refactoring is NOT adding features, fixing bugs, or changing APIs. If you're tempted to change behaviour, write a test first and return to DEVELOP.

## Code Smells to Watch For

Duplication, long methods, large classes, long parameter lists, feature envy, primitive obsession.

## Safety Checklist

Before: all tests pass, understand the code. After each change: tests still pass, behaviour unchanged, code is clearer (not just different).
