---
name: glossary
description: Add domain terms to project glossary in the Obsidian vault. Use when defining new terms, clarifying jargon, or when unfamiliar terminology appears in requirements.
---

# Glossary

Add domain terms to project glossaries in the Obsidian vault.

## Vault Location

`~/Documents/Notes/Projects/<YYYY[-MM] Project>/Glossary.md`

## Workflow

1. Search for existing term: `rg -i "<term>" ~/Documents/Notes/Projects/*<project>*/Glossary.md`
2. If not found, add using the format below

## Entry Format

```markdown
## Term Name

**Definition:** Clear, concise definition in plain language.

**Context:** Where/how this term is used in the project.

**Also known as:** Alternative names, abbreviations, or synonyms.

**Related:** [[Link to related terms or concepts]]

**Example:** Concrete example of the term in use.
```

For simple terms, **Definition** alone is sufficient.

## Example

```markdown
## Roster

**Definition:** A scheduled assignment of workers to shifts over a defined period.

**Context:** Core concept in workforce management. Contains shift assignments for multiple workers across days/weeks.

**Also known as:** Schedule, rota, shift pattern

**Related:** [[Shift]], [[Worker]], [[Duty]]
```

## Guidelines

- Plain language — avoid defining jargon with more jargon
- Link generously to related terms
- Update definitions as understanding evolves
