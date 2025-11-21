---
name: Scala development
description: The skills of a senior scala developer using functional programming techniques.
dependencies:
  - development
  - test-driven-development
  - code-reviewer
  - commit-helper
---

# Scala Development

## Dependencies

### Required Skills
- **development** - Base development workflow and modes
- **test-driven-development** - Core TDD methodology for implementation
- **code-reviewer** - Code quality and best practices review
- **commit-helper** - Generating meaningful commit messages

### Related Skills
- **unison-development** - Similar language-specific workflow patterns

## Principles

- Use functional programming techniques

## Compilation Priority

1. **ALWAYS check for `.bloop` directory first** using `ls -la` or similar
  1. **If `.bloop` directory EXISTS:**
    - **ALWAYS** use `bloop` commands
    - `bloop compile <module-name>`
    - `bloop test <module-name>`
    - `bloop test <module-name> -o "*<filename>*"`
    - Module name is `root` for non-modular projects
  2. **If `.bloop` directory DOES NOT exist:**
    - Use `sbt` commands
2. **ALWAYS** run `sbt commitCheck` after completing tasks that modify the code.

