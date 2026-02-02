---
name: code-reviewer
description: Autonomous code review for best practices, security, performance, and potential issues. Runs in isolation with read-only tools using Opus model. Use when reviewing code, checking PRs, or analysing code quality.
---

# Code Reviewer

Spawns the `code-reviewer` agent for autonomous code review.

## When to Use

- After completing a feature (before merging)
- When reviewing pull requests
- When asked to critique or analyse implementation
- As part of quality gates in the XP workflow

## What It Reviews

- Code organisation and structure
- Functional programming practices
- Error handling
- Performance
- Security
- Test coverage

See `.claude/agents/code-reviewer.md` for full configuration.
