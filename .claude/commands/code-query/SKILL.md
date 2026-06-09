---
name: code-query
description: Search the codebase and Obsidian vault for relevant implementation and project context. Use when the user asks how something works, where it is implemented, or wants related notes alongside code results.
---

# Code Query

Search codebase and vault documents for relevant information.

## Usage

```
/code-query <search-term>
```

Where `$ARGUMENTS` is the search term or question to investigate.

## Actions

1. Invoke the `vault` skill
2. Search the codebase: for unison projects use the unison MCP server; if `.codegraph/` exists use the CodeGraph routing below; otherwise search files using Grep/Glob
3. Search vault notes for related context and documentation
4. Return consolidated results with:
   - Relevant code locations (file:line)
   - Related vault notes
   - Summary of findings

## CodeGraph routing

When `.codegraph/` exists, route by question shape:

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "How does X reach/become Y? / trace the flow" | `codegraph_trace` (one call = the whole path, incl. callback/React/JSX dynamic hops) |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

Rules of thumb:

- **Answer directly — don't delegate exploration.** For "how does X work" questions: `codegraph_context` first, then ONE `codegraph_explore` for the source it surfaces. For flows, `codegraph_trace` from→to returns the whole path in one call — don't rebuild it with `codegraph_search` + `codegraph_callers`. CodeGraph IS the pre-built index; grep+read loops repeat its work at higher cost.
- **Trust indexed results** — don't re-grep them unless exhaustive textual coverage matters (strings, comments, config, generated files — those are `rg`'s surfaces).
- **Don't grep first** for a symbol by name; `codegraph_search` returns kind + location + signature in one call.
- **Don't chain search + node** for context (`codegraph_context` is one call) and don't loop `codegraph_node` over many symbols (one `codegraph_explore` is cheaper).
- **Hybrid rule**: for broad "find X" searches, CodeGraph first, then one targeted `rg` pass when the term also appears as text or results look sparse.
- **Staleness banner**: files listed as pending re-index → Read those files; everything else is fresh.
- If the MCP server says "not initialized", ask before running `codegraph init -i`; if declined, locate-then-read with `rg`.

## Examples

```
/code-query authentication flow
/code-query how errors are handled
/code-query database connection
```
