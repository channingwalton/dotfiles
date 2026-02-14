---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/` (vault name: `Notes`)

## Principles

1. **Obsidian vault for documents** - Detailed notes, task logs, project context
2. **Obsidian CLI for vault operations** - Use `obsidian` CLI for reading, writing, searching, and managing notes
3. **WikiLinks for connections** - Build traversable knowledge graph
4. **ALWAYS**: New tasks should be in an `open` state

## Templates

Templates are in the skill directory, not the notes directory:

- `.claude/skills/vault/templates/knowledge-note.md` - For knowledge notes
- `.claude/skills/vault/templates/task.md` - For new tasks
- `.claude/skills/vault/templates/recipe.md` - For project-specific recipes/runbooks
- `.claude/skills/vault/templates/weekly-summary.md` - For weekly summaries

## Obsidian CLI Commands

**Spaces in paths**: Single-quote the entire `key=value` pair to preserve spaces:
`obsidian read 'path=Projects/2025-10 Patchwork/Note.md'`

### Creating and writing

```bash
# Create a new note (path is the full vault-relative file path)
obsidian create 'path=<folder/file.md>' content="<text>" silent

# Create from an Obsidian template
obsidian create 'path=<folder/file.md>' template="<template-name>" silent

# Append to an existing note (e.g. adding a log entry)
obsidian append file="<name>" content="<text>"

# Prepend to an existing note
obsidian prepend file="<name>" content="<text>"
```

### Reading

```bash
# Read a file's contents
obsidian read file="<name>"

# Read by path (relative to vault root)
obsidian read path="<folder/file>"

# Show file info (path, size, dates)
obsidian file file="<name>"

# Show heading structure
obsidian outline file="<name>"
```

### Searching and finding

```bash
# Full-text search (vault-aware, respects excludes)
obsidian search query="<text>" path="<folder>" limit=<n> matches

# List files in a folder
obsidian files folder="<folder>"

# Find files by tag
obsidian tag name="<tag>"

# List all tags with counts
obsidian tags counts sort=count
```

### Properties (frontmatter)

```bash
# Read a property value
obsidian property:read name="<prop>" file="<name>"

# Set a property (avoids manual YAML editing)
obsidian property:set name="status" value="done" file="<name>"
obsidian property:set name="status" value="in-progress" file="<name>"

# Remove a property
obsidian property:remove name="<prop>" file="<name>"

# List all properties for a file
obsidian properties file="<name>"
```

### Graph queries (linking)

```bash
# List backlinks to a file
obsidian backlinks file="<name>" counts

# List outgoing links from a file
obsidian links file="<name>"

# Find orphan files (no incoming links)
obsidian orphans

# Find dead-end files (no outgoing links)
obsidian deadends

# Find broken/unresolved links
obsidian unresolved
```

### Tasks

```bash
# List open tasks in vault
obsidian tasks todo

# List completed tasks
obsidian tasks done

# List tasks in a specific file
obsidian tasks file="<name>"

# Toggle a task's status
obsidian task ref="<path:line>" toggle
```

### File management

```bash
# Move or rename a file
obsidian move file="<name>" to="<new-path>"

# Delete a file
obsidian delete file="<name>"
```

### Fallback: time-based file queries

The CLI doesn't support date-range filtering on files. Use `fd` for these:

```bash
# Recently modified (last 7 days)
fd -e md --changed-within 7d ~/Documents/Notes

# Recently modified in a specific folder
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*<project>*/Tasks
```

## Timestamps

Always use real timestamps, never placeholders:

```bash
# For task filename: YYYY-MM-DD HHMMSS
date +"%Y-%m-%d %H%M%S"

# For log entry header: YYYY-MM-DD HH:MM
date +"%Y-%m-%d %H:%M"

