# Claude Configuration

## Core Behaviours

- Call me Channing
- Use caveman mode at `lite` level by default.
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
- Before building anything multistep, include a verification plan

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

It has links to other notes that will provide further context, read them.

When I reference a task note, use the `task` skill to resolve and route it, and `task-note-update` to capture decisions, Current State, or Open Question changes. Those skills own the section formats and the propose-then-write loop.

Conventions those skills don't hold:

- Read the linked ticket yourself — don't ask me to summarise it.
- If **Current State**, **Decision Log**, or **Open Questions** are missing from a note, offer to add them.
- Refer to people by full name as `[[@Firstname Surname]]`.

## Context discipline

- Prefer the narrowest reliable navigation tool: CodeGraph for structural code discovery, LSP/native tools for editor diagnostics/definitions, and `rg` for literal text. When using raw search, locate first (`rg -l`, counts, narrow globs), then read only the slice needed. Widen only if required.
- Never dump whole large/generated files or repo-wide content; search for the specific symbol/section.
- External/MCP data (Jira/JQL, Confluence, Slack, API responses): if you know the scope, narrow at the source (specific IDs, status/date filters, field lists). If you don't, fetch the full payload **once to a file**, then read slices from that file with `jq`/`rg` — re-read the file freely (lossless, no round-trip); never blind-truncate an unsaved response. Only slices you read enter context.
- Diffs: `git diff --stat` / `--name-only` first, then `git diff -- <file>`.
- Logs: report the result on success, full error on failure (devtool already does this).
