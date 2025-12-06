---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context. Shell helpers provide fast searching. Use memory skill for atomic facts.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/`

## Shell Helpers (run via bash)

```bash
notes-tasks-open               # list in-progress tasks
notes-tasks-new <proj> <title> # create task from template
notes-context <topic>          # find notes + WikiLinks for topic
notes-search <pattern>         # full-text search with context
notes-obs <category>           # search by observation type
notes-extract <file>           # show observations + links from note
notes-find <name>              # find files by name
notes-recent [days]            # recently modified (default: 7 days)
notes-tasks <project>          # list project task files
notes-links <note>             # find WikiLinks to a note
notes-projects-list            # list all projects
```

## Before Starting Work

1. Search memory skill for atomic facts
2. Find related notes:
   ```bash
   notes-context "topic"
   notes-search "specific term"
   ```
3. Read key notes via Filesystem MCP

## During Work

Log decisions in task file at `Projects/<project>/Tasks/`:

```markdown
### 2025-12-06 14:30

- [done] Completed item
- [decision] Why X over Y
- [gotcha] Problem encountered
- [todo] Remaining work
```

## After Completing Work

1. Update task frontmatter: `status: done`
2. Write summary in Outcome section
3. Create knowledge notes for reusable patterns
4. Update memory skill with atomic facts
5. Add WikiLinks: `[[Note Name]]`

## Observation Categories

Use in task logs and knowledge notes:

- `[pattern]` — reusable approach
- `[technique]` — how to do something
- `[gotcha]` — common trap
- `[decision]` — why X over Y
- `[reference]` — link to docs
- `[issue]` — problem encountered
- `[done]` — completed item
- `[todo]` — remaining work
- `[question]` — unanswered query
- `[insight]` — realisation

## Task File Template

Created by `notes-tasks-new`:

```markdown
---
status: in-progress
priority: normal
projects:
  - "[[Project Name]]"
dateCreated: <ISO-8601>
tags:
  - task
---

# Task Title

## Goal

## Context

## Log

### <timestamp>

## Outcome

## Related
```

## Knowledge Note Template

```markdown
---
tags:
  - <domain>
created: <YYYY-MM-DD>
---

# [[Note Title]]

[[Parent Topic]] | [[Related Topic]]

Brief summary.

## Observations

- [pattern] Description
- [gotcha] Trap to avoid
- [technique] How to do X

## Related

- [[Related Note]] - how it relates
```

## Integration with Memory Skill

| Need | Tool |
|------|------|
| Atomic facts | Memory skill |
| Detailed docs | Vault (this skill) |
| Task logs | `Projects/<project>/Tasks/` |
| Fast search | Shell helpers |

Full workflow doc: `~/Documents/Notes/Process/Claude Code Knowledge Workflow.md`
