# TDD Workflow Detail

Detailed step-by-step instructions for each phase of the TDD cycle.

## RED Phase

1. Write ONE test for ONE behaviour
2. Use descriptive test name reflecting behaviour
3. Test the simplest case first (empty, zero, null, single element)
4. **DO NOT write any production code yet**
5. Show the test to the user
6. Run the test — confirm it fails with expected error:
   - Function doesn't exist, OR
   - Returns wrong value, OR
   - Throws wrong exception
7. **If test passes without code:** Fix the test
8. Announce: `✅ Test fails as expected`

**Test progression example:**
1. `test_add_zero_and_zero_returns_zero`
2. `test_add_positive_numbers_returns_sum`
3. `test_add_negative_numbers_returns_sum`

## GREEN Phase

1. Announce: `🟢 GREEN → Writing minimum code to pass test`
2. Write ONLY enough code to make current test pass
3. Hard-coded return values are acceptable initially
4. Resist writing "future-proof" code
5. Show the code to user

**Minimum code example:**
```
Test: assertEqual(add(0, 0), 0)
Code: return 0  ✅ Acceptable

Test: assertEqual(add(1, 2), 3)
Code: return a + b  ✅ Now justified by failing test
```

## VERIFY Phase

1. Run ALL tests (not just the new one)
2. Confirm all pass
3. Show test results to user
4. **If any fail:** Fix production code immediately
5. **DO NOT PROCEED** until all green
6. Announce: `✅ All tests passing`

## COMMIT Phase

1. Use commit-helper skill
2. Conventional commit format
3. **ONLY commit in green state**
4. Announce: `💾 Committed: [message]`

## REVIEW Phase

1. Use code-reviewer skill
2. Produce plan to fix issues
3. Fix issues, re-run tests

## REFACTOR Phase (If Valuable)

**Invoke the `refactor` skill** for structured refactoring workflow.

**When to refactor:**
- Code duplication exists
- Code is unclear or overly complex
- Better abstraction is obvious
- Code smells identified

**Quick inline refactoring** (simple renames, extract variable):
1. Announce: `🔵 REFACTOR → [what you're improving]`
2. Make small changes
3. Run tests after each change
4. **If tests fail:** Revert immediately
5. Commit with: `refactor: [description]`

**Significant refactoring** (extract class, restructure modules):
Use the `refactor` skill for the full cycle with safety checklist.

**If no refactoring needed:** Announce `No refactoring needed`

## Choosing Next Test

**Progressive complexity:**
1. Simplest case (empty/zero/null)
2. Simple valid case (one element)
3. Another simple case (different input)
4. Boundary cases (min/max values)
5. Edge cases (special conditions)
6. Error cases (invalid input)

Announce: `Next test: [description of next behaviour]`
