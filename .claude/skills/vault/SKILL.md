---
name: vault
description: Read and write notes in the Obsidian vault — paths, filename conventions, linking rules, and where a given kind of note belongs. Use when reading or writing vault notes, capturing knowledge, defining a domain term, or building context from notes.
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
| Topics | `Projects/<project>/Topics/<Topic>.md` |
| Research | `Projects/<project>/Research/<Title>.md` |
| Templates | `Vault Metadata/Templates/` |

Evergreen, project-independent knowledge lives in the top-level domain folders
(`Development/`, `Artificial Intelligence/`, `Process/`, `Knowledge management/`, ...), not
in a project's `Topics/`. Moving a note there is the `obsidian-topic-maintainer` graduation
step.

Section ownership: `Current State`, `Decision Log`, `Open Questions`, and `Next Session` on a
task note belong to `task-note-update`; routing a task note by `task-type` belongs to `task`.
Do not write those sections from here.

## Shell Rules

```bash
VAULT="$HOME/Documents/Notes"
date +"%Y-%m-%d %H%M%S"    # task filename
date +"%Y-%m-%d %H:%M"      # log entry header
date -Iseconds              # frontmatter
```

Use normal Unix tools (`rg`, `find`, `sed`, `awk`, `perl`, `stat`, `mkdir`, `cp`, `mv`, `printf`). Quote paths because project names contain spaces.

## Linking

Link if it improves navigation, not just because a term matches.

Use aliased WikiLinks for ticket references:

```markdown
[[2026-02-13 141534 RH-6949 Performance issue|RH-6949]]
```

Every mention of a Jira issue number in summaries, blockers, carryover, or task updates should be a WikiLink to its task note when a matching note exists.

## Domain terms

There is no `Glossary/` folder. A domain term is a short note in the project's `Topics/`,
sitting alongside the longer hubs — same folder, same shape, just briefer. Search first: if
the concept already has a hub, extend it rather than adding a second note, because duplicate
basenames make links ambiguous.

```markdown
---
aliases:
  - <abbreviation or singular/plural variant>
---

# [[Term]]

<Plain-language definition, one or two sentences, wikilinking the concepts it leans on.
Do not define jargon with more jargon.>

<Optional: a concrete example, or how it differs from the term it is confused with.>

## See also
[[Related]] · [[Related]]
```

Give every abbreviation an `aliases:` entry so existing links keep resolving. `obsidian-topic-maintainer` owns hub shape, alias collisions, and promotion to a domain folder.
