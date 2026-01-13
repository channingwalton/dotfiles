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

## Quality Criteria (for HIGH scores ≥0.7)

The MCP Memory Service scores memories 0.0-1.0 using AI + usage signals.

### Content Quality (DeBERTa classifier - 70% weight)

| DO | DON'T |
|----|-------|
| Specific, concrete details | Vague ("maybe", "todo", "look into") |
| Self-contained context | Requires external knowledge |
| Include rationale/why | Just facts without reasoning |
| Searchable keywords | Generic terms |

**Example HIGH:**
```
Python async: Use `asyncio.gather(return_exceptions=True)` for parallel API calls.
Prevents one timeout from cancelling siblings. Learned debugging webhook handler.
```

**Example LOW:**
```
async stuff - gather does something with exceptions?
```

### Usage Signals (30% weight)

- **Access frequency** (40%) — Store things you'll search for
- **Recency** (30%) — Active knowledge beats stale
- **Search ranking** (30%) — Use specific, findable terms

### Network Bonuses

| Tag | Retention Multiplier |
|-----|---------------------|
| `critical` | 2.0× |
| `important` | 1.5× |
| `reference` | 1.3× |

Memories with ≥5 connections to others get +20% quality boost.

### Quality Checklist

Before storing, verify:
- [ ] One atomic fact (not multiple combined)
- [ ] Includes context/rationale
- [ ] Contains searchable keywords
- [ ] Tagged with project + topic
- [ ] Would be useful if retrieved in 6 months
