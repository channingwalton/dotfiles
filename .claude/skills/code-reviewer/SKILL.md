---
name: Code Reviewer
description: Review code for best practices, security, performance, and potential issues. Use when reviewing code, checking pull requests, analysing code quality, or when asked to critique implementation.
---

# Code Reviewer

Review code using the checklist in `references/checklist.md`.

## Review Scope

- **PR/diff review:** Focus on changed lines plus immediate context
- **Full file review:** Apply all checklist criteria
- **Architecture review:** Focus on structure, abstractions, dependencies

## Instructions

1. Determine review scope (diff, file, or architecture)
2. Read target files
3. Search for patterns using Grep/rg
4. Find related files using Glob
5. Apply checklist criteria
6. Run `bugmagnet` command for test coverage and bug discovery

## Output Format

- 🔴 CRITICAL: Must fix before merge
- 🟡 WARNING: Should address
- ℹ️ SUGGESTION: Nice to have
