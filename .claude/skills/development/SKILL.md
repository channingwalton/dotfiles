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

## The TDD Cycle

```
📋 TASK    → Create/update task file (vault skill)
🔎 SEARCH  → Search vault for similar tasks for context
🔴 RED     → Write failing test
🟢 GREEN   → Write minimum code to pass
✅ VERIFY  → Run all tests, confirm passing
💾 COMMIT  → Save working state (commit-helper agent)
👀 REVIEW  → Check changes (code-reviewer agent)
⚠️ FIX     → Address review issues
🔵 REFACTOR → Improve code (refactor skill)
💾 COMMIT  → Save refactored state
📝 LOG     → Update task file with decisions/outcomes
```

## Agent/Skill Integration

| Phase | Invoke |
|-------|--------|
| TASK, SEARCH, LOG | `vault` skill |
| COMMIT | `commit-helper` agent |
| REVIEW | `code-reviewer` agent |
| REFACTOR | `refactor` skill |

## Phase Announcements

| Phase | Announce |
|-------|----------|
| RED | `🔴 RED → Writing failing test for [behaviour]` |
| GREEN | `🟢 GREEN → Writing minimum code` |
| VERIFY | `✅ All tests passing` |
| REFACTOR | `🔵 REFACTOR → [improvement]` |

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

## Memory Integration

- **Before work:** Search memory skill for atomic facts
- **Before work:** Search vault for related notes
- **During work:** Update vault task file with progress
- **After work:** Store atomic facts in memory skill
- **After work:** Update task frontmatter: `status: done`

## Common Mistakes

See `references/common-mistakes.md` for anti-patterns to avoid.

## Detailed Workflow

See `references/tdd-workflow.md` for step-by-step phase instructions.
