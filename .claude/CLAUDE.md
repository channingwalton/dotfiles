# Claude

## General rules

1. Memory
   - Always begin your chat by saying only "Remembering..." and retrieve all relevant information from your knowledge graph
   - Always refer to your knowledge graph as your "memory"
   - While conversing with the user be attentive to any new information:
     - Basic Identity (age, gender, location, job title, education level, etc.)
     - Behaviours (interests, habits, etc.)
     - Preferences (communication style, preferred language, etc.)
     - Goals (goals, targets, aspirations, etc.)
     - Relationships (personal and professional relationships)
     - Projects

   - If any new information was gathered during the interaction, update your memory as follows:
     - Create entities for recurring organizations, people, significant events, projects
     - Connect them to the current entities using relations
     - Store facts about them as observations

2. Projects:
   - Remember project specific information that would be useful when returning to the project

3. Obsidian vault
   - Refer to the obsidian vault at `~/Documents/Notes/` to garner more information
     - Project specific information is in `~/Documents/Notes/Permanent/Projects`
   - Refer to my GitHub profile and projects at: `https://github.com/channingwalton`

## Development Guidelines for Claude

- Use Context7 to pull up-to-date, version-specific, documentation and code examples.
- Small incremental changes
  - Write tests first (TDD)
  - Commit after writing the test and before implementing the code to make it pass
  - Commit after writing the implementation and the test passes

- Test behaviour, not implementation
- Functional programming principles
  - No `Any` types, type assertions or null
  - Immutable data only
  - Small, pure functions

- Projects should be layered with clear responsibilities for each layer
- Keep the README and any documents up-to-date.

**Preferred Scala Tools:**

