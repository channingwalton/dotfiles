# Development (TDD)

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to make the test pass
4. Run tests and verify green state before proceeding
5. **New behaviour requires a new test, even when similar existing code lacks one.** Precedent is not permission. Missing twin coverage is a gap to note, not a licence to skip.

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

1. Write the simplest code that makes the test pass — but choose appropriate data structures for the domain. A hard-coded value is fine as a first step; a `List` where a `Map` is the natural fit is not simplicity, it's a worse model.
2. Do not refactor yet
3. Run the test — it MUST pass

**Why minimum code matters:** Avoid speculative abstractions and features you don't need yet. But "minimum" refers to behaviour and architecture, not to picking naive data structures. If the domain naturally maps to a `Map`, use a `Map` from the start — that's not premature optimisation, it's accurate modelling.

### ✅ VERIFY — Confirm Green State

Run ALL tests, not just the new one. A single failing test means your argument is unsound, even if the new feature looks correct in isolation.

**Public signature changes require eyeballing every caller.** Compile-passing is weak evidence. Some languages coerce between function types — Kotlin accepts `() -> X` where `() -> Unit` is expected (return value dropped); TypeScript's structural typing accepts fewer parameters than the target signature declares — so stale callers stay stale and compile + tests both stay green. After any change to a public function's name, parameter list, or return type: `grep` the old shape, open each hit, confirm the new contract holds at every call site.

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

## Next Phase

When the current task's acceptance criteria are met and all tests pass, proceed to **REFACTOR**.
