---
name: Generating Commit Messages
description: Generates clear commit messages from git diffs. Use when writing commit messages or reviewing staged changes.
dependencies: []
related-skills:
  - test-driven-development
---

# Generating Commit Messages

## Dependencies

**None** - Standalone skill for commit message generation.

### Related Skills
- **test-driven-development** - Commits follow TDD cycle (e.g., "add test for X", "implement X")

## Instructions

1. Run `git diff --staged` to see changes
2. Suggest a commit message with a summary under 50 characters
3. **DO NOT** add contributors

