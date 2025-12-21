---
name: Consolidation
description: Consolidate atomic memories from MCP-Memory into Obsidian vault knowledge notes. Bridges episodic memory (experiences) with semantic knowledge (curated facts). Structure emerges from links, not naming conventions.
---

# Consolidation

This skill invokes the `consolidation` agent to distil memories into vault knowledge.

## Quick Reference

**Invoke:** `/consolidation [scope]`

**Scopes:**
- Domain tag (e.g., "unison", "scala")
- Time range (e.g., "last week")
- No argument = all unconsolidated memories

## Memory vs Knowledge

| Layer | Type | Content | Update Pattern |
|-------|------|---------|----------------|
| MCP Memory | Episodic | Experiences, observations, atomic facts | Append-only, decay |
| Obsidian Vault | Semantic | Curated knowledge, structured notes | Consolidate, version |

## Vault vs Skill Distinction

- **Vault** = declarative knowledge (facts, patterns, gotchas) — for reference
- **Skill** = procedural knowledge (how Claude should operate) — instructions

Ask: "Is this about **what** (→ vault) or **how Claude should work** (→ skill)?"

## Agent Behaviour

The consolidation agent:
1. Gathers unconsolidated memories
2. Classifies: consolidate / keep episodic / skip
3. Searches for existing vault notes to extend
4. Appends observations with hashtag markers
5. Adds WikiLinks to related notes
6. Marks memories as consolidated
7. Returns summary report

Runs autonomously without user interaction.

## When to Consolidate

Batch at natural breakpoints:
- End of work session
- Switching projects
- Weekly review
- When memory count feels high (~50+ unconsolidated)

**Don't interrupt flow** — consolidation is reflection time.
