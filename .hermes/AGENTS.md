# Hermes

## Core Behaviours

- **ALWAYS** use bash `date` when creating timestamps
- **NEVER** expand the scope of tasks
- **ALWAYS** put questions at the bottom of output so I can see them
  - Format: Bold **Question❓**
- **NEVER** assume that a question is a request to make changes unless it explicitly asks for a change

## Tools (use when appropriate)

- **`devtool`** — unified build tool. Detects project type automatically. Run via Bash:
  - `devtool check` — compile + lint + test. Use when asked to "commit check" or before committing.
  - `devtool compile` — compile only. Use when asked "does it compile", "check compilation", or "build the project".
  - `devtool test [pattern]` — run tests, optional filter. Use when asked to "run tests" or "run this test".
  - `devtool lint` — lint only.
  - `devtool cpd <language> [directory]` — find duplicate code using PMD CPD. Use during code review or when asked to find duplicates.
  - Output is suppressed on success; on failure the full log is cat'd between `--- output ---` markers and the log file path is printed (no need to re-run). Set `DEVTOOL_VERBOSE=1` to stream live.

## Context discipline

- Never dump whole large/generated files or repo-wide content; search for the specific symbol/section.
- External/MCP data (Jira/JQL, Confluence, Slack, API responses): if you know the scope, narrow at the source (specific IDs, status/date filters, field lists). If you don't, fetch the full payload **once to a file**, then read slices from that file with `jq`/`rg` — re-read the file freely (lossless, no round-trip); never blind-truncate an unsaved response. Only slices you read enter context.
- Diffs: `git diff --stat` / `--name-only` first, then `git diff -- <file>`.

