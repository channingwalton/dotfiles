---
name: code-query
description: Search the codebase and Obsidian vault for relevant implementation and project context. Use when the user asks how something works, where it is implemented, or wants related notes alongside code results.
---

# Code Query

Search codebase and vault documents for relevant information.

## Usage

Use the user's search term or question as the query. Resolve the repository root and vault path from the current session before searching.

## Actions

1. Use the `vault` skill for note context.
2. For Unison projects use the Unison MCP server if available; otherwise search files with `rg`.
3. Search vault notes for related context and documentation
4. Return consolidated results with:
   - Relevant code locations (file:line)
   - Related vault notes
   - Summary of findings

## Examples

- `authentication flow`
- `how errors are handled`
- `database connection`
