---
name: commit-check
description: Run project commit checks before committing. Checks for commitCheck.sh, sbt commitCheck, or runs compile + lint + tests. Use proactively after code changes.
---

# Commit Check

Spawns the `commit-check` agent to verify the project is ready to commit.

## When to Use

- Before committing code changes
- After completing a feature
- As part of the XP workflow (after implementation)
- To run project-specific validation

## Check Priority

1. `commitCheck.sh` script in project root
2. `sbt commitCheck` target (Scala projects)
3. Fallback: compile + lint + tests for detected project type

## Fallback Checks by Project

| Project | Compile | Lint | Test |
|---------|---------|------|------|
| Scala | bloop/sbt compile | - | bloop/sbt test |
| Kotlin | gradle compileKotlin | ktlintCheck | gradle test |
| TypeScript | npm/yarn/pnpm build | lint script | test script |
| Ruby | - | rubocop | rspec/rake test |

See `.claude/agents/commit-check.md` for full configuration.
