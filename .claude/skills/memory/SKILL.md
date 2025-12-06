---
name: Memory
description: Persist and retrieve information using the MCP Memory Server. Use before starting work to search existing knowledge, and after completing tasks to store learnings. Essential for maintaining context across sessions.
---

# Memory (MCP Memory Server)

## Tools

- `memory:search_nodes` — find entities by query
- `memory:read_graph` — view entire knowledge graph
- `memory:open_nodes` — retrieve specific entities by name
- `memory:create_entities` — add new entities with observations
- `memory:add_observations` — add facts to existing entities
- `memory:create_relations` — link entities together
- `memory:delete_entities` / `delete_observations` / `delete_relations` — remove data

## Before Starting Work

Search existing memory first with `search_nodes`:
- Matches entity names, types, AND observation content
- Start with specific terms (`foggysky`, `foggysky-authentication`)
- Use hyphenated entity names for precise retrieval

## After Completing Tasks

Add information with UTC timestamp:
- Format: `YYYY-MM-DDTHH:mm:ssZ [observation]`
- Claude Desktop: `new Date().toISOString()` in analysis tool
- Claude Code: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- For contradictions: delete old observation first, then add new

## Entity Structure

✅ ONE fact per observation — never combine multiple facts
✅ Atomic entities — split by component/feature/concern
✅ Naming: `project-component-feature` (hyphenated, searchable)
❌ No code blocks, paragraphs, or documentation dumps

**Good naming:**
- `foggyball-authentication-jwt`
- `orders-database-schema`
- `scala-bloop-commands`

**Bad naming:**
- `auth` (too vague)
- `stuff I learned today` (not searchable)
- `foggyball` (too broad — split by concern)

## Relations

Link entities with: `depends-on`, `solves`, `uses`, `implements`, `related-to`
Avoid duplicating information across entities.

## When NOT to Store

- Ephemeral session-specific details
- Information easily found in project files
- Trivial facts that don't aid future work
- Sensitive credentials or secrets
