---
name: commit-helper
description: Generate conventional commit messages from staged changes. Runs autonomously using Haiku model. Use after completing TDD cycles, after refactoring sessions, or when ready to commit.
---

# Commit Helper

Spawns the `commit-helper` agent to generate conventional commit messages.

## When to Use

- After completing a TDD cycle (tests pass)
- After a refactoring session
- After completing a task in the XP workflow
- Whenever you have staged changes ready to commit

## Commit Types

| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring |
| `test` | Adding/updating tests |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependencies |

See `.claude/agents/commit-helper.md` for full configuration.
