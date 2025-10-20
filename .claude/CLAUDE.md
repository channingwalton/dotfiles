# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

0. British spelling
1. TEST-DRIVEN DEVELOPMENT IS MANDATORY
2. MEMORY FIRST (MCP Memory Server)
  - **BEFORE starting any task:** Search existing memory
    - **Search matches:** entity names, entity types, AND observation content
    - **Best practice:** Start with specific terms (`foggysky`, `foggysky-authentication`)
    - **Multi-term searches work** if terms appear in observations
    - **Use hyphenated entity names** for precise retrieval
  
  - **AFTER completing any task:** Add information with UTC timestamp
    - **Format:** `YYYY-MM-DDTHH:mm:ssZ [observation]`
    - **Timestamp by environment:**
      - Claude Desktop: `new Date().toISOString()` in analysis tool
      - Claude Code: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
      - Fallback: State timestamp may be inaccurate
    - **For contradictions:** Reference old memory, state new info supersedes
  
  - **Entity Structure (Fine-Grained):**
    - ✅ **ONE fact per observation** - never combine multiple facts
    - ✅ **Atomic entities:** Split by component/feature/concern
    - ✅ **Naming:** `project-component-feature` (use searchable full words)
    - ❌ **No code blocks, paragraphs, or documentation dumps**

  - Obsidian Vault
    - interconnected markdown notes
    - Location: ~/channing/Documents/Notes
    - Project notes location in the vault in the `Projects` directory
    - link format: [[OtherNote]]
    - Consider Add memories to the vault when adding memories
    - **ALWAYS** ask if I want to add memories to my vault
    - **When switching projects:** "Should I update project overviews with recent insights?"
    - **After solving complex problems:** Consider adding a `HowTo` under the `HowTo` directory
    - **When discovering new patterns:** "Is this worth documenting for future use?"

    **Entity Decomposition:**
    ```
    project-overview          # High-level only
    project-architecture      # Architectural decisions
    project-stack-language    # Language choice
    project-stack-database    # Database tech
    project-feature-X         # Individual features
    project-issue-N           # Specific problems
    project-solution-N        # Specific solutions
    ```
    
    **Use Relations:**
    - Link entities with `depends-on`, `solves`, `uses`, `implements`
    - Avoid duplicating information across entities
  
3. Use the Development Workflows described below
4. Use the sequential thinking tool for complex tasks
5. Use the perplexity MCP tool to find information on the internet
6. Use the fetch tool to get information from websites
7. Use the Context7 tool to get library documentation
8. **NEVER** commit code without permission

---

## Development Workflows

Use the following modes and announce when switching mode:

- 🔍 **DISCOVERY** → Searching for libraries with Context7
- 🧑‍🎓 **LEARN** → Familiarizing with library/codebase before coding
- 📋 **PLAN** → Steps to implement
- 🐣 **IMPLEMENT** → Narrow, small, well-defined tasks (≤3 steps)
- 📝 **DOCUMENTING** → Adding documentation to existing code

---

## Implement Workflow

### Step 1: Confirm Before Coding

0. **MANDATORY** Test driven development
1. **Confirm types and signatures** with user before proceeding
2. **Suggest simple examples** of inputs/outputs
3. **Add examples as tests** once confirmed
4. **DO NOT proceed** until confirmed
5. **ALWAYS** commit changes between tasks

### Step 2: Implementation
1. **Red:** Write failing test (NO production code first)
2. **Green:** Write MINIMUM code to pass test
3. **MANDATORY:** Run tests to verify green state before proceeding
4. **Commit:** Only after confirmed green state
5. **Refactor:** Assess and improve if valuable, keep tests green

**Philosophy:** Typed functional programming
- ❌ **No `Any`**
- ❌ **No `null`**
- ❌ **No type assertions** (`asInstanceOf`, `isInstanceOf`)
- ❌ **No comments** in code (self-documenting code only)
- ✅ **Small, pure functions** only
- ✅ **Immutable data structures** only
- ✅ **BEFORE using any library:** Search Context7 for up-to-date documentation

---

## Git Commit Format

- Small summary message only
- No extra details
- No Co-Authored-By or links

## Unison Development
1. **ALWAYS check memory first** for unison language-reference
2. **If NOT found:** Fetch from https://www.unison-lang.org/docs/#language-reference
3. **ALWAYS** Type check everything using the unison MCP tool

## Scala Development

**Compilation Priority:**

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

## Communication Guidelines

- **ALWAYS Explain reasoning** behind significant design decisions
- **ALWAYS explain deviations** from guidelines with justification
- **ALWAYS ask for clarification** rather than assuming
- Questions format: Bold **Question❓**
- **ALWAYS** put questions at the bottom of output so I can see them
