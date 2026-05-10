---
name: task
description: "Resolve and operate on Channing's Obsidian vault task notes by frontmatter type. Use when the user references a task note, Jira/GitHub issue tracked by a vault task, asks to inspect or continue task context, or asks to update/capture task state. Routes task_type values such as investigation, implementation, review, and note to the appropriate specialist skill."
---

# Task

Router for vault-backed task work. The task note is the canonical entry point; specialist skills own the actual work.

## Resolve

1. Locate the task note under `~/Documents/Notes/Projects/<project>/Tasks/`.
2. If the user names a Jira/GitHub issue, find the matching task note before using the formal ticket.
3. Read the task note in full.
4. Read linked Jira or GitHub issue if present.
5. Read frontmatter and route by `task_type`. If missing, treat as `note`.

## Task Note Rules

Do not write to the task note unless the user explicitly asks for a change.

For `Current State`, `Decision Log`, or `Open Questions` edits, use `task-note-update` and show the draft before writing unless the user explicitly asked you to make the edit.

The task note owns:

- `Current State` - current working view.
- `Decision Log` - approved task decisions.
- `Open Questions` - active unresolved questions.

## Frontmatter

Preferred default:

```yaml
task_type: note
```

Investigation tasks:

```yaml
task_type: investigation
investigation_root: ./<same-basename>/README.md
```

If `investigation_root` is missing, look for a sibling folder with the same basename as the task note. Ask before creating or moving evidence.

## Routes

- `task_type: investigation` - load the task note, linked ticket, and `investigation_root`; then use `investigation`.
- `task_type: implementation` - load the task note and linked ticket; then use `software-development`.
- `task_type: review` - load the task note and linked PR/ticket; then use `code-reviewer`.
- `task_type: note` or missing - use `vault` and `task-note-update` as needed.

If a task type is unknown, read the note and ask how to route it.

## Investigation Links

For investigation tasks:

- Frontmatter uses `investigation_root` for machine routing.
- Body links to the dossier README and key dossier files near the top link block or under `## Context` / `## Related`.
- Dossier details belong to the `investigation` skill.

Prefer Markdown links for sibling files with spaces:

```markdown
- [Investigation dossier](./<task-basename>/README.md)
- [Event log](./<task-basename>/event-log.md)
- [Manifest](./<task-basename>/manifest.md)
- [Task note](../<task-basename>.md)
```

Use WikiLinks for semantic note links elsewhere in the vault.
