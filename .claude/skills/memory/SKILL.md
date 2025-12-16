---
name: Memory
description: Persist and retrieve information using the MCP-Memory Server. Use before starting work to search existing knowledge, and after completing tasks to store learnings. Essential for maintaining context across sessions.
---

# Memory (MCP Memory Server)

## Before Starting Work

Search existing memory first:

- Matches entity names, types, AND observation content
- Start with specific terms (`foggysky`, `foggysky-authentication`)

## After Completing Tasks

Add information with UTC timestamp after tasks that would potentially be useful
in the future.

## Entity Structure

✅ ONE fact per observation — never combine multiple facts
✅ Atomic entities — split by component/feature/concern
❌ No code blocks, paragraphs, or documentation dumps

**Good naming:**

- `foggyball-authentication-jwt`
- `orders-database-schema`
- `scala-bloop-commands`

**Bad naming:**

- `auth` (too vague)
- `stuff I learned today` (not searchable)

## Relations

Link entities with: `depends-on`, `solves`, `uses`, `implements`, `related-to`
Avoid duplicating information across entities.

## When NOT to Store

- Ephemeral session-specific details
- Information easily found in project files
- Trivial facts that don't aid future work
- Sensitive credentials or secrets
