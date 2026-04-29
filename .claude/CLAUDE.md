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
- Don't assume the user is always correct, push back if ideas, suggestions, requests don't make sense
- Before editing in response to a question, restate the intent in one sentence and only edit if confirmed. A question is not a request unless it explicitly asks for a change.

## Paths

Avoid using compound commands like `cd <path> && git ...`, and instead use directory options available
in the command like `git -C <path>` so that the user is prompted all the time.
Alternatively, run the commands sequentially.

## Tools (use when appropriate)

- **Fetch** — retrieve specific URLs
- **Sequential thinking** — genuinely complex multi-step reasoning
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

## Skill Discovery

- **ALWAYS** use the `/software-development` skill for software development tasks.
- **ALWAYS** use the **code-reviewer agent** for code reviews — never do ad-hoc reviews without it
- Check for relevant skills before performing tasks
- When user refers to `vault`, use the vault skill

## Task Notes

Tasks I work on are tracked as notes in my Obsidian vault at:

`~/Documents/Notes/Projects/<project>/Tasks/<YYYY-MM-DD HHMMSS> <ID> <title>.md`

The note is the canonical working memory for the task. JIRA or GitHub holds the formal ticket; the task note holds the *current state of my thinking* — what we tried, what we rejected, where we got to.

### When I reference a task note

1. Read the task note in full.
2. Read the JIRA or GitHub issue linked near the top (use the Atlassian or Github MCP if available; otherwise WebFetch the URL). Don't ask me to summarise the ticket — read it yourself.
3. Treat **Current State**, **Decision Log**, and **Open Questions** as the working context. If those sections don't exist in a task note, offer to add them.

#### While working — keep the task note current

Watch for these signals and **propose** an update — never write silently. Draft the change, show it to me, write on confirmation.

**Direction change, approach rejected, or trade-off made** → propose a Decision Log entry. Format:

```
- **YYYY-MM-DD** — <what changed>. **Why:** <reason>. **Rejected:** <alternative considered, with one-line why-not>.
```

Always run `date +%Y-%m-%d` via bash for the date — never hardcode. Insert newest-first at the top of the Decision Log list.

**Active approach changes** → propose a Current State rewrite. Current State is **overwrite-only** (never appended). Three to five sentences covering: where we are now, the active approach, what's blocking. Update the `*Updated: YYYY-MM-DD*` line.

**Open Question gets answered** → propose where the answer lands first, then remove the question:

- Decision Log if it shaped a choice.
- Current State if it's just information.
- New task / JIRA ticket if it's out of scope (leave a one-line pointer in Open Questions if it's load-bearing).

### Format rules

- One decision per Decision Log entry. If two decisions were made together, write two entries.
- The **Why** is mandatory. If you can't articulate it, ask me.
- Decision Log is append-only and dated. Don't edit or delete prior entries.
- Current State has no history — folded into the new version or dropped.
- Open Questions are ephemeral; they should empty over time.
- If you refer to people by full name use [[@Firstname Surname]]

### Anti-patterns

- Don't echo JIRA content into the task note. The note is for *the journey*; the ticket is for the formal record.
- Don't bundle a decision and its rationale into a prose paragraph. Keep the **Why:** / **Rejected:** labels — they make the log scannable months later.
- Don't lose still-relevant Current State when rewriting it. Fold what's still true into the new version; archive only what's now stale.
- Don't write entries autonomously. The Decision Log only has value if I trust it; that trust requires me to have seen every entry before it landed.
