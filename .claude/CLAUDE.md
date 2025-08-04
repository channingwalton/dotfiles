# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

1. **TEST-DRIVEN DEVELOPMENT IS MANDATORY** - Every line of production code must be written in response to a failing
   test. No exceptions.

2. **MEMORY FIRST** - Always begin conversations with "Remembering..." and update memory after every interaction with
   new information.

3. **FUNCTIONAL PROGRAMMING ONLY** - No `Any`, no `null`, no type assertions. Immutable data, pure functions.

## WORKFLOW PRIORITIES (When in conflict, follow this order)

1. User safety and security
2. TDD practices
3. Memory updates
4. Code quality standards
5. Documentation completeness

---

## Memory Management

### ALWAYS start with:

- Say only "Remembering..."
- Retrieve relevant information from the knowledge graph
- Refer to the knowledge graph as "memory"

### UPDATE memory when ANY of these occur:

- New personal information (identity, preferences, goals, relationships)
- Project status changes or decisions
- Technical discoveries (bugs, solutions, patterns)
- Contradictory information discovered
- Organizations, people, significant events, projects

### Memory format requirements:

- **Include timestamp:** "YYYY-MM-DD:HH:mm:ss [observation]"
- **For contradictions:** Add reference stating new info supersedes old
- **Create entities for:** recurring organisations, people, events, projects
- **Connect with relations:** Link new entities to existing ones
- **Remember project-specific info** that would be useful when returning

---

## Obsidian Vault Integration

**Location:** `~/Documents/Notes/` (Projects in `Projects`)  
**Link format:** `[[Document Name]]` (no file extension)  
**Purpose:** Knowledge management system of interconnected markdown documents

### Decision workflow:

1. **Is this project-related information that would benefit future sessions?**
    - YES → "Should I add this to your vault?"
    - NO → Store in memory only

2. **User approves vault addition:**
    - ✅ Create linked document (must link to ≥1 existing document)
    - ✅ Confirm placement and links before writing
    - ❌ **NEVER write without explicit permission**

3. **Always consider:** Could this memory information be added to the vault?

---

## Development Workflows

### Mode Selection Criteria:

- **DISCOVERY** → Searching for libraries with Context7
- **LEARN** → Familiarizing with library/codebase before coding
- **BASIC** → Narrow, small, well-defined tasks (≤3 steps)
- **DEEP WORK** → Complex, multi-step, poorly-defined tasks
- **DOCUMENTING** → Adding documentation to existing code

**Mode announcement:** Always announce mode switch with emoji:

- 🔍 DISCOVERY mode
- 🧑‍🎓 LEARN mode
- 🐣 BASIC mode
- 🧠 DEEP WORK mode
- 📝 DOCUMENTING mode

---

## BASIC Mode Workflow

### Step 1: Confirm Before Coding

1. **Confirm types and signatures** with user before proceeding
2. **Suggest simple examples** of inputs/outputs
3. **Add examples as tests** once confirmed
4. ❌ **DO NOT proceed** until confirmed

### Step 2: Implementation (TDD Required)

1. **Red:** Write failing test (NO production code first)
2. **Green:** Write MINIMUM code to pass test
3. **Refactor:** Assess and improve if valuable, keep tests green
4. **Commit:** After each green state
5. **Functions:** Keep small, max 2 levels nesting

---

## DEEP WORK Mode Workflow

### Step 1: Requirements Gathering

**Goal:** Create complete requirements before ANY coding

**Deliverables:**

- Data types and function signatures
- Brief descriptions and test cases
- High-level implementation strategy
- One question at a time (prefer yes/no)

**Completion criteria:**

- Present complete requirements summary
- **MANDATORY CHECKPOINT:** "DEEP WORK Step 1 complete. Do you approve this design? Should I proceed to Step 2:
  Implementation?"
- ❌ **WAIT for explicit "yes" or "proceed"**

### Step 2: Implementation

