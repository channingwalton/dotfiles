---
name: unison-development
description: Write, test, update, and repair Unison code using Unison MCP tools when available. Use when working with Unison language files (.u extension), UCM operations, Unison projects, or when `update-definitions` returns `sourceCodeUpdates` for affected definitions that no longer typecheck. An extension to the software-development skill.
---

# Unison Development

For implementation, extends `software-development`. Use Unison MCP tools for codebase operations in this workflow. If they are unavailable, report the missing capability and stop before codebase mutations; read-only explanations and local file inspection can still proceed.

## Why Unison is different

The UCM codebase holds the active definitions. Scratch `.u` files contain candidate definitions that enter the codebase through an update.

- MCP-only codebase operations are a workflow constraint here, preserving the update and dependent-repair procedure below. This includes branch creation.
- A Git commit of scratch files does not record a UCM codebase update; verify changes through the codebase tools.

Work in a branch, and use fully qualified names when writing code so references resolve unambiguously.

## Branch first

Before the first code change, select the branch authorised for this task or create one with the MCP server tool. Use a descriptive name like `extract-domain-service` or `fix-login-bug`, and verify the active branch before updating definitions.

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
