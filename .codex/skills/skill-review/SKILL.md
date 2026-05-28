---
name: skill-review
description: Audit Channing's authored skills for whether they earn their place — usefulness, overlap with other skills or Claude's built-in abilities, redundancy, gaps, and triggering quality. Use when asked to review, audit, critique, or prune skills; when wondering whether a skill is still worth keeping; or after writing or editing a skill. Reviews authored skills only: real dirs in ~/.claude/skills and ~/.claude/commands (symlinks skipped) plus the dev repo in ~/dev/skills/skills.
---

# Skill Review

Audit Channing's authored skills and tell him, honestly, which ones earn their place and which are dead weight.

A skill costs context every session its description sits in the menu, and costs more when it loads. The bar for keeping one is not "is this reasonable advice" — it's **"would Claude do worse without it?"** Most skill bloat is advice Claude already follows by default, dressed up as instructions. Your job is to find that and call it out.

This is a critical review, not a rubber stamp. Be willing to recommend dropping or merging skills. A short report that says "three of these should be deleted" is more valuable than a polite one that keeps everything.

## Scope

Default: review **every** authored skill. Discover them with the bundled script — it returns real dirs in `~/.claude/skills` and `~/.claude/commands` (skills exposed as slash commands, e.g. `unison-update`) plus everything in `~/dev/skills/skills`. Symlinks are skipped on purpose: they point at install targets for third-party or already-published skills, which are out of authored scope (published ones are reviewed via their dev-repo source instead):

```sh
~/.claude/skills/skill-review/scripts/discover.sh
```

If Channing names a single skill, review just that one. Read each skill's full `SKILL.md` and skim any bundled `scripts/`, `references/`, or `agents/` — a skill's weight includes what it pulls in.

## What to judge

For each skill, work through these. They are ordered by how often they matter; the first is the heart of it.

1. **Does it earn its place?** Strip it down mentally to its claims. For each instruction ask: would Claude do this anyway? General language patterns, testing-framework basics, FP principles, "write clear commit messages", standard tool usage — Claude already does these. What remains should be **project-specific tooling** (e.g. `devtool check`, bloop detection), **non-obvious conventions** (e.g. opaque types over case classes for encapsulation), **personal workflow** (vault note layout, task-note sections), or **fixed multi-step procedures** Claude wouldn't reliably reconstruct. If little remains after stripping general knowledge, say so — the skill is a candidate to trim hard or drop.

2. **Overlap with other skills.** Compare against the full set of currently available skills (they are listed in your context as the available-skills menu) and against the other authored skills in this audit. Two skills with overlapping trigger conditions cause mis-routing — Claude picks the wrong one or hesitates. Flag pairs that do the same job, or where one is a strict subset of another, and recommend a merge or a sharper boundary.

3. **Overlap with Claude's built-in abilities and harness.** Some skills duplicate things the harness or built-in commands already do (git commit/PR flows, file search, running the app). If a skill is a thin wrapper over something Claude handles natively, that's a strike against it.

4. **Triggering quality.** The description is the only thing Claude sees when deciding to invoke. Does it say *when* to use the skill in concrete terms, not just what it does? Is it specific enough to fire on real phrasings but bounded enough not to fire on near-misses? Vague descriptions cause under-triggering (the common failure). Note descriptions that are all "what" and no "when".

5. **Internal redundancy and bloat.** Repetition across sections, restating Claude's defaults, heavy-handed `ALWAYS`/`MUST`/`NEVER` where a reason would work better, content duplicated from another skill it depends on. Note length relative to value.

6. **Gaps and rot.** Broken or stale pointers (a referenced script/path that no longer exists), TODOs, instructions that contradict each other, missing edge cases, references to defunct projects or tools. Cross-check bundled-resource paths against what's actually on disk.

Don't force every dimension onto every skill — report only what's true. A genuinely tight skill might get a one-line "earns its place, no changes".

## Report

Print to the terminal. No files. Lead with the headline so Channing sees the verdict spread first.

```
# Skill review — <date from `date`>

Reviewed N skills.  Keep: a · Trim: b · Merge: c · Drop: d

## <skill-name>   —   <KEEP | TRIM | MERGE | DROP | REVISE>
<one-line rationale: the single most important reason for the verdict>

- <finding, tied to a dimension above, specific and actionable>
- <finding>
...

## <next skill> — ...
```

Verdicts:
- **KEEP** — earns its place, no material change.
- **TRIM** — keep, but cut identified bloat / general knowledge.
- **MERGE** — fold into another named skill; say which and why.
- **DROP** — delete; Claude does as well or better without it.
- **REVISE** — keep, but the content or triggering needs rework beyond trimming.

After the per-skill sections, add a short **Cross-cutting** block for issues spanning skills: overlapping pairs, a dependency that's itself weak, duplicated passages, gaps in coverage across the set.

## Proposing edits

After the report, offer concrete edits for the skills that need them — but **don't apply anything without approval**. Channing reviews each change. Lead with the highest-leverage edits (a DROP or a big TRIM beats fixing a typo). For a TRIM, show what you'd cut. For a MERGE, show the combined description and where content moves. Apply only what he approves.
