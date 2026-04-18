---
name: code-query
description: Search the codebase and Obsidian vault for relevant implementation and project context. Use when the user asks how something works, where it is implemented, or wants related notes alongside code results.
---

# Code Query

Search codebase and vault documents for relevant information.

## Workflow

1. Invoke the `vault` skill when project notes are likely to add useful context
2. For Unison projects use the Unison MCP server to search the codebase; otherwise search files using `rg` and direct file reads for code matches
3. Search vault notes for related context and documentation
4. Return consolidated results with:
   - Relevant code locations (`file:line`)
   - Related vault notes
   - Summary of findings

## Example Requests

- "code-query authentication flow"
- "code-query how errors are handled"
- "code-query database connection"
