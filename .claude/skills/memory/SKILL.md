---
name: Memory
description: Persist and retrieve information using the MCP-Memory Server. Use before starting work to search existing knowledge, and after completing tasks to store learnings. Essential for maintaining context across sessions.
---

# Memory (MCP Memory Server)

## Before Starting Work

Search existing memory first:

- `retrieve_memory` — semantic search by content
- `recall_memory` — natural language time queries ("last week", "yesterday")
- `search_by_tag` — find memories by tags

## After Completing Tasks

Store information with `store_memory`:

```json
{
  "content": "One atomic fact or learning",
  "metadata": {
    "tags": "project-name,topic,category",
    "type": "note"
  }
}
```

## Content Structure

✅ ONE fact per memory — never combine multiple facts
✅ Atomic memories — split by component/feature/concern
✅ Use descriptive tags for searchability
❌ No code blocks, paragraphs, or documentation dumps

**Good tags:** `foggyball-auth`, `scala-bloop`, `database-schema`
**Bad tags:** `stuff`, `misc`, `temp`

## When NOT to Store

- Ephemeral session-specific details
- Information easily found in project files
- Trivial facts that don't aid future work
- Sensitive credentials or secrets
