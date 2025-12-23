---
name: Memory
description: Persist and retrieve information using the MCP-Memory Server. Use before starting work to search existing knowledge, and after completing tasks to store learnings. Essential for maintaining context across sessions.
---

# Memory (MCP Memory Server)

## Session Start

Search existing memory for relevant context:

- `retrieve_memory` — semantic search by content
- `recall_memory` — natural language time queries ("last week", "yesterday")
- `search_by_tag` — find memories by project/topic tags

Query examples: current project name, technology stack, user preferences

## Session End (before user leaves)

Review the session and store any insights matching the triggers below. Don't wait to be asked.

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

## Automatic Storage Triggers

Store a memory when ANY of these occur:

1. **User corrects me** — their preferred approach/style
2. **Non-obvious solution found** — debugging insight that took effort
3. **Project convention discovered** — naming, structure, patterns not in docs
4. **User expresses preference** — explicit or implied ("I prefer X")
5. **Custom tooling encountered** — scripts, aliases, workflows unique to user
6. **Architectural decision made** — and its rationale
7. **Recurring issue identified** — something that keeps coming up
8. **Domain knowledge learned** — business logic, terminology, constraints

## When NOT to Store

- Ephemeral session-specific details
- Information easily found in project files
- Trivial facts that don't aid future work
- Sensitive credentials or secrets
- Standard library usage (use Context7 instead)
- One-off tasks unlikely to recur
