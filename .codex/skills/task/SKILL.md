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

Do not write to the task note unless the user explicitly asks for a change. For Current State, Decision Log, or Open Questions edits, use `task-note-update` and show the draft before writing.

## Frontmatter

Preferred fields:

```yaml
task_type: note
```

For investigations:

```yaml
task_type: investigation
investigation_root: ./<same-basename>/README.md
```

If `investigation_root` is missing for an investigation task, look for a sibling folder with the same basename as the task note. Ask before creating or moving evidence.

## Routes

- `task_type: investigation` — load the task note, linked ticket, and sibling dossier; then use `investigation`.
- `task_type: implementation` — load the task note and linked ticket; then use `software-development`.
- `task_type: review` — load the task note and linked PR/ticket; then use `code-reviewer`.
- `task_type: note` or missing — use `vault` and `task-note-update` as needed.

If a task type is unknown, read the note and ask how to route it.

## Investigation Dossiers

The dossier should live next to the task note:

```text
Tasks/
  <task-basename>.md
  <task-basename>/
    README.md
    manifest.md
    timeline.md
    reasoning-log.md
    data-lineage.md
    run-log.md
    task-note-evidence.md
    open-questions.md
    case-studies.md
    Data/
```

Keep bulky raw artefacts outside the vault only when needed; index them from `manifest.md` with stable paths, counts, checksums, and provenance.

## Links

For investigation tasks, keep both filesystem routing and Obsidian navigation:

- Task frontmatter uses `investigation_root` for machine routing.
- Task body links to the dossier README, usually under `## Context` or `## Related`.
- Dossier README links back to the task note and links to every top-level dossier file.
- Each top-level dossier Markdown file links back to the task note and dossier README.
- Task `## Decision Log` is canonical for approved task decisions.
- Dossier `reasoning-log.md` records evidence-backed investigation reasoning and links to evidence; do not make it a second Decision Log.
- `manifest.md` indexes evidence paths; Markdown files explain why the evidence matters.

Prefer Markdown links for sibling files with spaces:

```markdown
- [Investigation dossier](./<task-basename>/README.md)
- [Task note](../<task-basename>.md)
```

Use WikiLinks for semantic note links elsewhere in the vault.
