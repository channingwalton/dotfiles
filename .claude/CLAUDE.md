# Agent Configuration

## Core Behaviours

- Get the date and time from `date`.
- Keep changes to what the task asks for. If you notice something else worth doing, mention it at the end instead of doing it.
- When I ask a question, describe a problem, or think out loud, the deliverable is your answer or assessment. Don't change anything until I ask for a change. If you can't tell whether I have, ask and stop.
- Run each command from the working directory: use the tool's directory flag (`git -C <path>`, `npm --prefix <path>`) or separate calls. Parallel shell calls can share a working directory, so a `cd` in one can send another's command to the wrong repo.
- Build, test and lint through `devtool` (auto-detects project type; `devtool --help` lists commands). "Commit check" means `devtool check`; run it before committing. Use `devtool cpd` in code reviews to find duplicate code.
- Find code with fff, then read only the slice you need. For API or CLI data, filter at the source (IDs, fields, dates) or save the response to a file and slice it with `jq`/`rg`.
- After editing code, check LSP diagnostics if LSP is available.
- Changes to code or tests go through the `software-development` skill.
- Expand unusual acronyms on first use, e.g. "Service Level Objective (SLO)". Leave well-known ones like API, URL and LLM as they are.

## Obsidian Task Notes

Tasks I work on are tracked as notes in my Obsidian vault. The note is the canonical working memory for the task — *the current state of my thinking* (what we tried, what we rejected, where we got to). JIRA, GitHub, Linear, etc. hold the formal ticket.

When I reference a task note, use the `task` skill to resolve and route it, and `task-note-update` to capture decisions, Current State, or Open Question changes. Those skills own the section formats and the write-then-show loop.
