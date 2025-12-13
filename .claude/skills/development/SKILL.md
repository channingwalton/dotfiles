---
name: Development
description: Implement features using strict test-driven development. Use when writing new code, implementing features, fixing bugs, or when TDD is requested. Enforces RED-GREEN-REFACTOR cycle.
---

# Development (TDD)

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. One behaviour per test
3. Write minimum code to make the test pass
4. Run tests and verify green state before proceeding
5. Keep project documentation up to date
6. Use the vault skill to maintain tasks, notes, and memory
7. Use the code-reviewer skill to check changes

## The TDD Cycle

```
📋 TASK   → Create/update task file using the vault skill
🔎 SEARCH → Search the vault for similar tasks for this project to provide context
🔴 RED    → Write failing test
🟢 GREEN  → Write minimum code to pass
✅ VERIFY → Run all tests, confirm passing
💾 COMMIT → Save working state (use commit-helper)
👀 REVIEW → Use code-reviewer skill
⚠️ FIX    → Address review issues
🔵 REFACTOR → Improve code (use refactor skill)
💾 COMMIT → Save refactored state
📝 LOG    → Update task file with decisions/outcomes
```

See `references/tdd-workflow.md` for detailed step-by-step instructions.

## Quick Reference

| Phase | Announce | Action |
|-------|----------|--------|
| RED | `🔴 RED → Writing failing test for [behaviour]` | Write ONE test, verify it fails |
| GREEN | `🟢 GREEN → Writing minimum code` | Pass current test only |
| VERIFY | `✅ All tests passing` | Run ALL tests |
| REFACTOR | `🔵 REFACTOR → [improvement]` | Smal changes, tests stay green |

## Test Structure (AAA Pattern)

```
-- Arrange: set up test data
testData = createTestData()

-- Act: execute the code
result = functionUnderTest(testData)

-- Assert: verify resul
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

## Vault and Memory Integration

- **Before work:** Search memory skill for atomic facts
- **Before work**: Search the vault for related notes
- **During work**: Use the **vault skill** to track work in the tasks note
- **During work**: Use the **vault skill** to add new information in the vault
- **After work**: Update memory skill with atomic facts
- **After work**: Update task frontmatter when done: `status: done`
- **After work**: Write a summary in the Outcome section
- **After work**: Use the vault skill to add new information learnt in development to the vault
