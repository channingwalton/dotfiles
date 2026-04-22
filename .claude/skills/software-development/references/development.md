# Development (TDD)

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to make the test pass
4. Run affected-submodule tests (whole project if none) before proceeding
5. **New behaviour requires a new test, even when similar existing code lacks one.** Precedent is not permission. Missing twin coverage is a gap to note, not a licence to skip.

## The TDD Cycle

```
🔴 RED    → Write ONE failing test
🟢 GREEN  → Write MINIMUM code to pass
✅ VERIFY → Run affected-submodule tests (or whole project if none), confirm green
```

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

### ✅ VERIFY — Confirm Green State

Any failing test blocks — do not proceed.

**Public signature changes require eyeballing every caller.** Compile-passing is weak evidence. Some languages coerce between function types — Kotlin accepts `() -> X` where `() -> Unit` is expected (return value dropped); TypeScript's structural typing accepts fewer parameters than the target signature declares — so stale callers stay stale and compile + tests both stay green. After any change to a public function's name, parameter list, or return type: `grep` the old shape, open each hit, confirm the new contract holds at every call site.
