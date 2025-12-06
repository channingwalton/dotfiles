---
name: Memory
description: Persist and retrieve information using the MCP Memory Server. Use before starting work to search existing knowledge, and after completing tasks to store learnings. Essential for maintaining context across sessions.
---

# Memory (MCP Memory Server)

## Before Starting Work

Search existing memory first:
- Search matches entity names, types, AND observation content
- Start with specific terms (`foggysky`, `foggysky-authentication`)
- Use hyphenated entity names for precise retrieval

## After Completing Tasks

Add information with UTC timestamp:
- Format: `YYYY-MM-DDTHH:mm:ssZ [observation]`
- Claude Desktop: `new Date().toISOString()` in analysis tool
- Claude Code: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- For contradictions: remove old memory first

## Entity Structure (Fine-Grained)

✅ ONE fact per observation — never combine multiple facts
✅ Atomic entities — split by component/feature/concern
✅ Naming: `project component feature keywords` (searchable full words)
❌ No code blocks, paragraphs, or documentation dumps

## Relations

Link entities with: `depends-on`, `solves`, `uses`, `implements`
Avoid duplicating information across entities.
