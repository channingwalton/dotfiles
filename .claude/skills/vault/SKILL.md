---
name: vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/` (vault name: `Notes`)

## Principles

1. Treat the vault as Markdown files under `~/Documents/Notes`; do not use the `obsidian` CLI.
2. Use WikiLinks for semantic note links, especially dates: `[[YYYY-MM-DD]]`.
3. Use `date` for all timestamps; never hardcode placeholders.
4. New task notes start with `status: open`.
5. Read before writing, preserve existing structure, and avoid whole-file rewrites unless unavoidable.

## Core Paths

| Type | Path |
|---|---|
| Tasks | `Projects/<project>/Tasks/<YYYY-MM-DD HHMMSS> <ID> <title>.md` |
| Daily notes | `Journal/Daily Notes/<YYYY>/<YYYY-MM>/<YYYY-MM-DD>.md` |
| Weekly notes | `Journal/Weekly Notes/<YYYY>-W<WW>.md` |
| Events | `Projects/<project>/Events/<YYYY-MM-DD> <event type> <title>.md` |
| Glossary | `Projects/<project>/Glossary/` |
| Topics | Projects/<projects>/Topics |
| Research | `Projects/<project>/Research/<Title>.md` |
| Templates | `Vault Metadata/Templates/` |

## Shell Rules

```bash
VAULT="$HOME/Documents/Notes"
date +"%Y-%m-%d %H%M%S"    # task filename
date +"%Y-%m-%d %H:%M"      # log entry header
date -Iseconds              # frontmatter
```

Use normal Unix tools (`rg`, `find`, `sed`, `awk`, `perl`, `stat`, `mkdir`, `cp`, `mv`, `printf`). Quote paths because project names contain spaces.

## Task Notes

When creating a task note:

- Use `date +"%Y-%m-%d %H%M%S"` for the filename timestamp.
- Include the external ID when one exists, e.g. `RH-1234`.
- Create the note directly with required frontmatter and sections.
- If using a template, inspect `Vault Metadata/Templates/` and choose the relevant vault template.
- Keep knowledge notes out of `Tasks/`; extract reusable steps into `Recipes/`.

Task section ownership:

- `Current State`, `Decision Log`, and `Open Questions` are maintained through `task-note-update`.
- If those sections are missing from an active task note, offer to add them.
- Do not write task-note updates unless the user explicitly asks; draft first where `task-note-update` requires it.

## Linking

Link if it improves navigation, not just because a term matches.

Use aliased WikiLinks for ticket references:

```markdown
[[2026-02-13 141534 RH-6949 Performance issue|RH-6949]]
```

Every mention of a Jira issue number in summaries, blockers, carryover, or task updates should be a WikiLink to its task note when a matching note exists.

## Capture Heuristics

**Worth capturing when:** principle applies across contexts, caused debugging time, method that saves time later, non-obvious choice with reasoning worth preserving, link to documentation.

**Where to capture:**

| Destination | When |
|-------------|------|
| **Existing note** | Extends/refines an existing topic (search first) |
| **New note** | Substantial, standalone, referenceable |
| **Task log only** | One-off detail that won't generalise |
| **Project recipe** | Repeatable steps specific to this project |
