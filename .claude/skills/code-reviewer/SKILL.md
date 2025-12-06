---
name: Code Reviewer
description: Review code for best practices, security, performance, and potential issues. Use when reviewing code, checking pull requests, analysing code quality, or when asked to critique implementation.
---

# Code Reviewer

Review code using the checklist in `references/checklist.md`.

## Instructions

1. Read target files
2. Search for patterns using Grep/rg
3. Find related files using Glob
4. Apply checklist criteria
5. Run `bugmagnet` on modified or new files

## Output Format

- 🔴 CRITICAL: Must fix before merge
- 🟡 WARNING: Should address
- ℹ️ SUGGESTION: Nice to have
