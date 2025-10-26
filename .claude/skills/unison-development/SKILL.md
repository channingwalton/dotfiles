---
name: Unison Development
description: Comprehensive skill for writing, testing, and updating Unison code. Use when working with Unison language files (.u extension), UCM operations, or Unison projects. Follows TDD methodology with strict typechecking.
allowed-tools: Read, Write, Edit, mcp__unison__typecheck-code, mcp__unison__view-definitions, mcp__unison__search-definitions-by-name, mcp__unison__docs, mcp__unison__list-project-definitions, mcp__unison__get-current-project-context, mcp__unison__lib-install, mcp__unison__share-project-search, mcp__unison__share-project-readme, mcp__unison__list-project-libraries, mcp__unison__list-library-definitions, mcp__unison__list-local-projects, mcp__unison__list-project-branches, mcp__unison__search-by-type, mcp__unison__list-definition-dependencies, mcp__unison__list-definition-dependents
---

# Unison Development Skill

A comprehensive skill for writing, testing, and updating Unison code following best practices.

## Core Principles

1. **Test-Driven Development is MANDATORY**
2. **Typecheck** code. The MCP tool can typecheck source code itself as a string, OR a file path
3. **Always use fully qualified names in scratch.u**
4. **NEVER** create multiple scratch files, its too confusing
5. **NEVER** run UCM commands on the command line
6. After the UCM has been updated with changes in `*.u` files the
   contents of those files is redundant, and the user might delete them.

## Workflow

### 1. Research & Understanding

**Check Memory First:**
```
Search memory for: "unison language-reference"
If NOT found: Fetch from https://www.unison-lang.org/docs/#language-reference
```

**Understand the Codebase:**
- Use `mcp__unison__view-definitions` to see existing implementations
- Use `mcp__unison__search-definitions-by-name` to find related functions
- Use `mcp__unison__docs` to understand library functions
- Use `mcp__unison__list-project-definitions` to explore the project

### 2. Branch

1. Ask the user to create a feature branch

### 3. Write Tests First (TDD)

**Before implementing any feature:**
1. Write a comprehensive test that validates the desired behaviour
2. Test should cover:
   - Setup/preconditions
   - Action/operation
   - Assertions/verification
3. Use `test.verify`, `labeled`, and `ensureEqual`
4. Typecheck the test using `mcp__unison__typecheck-code`

**Example Test Structure:**
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

### 5. Implementation

**Understand the data structures:**
- View the type definitions (e.g., `Tables`, domain models)
- Understand composite keys (e.g., `(UserId, PredictionId)`)
- Know which tables/indices need updates

**Common Patterns:**
- `OrderedTable.tryRead.tx` - Read within transaction
- `OrderedTable.write.tx` - Write within transaction
- `OrderedTable.delete.tx` - Delete within transaction
- `toStream.keys.tx` - Stream all keys in transaction
- `rangeClosed.prefix.keys.tx` - Range query by prefix
- `Stream.filter`, `Stream.toList` - Stream operations
- `List.foreach` - Iterate with side effects

**Effect Handling:**
- `{Transaction}` - Database transactions
- `{Remote}` - Remote/distributed operations
- `{Exception}` - Error handling
- `{Random}` - Random number generation
- `{IO}` - I/O operations

### 6. Add to scratch.u with Fully Qualified Names

**CRITICAL: Use fully qualified names**

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

### 7. Final Typecheck

**Before completing:**
```
mcp__unison__typecheck-code with {"filePath": "/path/to/scratch.u"}
```

**Expected output:**
```
+ projectName.module.tests.newTest : '{IO, Exception} [Result]
~ projectName.module.existingFunction : Type -> Signature
```

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

## Checklist

Before finalising any Unison code:

- [ ] Searched memory for relevant context
- [ ] Reviewed existing implementations
- [ ] **Wrote test first** (TDD)
- [ ] Typechecked test successfully
- [ ] Implemented solution
- [ ] Typechecked implementation incrementally
- [ ] Added to scratch.u with **fully qualified names**
- [ ] Final typecheck shows `~` for modifications (not `+`)
- [ ] Test verifies the behaviour
- [ ] Updated memory with timestamp if needed

## Tools Reference

### Essential MCP Tools
- `mcp__unison__typecheck-code` - Validate code
- `mcp__unison__view-definitions` - See existing code
- `mcp__unison__search-definitions-by-name` - Find functions
- `mcp__unison__docs` - Read documentation
- `mcp__unison__list-project-definitions` - Explore project
- `mcp__unison__get-current-project-context` - Check project/branch

### File Operations
- Write code to scratch.u: `Write` tool with absolute path
- Always use: `/full/path/to/project/scratch.u`

## Example Session

1. **Understand requirement:** "Implement cascade deletes"
2. **Search memory:** Look for existing patterns
3. **View existing code:** `view-definitions` for current implementation
4. **Write test first:**
   - Create comprehensive test
   - Typecheck: `{"text": "test code"}`
   - Iterate until clean
5. **Implement solution:**
   - Write implementation
   - Typecheck: `{"text": "implementation code"}`
   - Iterate until clean
6. **Add to scratch.u:**
   - Use fully qualified names
   - Include both test and implementation
   - Final typecheck: `{"filePath": "scratch.u"}`
7. **Verify output:**
   - Check for `~` (modified) on existing functions
   - Check for `+` (added) on new tests
8. **Update memory** with timestamp

## Success Criteria

✅ All code typechecks successfully
✅ Tests written before implementation
✅ Fully qualified names in scratch.u
✅ Modified functions show `~` not `+`
✅ Comprehensive test coverage
✅ Memory updated with learnings
