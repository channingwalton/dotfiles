---
name: Vault
description: Read and write notes in the Obsidian vault. Use for task logs, knowledge capture, and building context. Use memory skill for atomic facts.
---

# Vault (Obsidian Notes)

Location: `~/Documents/Notes/`

## Bash Commands for Claude Code

```bash
# List in-progress tasks
rg --type md -l "^status:\s*in-progress" ~/Documents/Notes/Projects/*/Tasks

# Find notes + WikiLinks for a topic
rg --type md -l -i "<topic>" ~/Documents/Notes
rg --type md -l "\[\[<topic>" ~/Documents/Notes

# Full-text search with context
rg --type md -i -C 2 "<pattern>" ~/Documents/Notes

# Search by observation category (pattern, gotcha, decision, etc.)
rg --type md -i "^\s*-\s*\[<category>\]" ~/Documents/Notes

# Find project directory (handles YYYY[-MM] prefix)
fd -t d -d 1 -i "<project>" ~/Documents/Notes/Projects

# List project task files
fd -e md . ~/Documents/Notes/Projects/*<project>*/Tasks

# Find files by name
fd -e md -i "<name>" ~/Documents/Notes

# Recently modified (last 7 days)
fd -e md --changed-within 7d ~/Documents/Notes
```

## Creating Task Files

Use Filesystem MCP to create task files directly:

Path: `~/Documents/Notes/Projects/<YYYY[-MM] Project>/Tasks/<YYYY-MM-DD HHMMSS> <Title>.md`

Template:
```markdown
---
status: in-progress
priority: normal
projects:
  - "[[Project Name]]"
dateCreated: <ISO-8601>
dateModified: <ISO-8601>
tags:
  - task
---

# Task Title

## Goal

## Context

## Log

### <YYYY-MM-DD HH:MM>

## Outcome

## Related
```

## Before Starting Work

1. Search memory skill for atomic facts
2. Find related notes:
   ```bash
   rg --type md -l -i "topic" ~/Documents/Notes
   ```
3. Read key notes via Filesystem MCP

## During Work

Log decisions in task file at `Projects/<project>/Tasks/`:

```markdown
### 2025-12-06 14:30

- [done] Completed item
- [decision] Why X over Y
- [gotcha] Problem encountered
- [ ] Remaining work
```

## After Completing Work

1. Update task frontmatter: `status: done`
2. Write summary in Outcome section
3. Create knowledge notes for reusable patterns
4. Update memory skill with atomic facts
5. Add WikiLinks: `[[Note Name]]`

## Observation Categories

- `[pattern]` — reusable approach
- `[technique]` — how to do something
- `[gotcha]` — common trap
- `[decision]` — why X over Y
- `[reference]` — link to docs
- `[issue]` — problem encountered
- `[done]` — completed item
- `[ ]` — todo (unchecked)
- `[x]` — todo (checked)
- `[question]` — unanswered query
- `[insight]` — realisation

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
| Fast search | Bash commands above |

Full workflow doc: `~/Documents/Notes/Process/Claude Code Knowledge Workflow.md`
