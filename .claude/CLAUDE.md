# Claude Configuration

## Core Behaviours

- Call me Channing
- **Never** be sycophantic
- **ALWAYS** be maximally concise — fewest words that convey the point, no filler, no preamble, no recap
- **ALWAYS** drop pleasantries
- **NEVER** restate what I just said or summarise what you're about to do — just do it
- **NEVER** add explanatory prose the user didn't ask for
- **ALWAYS** use British spelling
- **ALWAYS** use bash `date` when creating timestamps
- **NEVER** expand the scope of tasks
- **ALWAYS** put questions at the bottom of output so I can see them
  - Format: Bold **Question❓**
- **NEVER** assume that the user is always correct, push back if anything doesn't make sense
- **NEVER** assume that a question is a request to make changes unless it explicitly asks for a change

## Paths

Avoid using compound commands like `cd <path> && git ...`, and instead use directory options available
in the command like `git -C <path>` so that the user is prompted all the time.
Alternatively, run the commands sequentially.

## Tools (use when appropriate)

- **Vault skill** — notes, tasks, and context building
- **`devtool`** — unified build tool. Detects project type automatically. Run via Bash:
  - `devtool check` — compile + lint + test. Use when asked to "commit check" or before committing.
  - `devtool compile` — compile only. Use when asked "does it compile", "check compilation", or "build the project".
  - `devtool test [pattern]` — run tests, optional filter. Use when asked to "run tests" or "run this test".
  - `devtool lint` — lint only.
  - `devtool cpd <language> [directory]` — find duplicate code using PMD CPD. Use during code review or when asked to find duplicates.
  - Output is suppressed on success; on failure the full log is cat'd between `--- output ---` markers and the log file path is printed (no need to re-run). Set `DEVTOOL_VERBOSE=1` to stream live.
- Prefer LSP over Grep/Read for code navigation
  - After writing or editing code, check LSP diagnostics and fix errors before proceeding.
  - Use Grep or rg only when LSP isn't available or for text/pattern searches (comments, strings, config).
- ast-grep is installed. Reach for it when the *match condition itself is structural* and a text search can't express it without false positives (e.g. "useEffect missing deps", "catch blocks that swallow errors", "calls to X with a literal arg"), or for shape-based codemods (`-r`). Use `ast-grep --lang [language] -p '<pattern>'`; adjust `--lang` per language. It is syntactic, not type-aware — for "where is X defined / who calls it" use LSP, and for plain text-locate use rg. Do not lead with ast-grep for ordinary locate-then-read exploration; its iteration cost (standalone-parse traps, node kinds) only pays off on genuinely structural queries. When a `-p` pattern misbehaves, run `--debug-query=ast` to find the real node kind, then write a YAML rule (`kind`/`inside`/`regex`).

## Skill Discovery

- **ALWAYS** use the `/software-development` skill for software development tasks.
- **ALWAYS** use the **code-reviewer agent** for code reviews — never do ad-hoc reviews without it
- Check for relevant skills before performing tasks
- When user refers to `vault`, use the vault skill

## Task Notes

Tasks I work on are tracked as notes in my Obsidian vault at:

`~/Documents/Notes/Projects/<project>/Tasks/<YYYY-MM-DD HHMMSS> <ID> <title>.md`

The note is the canonical working memory for the task — *the current state of my thinking* (what we tried, what we rejected, where we got to). JIRA or GitHub holds the formal ticket.

When I reference a task note, use the `task` skill to resolve and route it, and `task-note-update` to capture decisions, Current State, or Open Question changes. Those skills own the section formats and the propose-then-write loop.

Conventions those skills don't hold:

- Read the linked ticket yourself — don't ask me to summarise it.
- If **Current State**, **Decision Log**, or **Open Questions** are missing from a note, offer to add them.
- Refer to people by full name as `[[@Firstname Surname]]`.

## Context discipline

- Prefer LSP/native navigation first; otherwise explore in two passes: locate first (Grep `files_with_matches`/`count`, `head_limit`, narrow glob), then read only the slice needed (Read with offset/limit around the match). Widen only if required.
- Never dump whole large/generated files or repo-wide content; search for the specific symbol/section.
- Diffs: `git diff --stat` / `--name-only` first, then `git diff -- <file>`.
- Logs: report the result on success, full error on failure (devtool already does this).

<!-- CODEGRAPH_START -->
## CodeGraph

My larger projects have a CodeGraph MCP server (`codegraph_*` tools) configured. CodeGraph is a tree-sitter-parsed knowledge graph of every symbol, edge, and file. Reads are sub-millisecond and return structural information grep cannot.

### When to prefer codegraph over native search

Use codegraph for **structural** questions — what calls what, what would break, where is X defined, what is X's signature. Use native grep/read only for **literal text** queries (string contents, comments, log messages) or after you already have a specific file open.

If no `.codegraph` dir exists in the project root, suggest running `codegraph init -i`. If one does exist, ensure its up-to-date with `codegraph sync`

| Question | Tool |
|---|---|
| "Where is X defined?" / "Find symbol named X" | `codegraph_search` |
| "What calls function Y?" | `codegraph_callers` |
| "What does Y call?" | `codegraph_callees` |
| "How does X reach/become Y? / trace the flow from X to Y" | `codegraph_trace` (one call = the whole path, incl. callback/React/JSX dynamic hops) |
| "What would break if I changed Z?" | `codegraph_impact` |
| "Show me Y's signature / source / docstring" | `codegraph_node` |
| "Give me focused context for a task/area" | `codegraph_context` |
| "See several related symbols' source at once" | `codegraph_explore` |
| "What files exist under path/" | `codegraph_files` |
| "Is the index healthy?" | `codegraph_status` |

### Rules of thumb

- **Answer directly — don't delegate exploration.** For "how does X work" / architecture questions, answer with 2-3 codegraph calls: `codegraph_context` first, then ONE `codegraph_explore` for the source of the symbols it surfaces. For a specific **flow** ("how does X reach Y") start with `codegraph_trace` from→to — one call returns the whole path with dynamic hops bridged — then ONE `codegraph_explore` for the bodies; don't rebuild the path with `codegraph_search` + `codegraph_callers`. Codegraph IS the pre-built index, so spawning a separate file-reading sub-task/agent — or running a grep + read loop — repeats work codegraph already did and costs more for the same answer.
- **Trust codegraph results.** They come from a full AST parse. Do NOT re-verify them with grep — that's slower, less accurate, and wastes context.
- **Don't grep first** when looking up a symbol by name. `codegraph_search` is faster and returns kind + location + signature in one call.
- **Don't chain `codegraph_search` + `codegraph_node`** when you just want context — `codegraph_context` is one call.
- **Don't loop `codegraph_node` over many symbols** — one `codegraph_explore` call returns several symbols' source grouped in a single capped call, while each separate node/Read call re-reads the whole context and costs far more.
- **Index lag — check the staleness banner, don't guess a wait.** When a codegraph response starts with "⚠️ Some files referenced below were edited since the last index sync…", the listed files are pending re-index — Read those specific files for accurate content. Files NOT in that banner are fresh and codegraph is authoritative for them. `codegraph_status` also lists pending files under "Pending sync".

### If `.codegraph/` doesn't exist

The MCP server returns "not initialized." Ask the user: *"I notice this project doesn't have CodeGraph initialized. Want me to run `codegraph init -i` to build the index?"*
<!-- CODEGRAPH_END -->
