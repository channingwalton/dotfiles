---
name: Unison Development
description: Write, test, and update Unison code using MCP tools. Use when working with Unison language files (.u extension), UCM operations, or Unison projects. Enforces TDD with strict typechecking via development skill.
---

# Unison Development

Uses `development` skill for TDD workflow, enhanced with Unison-specific tooling.

## Core Principles

1. **NEVER run UCM commands on command line** — use MCP tools only
2. Code stored by Unison Code Manager, not Git
3. **TDD is mandatory** — be aware UCM may enter "Handling typecheck errors after update"
4. Always use fully qualified names in scratch.u
5. Never create multiple scratch files

## Workflow

### 1. Research & Understanding

- `mcp__unison__view-definitions` — see implementations
- `mcp__unison__search-definitions-by-name` — find related functions
- `mcp__unison__docs` — understand library functions
- `mcp__unison__list-project-definitions` — explore project

### 2. Branch

Ask user to create feature branch before beginning.

### 3. Write Tests First

Use `test.verify`, `labeled`, and `ensureEqual`:

```unison
projectName.module.tests.featureTest : '{IO, Exception} [Result]
projectName.module.tests.featureTest = do
  test.verify do
    labeled "Description" do
      use test ensureEqual
      result = performOperation testData
      ensureEqual result expectedValue
```

### 4. Typecheck Incrementally

```
mcp__unison__typecheck-code with {"text": "code here"}
```

Iterate until clean — fix type errors, add imports, verify effects.

### 5. Add to scratch.u with Fully Qualified Names

❌ **WRONG:** `deletePredictionImpl : Tables -> ...`
✅ **CORRECT:** `foggyball.store.FoggyBallStore.default.deletePredictionImpl : Tables -> ...`

**Why:** Without FQN, Unison creates new function instead of modifying.

Typecheck output:
- `+` (added) — new definition
- `~` (modified) — updated existing

**Verify you see `~` for modifications!**

### 6. Final Typecheck

```
mcp__unison__typecheck-code with {"filePath": "/path/to/scratch.u"}
```

### 7. UPDATE MODE: Handling Typecheck Errors

If UCM adds this comment after update:
```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

**CRITICAL:**
- **DO NOT** delete functions from scratch.u — they will be removed from codebase
- Repair broken code, typechecking as you go
- Ask user to verify via UCM output
- After successful update, you may remove code from scratch.u

### 8. Update Memory

Store learnings about the change.

## Common Pitfalls

See `references/pitfalls.md` for syntax gotchas.
