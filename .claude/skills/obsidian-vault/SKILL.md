---
name: obsidian-vault
description: Read and write notes in the Obsidian vault — paths, filename conventions, frontmatter, linking rules, and where a given kind of note belongs. Use when reading or writing vault notes, capturing knowledge, defining a domain term, or building context from notes.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/` (vault name: `Notes`)

## Principles

1. Treat the vault as Markdown files under `~/Documents/Notes`; do not use the `obsidian` CLI.
2. Use WikiLinks for semantic note links, especially dates: `[[YYYY-MM-DD]]`.
3. Read before writing, preserve existing structure, and avoid whole-file rewrites unless unavoidable.
4. In prose, escape `<` as `\<` so Obsidian doesn't parse it as HTML. Leave code spans and fenced blocks as they are; a backslash there renders literally.
5. Hubs are queries. `Topics.md`, `Events.md`, a project note's Research section and a Topic's list of its Events are Dataview tables over frontmatter. Never add an entry to a hub by hand.

## Writing notes

These hold for every skill that writes to the vault.

- Use British spelling.
- Write for a reader scanning the note: real markdown lists over dense prose, short sentences, one distinct fact per bullet. Where a run of `(1)… (2)…` or `(a)… (b)…` would go, write a numbered or bulleted list.
- Take every date and timestamp from `date` (Shell Rules below), never from memory.
- When you edit a note that has `dateModified`, set it to `date -Iseconds`.
- A new note matches the H1 and parent-link pattern of its siblings. Topic, research and domain notes open with a self-wikilinked H1, `# [[Note Title]]`, then a line linking the parent (`[[<Project>]]`, `[[<Project>#Research|Research]]`, `[[<Domain>]]`).
- Notes are normally created in Obsidian through the Templater folder templates in `Vault Metadata/Templates/Inputs/`. A note created from here matches what the template would have produced.

## Core Paths

| Type | Path |
| --- | --- |
| Daily notes | `Journal/Daily Notes/<YYYY>/<YYYY-MM>/<YYYY-MM-DD>.md` |
| Weekly notes | `Journal/Weekly Notes/<YYYY>-W<WW>.md` |
| Monthly notes | `Journal/Monthly Notes/<YYYY>-<MM>.md` |
| Quarterly notes | `Journal/Quarterly Notes/<YYYY>-Q<Q>.md` |
| Yearly notes | `Journal/Yearly Notes/<YYYY>.md` |
| Tasks | `Projects/<project>/Tasks/<YYYY-MM-DD HHMMSS> <ID> <title>.md` |
| Research | `Projects/<project>/Tasks/<Title>.md` — a task with `task-type: research`, named by its question, no date prefix |
| Events | `Projects/<project>/Events/<YYYY-MM-DD HHMMSS> <title>.md` |
| Topics | `Projects/<project>/Topics/<Topic>.md` |
| People | `People/@Firstname Surname.md` |
| Templates | `Vault Metadata/Templates/` |

Three kinds of project note, told apart by lifecycle: a note with `status` is a task; a note fixed at a date is an event; an evergreen note is a topic. Research is a task because it has a lifecycle. Archived projects live under `Projects/Archive/<project>/` with the same layout.

Evergreen, project-independent knowledge lives in the top-level domain folders (`Development/`, `Artificial Intelligence/`, `Process/`, `Knowledge management/`, ...), not in a project's `Topics/`. Moving a note there is the `obsidian-connect` graduation step.

## Shell Rules

```bash
VAULT="$HOME/Documents/Notes"
date +"%Y-%m-%d %H%M%S"    # task and event filename
date +"%Y-%m-%d %H:%M"      # log entry header
date -Iseconds              # frontmatter
```

## Frontmatter

### Task

The TaskNotes plugin reads these fields.

```yaml
---
status: open                 # open | in-progress | in-review | blocked | done
priority: normal
task-type: implementation    # implementation | investigation | review | experiment | research | note
projects:
  - "[[<Project>]]"
topics:
  - "[[<Topic>]]"
dateCreated: <ISO8601>
dateModified: <ISO8601>
tags:
  - task                     # research tasks also carry `research`
completedDate: <YYYY-MM-DD>  # only with status: done
---
```

New task notes start with `status: open`. Experiment tasks add `research:` with a wikilink to their research note. Investigation tasks add `investigation_root: ./<same-basename>/README.md`. Routing by `task-type` and the rules for `done` belong to `obsidian-task`.

### Event

```yaml
---
date: <YYYY-MM-DD>
type: meeting                # event | meeting | email | document | decision | observation
project: "[[<Project>]]"
topics:
  - "[[<Topic>]]"
participants:
  - "[[@Firstname Surname]]"
source:
aliases:
  - <title without timestamp>
---
```

A decision or observation made in a meeting is a section of that meeting's note, not a separate Event. A standalone `decision` or `observation` Event is for one with no other record. Recurring meetings carry a topic for the series (for example `[[Weekly meeting]]`), whose note lists them with a query.

### Topic

```yaml
---
date: <YYYY-MM-DD>
project: "[[<Project>]]"
aliases:
  - <abbreviation or singular/plural variant>
source:
---
```

## Linking

`topics:` is the one mechanism that attaches a Task or Event to its Topics. Links run one way, note to topic; a Topic never lists its tasks or events by hand, though it may list them with a query. Older notes carry a bare-wikilink line under the H1 instead; when editing such a note, move those links into `topics:`.

Link if it improves navigation, not just because a term matches. A mention in the body is not the same as the note being about that topic.

Link people by full name: `[[@Firstname Surname]]`.

Use aliased WikiLinks for ticket references:

```markdown
[[2026-02-13 141534 RH-6949 Performance issue|RH-6949]]
```

Every mention of a Jira/Linear/etc. issue number in summaries, blockers, carryover, or task updates should be a WikiLink to its task note when a matching note exists.

Keep note basenames unique across the vault. Obsidian resolves a bare `[[Name]]` by filename only; aliases help autocomplete, not resolution, so a duplicate basename forces path-qualified links. When moving a note, keep its basename and fix path-qualified incoming links and source-relative outgoing links.

## Domain terms

There is no `Glossary/` folder. A domain term is a short note in the project's `Topics/`, sitting alongside the longer hubs — same folder, same shape, just briefer. Search first: if the concept already has a hub, extend it rather than adding a second note, because duplicate basenames make links ambiguous.

```markdown
---
aliases:
  - <abbreviation or singular/plural variant>
project: "[[<Project>]]"
---

# [[Term]]

[[<Project>]]

<Plain-language definition, one or two sentences, wikilinking the concepts it leans on.
Do not define jargon with more jargon.>

<Optional: a concrete example, or how it differs from the term it is confused with.>

## See also
[[Related]] · [[Related]]
```

Give every abbreviation an `aliases:` entry so existing links keep resolving. `obsidian-connect` owns hub shape, alias collisions, and promotion to a domain folder.
