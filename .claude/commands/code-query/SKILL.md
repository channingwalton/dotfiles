---
name: code-query
description: Search the codebase and Obsidian vault together for relevant implementation and project context. Use when the user asks how something works, where it is implemented, or wants related notes alongside code results.
---

# Code Query

Answer a "how does X work / where is X" question from **both** the code and the vault. The
vault half is the point — code search alone misses the decisions, tickets and topic notes
that explain why the code is the way it is.

## Usage

```
/code-query <search-term>
```

`$ARGUMENTS` is the search term or question.

## Actions

1. Search the codebase. For Unison projects use the `unison` MCP server; otherwise locate
   first (`rg -l`, narrow globs) and read only the slice needed.
2. Search the vault for related context — task notes, Topics, Events — via the `vault` skill.
3. Return consolidated results:
   - code locations as `file:line`
   - related vault notes as wikilinks
   - a short summary tying the two together

## Examples

```
/code-query authentication flow
/code-query how errors are handled
/code-query database connection
```
