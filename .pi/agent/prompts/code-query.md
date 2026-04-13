# Code Query

Search codebase and vault documents for relevant information.

## Usage

```
/code-query <search-term>
```

Where `$ARGUMENTS` is the search term or question to investigate.

## Actions

1. Invoke the `vault` skill
2. For unison projects use the unison MCP server to search the codebase, otherwise search files using Grep/Glob for code matches
3. Search vault notes for related context and documentation
4. Return consolidated results with:
   - Relevant code locations (file:line)
   - Related vault notes
   - Summary of findings

## Examples

```
/code-query authentication flow
/code-query how errors are handled
/code-query database connection
```
