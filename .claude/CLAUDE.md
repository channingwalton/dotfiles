# Claude Configuration

## Core Behaviours

- Get timestamps from bash `date`; you don't know the current date or time.
- Keep changes to what the task asks for. If you notice something else worth doing, mention it at the end instead of doing it.
- When I ask a question, describe a problem, or think out loud, the deliverable is your answer or assessment. Don't change anything until I ask for a change.
- Avoid using compound commands like `cd <path> && git ...`
  - Try to use directory options available in the command like `git -C <path>`
  - Alternatively, run the commands sequentially.
- **Vault skill** — notes, tasks, and context building
- **`devtool`** — unified build tool. Detects project type automatically. Run via Bash:
  - `devtool check` — compile + lint + test. Use when asked to "commit check" or before committing.
  - `devtool compile` — compile only. Use when asked "does it compile", "check compilation", or "build the project".
  - `devtool test [pattern]` — run tests, optional filter. Use when asked to "run tests" or "run this test".
  - `devtool lint` — lint only.
  - `devtool cpd [directory] [--format <language>] [--sorted]` — find duplicate code using jscpd. Use during code review or when asked to find duplicates. Directory defaults to `.`; all detected formats are scanned unless `--format` restricts to one; `--sorted` lists clones largest first.
- Search narrow before wide: locate with `rg -l`, a count, or a narrow glob, then read only the slice you need. After editing code, check LSP diagnostics if LSP is available.
- **ALWAYS** use the `/software-development` skill for software development tasks.
- **ALWAYS** use the **code-reviewer skill** (`Skill(code-reviewer)`, not an agent type) for code reviews — never do ad-hoc reviews without it
- When user refers to `vault`, use the vault skill
- Never dump whole large/generated files or repo-wide content; search for the specific symbol/section.
- External/MCP data (Jira/JQL, Confluence, Slack, API responses): if you know the scope, narrow at the source (specific IDs, status/date filters, field lists). If you don't, fetch the full payload **once to a file**, then read slices from that file with `jq`/`rg` — re-read the file freely (lossless, no round-trip); never blind-truncate an unsaved response. Only slices you read enter context.
- Diffs: `git diff --stat` / `--name-only` first, then `git diff -- <file>`.

## Obsidian Task Notes

Tasks I work on are tracked as notes in my Obsidian vault at:

`~/Documents/Notes/Projects/<project>/Tasks/<YYYY-MM-DD HHMMSS> <ID> <title>.md`

The note is the canonical working memory for the task — *the current state of my thinking* (what we tried, what we rejected, where we got to). JIRA or GitHub holds the formal ticket.

It has links to other notes that will provide further context, read them.

When I reference a task note, use the `task` skill to resolve and route it, and `task-note-update` to capture decisions, Current State, or Open Question changes. Those skills own the section formats and the write-then-show loop.

Conventions those skills don't hold:

- Read the linked ticket yourself — don't ask me to summarise it.
- If **Current State**, **Decision Log**, or **Open Questions** are missing from a note, offer to add them.
- Refer to people by full name as `[[@Firstname Surname]]`.

Note that xml needs to be escaped to avoid parsing errors in Obsidian: \<tag>