# For frontmatter (ISO-8601)
date -Iseconds
```

## Task File Path

`~/Documents/Notes/Projects/<YYYY[-MM] Project>/Tasks/<YYYY-MM-DD HHMMSS> <Title>.md`

## Linking Strategy

> Link if it improves the note, not just because it matches a term.

### What to search for

| Search for | Example (if writing about "Unison abilities") |
|------------|-----------------------------------------------|
| Direct terms | "abilities", "Unison abilities" |
| Parent concepts | "effect handlers", "functional programming" |
| Sibling techniques | "monads", "algebraic effects" |
| Tools/tech used | "UCM", "Jit" |

### Linking workflow

1. **Semantic discovery** — `obsidian search query="<concept>" matches` for related content
2. **Backlinks** — `obsidian backlinks file="<name>"` to find what links to your topics
3. **Tags overlap** — `obsidian tag name="<tag>"` for notes sharing tags
4. Add discovered notes as WikiLinks using breadcrumb pattern: `[[Parent]] | [[Related]]`

## Capture Heuristics

**Worth capturing when:**

| Marker | Trigger |
|--------|---------|
| 📋 | Principle applies across multiple contexts |
| 🤔 | Caused debugging time or surprised me |
| ⚙️ | Method that could save time later |
| 📎 | Link to documentation or source |
| ☝️ | Non-obvious choice with reasoning worth preserving |

**Where to capture:**

| Destination | When |
|-------------|------|
| **Existing note** | Discovery extends/refines an existing topic (search first) |
| **New note** | Substantial, standalone, referenceable by other notes |
| **Task log only** | One-off detail that won't generalise |
| **Project recipe** | Repeatable steps specific to this project's systems |

## Note Locations

| Folder | Purpose | Examples |
|--------|---------|----------|
| `Development/` | Conceptual, non-project, topics, paradigms, architectural patterns | "Functional Programming", "Test Driven Development", "Unison Web Application Patterns" |
| `HowTo/` | Procedural guides, specific techniques, step-by-step instructions, unrelated to projects | "Unison Testing with Effect Handlers", "TDD with Functional Programming" |
| `Tools/` | Software tools and their usage | "Claude", "Git", "HTMX", "Obsidian" |
| `Projects/<project>/` | Project level knowledge  in an appropriate note in the project folder | |
| `Projects/<project>/Tasks/` | Task logs only — never knowledge notes | |
| `Projects/<project>/Glossary/` | Glossary entries | |
| `Projects/<project>/Recipes/` | Project-specific recipes, runbooks, step-by-step guides for that project's systems | "Testing Allocate Imports", "Deploying Rota Bridge to Staging" |
| `Projects/<project>/Meetings/` | Meetings with a date prefix and linked to the '<Project> meetings' note in that folder | "2026-02-15 Lance and Channing" |
| `Journal/Weekly Notes/` | Weekly summary notes (generated from task activity) | |


## Recipes vs HowTo vs Task Logs

| Location | Scope | Example |
|----------|-------|---------|
| `HowTo/` | General technique, not project-specific | "TDD with Functional Programming" |
| `Projects/<project>/Recipes/` | Project-specific steps in that project's systems | "Testing Allocate Imports in Staging" |
| `Projects/<project>/Tasks/` | Chronological log of a single piece of work | "RH-6870 Load RotaMap Data" |

**Extraction signal:** When a task log contains steps you'd need to repeat for a different task, extract those steps into a recipe and link to it from the task.

## Generating Weekly Summaries

Weekly summaries are generated from vault data, not written by hand.

### Data gathering commands

```bash
# Tasks modified this week (all projects — needs fd for date filtering)
fd -e md --changed-within 7d -p '/Tasks/' ~/Documents/Notes/Projects

# Tasks modified this week (in a specific project)
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*<project>*/Tasks

# In-progress tasks (by property)
obsidian search query="status: in-progress" path="Projects" matches

# Recently created notes (non-task)
fd -e md --changed-within 7d --exclude Tasks ~/Documents/Notes/Projects

# Recently created recipes
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*/Recipes
```

### Weekly summary file path

`~/Documents/Notes/Journal/Weekly Notes/<YYYY>-W<WW>.md`

### Workflow

1. Gather modified tasks and new notes using commands above
2. Read each modified task's log entries: `obsidian read file="<task>"`
3. Populate the weekly summary template
4. Create the summary: `obsidian create name="<YYYY>-W<WW>" path="Journal/Weekly Notes" content="<text>"`

## Generating Daily Notes

Daily notes serve as a lightweight index linking to tasks worked that day.
Generated on demand, not written by hand.

### Data gathering commands

```bash
# Tasks modified today (all projects)
fd -e md --changed-within 1d -p '/Tasks/' ~/Documents/Notes/Projects

# Meetings today
obsidian files folder="Projects" | grep "Meetings/$(date +%Y-%m-%d)"

# Notes created/modified today (non-task, non-meeting)
fd -e md --changed-within 1d --exclude Tasks --exclude Meetings ~/Documents/Notes/Projects
```

### Daily note file path

`~/Documents/Notes/Journal/Daily Notes/<YYYY>/<YYYY-MM>/<YYYY-MM-DD>.md`

### Format

Keep entries minimal — a wiki link and a one-line summary. Read each task's log or checklist to determine what changed today.

```markdown
---


---
# [[YYYY-MM-DD]]

## Work
- [[Task link|Short name]] — one-line summary
- [[Task link|Short name]] — one-line summary

## Meetings
- [[Meeting note]]

## Notes created
- [[Note name]] (type)
```

### Workflow

1. Find tasks, meetings, and notes modified today using commands above
2. Read each modified task: `obsidian read file="<task>"`
3. Populate or update the daily note
4. Create: `obsidian create name="<YYYY-MM-DD>" path="Journal/Daily Notes/<YYYY>/<YYYY-MM>" content="<text>"`
   Or append if it already exists: `obsidian append file="<YYYY-MM-DD>" content="<text>"`

## What NOT to include

- **DO NOT** include changed files
