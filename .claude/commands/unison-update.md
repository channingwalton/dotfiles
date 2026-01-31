# Unison Update

Triggered when `mcp__unison__update-definitions` returns affected definitions that no longer typecheck.

## Context

When the MCP server returns `sourceCodeUpdates` containing:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

## Workflow

1. Review all affected definitions in the `sourceCodeUpdates` response
2. Fix all type errors and update signatures as needed
3. Include ALL fixed definitions in a single `mcp__unison__update-definitions` call
4. Repeat until update succeeds

## Critical Rules

- **DO NOT omit functions** — they will be removed from the codebase
- Fix ALL affected definitions together in one update call
- Repair by fixing type mismatches or updating signatures
- Preserve all existing functionality
