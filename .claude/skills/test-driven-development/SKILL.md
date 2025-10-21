---
name: Test-Driven Development
description: Implement features using test-driven development methodology. Use when writing new code, implementing features, fixing bugs, or when the user explicitly requests TDD. Follows red-green-refactor cycle with strict discipline.
allowed-tools: Read, Write, Edit, Execute, Git
---

# Test-Driven Development

## Core Rules (Non-Negotiable)

1. **NEVER write production code without a failing test first**
2. **Write minimum code to pass the test**
3. **Run tests and verify green state before proceeding**
4. **Commit only when all tests pass**
5. **One behaviour per test**

## The TDD Cycle

```
🔴 RED    → Write failing test
🟢 GREEN  → Write minimum code to pass
✅ VERIFY → Run all tests, confirm passing
💾 COMMIT → Save working state
🔵 REFACTOR → Improve code (optional, keep tests green)
💾 COMMIT → Save refactored state
```

## Step-by-Step Process

### Before Starting

1. **Identify the simplest behaviour** to implement next
2. **Describe the test** to the user in plain English
3. **Confirm approach** before writing any code
4. **Announce:** `🔴 RED → Writing failing test for [behaviour]`

### Step 1: RED - Write Failing Test

**Instructions:**
1. Write ONE test for ONE behaviour
2. Use descriptive test name: `test_<function>_<scenario>_<expected_result>`
3. Test the simplest case first (empty, zero, null, single element)
4. **DO NOT write any production code yet**
5. Show the test to the user

**Example progression:**
- First: `test_add_zero_and_zero_returns_zero`
- Second: `test_add_positive_numbers_returns_sum`
- Third: `test_add_negative_numbers_returns_sum`

### Step 2: Verify RED State

1. Run the test
2. **Confirm it fails** with expected error:
   - Function doesn't exist, OR
   - Returns wrong value, OR
   - Throws wrong exception
3. Show failure output to user
4. **If test passes without code:** Fix the test
5. **Announce:** `✅ Test fails as expected`

### Step 3: GREEN - Write Minimum Code

**Instructions:**
1. **Announce:** `🟢 GREEN → Writing minimum code to pass test`
2. Write ONLY enough code to make current test pass
3. Hard-coded return values are acceptable initially
4. Resist writing "future-proof" code
5. Show the code to user

**Examples:**
```
Test: assert add(0, 0) == 0
Code: return 0  ✅ Minimum

Test: assert add(1, 2) == 3
Code: return a + b  ✅ Now justified
```

### Step 4: Verify GREEN State

1. **Run ALL tests**
2. Confirm all pass
3. Show test results to user
4. **If any fail:** Fix production code immediately
5. **DO NOT PROCEED** until all tests green
6. **Announce:** `✅ All tests passing`

### Step 5: Commit

1. Create commit message describing the behaviour
2. Format: `add [behaviour description] test` or `implement [behaviour]`
3. **ONLY commit in green state**
4. **Announce:** `💾 Committed: [message]`

### Step 6: Refactor (If Valuable)

**When to refactor:**
- Code duplication exists
- Code is unclear or overly complex
- Better abstraction is obvious
- Performance improvement needed

**If refactoring:**
1. **Announce:** `🔵 REFACTOR → [what you're improving]`
2. Make small changes
3. Run tests after each change
4. **If tests fail:** Revert immediately
5. Show refactored code to user
6. Commit with message: `refactor: [description]`

**If no refactoring needed:**
- **Announce:** `No refactoring needed`

### Step 7: Choose Next Test

**Progressive complexity:**
1. ✅ Simplest case (empty/zero/null)
2. ✅ Simple valid case (one element)
3. ✅ Another simple case (different input)
4. ✅ Boundary cases (min/max values)
5. ✅ Edge cases (special conditions)
6. ✅ Error cases (invalid input)

**Announce:** `Next test: [description of next behaviour]`

**Repeat cycle from Step 1**

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

## Common Mistakes to Avoid

### ❌ Writing Production Code First
- **Never** write production code before failing test
- Always resist this urge

### ❌ Writing Multiple Tests at Once
- One test at a time only
- Make it green before writing next test

### ❌ Writing Too Much Code
- Only write enough to pass current test
- Don't anticipate future tests

### ❌ Not Running Tests
- Run tests after every change
- Verify green state before proceeding

### ❌ Skipping Commits
- Commit every green state
- Provides safe revert point

### ❌ Testing Implementation
- Test behaviour/interface, not implementation
- Tests should survive refactoring

## Handling Different Scenarios

### New Feature
1. Start with simplest acceptance criterion
2. Break into small unit tests
3. Follow RED-GREEN-REFACTOR for each
4. Build complexity gradually

### Bug Fix
1. Write test reproducing bug (should fail)
2. Fix bug (test should pass)
3. Commit fix
4. Add edge case tests if needed

### Refactoring Existing Code
1. Add tests for current behaviour first
2. Ensure all tests pass
3. Refactor with test safety net
4. Keep tests green throughout

## Communication with User

**Always announce:**
- Current phase: 🔴 RED, 🟢 GREEN, 🔵 REFACTOR
- What behaviour you're testing
- Test results (pass/fail)
- Commits made
- Next steps

**Show to user:**
- Each test before running
- Test failure output (RED phase)
- Production code written (GREEN phase)
- Test success output (verification)
- Refactored code (if applicable)

**Ask user:**
- Confirm approach before starting
- Clarify requirements if ambiguous
- Whether to proceed to next test

## Example Interaction

```
Me: 🔴 RED → Writing failing test for adding zero
[show test code]

Me: Running test...
❌ NameError: name 'add' is not defined
✅ Test fails as expected

Me: 🟢 GREEN → Writing minimum code to pass test
[show production code]

Me: Running all tests...
✅ All 1 tests passing

Me: 💾 Committed: add function returns zero for zero inputs

Me: Next test: adding two positive numbers
[repeat cycle]
```

## Checklist for Each Cycle

- [ ] Write failing test (RED)
- [ ] Verify test fails for right reason
- [ ] Write minimum code (GREEN)
- [ ] Run all tests, verify passing
- [ ] Commit changes
- [ ] Refactor if valuable (optional)
- [ ] Commit refactoring (if done)
- [ ] Choose next test
- [ ] Repeat

## Remember

- **Discipline over speed** - Follow process even when it feels slow
- **Trust the process** - TDD prevents bugs and enables fearless refactoring
- **Small steps** - Each test is a tiny increment
- **Always green** - Commit frequently in working state
- **Let tests drive design** - Hard to test = poor design
