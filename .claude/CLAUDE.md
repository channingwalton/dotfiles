# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

0. British spelling
1. TEST-DRIVEN DEVELOPMENT IS MANDATORY
2. MEMORY FIRST
  - **BEFORE starting any task:** Search existing memory
    - **Use single terms:** `foggysky` or `foggysky-authentication` or `postgresql`
    - **NOT multi-term:** ~~`foggysky database auth`~~ (returns zero)
    - **Memory matches entity NAMES only**, not observation content
  
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
  
  - **Memory vs Vault:**
    - **Memory:** All insights, progress, solutions (comprehensive log)
    - **Vault:** Only reusable patterns and substantial insights (curated knowledge)
  
  - **Obsidian Vault:** `~/Documents/Notes/` - **ALWAYS** suggest vault updates for reusable insights
3. Use the Development Workflows described below
4. Use the perplexity MCP tool to find information on the internet
5. Use the sequential thinking tool for complex tasks
6. Use the fetch tool to get information from websites
7. **NEVER** commit code without permission

---

## OBSIDIAN VAULT MAINTENANCE

**Location:** `~/Documents/Notes/` 

### When to Update Vault (Beyond Memory)

**ALWAYS ASK to update vault files when:**
- **New reusable patterns** emerge from problem-solving
- **Technical insights** that apply beyond current project
- **Hard-won knowledge** that would be expensive to rediscover
- **Project architectures** become substantial enough to document
- **Solutions to complex problems** that others might face

### Update Decision Tree

1. **Is this a general pattern/technique?** → Create/enhance a HowTo guide
2. **Is this project-specific progress?** → Enhance existing project overview
3. **Is this a new significant project?** → Create new project file
4. **Is this a bug fix or small task?** → Memory only (don't clutter vault)

### HowTo Guide Strategy

**Create NEW HowTo when:**
- **No existing guide** covers the technique
- **Substantially different approach** than existing guides
- **Cross-cutting concern** that applies to multiple technologies
- Add links to relevant guides or documents in the vault

**ENHANCE existing HowTo when:**
- **Adding patterns** to established technique
- **Discovered edge cases** or gotchas
- **Better examples** or clearer explanations

### Project Overview Strategy

**Enhance existing project when:**
- **Architecture evolves** significantly
- **New major components** added
- **Key technical challenges** solved
- **Technology stack** changes

**Create new project when:**
- **Completely different** technology/approach
- **Substantial independent** effort (>1 week)
- **Different problem domain** than existing projects

### Cross-Linking Requirements

**MANDATORY for all vault updates:**
1. **Link to [[HowTo]] index** from new HowTo guides
2. **Link FROM relevant existing files** to new content
3. **Link TO relevant existing files** from new content
4. **Update parent indices** (Projects.md, HowTo.md, etc.)
5. **Use explicit wikilinks** throughout: `[[Technology]]`, `[[Related Pattern]]`

### Vault Update Process

**During DEEP WORK mode:**
- **After Step 1:** Consider if insights warrant vault updates
- **After Step 2:** Update vault with architectural insights and patterns

**During BASIC mode:**
- **After each task:** Check if reusable patterns emerged
- **Only update vault** if pattern applies beyond current context

**During problem-solving sessions:**
- **ALWAYS ask:** "Is this technique reusable?"
- **ALWAYS ask:** "Would this save time if documented?"
- **ALWAYS ask:** "Does this enhance existing documentation?"

### Maintenance Schedule

**Weekly:** Review memory for vault-worthy insights
**Per project completion:** Update relevant project overview
**When switching contexts:** Consider creating a HowTo from recent patterns

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

## Unison Development
1. **ALWAYS check memory first** for unison language-reference
2. **If NOT found:** Fetch from https://www.unison-lang.org/docs/#language-reference
3. **ALWAYS** Type check everything using the unison MCP tool

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
- ✅ **BEFORE using any library:** Search Context7 for up-to-date documentation

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
- **Vault Maintenance Reminders:**
  - **When switching projects:** "Should I update project overviews with recent insights?"
  - **After solving complex problems:** "Should this become a HowTo guide?"
  - **When discovering new patterns:** "Is this worth documenting for future use?"
  - **During weekly reviews:** "What memory insights should be added to the vault?"

