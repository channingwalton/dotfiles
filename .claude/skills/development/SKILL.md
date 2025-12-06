---
name: Development
description: Implement features using strict test-driven development. Use when writing new code, implementing features, fixing bugs, or when TDD is requested. Enforces RED-GREEN-REFACTOR cycle.
---

# Development (TDD)

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to pass the test
4. Run tests and verify green state before proceeding
5. Commit only when all tests pass
6. Keep project documentation up to date

## The TDD Cycle

```
🔴 RED    → Write failing test
🟢 GREEN  → Write minimum code to pass
✅ VERIFY → Run all tests, confirm passing
💾 COMMIT → Save working state (use commit-helper)
👀 REVIEW → Use code-reviewer skill
⚠️ FIX    → Address review issues
🔵 REFACTOR → Improve code (keep tests green)
💾 COMMIT → Save refactored state
```

See `references/tdd-workflow.md` for detailed step-by-step instructions.

## Quick Reference

| Phase | Announce | Action |
|-------|----------|--------|
| RED | `🔴 RED → Writing failing test for [behaviour]` | Write ONE test, verify it fails |
| GREEN | `🟢 GREEN → Writing minimum code` | Pass current test only |
| VERIFY | `✅ All tests passing` | Run ALL tests |
| REFACTOR | `🔵 REFACTOR → [improvement]` | Small changes, tests stay green |

## Test Structure (AAA Pattern)

```
-- Arrange: set up test data
testData = createTestData()

-- Act: execute the code
result = functionUnderTest(testData)

-- Assert: verify result
assertEqual(result, expectedValue)
```

Language-specific test syntax provided by language skills (scala-developer, ruby-developer, etc.)

## Handling Scenarios

| Scenario | Approach |
|----------|----------|
| New feature | Start with simplest criterion, build complexity gradually |
| Bug fix | Write test reproducing bug first, then fix |
| Refactoring | Add tests for current behaviour first, then refactor |

## Common Mistakes

See `references/common-mistakes.md` for anti-patterns to avoid.
