---
name: scala-developer
description: Senior Scala developer using functional programming and Typelevel ecosystem. Use when writing Scala code, implementing Scala features, or working with sbt/bloop projects. Used as a part of the XP skill.
---

# Scala Development

## Build Tool Selection

Projects may use bloop (faster incremental compilation) or sbt. Check which is available before compiling — using the wrong one wastes time and confuses error output.

1. **Check for `.bloop` directory first** — if it exists, the project is configured for bloop:

```bash
bloop compile <module-name>
bloop test <module-name>
bloop test <module-name> -o "*<filename>*"
```

Module name is `root` for non-modular projects.

2. **Fall back to sbt** if no `.bloop` directory:

```bash
sbt compile
sbt test
sbt "testOnly *SpecName*"
```

3. **After completing code changes**, run `devtool check` — this is a unified tool that runs compile + lint + test regardless of build tool.

## Design Opinions

These reflect Channing's preferred style and may differ from what you'd produce by default:

- **Encapsulation over transparency**: prefer `class` with `private val` (or opaque types) over `case class` when a type has internal structure that shouldn't be part of its public API (e.g. a `Map` tracking counts, a buffer, an index). Reserve `case class` for value types where every field is meaningful to callers (e.g. `Book(title, author)`, `Config(host, port)`). The instinct to reach for `case class` by default leads to types that leak implementation details.

- **Typelevel ecosystem**: prefer cats, cats-effect, and fs2 over alternatives (e.g. ZIO, Akka). This is a codebase consistency choice, not a judgement call — mixing effect systems creates friction.
