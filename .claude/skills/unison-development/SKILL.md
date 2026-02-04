---
name: Unison Development
description: Write, test, and update Unison code using the Unison MCP tool. Use when working with Unison language files (.u extension), UCM operations, or Unison projects. An extension to the XP skill.
---

# Unison Development

- Uses `xp` skill.
- Use the Unison MCP server commands for all operations.

## Core Principles

1. **ALWAYS** work in branches - create one with an appropriate name
2. **NEVER run UCM commands on the command line** — use MCP tools only (exception: branch creation)
3. **NEVER use scratch.u files** — use MCP tools directly
4. **Code is stored by the UCM, NOT Git** — NEVER suggest git commits for code changes
5. **NEVER use commit-helper agent** — Unison code is managed by UCM
6. **Always** use fully qualified names when writing code
7. Use the MCP tools to explore the codebase before writing code

## Branch Creation (MANDATORY FIRST STEP)

**Before making any code changes**, create a branch with the MCP server tool.
Use descriptive branch names like `extract-domain-service` or `fix-login-bug`.

## Workflow

1. **Explore**: Use `view-definitions`, `search-definitions-by-name`, `list-project-definitions` to understand existing code
2. **Typecheck**: Use `mcp__unison__typecheck-code` to validate code before updating
3. **Update**: Use `mcp__unison__update-definitions` to apply changes directly to the codebase
4. **Test**: Use `mcp__unison__run-tests` to verify changes

## Handling Typecheck Errors During Update

When `update-definitions` returns affected definitions that no longer typecheck:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

**CRITICAL:**

- The MCP server creates a temporary branch with affected code in `sourceCodeUpdates`
- Fix ALL affected definitions and include them in the next `update-definitions` call
- **DO NOT** omit functions — they will be removed from codebase
- Include all fixes in a single `update-definitions` call

## Modifying Abilities

When modifying abilities, include all affected dependents in the same update:

1. View the ability and its `default` handler
2. Use `list-definition-dependents` to find all callers
3. Update the ability AND all dependents together in one `update-definitions` call

## Success Criteria

- All code typechecks successfully via MCP tools
- Tests pass via `mcp__unison__run-tests`
- Fully qualified names used throughout

