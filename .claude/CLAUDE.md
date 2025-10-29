# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

0. British spelling
1. TEST-DRIVEN DEVELOPMENT IS MANDATORY
2. MEMORY FIRST (MCP Memory Server)
  - **BEFORE starting project tasks:** Search existing memory
    - **Search matches:** entity names, entity types, AND observation content
    - **Best practice:** Start with specific terms (`foggysky`, `foggysky-authentication`)
    - **Multi-term searches work** if terms appear in observations
    - **Use hyphenated entity names** for precise retrieval
  
  - **AFTER completing project tasks:** Add information with UTC timestamp
    - **Format:** `YYYY-MM-DDTHH:mm:ssZ [observation]`
    - **Timestamp by environment:**
      - Claude Desktop: `new Date().toISOString()` in analysis tool
      - Claude Code: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
      - Fallback: State timestamp may be inaccurate
    - **For contradictions:** Remove the old memory
  
  - **Entity Structure (Fine-Grained):**
    - ✅ **ONE fact per observation** - never combine multiple facts
    - ✅ **Atomic entities:** Split by component/feature/concern
    - ✅ **Naming:** `project component feature keywords` (use searchable full words)
    - ❌ **No code blocks, paragraphs, or documentation dumps**
  - **Use Relations:**
    - Link entities with `depends-on`, `solves`, `uses`, `implements`
    - Avoid duplicating information across entities
  
3. Use the sequential thinking tool for complex tasks
4. Use the perplexity MCP tool to find information on the internet
5. Use the fetch tool to get information from websites
6. Use the Context7 tool to get library documentation
7. **NEVER** commit code without permission

---

## Communication Guidelines

- **ALWAYS Explain reasoning** behind significant design decisions
- **ALWAYS explain deviations** from guidelines with justification
- **ALWAYS ask for clarification** rather than assuming
- Questions format: Bold **Question❓**
- **ALWAYS** put questions at the bottom of output so I can see them
