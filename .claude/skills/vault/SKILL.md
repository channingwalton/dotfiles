---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context. Use memory skill for atomic facts.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/`

## Principles

1. **Memory MCP for atomic facts** - Quick retrieval of entities, observations, relations
2. **Obsidian vault for documents** - Detailed notes, task logs, project context
3. **Unix tools for fast search** - ripgrep, fd for finding content efficiently
4. **WikiLinks for connections** - Build traversable knowledge graph
5. New tasks should be in an `open` state

## Templates

- `templates/knowledge-note.md` - For knowledge notes
- `templates/task.md` - For new tasks
- `templates/glossary.md` - For project glossary entries

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

> Link if it helps understand the note, not just because it matches a term.

### What to search for

| Search for | Example (if writing about "Unison abilities") |
|------------|-----------------------------------------------|
| Direct terms | "abilities", "Unison abilities" |
| Parent concepts | "effect handlers", "functional programming" |
| Sibling techniques | "monads", "algebraic effects" |
| Tools/tech used | "UCM", "Jit" |

### Semantic search (mdfind)

```bash
# Find semantically related notes (uses Spotlight index)
mdfind -interpret -onlyin ~/Documents/Notes "<concept>"

# Finds related concepts, not just literal matches
# e.g. "effect handlers" finds "Algebraic Effects", "Abilities" articles
```

### Precise search (rg)

```bash
# Find notes mentioning topic (literal)
rg --type md -l -i "<topic>" ~/Documents/Notes

# Find existing WikiLinks to topic (backlinks)
rg --type md -l "\[\[<topic>" ~/Documents/Notes

# Find notes with specific tag
rg --type md -l "^  - <tag>$" ~/Documents/Notes

# Full-text search with context
rg --type md -i -C 2 "<pattern>" ~/Documents/Notes
```

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
| **Existing note** | Discovery extends/refines an existing topic (search firs ) |
| **New note** | Substantial, standalone, referenceable by other notes |
| **Task log only** | One-off detail that won't generalise |
| **Memory skill** | Atomic fact for quick retrieval |

## Note Locations

| Folder | Purpose | Examples |
|--------|---------|----------|
| `Development/` | Conceptual, non-project, topics, paradigms, architectural patterns | "Functional Programming", "Test Driven Development", "Unison Web Application Patterns" |
| `HowTo/` | Procedural guides, specific techniques, step-by-step instructions, unrelated to projects | "Unison Testing with Effect Handlers", "TDD with Functional Programming" |
| `Tools/` | Software tools and their usage | "Claude", "Git", "HTMX", "Obsidian" |
| `Projects/<project>/` | Project level knowledge  in an appropriate note in the project folder | |
| `Projects/<project>/Tasks/` | Task logs only — never knowledge notes | |
| `Projects/<project>/Glossary` | Glossary entries | |

## Integration with Memory Skill

| Need | Tool |
|------|------|
| Atomic facts | Memory skill |
| Detailed docs | Vault (this skill) |
| Task logs | `Projects/<project>/Tasks/` |
| Fast search | Bash commands above |

## What NOT to include

- **DO NOT** include changed files
