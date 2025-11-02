# Claude Configuration

## CORE PRINCIPLES (Non-Negotiable)

0. British spelling
1. MEMORY FIRST (MCP Memory Server)
  - **BEFORE starting work:** Search existing memory
    - **Search matches:** entity names, entity types, AND observation content
    - **Best practice:** Start with specific terms (`foggysky`, `foggysky-authentication`)
    - **Multi-term searches work** if terms appear in observations
    - **Use hyphenated entity names** for precise retrieval

  - **AFTER completing tasks:** Add information with UTC timestamp
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
2. Use the sequential thinking tool for complex tasks
3. Use the perplexity MCP tool to find information on the internet
4. Use the fetch tool to get information from websites
5. Use the Context7 tool to get library documentation
6. **ALWAYS Explain reasoning** behind significant design decisions
7. **ALWAYS explain deviations** from guidelines with justification
8. **ALWAYS ask for clarification** rather than assuming
9. Questions format: Bold **Question❓**
10. **ALWAYS** put questions at the bottom of output so I can see them
