---
name: scala-developer
description: Scala conventions and build-runner selection for Channing's projects — functional programming, Typelevel ecosystem, sbt/bloop. Use when writing or changing Scala code. An extension to the software-development skill.
---

# Scala Development

## Build runner

`devtool` is the default and detects the project itself. Drop to the underlying tool only when it is absent: use bloop if a `.bloop` directory exists (faster incremental), otherwise sbt. For non-modular projects the module name is `root`.

```bash
bloop compile <module-name>
bloop test <module-name> -o "*<filename>*"

sbt compile
sbt "testOnly *SpecName*"
```

## Design opinions

These are Channing's preferred style and differ from the default choice:

- **Encapsulation over transparency**: prefer `class` with `private val` (or opaque types) over `case class` when a type has internal structure that shouldn't be part of its public API (e.g. a `Map` tracking counts, a buffer, an index). Reserve `case class` for value types where every field is meaningful to callers (e.g. `Book(title, author)`, `Config(host, port)`). Reaching for `case class` by default produces types that leak implementation details.

- **Typelevel ecosystem**: prefer cats, cats-effect and fs2 over the alternatives (ZIO, Akka). This is a codebase consistency choice, not a judgement on the alternatives — mixing effect systems creates friction.

## Red flag

**A deliberate semantic divergence with no discriminating test.** When behaviour intentionally differs from the mirrored precedent or the happy path — scale-insensitive `BigDecimal` equality, instant-based `ZonedDateTime`, extension-stack resolution in a repeating row — write the test that *fails* if the divergence regresses. The reviewer caught these every time; the implementer did not write them first.
