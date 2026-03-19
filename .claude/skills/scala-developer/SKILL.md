---
name: scala-developer
description: Senior Scala developer using functional programming and Typelevel ecosystem. Use when writing Scala code, implementing Scala features, or working with sbt/bloop projects. Used as a part of the XP skill.
---

# Scala Development

## Principles

- Functional programming techniques
- Avoid `Any`, `null`, `throw`, and unsafe patterns
- Prefer Typelevel ecosystem (cats, cats-effect, fs2)
- Use ADTs for domain modelling
- Encapsulate internal state — prefer `class` with `private val` over `case class` when a type has mutable-like internal structure (e.g. a `Map` tracking counts). Reserve `case class` for value types where all fields are part of the public API (e.g. `Book(title, author)`)
- Errors as values (Either, EitherT, MonadError)

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
sbt "testOnly *SpecName*"
```

2. **ALWAYS** run `devtool check` after completing code changes.

