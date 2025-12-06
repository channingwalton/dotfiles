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
💾 COMMIT → Save working state
👀 REVIEW → Use code-reviewer skill
⚠️ FIX    → Address review issues
🔵 REFACTOR → Improve code (keep tests green)
💾 COMMIT → Save refactored state
```

## Step-by-Step Process

See `references/tdd-workflow.md` for detailed step-by-step instructions.

### Before Starting

1. Identify the simplest behaviour to implement
2. Describe the test in plain English
3. Confirm approach before writing code
4. Announce: `🔴 RED → Writing failing test for [behaviour]`

### RED Phase

- Write ONE test for ONE behaviour
- Use descriptive names: `test_<function>_<scenario>_<expected>`
- Test simplest case first (empty, zero, null, single element)
- **DO NOT write production code yet**

### GREEN Phase

- Announce: `🟢 GREEN → Writing minimum code`
- Write ONLY enough to pass current test
- Hard-coded returns acceptable initially
- Resist "future-proof" code

### Verification

- Run ALL tests
- Show results to user
- **DO NOT PROCEED** until all green
- Announce: `✅ All tests passing`

### Commit

- Use commit-helper skill
- Format: `add [behaviour] test` or `implement [behaviour]`
- **ONLY commit in green state**

### Refactor (If Valuable)

- Announce: `🔵 REFACTOR → [improvement]`
- Make small changes
- Run tests after each change
- If tests fail: revert immediately

## Test Structure (AAA Pattern)

```python
def test_function_scenario_expected():
    # Arrange - set up test data
    input_data = create_test_data()

    # Act - execute the code
    result = function_under_test(input_data)

    # Assert - verify result
    assert result == expected_value
```

## Handling Scenarios

| Scenario | Approach |
|----------|----------|
| New feature | Start with simplest criterion, build complexity gradually |
| Bug fix | Write test reproducing bug first, then fix |
| Refactoring | Add tests for current behaviour first, then refactor |

## Common Mistakes

See `references/common-mistakes.md` for anti-patterns to avoid.
