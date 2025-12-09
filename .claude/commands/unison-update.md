# Unison Update

Triggered after editing Unison code when UCM creates an update branch.

## Context

When you update definitions in Unison and the ucm creates a new branch
named `update-<original branch>`, and the `scratch.u` contains the
text:

```
-- The definitions below no longer typecheck with the changes above.
-- Please fix the errors and try `update` again.
```

## Workflow

1. typecheck `scratch.u` with the mcp server
2. Repair issues

## Critical Rules

- **DO NOT delete functions** — this removes them from the codebase entirely
- Repair by fixing type mismatches or updating signatures
- Preserve all existing functionality
