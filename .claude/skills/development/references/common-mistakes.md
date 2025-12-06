# Common TDD Mistakes

## ❌ Writing Production Code First

- **Never** write production code before failing test
- Always resist this urge

## ❌ Writing Multiple Tests at Once

- One test at a time only
- Make it green before writing next test

## ❌ Writing Too Much Code

- Only write enough to pass current test
- Don't anticipate future tests

## ❌ Not Running Tests

- Run tests after every change
- Verify green state before proceeding

## ❌ Skipping Commits

- Commit every green state
- Provides safe revert point

## ❌ Testing Implementation

- Test behaviour/interface, not implementation
- Tests should survive refactoring
