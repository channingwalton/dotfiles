# TDD Workflow Detail

## Step 1: RED - Write Failing Test

1. Write ONE test for ONE behaviour
2. Use descriptive test name: `test_<function>_<scenario>_<expected_result>`
3. Test the simplest case first (empty, zero, null, single element)
4. **DO NOT write any production code yet**
5. Show the test to the user

**Example progression:**
- First: `test_add_zero_and_zero_returns_zero`
- Second: `test_add_positive_numbers_returns_sum`
- Third: `test_add_negative_numbers_returns_sum`

## Step 2: Verify RED State

1. Run the test
2. **Confirm it fails** with expected error:
   - Function doesn't exist, OR
   - Returns wrong value, OR
   - Throws wrong exception
3. Show failure output to user
4. **If test passes without code:** Fix the test
5. **Announce:** `✅ Test fails as expected`

## Step 3: GREEN - Write Minimum Code

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

## Step 4: Verify GREEN State

1. **Run ALL tests**
2. Confirm all pass
3. Show test results to user
4. **If any fail:** Fix production code immediately
5. **DO NOT PROCEED** until all tests green
6. **Announce:** `✅ All tests passing`

## Step 5: Commit

1. Use commit-helper skill
2. Format: `add [behaviour description] test` or `implement [behaviour]`
3. **ONLY commit in green state**
4. **Announce:** `💾 Committed: [message]`

## Step 6: Review

1. Use code-reviewer skill
2. Produce plan to fix issues
3. Fix the issues

## Step 7: Refactor (If Valuable)

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

**If no refactoring needed:** Announce `No refactoring needed`

## Step 8: Choose Next Test

**Progressive complexity:**
1. ✅ Simplest case (empty/zero/null)
2. ✅ Simple valid case (one element)
3. ✅ Another simple case (different input)
4. ✅ Boundary cases (min/max values)
5. ✅ Edge cases (special conditions)
6. ✅ Error cases (invalid input)

**Announce:** `Next test: [description of next behaviour]`

## Communication Checklist

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
