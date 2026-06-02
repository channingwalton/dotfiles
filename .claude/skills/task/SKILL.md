---
name: task
description: "Resolve and operate on Channing's Obsidian vault task notes by frontmatter type. Use when the user references a task note, Jira/GitHub issue tracked by a vault task, asks to inspect or continue task context, or asks to update/capture task state. Routes task_type values such as investigation, implementation, review, and note to the appropriate specialist skill."
---

# Task

Router for vault-backed task work. The task note is the canonical entry point.

## Resolve

1. Locate the task note under `~/Documents/Notes/Projects/<project>/Tasks/`; if the user names a Jira/GitHub issue, find the matching task note first.
2. Read the task note in full.
3. Read linked Jira or GitHub issue if present.
4. Read frontmatter and route by `task_type`. If missing, treat as `note`.

## External Data

For investigation tasks, stage long ticket/PR descriptions, comment threads, or diffs into the dossier and reference by path rather than the task note.

## Task Note Rules

Do not write unless the user explicitly asks. For `Current State`, `Decision Log`, or `Open Questions`, use `task-note-update`.

## Frontmatter

- Default: `task_type: note`
- Investigation: `task_type: investigation` plus `investigation_root: ./<same-basename>/README.md`

If `investigation_root` is missing, look for a sibling folder with the same basename as the task note. Ask before creating or moving evidence.

## Routes

- `task_type: investigation` - load the task note, linked ticket, and `investigation_root`; then use `investigation`.
- `task_type: implementation` - load the task note and linked ticket; then use `software-development`.
- `task_type: review` - load the task note and linked PR/ticket; then use `code-reviewer`.
- `task_type: note` or missing - use `vault` and `task-note-update` as needed

If a task type is unknown, read the note and ask how to route it.

## Investigation Links

For investigation tasks:

- Frontmatter uses `investigation_root` for machine routing.
- Body links to the dossier README and key dossier files near the top link block or under `## Context` / `## Related`.
- Dossier details belong to the `investigation` skill.
