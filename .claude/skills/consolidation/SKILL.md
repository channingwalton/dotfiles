---
name: Consolidation
description: Consolidate atomic memories from MCP-Memory into Obsidian vault knowledge notes. Bridges episodic memory (experiences) with semantic knowledge (curated facts). Structure emerges from links, not naming conventions.
---

# Consolidation (Memory → Vault)

## Purpose

Memory and knowledge serve different functions:

| Layer | Type | Content | Update Pattern |
|-------|------|---------|----------------|
| MCP Memory | Episodic | Experiences, observations, atomic facts | Append-only, decay |
| Obsidian Vault | Semantic | Curated knowledge, structured notes | Consolidate, version |

Consolidation **distils** valuable memories into permanent knowledge notes.

## Workflow

### 1. Gather Unconsolidated Memories

```bash
# By recency
recall_memory("last week")

# By domain tag
search_by_tag(["unison"])
search_by_tag(["scala"])

# Exclude already consolidated
# Look for memories WITHOUT "consolidated" tag
```

### 2. Classify Memories

| Type | Action |
|------|--------|
| Reusable pattern/technique | Consolidate → vault |
| Project-specific detail | Keep in memory (episodic) |
| Already documented | Mark consolidated, skip |
| Trivial/ephemeral | Tag `ephemeral`, skip |

**Project-specific memories stay episodic** — they support active work and don't generalise.

### 3. Find Existing Notes

Before creating anything new, search for existing notes:

```bash
# Find notes mentioning topic
rg --type md -l -i "<topic>" ~/Documents/Notes

# Check HowTo and Development folders
find ~/Documents/Notes/Development ~/Documents/Notes/HowTo -name "*.md" | xargs grep -l -i "<topic>"

# Find notes already linking to topic
rg --type md -l "\[\[<topic>" ~/Documents/Notes
```

**Extend existing notes rather than creating new ones.**

### 4. Consolidation Targets

| Memory Type | Target |
|-------------|--------|
| Language technique | `Development/<Language>.md` or `HowTo/` |
| Library/tool pattern | Existing note for that tool, or `HowTo/` |
| Reusable pattern | `Development/` or `HowTo/` |
| Workflow/process | `Tools/` or `Process/` |
| **Claude workflow improvement** | **Skill in `~/.claude/skills/`** |

**Vault vs Skill distinction:**

- Vault = declarative knowledge (facts, patterns, gotchas) — for human and Claude reference
- Skill = procedural knowledge (how Claude should operate) — instructions for Claude

Ask: "Is this about **what** (→ vault) or **how Claude should work** (→ skill)?"

### 5. Update Notes

**Extend existing note** — append observations using hashtag markers:

- `#pattern` — Pattern or principle
- `#gotcha` — Something that catches people out
- `#technique` — Useful approach
- `#reference` — Factual information, API details
- `#decision` — Why X was chosen over Y

Example:

```markdown
## Section Name

- #gotcha LazyVim uses fzf-lua by default, not telescope
- #technique Configure with `hidden = true` to show dotfiles
```

**Create new note** — only when no existing note covers the topic. Use Knowledge Note Template from vault skill.

### 6. Splitting Notes

**Split when a note covers distinct concepts.** Signs a split is needed:

- Note has sections that could stand alone
- Sections have different audiences or contexts
- One concept is a specific instance of another (e.g., LazyVim is a Neovim distribution)

After splitting, link the notes to each other.

### 7. Add WikiLinks

Link new/updated notes to related notes:

```bash
# Find related notes to link
rg --type md -l "\[\[<topic>" ~/Documents/Notes
```

Add links in a `## Related` section or inline where contextually appropriate.

### 8. Hub Notes (Not MOCs)

**Any note can become a hub** by accumulating links to related notes. No special naming needed.

A note naturally becomes a hub when:

- It links to 5+ related notes
- It serves as an entry point for a topic area
- Other notes link back to it

**Don't pre-create hubs.** Let them emerge from the link structure.

Example: `Unison Programming Language.md` became a hub by adding Related section:

```markdown
## Related

- [[Unison Web Application Patterns]]
- [[Unison Testing with Effect Handlers]]
- [[Unison Route Patterns]]
```

### 9. Mark Memory as Consolidated

```
update_memory_metadata(content_hash, {"tags": [...existing, "consolidated"]})
```

## Tag Conventions

| Tag | Meaning |
|-----|---------|
| `consolidated` | Memory distilled into vault |
| `ephemeral` | Do not consolidate, will decay |
| Domain tags | Topic area (unison, scala, patchwork) |
| Project tags | Project name |

## Quality Heuristics

**Worth consolidating:**

- Patterns that apply across contexts
- Gotchas that caused debugging time
- Techniques that save time
- Decisions with reasoning worth preserving
- Library/API knowledge that's hard to find

**Skip consolidation:**

- Project-specific context (keep as episodic memory)
- Information already in project files
- Trivial facts
- Already documented in vault

## When to Consolidate

Batch at natural breakpoints, not after every task:

- End of work session
- Switching projects
- Weekly review
- When memory count feels high (~50+ unconsolidated)

**Don't interrupt flow** — consolidation is reflection time, not task overhead.

## Commands

```
# Full consolidation workflow
"consolidate memories"

# Preview without writing
"what memories need consolidating?"

# Domain-specific
"consolidate unison memories"

# Check status
"how many memories are consolidated?"
```

## Consolidation Checklist

1. [ ] Retrieve unconsolidated memories
2. [ ] Classify: consolidate vs keep episodic vs skip
3. [ ] Search for existing notes to extend
4. [ ] Append observations with hashtag markers
5. [ ] Consider splitting bloated notes
6. [ ] Add WikiLinks to related notes
7. [ ] Mark memories as consolidated
