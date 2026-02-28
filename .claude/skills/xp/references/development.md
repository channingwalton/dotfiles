# Development (TDD)

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to make the test pass
4. Run tests and verify green state before proceeding

## The TDD Cycle

```
🔴 RED    → Write ONE failing test
🟢 GREEN  → Write MINIMUM code to pass
✅ VERIFY → Run all tests, confirm green
```

## Why This Works

TDD mirrors the structure of sound reasoning:

- **Code that compiles** is like a **valid argument** — correct form, but the conclusion might still be wrong.
- **Code that passes tests** is like a **sound argument** — correct form and the premises hold.
- **Code that survives edge-case analysis** (→ `bugmagnet`) is like an argument that withstands **systematic counter-examination**.

Compilation alone is necessary but not sufficient. Tests connect form to truth.

## Detailed Steps

### 🔴 RED — Write a Failing Test

1. Identify the next behaviour to implement
2. Write a test that specifies that behaviour
3. Run the test — it MUST fail
4. If it passes: **your model of the code is wrong.** Investigate before continuing.

### 🟢 GREEN — Make It Pass

1. Write the simplest code that makes the test pass — hard-coded values, duplication, and "ugly" code are all acceptable
2. Do not refactor yet
3. Run the test — it MUST pass

**Why minimum code matters:** The temptation to write "good" code immediately is the developer's equivalent of stopping when the answer *feels* satisfying. You don't yet have enough evidence (tests) to know what "good" looks like. Minimum code is **intellectual humility** — trusting the process over intuition.

### ✅ VERIFY — Confirm Green State

Run ALL tests, not just the new one. A single failing test means your argument is unsound, even if the new feature looks correct in isolation.

## Test Naming

Good test names are **claims** — propositions your code must make true:

```scala
// Good — states a claim
"return empty list when library has no books"
"return error when member not found"

// Bad — describes nothing
"test1"
"testGetBooks"
```

## Common Mistakes

- Writing production code before the test
- Writing multiple tests before making any pass
- Refactoring while still red
- Skipping the verify step
- Testing implementation, not behaviour
- Writing more code than the test demands — acting on assumptions rather than evidence
- Ignoring a test that passes unexpectedly — a surprise pass means your mental model is wrong
