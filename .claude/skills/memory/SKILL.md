---
name: Memory
description: Persist and retrieve information using the MCP-Memory Server. Session start/end context is handled automatically by hooks. Use tools mid-session for explicit storage and retrieval.
---

# Memory (MCP Memory Server)

**MCP Server**: mcp-memory

## Automatic triggers via hooks

- **Session Start**: Relevant memories injected automatically based on project context
- **Session End**: Insights captured automatically when conversation ends
- **Mid-Conversation**: Pattern detection triggers memory retrieval (e.g., "what did we decide about...")

## Manual Tools

When you need context the hooks didn't provide:

- `retrieve_memory` — semantic search by content
- `recall_memory` — natural language time queries ("last week", "yesterday")
- `search_by_tag` — find memories by project/topic tags

## Storing Memories

Use `store_memory` when triggers below are met:

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
❌ No code blocks or documentation dumps

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
- Trivial facts that won't aid future work
- Sensitive credentials or secrets
- Standard library usage (use Context7 instead)
- One-off tasks unlikely to recur
