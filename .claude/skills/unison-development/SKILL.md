---
name: Unison Development
description: Comprehensive skill for writing, testing, and updating Unison code. Use when working with Unison language files (.u extension), UCM operations, or Unison projects. Follows TDD methodology with strict typechecking.
allowed-tools: Read, Write, Edit, mcp__unison__typecheck-code, mcp__unison__view-definitions, mcp__unison__search-definitions-by-name, mcp__unison__docs, mcp__unison__list-project-definitions, mcp__unison__get-current-project-context, mcp__unison__lib-install, mcp__unison__share-project-search, mcp__unison__share-project-readme, mcp__unison__list-project-libraries, mcp__unison__list-library-definitions, mcp__unison__list-local-projects, mcp__unison__list-project-branches, mcp__unison__search-by-type, mcp__unison__list-definition-dependencies, mcp__unison__list-definition-dependents
dependencies:
  - development
  - test-driven-development
  - code-reviewer
---

# Unison Development Skill

A comprehensive skill for writing, testing, and updating Unison code following best practices.

## Dependencies

### Required Skills
- **development** - Base development workflow
- unison MCP server

## Core Principles

0. Code is not tracked in GIT or external version control systems, it is stored by the Unison Code Manager (ucm)
1. **Test-Driven Development is MANDATORY** using the Test Driven Development skill but be aware
  that after updating the ucm with new code, the ucm may go into "Handling typecheck errors after update"
2. **Typecheck** code. The MCP tool can typecheck source code itself as a string, OR a file path
3. **Always use fully qualified names in scratch.u**
4. **NEVER** create multiple scratch files, its too confusing
5. **NEVER** run UCM commands on the command line
6. After the UCM has been updated check for "Handling typecheck errors after update" in scratch.u
7. If the ucm is in "Handling typecheck errors after update" mode DO NOT delete functions in `scratch.u`, doing so will remove the functions from the code manager.

## Workflow

Use the Development skill enhanced with the following Unison specific features:

### 1. Research & Understanding

**Understand the Codebase:**
- Use `mcp__unison__view-definitions` to see existing implementations
- Use `mcp__unison__search-definitions-by-name` to find related functions
- Use `mcp__unison__docs` to understand library functions
- Use `mcp__unison__list-project-definitions` to explore the project

### 2. Branch

1. Ask the user to create a feature branch before beginning work

### 3. Use the Development Skill

1. Use `test.verify`, `labeled`, and `ensureEqual`
2. Typecheck the test using `mcp__unison__typecheck-code`

**Example Test Structure for an IO test:**
```unison
projectName.module.tests.featureTest : '{IO, Exception} [Result]
projectName.module.tests.featureTest = do
  test.verify do
    labeled "Description of what is being tested" do
      use test ensureEqual

      -- Setup
      testData = createTestData()

      -- Action
      result = performOperation testData

      -- Verification
      ensureEqual result expectedValue
```

### 4. Typecheck Incrementally

**Always typecheck before finalising code:**
```
Use: mcp__unison__typecheck-code with {"text": "code here"}
```

**Iterate until clean:**
- Fix type errors
- Add missing imports/uses
- Ensure function signatures match
- Verify effects are correct ({Transaction}, {Remote}, etc.)

### 5. Add to scratch.u with Fully Qualified Names

**CRITICAL: Use fully qualified names to avoid creating duplicate functions**

❌ **WRONG:**
```unison
deletePredictionImpl : Tables -> PredictionId -> ...
```

✅ **CORRECT:**
```unison
foggyball.store.FoggyBallStore.default.deletePredictionImpl : Tables -> PredictionId -> ...
foggyball.store.FoggyBallStore.default.deletePredictionImpl tables id = ...
```

**Why:** Without fully qualified names, Unison treats it as a new function instead of modifying the existing one.

**Typecheck output indicates:**
- `+` (added) - New definition
- `~` (modified) - Updated existing definition

**Verify you see `~` for modifications!**

### 6. Final Typecheck

**Before completing:**
```
mcp__unison__typecheck-code with {"filePath": "/path/to/scratch.u"}
```

**Expected output:**
```
+ projectName.module.tests.newTest : '{IO, Exception} [Result]
~ projectName.module.existingFunction : Type -> Signature
```

### 7. Handling typecheck errors after update

The UCM will add the following comment to scratch.u and add functions that need fixing after changes
have been added to the codebase:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

- Repair the issues
- **DO NOT** delete functions from `scratch.u` in this phase as they will be removed from the codebase
- Ask the user to verify your changes by checking the output of the UCM

### 8. Update memory

Update your memory about the change and anything learnt during development

## Common Pitfalls

### 1. Pipe Operator Syntax
❌ **WRONG:**
```unison
postKeys = rangeClosed.prefix.keys.tx table prefix id id
  |> Stream.toList
```

✅ **CORRECT:**
```unison
postKeys = (rangeClosed.prefix.keys.tx table prefix id id |> Stream.toList)
```

### 2. List.foreach Argument Order
❌ **WRONG:**
```unison
List.foreach items (item -> doSomething item)
```

✅ **CORRECT:**
```unison
List.foreach (item -> doSomething item) items
```

### 3. Pattern Matching Tuples
✅ **CORRECT:**
```unison
Stream.filter (cases (_, predId) -> predId === id)
```

### 4. Effect Signatures
Ensure function signatures include all required effects:
```unison
myFunction : Type ->{Transaction, Exception, Random} Result
```


## Success Criteria

✅ All code typechecks successfully
✅ Tests written before implementation
✅ Fully qualified names in scratch.u
✅ Modified functions show `~` not `+`
✅ Comprehensive test coverage
✅ Memory updated with learnings
