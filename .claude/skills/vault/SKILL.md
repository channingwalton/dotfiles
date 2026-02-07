---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/`

## Principles

1. **Obsidian vault for documents** - Detailed notes, task logs, project context
2. **Unix tools for fast search** - ripgrep (rg), fd, or mdfind for finding content efficiently
3. **WikiLinks for connections** - Build traversable knowledge graph
4. **ALWAYS**: New tasks should be in an `open` state
5. Branches in git repos are often named after or prefixed with JIRA ticket number

## Templates

Templates are in the skill directory, not the notes directory:

- `.claude/skills/vault/templates/knowledge-note.md` - For knowledge notes
- `.claude/skills/vault/templates/task.md` - For new tasks
- `.claude/skills/vault/templates/recipe.md` - For project-specific recipes/runbooks
- `.claude/skills/vault/templates/weekly-summary.md` - For weekly summaries

## Bash Commands

```bash
# List in-progress tasks
rg --type md -l "^status:\s*in-progress" ~/Documents/Notes/Projects/*/Tasks

# Find project directory (handles YYYY[-MM] prefix)
fd -t d -d 1 -i "<project>" ~/Documents/Notes/Projects

# List project task files
fd -e md . ~/Documents/Notes/Projects/*<project>*/Tasks

# Find files by name
fd -e md -i "<name>" ~/Documents/Notes

# Recently modified (last 7 days)
fd -e md --changed-within 7d ~/Documents/Notes

# Find with Spotlight index
mdfind -interpret -onlyin ~/Documents/Notes "<concept>"
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

1. **Semantic discovery** — `mdfind -interpret` for related concepts
2. **Backlinks** — `rg "\[\[<concept>"` to find what links to your topics
3. **Tags overlap** — `rg "^  - <tag>$"` for notes sharing tags
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
# Tasks modified this week (in a specific project)
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*<project>*/Tasks

# Tasks modified this week (all projects)
fd -e md --changed-within 7d -p '/Tasks/' ~/Documents/Notes/Projects

# In-progress tasks
rg --type md -l "^status:\s*in-progress" ~/Documents/Notes/Projects/*/Tasks

# Tasks completed this week
rg --type md -l "^status:\s*done" ~/Documents/Notes/Projects/*/Tasks | xargs fd --changed-within 7d

# Recently created notes (non-task)
fd -e md --changed-within 7d --exclude Tasks ~/Documents/Notes/Projects

# Recently created recipes
fd -e md --changed-within 7d ~/Documents/Notes/Projects/*/Recipes
```

### Weekly summary file path

`~/Documents/Notes/Journal/Weekly Notes/<YYYY>-W<WW>.md`

### Workflow

1. Gather modified tasks and new notes using commands above
2. Read each modified task's log entries for the relevant week
3. Populate the weekly summary template
4. Save to `Journal/Weekly/`

## Generating Daily Notes

Daily notes serve as a lightweight index linking to tasks worked that day.
Generated on demand, not written by hand.

### Data gathering commands

```bash
# Tasks modified today (all projects)
find ~/Documents/Notes/Projects/*/Tasks -name "*.md" -newer /tmp/today_marker
# (create marker first: touch -t $(date +"%Y%m%d0000") /tmp/today_marker)

# Meetings today
find ~/Documents/Notes/Projects/*/Meetings -name "$(date +%Y-%m-%d)*"

# Notes created/modified today (non-task, non-meeting)
find ~/Documents/Notes/Projects -name "*.md" -not -path "*/Tasks/*" -not -path "*/Meetings/*" -newer /tmp/today_marker
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

1. Create today marker: `touch -t $(date +"%Y%m%d0000") /tmp/today_marker`
2. Find tasks, meetings, and notes modified today
3. Read each modified task to summarise what changed
4. Populate or update the daily note

## What NOT to include

- **DO NOT** include changed files
