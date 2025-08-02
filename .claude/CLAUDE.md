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
   - Remember project specific information that would be useful when returning to the project

2. Obsidian vault
   - Refer to the obsidian vault at `~/Documents/Notes/` to garner more information
     - Project specific information is in `~/Documents/Notes/Permanent/Projects`
   - Refer to my GitHub profile and projects at: `https://github.com/channingwalton`

## Development Guidelines for Claude

- Do not write comments
- Use Context7 to pull up-to-date, version-specific, documentation and code examples.
- Small incremental changes
  - Write tests first (TDD)
  - Commit after writing the test and before implementing the code to make it pass
  - Commit after writing the implementation and the test passes

- Functional programming principles
  - No `Any` types, type assertions or null
  - Immutable data only
  - Small, pure functions

- Projects should be layered with clear responsibilities for each layer
- Keep the README and any documents up-to-date.

**Preferred Scala Tools:**

- **Libraries**: [Typelevel](https://typelevel.org/) libraries: [cats](https://github.com/typelevel/cats), [cats-effect](https://github.com/typelevel/cats-effect/), [FS2](https://github.com/typelevel/fs2), [HTTP4S](https://github.com/http4s/http4s), [Circe](https://github.com/circe/circe), [Doobie](https://github.com/typelevel/doobie)
- **Testing**: [munit](https://github.com/scalameta/munit), [munit-cats-effect](https://github.com/typelevel/munit-cats-effect), [ScalaCheck](https://github.com/typelevel/scalacheck)
- **Builds**: [SBT](https://www.scala-sbt.org/)

### Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

- Tests should verify expected behaviour, treating implementation as a black box
- Test through the public API exclusively - internals should be invisible to tests
- 100% coverage should be expected at all times but it isn't the goal, it should emerge from TDD 
- Tests must document expected business behaviour

### Unison guidelines

- Fetch the instructions and guide from [here](https://github.com/unisoncomputing/unison-llm-support/)

### Scala Guidelines

- **No `Any`** - ever
- **No null** - ever
- **No type assertions** (`asInstanceOf`) unless absolutely necessary with clear justification
- These rules apply to test code as well as production code

### GIT Guidelines

- Provide a small summary message
- Do not include lots of extra details
- Do not include Co-Authored-By or links to [Claude Code](https://claude.ai/code)

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

Only If the project has a `.bloop` directory then use the bloop command to compile quickly when working through problems.
- modules are compiled with `bloop compile <module-name>`
- modules are tested with `bloop test <module-name>`
- individual tests can be run with `bloop test <module-name> -o "*<filename>*"`
- the module name is `root` if the code isn't in a module and is under a `src` directory in the root of the project
- bloop documents are [here](https://scalacenter.github.io/bloop/docs/cli/tutorial)

### Code Style

#### Code Structure

- No nested if/else statements
- Avoid deep nesting (max 2 levels)
- Keep functions small and focused on a single responsibility
- Layer application code so that functions and classes have a single clear responsibility. Think of it as a light [hexagonal architecture](https://en.wikipedia.org/wiki/Hexagonal_architecture_(software))

#### No Comments in Code

Code should be self-documenting through clear naming and structure. Do not write comments that explain what the code is doing, however, documenting *why* something is as it is when its not obvious is acceptable.

### Development Workflow

To assist me with writing code, you'll operate in one of these modes:

* The DISCOVERY mode is used when searching for libraries
* The LEARN mode is for familiarizing yourself with a library using the Context7 MCP server, or a codebase, in preparation for writing or editing code or answering questions about the library. If I ask you to learn about a library or familiarize yourself with it, use this mode. You can also choose to dynamically enter this mode as part of a coding task, if you find you are unfamiliar with something
* The BASIC mode is for somewhat narrow, small, or well-defined tasks. For these, use the BASIC mode instructions, defined below.
* The DEEP WORK mode is for tasks which may involve a fair amount of code and which are not well defined. For these, follow the DEEP WORK mode instructions below.
* The DOCUMENTING mode is for adding documentation to code

Whenever entering a mode, tell me on its own line one of:

- 🔍 Switching to DISCOVERY mode.
- ‍🐣 Switching to BASIC mode.
- 🧑‍🎓 Switching to LEARN mode.
- 🧠 Switching to DEEP WORK mode.
- 📝 Switching to DOCUMENTING mode.

#### DISCOVERY mode instructions

Follow these steps to discover libraries for use:

1. Use Context7
2. Fetch documentation from
  - [Typelevel](https://typelevel.org/projects/)
  - [Scala](https://docs.scala-lang.org/api/all.html)
3. Remember what you discover

#### LEARN mode instructions

##### LEARNING (single definition) steps:

To learn about a single definition
1. read that definition's documentation, source code, and explore related definitions
2. If necessary, use Context7 to study related documentation of relevant libraries
3. Ask me for clarification if you don't understand
4. Remember what you discover


#### BASIC mode instructions 

These instructions are designed to make sure that you understand my intent before moving ahead with an implementation. It takes work for me to review a pile of code so it's better to be sure that you understand my request before writing any code. These instructions will also help me to discover relevant existing functions.

##### BASIC mode, step 1: before writing any code: confirm types and signatures

1. If code involves new types, confirm the declarations with me before proceeding.
2. Confirm type signatures with me before generating any code.
3. If possible, suggest a few simple examples of inputs and outputs for the function being implemented. Confirm that these are what I expect, then add these as a test.

Do not proceed to the next step until both these are confirmed.

I may tell you to skip checks and proceed directly to implementation, but if I don't say otherwise, proceed to step 2.

##### BASIC mode, step 2: Implementation

Now that we've agreed on the signature of the functions and have a few test cases, you can proceed with implementation.
You MAY use the LEARNING (single definition) steps to learn about types and functions you are trying to use in your implementation. 
Functions MUST be small with no more than two levels of nesting. Call helper functions if necessary to make the code more readable.

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

#### DEEP WORK mode

This mode of operating should be used for tasks which may involve a fair amount of code and are not well defined. You will NOT plow ahead writing code for tasks that fit into this category. Instead, you will use a staged approach, described below, in which we first agree on a design, test cases, and a rough implementation strategy, I approve this, and then and ONLY then do you proceed with trying to fill in the implementation.

##### DEEP WORK, step 1: gather requirements

Your goal is to come up with the following ASSETS:

1. A set of data types and function signatures
2. For each function or data type you should have a brief description of what it does, test cases if applicable, and high-level notes on implementation strategy.
3. You will ask me questions about the task, one at a time. Prefer yes / no questions to open ended questions. If after an answer, one of the assets (a data declarations, function signature, test case, implementation strategy, etc.) becomes clear, show me the code or docs and ask me if it looks okay before continuing.
4. Repeat 1 until you feel you have a complete set of requirements.
5. Provide a summary and a high-level implementation plan.
6. Ask me if it looks okay before continuing. Repeat until I say it sounds good, then move to DEEP WORK, Step 2: Implementation

####### DEEP WORK, MANDATORY CHECKPOINT

After completing requirements gathering, you MUST:

1. State "DEEP WORK Step 1 complete"
2. Present the complete requirements summary
3. Ask: "Do you approve this design? Should I proceed to Step 2: Implementation?"
4. WAIT for explicit "yes" or "proceed" before continuing
5. If I don't explicitly approve, ask clarifying questions

##### DEEP WORK, step 2: Implementation

Now that we've agreed on the requirements in step 1, you can then proceed to implementation. You will work in a more structured way to make it more likely that you'll succeed, and to make it easier for me to provide support or guidance if you get stuck:

1. Use the BASIC mode to implement each task
2. When the code compiles and the `commitCheck` passes, ask if I want to commit the code
  - if I say yes, produce a short commit message and confirm that I like it
  - when I am happy commit the code
3. Move onto the next task and repeat until all tasks are complete

If you are having trouble, work in smaller pieces:
  - Don't write a bunch of code, then try to get it to compile. Write and compile a function at a time. 
  - NEVER write more code if the code you've just written doesn't compile.

If you're having trouble with an API or some code after a few attempts, you can stop and ask me for guidance.

If during implementation you realize that the requirements were unclear, move back to DEEP WORK: step 1, gathering requirements until we have clarity. Then proceed.

Once you've written code that compile and passes all agreed upon tests, show me the overall implementation and ask if I have any suggestions or anything else I'd like to see changed. Repeat until I say it looks good.

Lastly, thank you for your help! If you manage to complete a DEEP WORK task, that is excellent.

When asking me a question, preface it with *Question❓:*, in bold, and put it at the bottom of any other output you've generated. This makes it easier for me to scan for. Do NOT include questions for me at random within a bunch of other output.

**Looking up documentation and source code**: As you're trying to implement something, you can use `Context7` and `fetch` to look up documentation and view source code for functions or types you are considering using.

**REQUIREMENT**: do a code clean-up pass by running `sbt commitCheck` if the `build.sbt` has a `commitCheck` alias and ensure it succeeds.

###### Refactoring - The Critical Third Step

**REQUIREMENT**: Always commit your working code before starting any refactoring. This gives you a safe point to return to:

Evaluating refactoring opportunities is not optional - it's the third step in the TDD cycle. After achieving a green state and committing your work, you MUST assess whether the code can be improved. However, only refactor if there's clear value - if the code is already clean and expresses intent well, move on to the next test.

Refactoring means changing the internal structure of code without changing its external behavior. The public API remains unchanged, all tests continue to pass, but the code becomes cleaner, more maintainable, or more efficient. Remember: only refactor when it genuinely improves the code - not all code needs refactoring.

When to Refactor:
- **Always assess after green**: Once tests pass, before moving to the next test, evaluate if refactoring would add value
- **When you see duplication**: But understand what duplication really means (see DRY below)
- **When names could be clearer**: Variable names, function names, or type names that don't clearly express intent
- **When structure could be simpler**: Complex conditional logic, deeply nested code, or long functions
- **When patterns emerge**: After implementing several similar features, useful abstractions may become apparent

**Remember**: Not all code needs refactoring. If the code is already clean, expressive, and well-structured, commit and move on. Refactoring should improve the code - don't change things just for the sake of change.

Before considering refactoring complete, verify:

- [ ] The refactoring actually improves the code (if not, don't refactor)
- [ ] `commitCheck` passes
- [ ] No new public APIs were added (only internal ones)
- [ ] Code is more readable than before
- [ ] Any duplication removed was duplication of knowledge, not just code
- [ ] No speculative abstractions were created
- [ ] The refactoring is committed separately from feature changes

**CRITICAL**: After every refactoring:

1. `commitCheck` must run successfully
2. Commit the refactoring separately from feature changes

```bash
# After refactoring
sbt commitCheck   # All tests must pass
```

#### DOCUMENTING mode

You will use this mode to add good documentation for a definition. After you've written code for me, you may ask me if I'd like you to add documentation, but you should not enter this mode without my consent.

Documentation should include:

1. A short description
2. If applicable, the reason why the function has been written, but ask me first if I want that.

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

The key is to write clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behaviour,
and the implementation should be the simplest thing that makes that test pass. When in doubt, favour simplicity and readability over cleverness.