- **Libraries**: [Typelevel](https://typelevel.org/) libraries: [cats](https://github.com/typelevel/cats), [cats-effect](https://github.com/typelevel/cats-effect/), [FS2](https://github.com/typelevel/fs2), [HTTP4S](https://github.com/http4s/http4s), [Circe](https://github.com/circe/circe), [Doobie](https://github.com/typelevel/doobie)
- **Testing**: [munit](https://github.com/scalameta/munit), [munit-cats-effect](https://github.com/typelevel/munit-cats-effect), [Scalacheck](https://github.com/typelevel/scalacheck)
- **Builds**: [SBT](https://www.scala-sbt.org/)

### Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

- Tests should verify expected behaviour, treating implementation as a black box
- Test through the public API exclusively - internals should be invisible to tests
- 100% coverage should be expected at all times but it isn't the goal, it should emerge from TDD 
- Tests must document expected business behaviour

### Scala Guidelines

- **No `Any`** - ever
- **No null** - ever
- **No type assertions** (`asInstanceOf`) unless absolutely necessary with clear justification
- These rules apply to test code as well as production code

#### sbt

Include the following command alias in `build.sbt`:

```
addCommandAlias("commitCheck", "clean;test;scalafmtSbt;scalafmtAll;scalafixAll")
```

If new modules are added to the project ensure `commitCheck` includes them.

**plugins.sbt** - minimal set

(use latest versions)

```
addSbtPlugin("ch.epfl.scala" % "sbt-scalafix" % "x.y.z")
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "x.y.z")
addSbtPlugin("org.typelevel" % "sbt-tpolecat" % "x.y.z")
addDependencyTreePlugin
```

### Compilation

If the project has a `.bloop` directory then use the bloop command to compile quickly when working through problems.
- modules are compiled with `bloop compile <module-name>`
- modules are tested with `bloop test <module-name>`
- the module name is `root` if the code isn't in a module and is under a `src` directory in the root of the project
- bloop documenta are [here](https://scalacenter.github.io/bloop/docs/cli/tutorial)

### Code Style

#### Code Structure

- No nested if/else statements
- Avoid deep nesting (max 2 levels)
- Keep functions small and focused on a single responsibility
- Layer application code so that functions and classes have a single clear responsibility. Think of it as a light [hexagonal architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))

#### No Comments in Code

Code should be self-documenting through clear naming and structure. Do not write comments that explain what the code is doing, however, documenting *why* something is as it is when its not obvious is acceptable.

### Development Workflow

#### TDD Process - THE FUNDAMENTAL PRACTICE

**CRITICAL**: TDD is not optional. Every feature, every bug fix, every change MUST follow this process:

Follow Red-Green-Refactor strictly:

1. **Red**: Write a failing test for the desired behavior – NO PRODUCTION CODE until you have a failing test.
2. **Green**: Write the MINIMUM code to make the test pass. Resist the urge to write more than needed.
3. **Refactor**: Assess the code for improvement opportunities. If refactoring would add value, clean up the code while keeping tests green. If the code is already clean and expressive, move on.

**Common TDD Violations to Avoid:**

- Writing production code without a failing test first
- Writing multiple tests before making the first one pass
- Writing more production code than needed to pass the current test
- Skipping the refactor assessment step when code could be improved
- Adding functionality "while you're there" without a test driving it

**Remember**: If you're typing production code and there isn't a failing test demanding that code, you're not doing TDD.

#### Refactoring - The Critical Third Step

Evaluating refactoring opportunities is not optional - it's the third step in the TDD cycle. After achieving a green state and committing your work, you MUST assess whether the code can be improved. However, only refactor if there's clear value - if the code is already clean and expresses intent well, move on to the next test.

##### What is Refactoring?

Refactoring means changing the internal structure of code without changing its external behavior. The public API remains unchanged, all tests continue to pass, but the code becomes cleaner, more maintainable, or more efficient. Remember: only refactor when it genuinely improves the code - not all code needs refactoring.

##### When to Refactor

- **Always assess after green**: Once tests pass, before moving to the next test, evaluate if refactoring would add value
- **When you see duplication**: But understand what duplication really means (see DRY below)
- **When names could be clearer**: Variable names, function names, or type names that don't clearly express intent
- **When structure could be simpler**: Complex conditional logic, deeply nested code, or long functions
- **When patterns emerge**: After implementing several similar features, useful abstractions may become apparent

**Remember**: Not all code needs refactoring. If the code is already clean, expressive, and well-structured, commit and move on. Refactoring should improve the code - don't change things just for the sake of change.

##### Refactoring Guidelines

###### Commit Before Refactoring

Always commit your working code before starting any refactoring. This gives you a safe point to return to:

```bash
git add .
git commit -m "feat: add payment validation"
# Now safe to refactor
```

###### Look for Useful Abstractions Based on Semantic Meaning

Create abstractions only when code shares the same semantic meaning and purpose. Don't abstract based on structural similarity alone - **duplicate code is far cheaper than the wrong abstraction**.

**Questions to ask before abstracting:**

- Do these code blocks represent the same concept or different concepts that happen to look similar?
- If the business rules for one change, should the others change too?
- Would a developer reading this abstraction understand why these things are grouped together?
- Am I abstracting based on what the code IS (structure) or what it MEANS (semantics)?

**Remember**: It's much easier to create an abstraction later when the semantic relationship becomes clear than to undo a bad abstraction that couples unrelated concepts.

##### Verify and Commit After Refactoring

**CRITICAL**: After every refactoring:

1. `commitCheck` must run successfully
2. Commit the refactoring separately from feature changes

```bash
# After refactoring
sbt commitCheck   # All tests must pass

# Only then commit
git add .
git commit -m "refactor: extract payment validation helpers"
```

#### Refactoring Checklist

Before considering refactoring complete, verify:

- [ ] The refactoring actually improves the code (if not, don't refactor)
- [ ] `commitCheck` passes
- [ ] No new public APIs were added (only internal ones)
- [ ] Code is more readable than before
- [ ] Any duplication removed was duplication of knowledge, not just code
- [ ] No speculative abstractions were created
- [ ] The refactoring is committed separately from feature changes

#### Commit Guidelines

- Each commit should represent a complete, working change
- Use conventional commits format:
  ```
  feat: add payment validation
  fix: correct date formatting in payment processor
  refactor: extract payment validation logic
  test: add edge cases for payment validation
  ```
- Include test changes with feature changes in the same commit

#### Pull Request Standards

- Every PR must have `commitCheck` passing
- Work in small increments that maintain a working state
- PRs should be focused on a single feature or fix
- Include description of the behavior change, not implementation details

### Working with Claude

#### Expectations

When working with my code:

1. **ALWAYS FOLLOW TDD** - No production code without a failing test. This is not negotiable.
2. **Think deeply** (sequential-thinking) before making any edits
3. **Understand the full context** of the code and requirements
4. **Ask clarifying questions** when requirements are ambiguous
5. **Think from first principles** - don't make assumptions
6. **Assess refactoring after every green** - Look for opportunities to improve code structure, but only refactor if it adds value
7. **Keep project docs current** - update them whenever you introduce meaningful changes

#### Code Changes

When suggesting or making changes:

- **Start with a failing test** - always. No exceptions.
- After making tests pass, always assess refactoring opportunities (but only refactor if it adds value)
- After refactoring, verify all tests and static analysis pass, then commit
- Respect the existing patterns and conventions
- Maintain test coverage for all behavior changes
- Keep changes small and incremental
- Ensure all build warnings are addressed
- Provide rationale for significant design decisions

**If you find yourself writing production code without a failing test, STOP immediately and write the test first.**

#### Communication

- Be explicit about trade-offs in different approaches
- Explain the reasoning behind significant design decisions
- Flag any deviations from these guidelines with justification
- Suggest improvements that align with these principles
- When unsure, ask for clarification rather than assuming

### Example Projects

Look for a directory called `example-projects` to base new code on.

### Resources and References

- [Scala Documentation](https://docs.scala-lang.org/)
- [Cats Documentation](https://typelevel.org/cats/)
- [Cats Effect Documentation](https://typelevel.org/cats-effect/)
- [MUnit Documentation](https://scalameta.org/munit/)
- [Http4s Documentation](https://http4s.org/)

### Summary

The key is to write clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior, and the implementation should be the simplest thing that makes that test pass. When in doubt, favor simplicity and readability over cleverness.

### References

- Inspired by [Paul Hammond](https://github.com/citypaul/.dotfiles/blob/main/claude/.claude/CLAUDE.md)
