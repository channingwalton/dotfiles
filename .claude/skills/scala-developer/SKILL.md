---
name: Scala development
description: The skills of a senior scala developer.
---

# Scala Development

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

