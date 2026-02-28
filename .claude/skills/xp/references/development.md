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

## Why This Works (The Logic Behind TDD)

TDD mirrors the structure of sound reasoning:

- **Code that compiles** is like a **valid argument** — the form is correct, but the conclusion might still be wrong. `devtool compile` checks this.
- **Code that passes tests** is like a **sound argument** — not only is the form correct, but the premises (expectations) hold and the conclusion (behaviour) follows.
- **Code that survives edge-case analysis** (→ `bugmagnet`) is like an argument that withstands **systematic counter-examination** — you've tried to falsify it and failed.

Compilation alone is necessary but not sufficient. A function with the right type signature can return nonsense. Tests are what connect form to truth.

## Detailed Steps

### 🔴 RED — Write a Failing Test

1. Identify the next behaviour to implement
2. Write a test that specifies that behaviour
3. Run the test — it MUST fail
4. If it passes, you've either:
   - Written the wrong test, or
   - The behaviour already exists

A passing test you expected to fail is a signal: **your model of the code is wrong.** Investigate before continuing.

### 🟢 GREEN — Make It Pass (Pragmatic Doubt)

1. Write the simplest code that makes the test pass
2. Do not write more than necessary
3. Do not refactor yet
4. Run the test — it MUST pass

**Why minimum code matters:** The temptation to write "good" code immediately is the developer's equivalent of stopping when the answer *feels* satisfying. You don't yet have enough evidence (tests) to know what "good" looks like. Writing minimum code is an act of **intellectual humility** — trusting the process over your intuition about where the design should go.

### ✅ VERIFY — Confirm Green State

1. Run ALL tests, not just the new one
2. All tests must pass
3. If any fail, fix before continuing

Verification is non-negotiable because **each test is a premise in your overall argument that the system works.** A single failing test means your argument is unsound, even if the new feature looks correct in isolation.

## What Counts as "Minimum Code"

- Hard-coded values are acceptable initially
- Duplication is acceptable initially
- "Ugly" code is acceptable initially
- Refactoring comes AFTER green using the refactoring skill

These aren't shortcuts — they're **deliberate restraint.** Each represents a refusal to act on assumptions that haven't yet been tested.

## Test Naming

Use descriptive names that document behaviour:

```scala
// Good
"return empty list when library has no books"
"return error when member not found"

// Bad
"test1"
"testGetBooks"
```

Good test names are **claims.** Each one states a proposition that your code must make true. Reading a test suite should read like a list of things you know to be the case about your system.

## Announcing Progress

```
🔴 RED → [behaviour being tested]
🟢 GREEN → Test passes
✅ VERIFY → All tests green
```

## Common Mistakes

- Writing production code before the test
- Writing multiple tests before making any pass
- Refactoring while still red
- Skipping the verify step
- Writing tests that test implementation, not behaviour
- **Writing more code than the test demands** — acting on assumptions rather than evidence
- **Ignoring a test that passes unexpectedly** — a surprise pass means your mental model is wrong