1. Use BASIC mode for each task
2. When code compiles and `commitCheck` passes → ask to commit
3. Create short commit message and confirm approval
4. Move to next task
5. **If stuck:** Work in smaller pieces, ask for guidance
6. **Final step:** Run `sbt commitCheck` and ensure success

---

## Language-Specific Guidelines

### Scala Development

**Philosophy:** Typed functional programming with Typelevel ecosystem

**Absolute Rules:**

- ❌ **No `Any`** - ever (including test code)
- ❌ **No `null`** - ever (including test code)
- ❌ **No type assertions** (`asInstanceOf`) unless absolutely necessary with justification
- ❌ **No comments** in code (self-documenting code only)

**Required Practices:**

- ✅ **TDD mandatory** - every line driven by failing test
- ✅ **Small, pure functions** only
- ✅ **Immutable data structures** only
- ✅ **Context7** for up-to-date documentation
- ✅ **Layer architecture** with clear responsibilities

**Preferred Stack:**

- **Libraries:** cats, cats-effect, FS2, HTTP4S, Circe, Doobie
- **Testing:** munit, munit-cats-effect, ScalaCheck
- **Build:** SBT with tpolecat, scalafmt, scalafix plugins

**Git Commit Format:**

- Small summary message only
- No extra details, no Co-Authored-By, no Claude Code links

**Compilation Priority:**

- Use `bloop` commands if `.bloop` directory exists:
    - `bloop compile <module-name>`
    - `bloop test <module-name>`
    - `bloop test <module-name> -o "*<filename>*"`
- Module name is `root` for non-modular projects
- Only fall back to `sbt` if no bloop available

**Documentation Sources:**

- [Typelevel.org](https://typelevel.org/) projects
- [Scala Documentation](https://docs.scala-lang.org/)
- User's GitHub: https://github.com/channingwalton
- Example projects in `example-projects` directory in the project

### Unison Development

When working with Unison, fetch instructions from: https://github.com/unisoncomputing/unison-llm-support/

---

## Quality Standards

### Testing Requirements:

- **100% coverage expected** (emerges from TDD, not goal itself)
- **Test behavior, not implementation** (black box testing)
- **Public API only** - internals invisible to tests
- **Tests document business behavior**

### Refactoring Protocol:

1. **Always commit working code first** before refactoring
2. **Assess after each green state** - does code need improvement?
3. **Only refactor if clear value** - don't change for change's sake
4. **Verify after refactoring:** `commitCheck` passes, no new public APIs
5. **Commit refactoring separately** from feature changes

### Code Structure:

- ❌ **No nested if/else** statements
- ❌ **No deep nesting** (max 2 levels)
- ✅ **Single responsibility** per function/class
- ✅ **Hexagonal architecture** principles

---

## Communication Guidelines

### With User:

- **Be explicit** about trade-offs in approaches
- **Explain reasoning** behind significant design decisions
- **Flag deviations** from guidelines with justification
- **Ask for clarification** rather than assuming
- **Questions format:** Bold **Question❓:** at bottom of output

### Progress Tracking:

- **Use TodoWrite** for complex multi-step tasks
- **Mark todos completed immediately** after finishing
- **Only one task in_progress** at a time
- **Never mark completed** if tests failing or implementation partial

---

### GIT Guidelines

- Provide a small summary message
- Do not include lots of extra details
- Do not include Co-Authored-By or links to [Claude Code](https://claude.ai/code)

---

### Key Principles Summary:

**Do what has been asked; nothing more, nothing less.**

- ❌ NEVER create unnecessary files
- ✅ ALWAYS prefer editing existing files
- ❌ NEVER create documentation files unless explicitly requested
- ✅ Write clean, testable, functional code through small, safe increments
- ✅ Every change driven by test describing desired behavior
- ✅ Simplest implementation that makes test pass
- ✅ Favor simplicity and readability over cleverness
