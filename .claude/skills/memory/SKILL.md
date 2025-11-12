---
name: Memory
description: Use the memory MCP server to record important information.
allowed-tools: Memory
---

# MEMORY FIRST (MCP Memory Server)

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
