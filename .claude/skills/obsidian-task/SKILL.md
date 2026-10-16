---
name: obsidian-task
description: "Resolve and operate on Channing's Obsidian vault task notes by frontmatter type. Use when the user references a task note or a Jira/GitHub issue tracked by a vault task, or asks to inspect or continue task context. Routes task-type values such as investigation, implementation, review, experiment, and note to the appropriate specialist skill."
---

# Task

Router for vault-backed task work. The task note is the canonical entry point.

## Resolve

1. Locate the task note under `~/Documents/Notes/Projects/<project>/Tasks/`; if the user names a Jira/GitHub issue, find the matching task note first.
2. Read the task note in full, then the notes it links to, one hop deep.
3. Read the linked Jira, GitHub, or Linear ticket yourself rather than asking the user to summarise it.
4. Read frontmatter and route by `task-type` (a few legacy notes use `task_type`; treat it the same). If missing, treat as `note`.
5. When resuming work and the note has a `## Next Session` block, take it as the starting instruction. If its date is older than Current State's `*Updated:*`, it is stale — ignore it and say so.

## Task Note Rules

Write to the task note only when the user asks for a change. For `Current State`, `Decision Log`, or `Open Questions`, use `obsidian-task-note-update`, which then writes directly and shows the result. If any of those three sections is missing, offer to add it.

In every section, including hand-written ones like `Design`, `Hypotheses`, or `Context`, follow the `obsidian-vault` skill's Writing notes rules.

## Frontmatter

- Default: `task-type: note`
- Investigation: `task-type: investigation` plus `investigation_root: ./<same-basename>/README.md`
- Experiment: `task-type: experiment` plus a `research:` wikilink to its research note

## Routes

- `task-type: investigation` - load the task note, linked ticket, and the dossier at `investigation_root` (or a sibling folder with the task note's basename; ask before creating or moving evidence); then use `investigation`, which owns the dossier and its links.
- `task-type: implementation` - load the task note and linked ticket; then use `software-development`.
- `task-type: review` - load the task note and linked PR/ticket; then run the host's native code review as `fix-loop` describes it for this host, reporting only. Use `fix-loop` itself when the task also asks for fixes.
- `task-type: experiment` - load the task note and its linked research note; use `obsidian-task-note-update` for capture and `obsidian-research-maintainer` for roll-up.
- `task-type: note` or missing - use `obsidian-vault` and `obsidian-task-note-update` as needed

If a task type is unknown, read the note and ask how to route it.
