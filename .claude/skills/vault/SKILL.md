---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context. Use memory skill for atomic facts.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/`

**Templates & notation:** See `~/Documents/Notes/Process/Claude Code Knowledge Workflow.md`

## Bash Commands

```bash
# List in-progress tasks
rg --type md -l "^status:\s*in-progress" ~/Documents/Notes/Projects/*/Tasks

# Find notes + WikiLinks for a topic
rg --type md -l -i "<topic>" ~/Documents/Notes
rg --type md -l "\[\[<topic>" ~/Documents/Notes

# Full-text search with context
rg --type md -i -C 2 "<pattern>" ~/Documents/Notes

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

## Workflow

1. **Before work:** Search memory skill for atomic facts, find related notes
2. **During work:** Log in task file using templates from workflow doc
3. **After work:** Update status to `done`, write outcome, create knowledge notes, update memory skill

## Linking Related Notes

During tasks, find and link related notes:

```bash
# Find notes mentioning topic
rg --type md -l -i "<topic>" ~/Documents/Notes

# Find existing WikiLinks to topic
rg --type md -l "\[\[<topic>" ~/Documents/Notes
```

Add discovered notes as WikiLinks in task **Context** section or use breadcrumb pattern: `[[Parent]] | [[Related]]`

## Capture Heuristics

**Worth capturing when:**

| Marker | Trigger |
|--------|---------|
| `[pattern]` | Principle applies across multiple contexts |
| `[gotcha]` | Caused debugging time or surprised me |
| `[technique]` | Method that could save time later |
| `[decision]` | Non-obvious choice with reasoning worth preserving |

**Where to capture:**

| Destination | When |
|-------------|------|
| **Existing note** | Discovery extends/refines an existing topic (search first) |
| **New note** | Substantial, standalone, referenceable by other notes |
| **Task log only** | One-off detail that won't generalise |
| **Memory skill** | Atomic fact for quick retrieval |

## Note Locations

| Folder | Purpose | Examples |
|--------|---------|----------|
| `Development/` | Conceptual topics, paradigms, architectural patterns | "Functional Programming", "Test Driven Development", "Unison Web Application Patterns" |
| `HowTo/` | Procedural guides, specific techniques, step-by-step instructions | "Unison Testing with Effect Handlers", "TDD with Functional Programming" |
| `Tools/` | Software tools and their usage | "Claude", "Git", "HTMX", "Obsidian" |
| `Projects/<project>/Tasks/` | Task logs only — never knowledge notes |

## Integration with Memory Skill

| Need | Tool |
|------|------|
| Atomic facts | Memory skill |
| Detailed docs | Vault (this skill) |
| Task logs | `Projects/<project>/Tasks/` |
| Fast search | Bash commands above |
