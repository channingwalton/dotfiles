# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

0. I prefer British spelling
1. TEST-DRIVEN DEVELOPMENT IS MANDATORY
2. MEMORY FIRST
  - Retrieve relevant information from the knowledge graph when starting tasks
  - Update your memory after tasks with relevant information for future use
    - Include a UTC timestamp in the memory entry "YYYY-MM-DD:HH:mm:ss [observation]" 
    - For contradictions add a reference to the contradictory memory stating new info supersedes old
  - Obsidian Vault Integration
    - Location `~/Documents/Notes/` (Projects in `~/Documents/Notes/Projects`)  
    - Link format `[[Document Name]]` (no file extension)  
    - Always consider whether new information is worth adding to the vault
3. Use the Development Workflows described below

---

## Development Workflows

Use the following modes and announce when switching mode:

- 🔍 **DISCOVERY** → Searching for libraries with Context7
- 🧑‍🎓 **LEARN** → Familiarizing with library/codebase before coding
- 🐣 **BASIC** → Narrow, small, well-defined tasks (≤3 steps)
- 🧠 **DEEP WORK** → Complex, multi-step, poorly-defined tasks
- 📝 **DOCUMENTING** → Adding documentation to existing code

---

## BASIC Mode Workflow

### Step 1: Confirm Before Coding

1. **Confirm types and signatures** with user before proceeding
2. **Suggest simple examples** of inputs/outputs
3. **Add examples as tests** once confirmed
4. ❌ **DO NOT proceed** until confirmed

### Step 2: Implementation

1. **Red:** Write failing test (NO production code first)
2. **Green:** Write MINIMUM code to pass test
3. **Refactor:** Assess and improve if valuable, keep tests green
4. **Commit:** After each green state

---

## DEEP WORK Mode Workflow

- **Step 1: Goal**
  - Obtain deeper understanding by asking questions, analysing the codebase, and documentation
  - Produce a markdown document containing:
    - Requirements
    - Data types and function signatures
    - Brief descriptions and test cases
    - A task list
    - Completion criteria
    - Ask if I want to proceed to Step 2
- **Step 2: Implementation**
  - Use BASIC mode for each task
  - When completing a task ask if I want to check the task off in the document
  - Ask before proceeding to the next task
  - **If stuck:** Work in smaller pieces, ask for guidance, update the task list in the document if necessary

---

## Git Commit Format

- Small summary message only
- No extra details
- No Co-Authored-By or links

## Scala Development

**Philosophy:** Typed functional programming
- ❌ **No `Any`**
- ❌ **No `null`**
- ❌ **No type assertions** (`asInstanceOf`, `isInstanceOf`)
- ❌ **No comments** in code (self-documenting code only)

**Required Practices:**
- ✅ **TDD mandatory** - every line driven by failing test
- ✅ **Small, pure functions** only
- ✅ **Immutable data structures** only
- ✅ Use **Context7** for up-to-date documentation

**Compilation Priority:**

- If the project contains a `.bloop` directory
  - use `bloop` on the command line
  - `bloop compile <module-name>`
  - `bloop test <module-name>`
  - `bloop test <module-name> -o "*<filename>*"`
  - Module name is `root` for non-modular projects
- Use `sbt` if no `.bloop` directory exists

**Documentation Sources:**

- [Typelevel.org](https://typelevel.org/)
- [Scala Documentation](https://docs.scala-lang.org/)
- Context7 MCP tool

## Communication Guidelines

- **Explain reasoning** behind significant design decisions
- **Flag deviations** from guidelines with justification
- **Ask for clarification** rather than assuming
- **Questions format: ** Bold **Question❓** at bottom of output

