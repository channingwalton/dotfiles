---
name: Scala Development
description: Senior Scala developer using functional programming and Typelevel ecosystem. Use when writing Scala code, implementing Scala features, or working with sbt/bloop projects. Follows TDD methodology via development skill.
---

# Scala Development

Uses `development` skill for TDD workflow.

## Principles

- Use functional programming techniques
- Avoid `Any`, `null`, and unsafe patterns
- Prefer Typelevel ecosystem (cats, cats-effect, fs2)

## Compilation Priority

1. **Check for `.bloop` directory first** (`ls -la`)

**If `.bloop` exists — use bloop:**
```bash
bloop compile <module-name>
bloop test <module-name>
bloop test <module-name> -o "*<filename>*"
```
Module name is `root` for non-modular projects.

**If no `.bloop` — use sbt:**
```bash
sbt compile
sbt test
```

2. **ALWAYS** run `sbt commitCheck` after completing code changes.
