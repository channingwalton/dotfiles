---
name: compile
description: Compile code autonomously. Detects project type (Scala/Kotlin/TypeScript/Ruby) and runs appropriate build tool. Use proactively after writing or modifying code.
---

# Compile

Spawns the `compile` agent to build the current project.

## When to Use

- After writing or modifying code
- Before running tests
- To verify code compiles without errors
- As part of the XP workflow

## Supported Projects

| Config File | Language | Build Tool |
|-------------|----------|------------|
| `build.sbt` | Scala | bloop or sbt |
| `build.gradle.kts` | Kotlin | Gradle |
| `package.json` | TypeScript/JS | npm/yarn/pnpm |
| `Gemfile` | Ruby | rubocop |

See `.claude/agents/compile.md` for full configuration.
