---
name: Commit Helper
description: Generate clear conventional commit messages from git diffs. Use when writing commit messages, reviewing staged changes, or after completing TDD cycles.
---

# Commit Helper

## Process

1. Run `git diff --staged` to see changes
2. Identify the primary change type
3. Write commit message following format below

## Conventional Commit Format

```
<type>: <summary>

[optional body]

[optional footer]
```

**Summary:** Under 50 characters, imperative mood ("add" not "added")

## Types

| Type | Use for |
|------|---------|
| `feat` | New feature or behaviour |
| `fix` | Bug fix |
| `refactor` | Code change that neither fixes nor adds |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, tooling, dependencies |

## Examples

**Simple:**
```
feat: add user authentication
```

**With body (complex changes):**
```
refactor: extract validation logic to separate module

Moved input validation from UserController to ValidationService
to improve testability and reuse across endpoints.
```

**With breaking change:**
```
feat: change API response format

BREAKING CHANGE: responses now wrap data in `result` key
```

## Rules

- **DO NOT** add contributors
- One logical change per commit
- If you need "and" in the summary, consider splitting
