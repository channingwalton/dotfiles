---
name: unison-development
description: Write, test, update, and repair Unison code using Unison MCP tools when available. Use when working with Unison language files (.u extension), UCM operations, Unison projects, or when `update-definitions` returns `sourceCodeUpdates` for affected definitions that no longer typecheck. An extension to the software-development skill.
---

# Unison Development

Extends `software-development`. Use the Unison MCP tools for every operation when they are available in the session. If they are missing, stop and say so rather than falling back to ad hoc UCM commands — the command line bypasses the safeguards below.

## Why Unison is different

Unison stores code in the UCM codebase, not in files or Git. Two consequences drive everything else:

- The CLI and `scratch.u` files are not the source of truth, so editing or running code outside the MCP tools desyncs your work from the codebase. Drive everything through the MCP tools directly — the one exception is branch creation.
- Git never holds Unison code. A git commit won't capture your changes and `commit-commands` don't apply, so don't reach for them.

Work in a branch, and use fully qualified names when writing code so references resolve unambiguously.

## Branch first

Before any code change, create a branch with the MCP server tool — working outside a branch mutates shared state. Use a descriptive name like `extract-domain-service` or `fix-login-bug`.

## Workflow

1. **Explore**: `view-definitions`, `search-definitions-by-name`, `list-project-definitions` to understand existing code before writing.
2. **Typecheck**: `mcp__unison__typecheck-code` to validate before updating.
3. **Update**: `mcp__unison__update-definitions` to apply changes to the codebase.
4. **Test**: `mcp__unison__run-tests` to verify.

## When `update-definitions` reports broken dependents

The call returns `sourceCodeUpdates` when affected definitions no longer typecheck:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

The server has placed that code in a temporary branch for you to fix. Repair loop:

1. Review **every** affected definition in the `sourceCodeUpdates` response.
2. Fix the type errors, updating signatures where needed, preserving existing behaviour.
3. Include **every** fixed definition in a single `update-definitions` call — any definition left out is removed from the codebase, so completeness here is not optional.
4. Repeat until the update succeeds.

## Modifying abilities

Changing an ability breaks its dependents, so repair them in the same update. View the ability and its `default` handler, use `list-definition-dependents` to find every caller, and include the ability and all dependents in one `update-definitions` call.

## Done when

- Code typechecks via the MCP tools.
- Tests pass via `mcp__unison__run-tests`.
- Fully qualified names are used throughout.
