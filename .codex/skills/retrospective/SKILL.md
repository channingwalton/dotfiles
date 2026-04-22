---
name: retrospective
description: Use at the end of a software-development session when the user asks how it went, what could be improved, how well the skill worked, or says "retrospective" / "retro" / "what did we learn". Surfaces gaps in the software-development skill itself and proposes targeted edits to fix them.
---

# Retrospective

## Overview

Run **after** a software-development session. Reflect honestly on what worked and what didn't, then feed process-level learnings back into the software-development skill so next session is better.

**Core principle:** A retrospective is worthless without a concrete change. Every useful finding produces either a skill-file edit or a vault/memory entry. Anything else is venting.

## When to Use

Triggers:
- "How well did [the skill / that / it] work?" / "How did that go?"
- "What could we improve?" / "retro" / "what did we learn"
- End of a feature/task, after commit, before moving on

**Not for** mid-task check-ins or routine status reports.

## The Process

```
1. AUDIT    — Two lists: worked / didn't. One sentence per item, concrete.
2. SORT     — Each "didn't" item: skill gap or work lesson?
3. LOCATE   — For skill gaps: name the file and section.
4. PROPOSE  — Write the exact edit (before/after).
5. CONFIRM  — Ask "apply these?" — do nothing without a yes.
6. APPLY    — Edit skill files once approved.
```

### Sort: skill gap vs. work lesson

| Finding | Goes to |
|---------|---------|
| Rule that applies to any project | Skill file edit |
| Discipline slipped (knew rule, skipped it) | Skill edit + red-flag counter |
| Codebase-specific tripwire | Vault note |
| How user likes to work | `feedback` memory |
| Project/team fact | `project` memory |
| Domain term | Glossary skill |

Rule of thumb: *would a developer on another project benefit?* Yes → skill. No → vault/memory.

### Propose format

```
File: <path>
Section: <heading>
Before: <existing line(s) or "new subsection">
After: <proposed line(s)>
Why: <one-sentence rationale>
```

One rule per paragraph, one example max. Skills bloat when every retro adds three paragraphs.

## Output Shape

```
## Worked
- <concrete item with why>

## Didn't work
- <concrete item with why>

## Proposed skill edits
1. File: <path>
   Section: <heading>
   Change: <old → new>
   Why: <one sentence>

## Proposed vault/memory entries
- <type>: <entry>

Apply these?
```

## Red Flags — restart

- Praising what the user just praised (affirmation ≠ retrospection)
- "Overall it went well" / "a few small things" (empty phrases)
- Proposing an edit without a file path + section heading
- Paragraphs of analysis with no concrete change attached
- Applying edits before the user says yes
- Bundling a domain fact and a skill rule into one finding

If any of these fire, stop. Restart the retro with the sections above.

## Common Mistakes

- **Sycophancy.** "CLARIFY worked well" is empty. What premise did it *miss*?
- **Generic advice.** "Test more" / "plan better" — not an edit. Name a file and section or drop it.
- **Mixing layers.** A Postmark limit does not belong in the software-development skill. Project facts go to vault, skill rules go to skill files.
- **Sprawl.** If a finding needs 30 lines to express, it's a rewrite, not a retro.

## Meta

This skill is itself subject to retrospection. If a retro using this skill surfaces a gap in *this* skill, edit `SKILL.md` here. Same loop.
