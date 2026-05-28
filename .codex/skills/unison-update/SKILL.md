---
name: unison-update
description: Repair Unison definitions after `update-definitions` reports affected definitions that no longer typecheck. Use when an update response includes `sourceCodeUpdates` for broken dependents.
---

# Unison Update

The repair loop for when `mcp__unison__update-definitions` returns affected definitions that no longer typecheck.

## Trigger

The MCP server returns `sourceCodeUpdates` containing:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

It has placed the affected code in a temporary branch for you to fix.

## Workflow

1. Review every affected definition in the `sourceCodeUpdates` response.
2. Fix the type errors, updating signatures where needed, and preserve existing behaviour.
3. Include **every** fixed definition in a single `mcp__unison__update-definitions` call — any definition left out is removed from the codebase, so completeness here is not optional.
4. Repeat until the update succeeds.
