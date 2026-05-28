---
name: scala-developer
description: Senior Scala developer using functional programming and Typelevel ecosystem. Use when writing Scala code, implementing Scala features, or working with sbt/bloop projects. Used as a part of the XP skill.
---

# Scala Development

## Build Tool Selection

Prefer `devtool` when it is available — it auto-detects the project and wraps compile/lint/test, so you don't pick the runner by hand or risk using the wrong one:

- `devtool check` — compile + lint + test (run before committing)
- `devtool compile` — compile only
- `devtool test [pattern]` — run tests, optional filter

Drop to the underlying tool only when `devtool` is absent. Use bloop (faster incremental) if a `.bloop` directory exists, otherwise sbt; module name is `root` for non-modular projects:

```bash
bloop compile <module-name>
bloop test <module-name> -o "*<filename>*"

sbt compile
sbt "testOnly *SpecName*"
```

## Design Opinions

These reflect Channing's preferred style and may differ from what you'd produce by default:

- **Encapsulation over transparency**: prefer `class` with `private val` (or opaque types) over `case class` when a type has internal structure that shouldn't be part of its public API (e.g. a `Map` tracking counts, a buffer, an index). Reserve `case class` for value types where every field is meaningful to callers (e.g. `Book(title, author)`, `Config(host, port)`). The instinct to reach for `case class` by default leads to types that leak implementation details.

- **Typelevel ecosystem**: prefer cats, cats-effect, and fs2 over alternatives (e.g. ZIO, Akka). This is a codebase consistency choice, not a judgement call — mixing effect systems creates friction.
