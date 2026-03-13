---
name: vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/` (vault name: `Notes`)

## Principles

1. **Obsidian vault for documents** — detailed notes, task logs, project context
2. **Obsidian CLI for vault operations** — use `obsidian` CLI for all vault operations
3. **WikiLinks for connections** — build traversable knowledge graph
4. **ALWAYS**: New tasks should be in an `open` state

## Templates

Templates are in the skill directory, not the notes directory:

- `.claude/skills/vault/templates/knowledge-note.md`
- `.claude/skills/vault/templates/task.md`
- `.claude/skills/vault/templates/recipe.md`
- `.claude/skills/vault/templates/weekly-summary.md`

## Obsidian CLI Commands

**Spaces in paths**: Single-quote the entire `key=value` pair:
`obsidian read 'path=Projects/2025-10 Patchwork/Note.md'`

### Creating and writing

```bash
obsidian create 'path=<folder/file.md>' content="<text>" silent
obsidian create 'path=<folder/file.md>' template="<template-name>" silent
obsidian append file="<n>" content="<text>"
obsidian prepend file="<n>" content="<text>"
```

### Reading

```bash
obsidian read file="<n>"
obsidian read path="<folder/file>"
obsidian file file="<n>"           # file info (path, size, dates)
obsidian outline file="<n>"        # heading structure
```

### Searching and finding

```bash
obsidian search query="<text>" path="<folder>" limit=<n> matches
obsidian files folder="<folder>"
obsidian tag name="<tag>"
obsidian tags counts sort=count
```

### Properties (frontmatter)

```bash
obsidian property:read name="<prop>" file="<n>"
obsidian property:set name="status" value="done" file="<n>"
obsidian property:remove name="<prop>" file="<n>"
obsidian properties file="<n>"
```

### Graph queries (linking)

```bash
obsidian backlinks file="<n>" counts
obsidian links file="<n>"
obsidian orphans
obsidian deadends
obsidian unresolved
```

### Tasks

```bash
obsidian tasks todo
obsidian tasks done
obsidian tasks file="<n>"
obsidian task ref="<path:line>" toggle
```

### File management

```bash
obsidian move file="<n>" to="<new-path>"
obsidian delete file="<n>"
```

### Fallback: time-based file queries

The CLI doesn't support date-range filtering. Use `fd`:

```bash
fd -e md --changed-within 7d ~/Documents/Notes
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*<project>*/Tasks
```

## Timestamps

Always use real timestamps, never placeholders:

```bash
date +"%Y-%m-%d %H%M%S"    # task filename
date +"%Y-%m-%d %H:%M"      # log entry header
date -Iseconds               # frontmatter (ISO-8601)
```

## Task File Path

`~/Documents/Notes/Projects/<YYYY[-MM] Project>/Tasks/<YYYY-MM-DD HHMMSS> <Title>.md`

## Linking Strategy

> Link if it improves the note, not just because it matches a term.

1. **Semantic discovery** — `obsidian search query="<concept>" matches`
2. **Backlinks** — `obsidian backlinks file="<n>"`
3. **Tags overlap** — `obsidian tag name="<tag>"`
4. Add as WikiLinks using breadcrumb pattern: `[[Parent]] | [[Related]]`

## Capture Heuristics

**Worth capturing when:** principle applies across contexts, caused debugging time, method that saves time later, non-obvious choice with reasoning worth preserving, link to documentation.

**Where to capture:**

| Destination | When |
|-------------|------|
| **Existing note** | Extends/refines an existing topic (search first) |
| **New note** | Substantial, standalone, referenceable |
| **Task log only** | One-off detail that won't generalise |
| **Project recipe** | Repeatable steps specific to this project |

## Note Locations

| Folder | Purpose |
|--------|---------|
| `Development/` | Conceptual topics, paradigms, architectural patterns |
| `HowTo/` | Procedural guides, techniques, not project-specific |
| `Tools/` | Software tools and their usage |
| `Projects/<project>/` | Project-level knowledge |
| `Projects/<project>/Tasks/` | Task logs only — never knowledge notes |
| `Projects/<project>/Glossary/` | Glossary entries |
| `Projects/<project>/Recipes/` | Project-specific recipes and runbooks |
| `Projects/<project>/Meetings/` | Meetings with date prefix |
| `Journal/Weekly Notes/` | Weekly summaries (generated from task activity) |

**Extraction signal:** When a task log contains repeatable steps, extract into a recipe.

## Task Reference Resolution

**Every mention of a JIRA issue number must be a wiki-link to its task note.** Never leave bare issue numbers.

1. Build lookup from `fd` results: issue number → full filename
2. If not found: `obsidian search query="RH-6949" path="Projects" matches`
3. Use aliased wiki-links: `[[2026-02-13 141534 RH-6949 Performance issue|RH-6949]]`

Applies to **all sections** — summaries, blockers, carryover, etc.

## Generating Weekly Summaries

Path: `~/Documents/Notes/Journal/Weekly Notes/<YYYY>-W<WW>.md`

### Data gathering

```bash
fd -e md --changed-within 7d -p '/Tasks/' ~/Documents/Notes/Projects
obsidian search query="status: in-progress" path="Projects" matches
fd -e md --changed-within 7d --exclude Tasks ~/Documents/Notes/Projects
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*/Recipes
```

### Workflow

1. Gather modified tasks, new notes, outstanding tasks from previous week
2. Read each: `obsidian read file="<task>"`
3. Build JIRA → filename lookup (see Task Reference Resolution)
4. Populate weekly summary template, wiki-linking all references
5. Create: `obsidian create name="<YYYY>-W<WW>" path="Journal/Weekly Notes" content="<text>"`

## Generating Daily Notes

Path: `~/Documents/Notes/Journal/Daily Notes/<YYYY>/<YYYY-MM>/<YYYY-MM-DD>.md`

### Data gathering

```bash
fd -e md --changed-within 1d -p '/Tasks/' ~/Documents/Notes/Projects
obsidian files folder="Projects" | grep "Meetings/$(date +%Y-%m-%d)"
fd -e md --changed-within 1d --exclude Tasks --exclude Meetings ~/Documents/Notes/Projects
```

### Slack conversations

Search Slack for important conversations **the user is involved in** today. Use `slack_search_public_and_private` with `from:<@USER_ID>` and date filters to find messages the user sent. Then read the threads of those messages to get full context. **Only include conversations the user participated in. Exclude DMs.**

For each noteworthy conversation, capture:
- A one-line summary
- A link to the thread (from the message permalink)

### Format

```markdown
---
---
# [[YYYY-MM-DD]]

## Work
- [[Task link|Short name]] — one-line summary

## Meetings
- [[Meeting note]]

## Notes created
- [[Note name]] (type)

## Slack conversations
- One-line summary of discussion — [link](permalink)
```

### Workflow

1. Find tasks, meetings, notes modified today
2. Read each: `obsidian read file="<task>"`
3. Search Slack for conversations the user participated in today (`from:<@USER_ID>`, no DMs), then read threads for context
4. Build JIRA → filename lookup (see Task Reference Resolution)
5. Create or append daily note, wiki-linking all references

## What NOT to include

- **DO NOT** include changed files
