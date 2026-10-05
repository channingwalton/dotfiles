---
name: task-note-update
description: Append a Decision Log entry, rewrite Current State, or resolve an Open Question on the active task note in Channing's vault. Use when the user says "log this decision", "update the task note", "add to the decision log", "current state has changed", "answer to the open question is X", asks for a prompt to continue the task in a new session, or otherwise asks to capture, record, or log something about the task being worked on.
---

# Task Note Update

Maintains `Current State`, `Decision Log`, and `Open Questions`. Writes directly when the content is already established in the session; asks first only when something material is missing or ambiguous.

## Procedure

1. Resolve the active task note. If one exact match is not clear, ask; do not guess.

2. If unclear, ask which section changes: `Decision Log`, `Current State`, or `Open Questions`.

3. Get today's date via `date +%Y-%m-%d` in bash. Never hardcode.

4. Draft the change.

   **Decision Log entry** — insert newest-first at the top of the list. When the decision carries only a **Why**, one line is fine:

   ```
   - **[[YYYY-MM-DD]]** — <what changed>. **Why:** <reason>.
   ```

   When it carries multiple facets (**Why**, **Rejected**, **Watch**, supporting evidence), break them onto indented sub-bullets rather than chaining them into a run-on sentence:

   ```
   - **[[YYYY-MM-DD]]** — <what changed>.
     - **Why:** <reason>
     - **Rejected:** <alternative considered, one-line why-not>
     - **Watch:** <risk to keep an eye on> (only if there is one)
   ```

   `Why` is mandatory. Ask if missing.

   **Current State** — overwrite the block:

   - Lead with one or two plain sentences: what this is and where it stands.
   - Give each distinct strand its own bullet with a **bold label** — subjects, active approach, blockers, inherited context. The strands live in the bullets, not the lead.
   - Set `*Updated: [[YYYY-MM-DD]]*`.
   - Rewrite `## Next Session` (below) in the same edit.

   ```
   ## Current State
   *Updated: [[YYYY-MM-DD]]*

   <one- to two-sentence lead>

   - **<Strand>:** <detail>
   - **Blocker:** <detail>
   ```

   **Next Session** — a ready-to-paste prompt that resumes this task in a fresh session:

   - Operational content only: the exact next action, branch, file paths, commands, and constraints agreed in-session.
   - Leave out Current State and Open Questions; the resuming session reads those anyway.
   - Leave out notes for future tickets; they belong in that ticket, because this note will be closed and forgotten.
   - Put any working directory and branch on a lead line, then one action per item in a **numbered markdown list**.

   ```
   ## Next Session
   *Updated: [[YYYY-MM-DD]]*
   In `<dir>` on `<branch>`.

   1. <first action>
   2. <second action>
   ```

   **Open Question resolution** — write the destination first (`Decision Log`, `Current State`, spun-out task, or — for experiment tasks — the research note via roll-up), then remove the question.

5. Write directly when the content derives from work done or decisions made in this session — things the user has already seen or agreed. Apply surgically, then show the written entry (not a proposal) so it can be corrected if wrong.

6. Ask **before** writing only when something material is missing or ambiguous: which note, which section, a Decision Log **Why**, or content the user has never seen (e.g. reconstructing history from outside the session).

If the user asks to update both task note and dossier, update dossier files directly under the investigation workflow; the same direct-write rule applies to the task note.

## Experiment tasks

A task with `task-type: experiment` belongs to a research note: a `research:` frontmatter link and a `[[<Research Note>]]` backlink under its H1. Preserve both on every update.

- The task holds only this experiment's material — setup, protocol, results, per-experiment decisions. Cross-experiment synthesis belongs in the research note's Findings (the obsidian-research-maintainer skill rolls it up); never write it into Current State.
- Open Questions stay experiment-scoped. If an update surfaces a question that spans experiments or would outlive this one, flag it as a promotion candidate for the research note rather than adding it here.
- After a Current State rewrite, or a Decision Log entry or Open Question resolution with research-level substance, offer a roll-up into the research note in one line — do not perform it unasked.

## Format rules

Writing:

- Write for a reader scanning the note, not a transcript. Prefer real markdown lists over dense prose; keep sentences short; give each distinct fact its own line or bullet rather than chaining clauses. A Current State or Decision Log entry that packs several distinct strands into one dense paragraph is the failure being avoided.
- Never use inline pseudo-lists — `(1)… (2)…`, `(a)… (b)…`, or semicolon-chained runs — where a numbered or bulleted markdown list belongs.
- Link, don't copy: never echo JIRA or PR content into the task note.
- Use British spelling.
- Dates are Obsidian wikilinks `[[YYYY-MM-DD]]` — never bare `YYYY-MM-DD` — so they backlink to daily notes. Get them from `date`, never from memory.

Section mechanics:

- One decision per Decision Log entry, each with a **Why**. Append-only and dated — do not edit or delete prior entries.
- Current State is overwrite-only.
- Next Session is overwrite-only and moves **only** alongside Current State, never on a Decision Log or Open Question update. Its date always matches Current State's.
- Open Questions are ephemeral and should empty over time.

Claims and status:

- Write a causal or factual claim into Decision Log, Current State or a research note only once the check that establishes it has run. A claim in a note is later read as established fact.
- When a claim rests on inference, raise it as an Open Question, or state the evidence and its limit ("from the SP log only").
- Frontmatter `status` values are hyphenated: `in-progress` / `done` (never `in progress`).
- Set `status: done` + `completedDate` only after the branch is **merged**. An open or approved PR is still `in-progress`.
- A task with no branch (an investigation) is `done` only when every strand in Current State and Open Questions is resolved. "No work needed on strand X" does not complete the task.
- When the user says "close it out" before then, propose `in-progress` with the open strand named. `done` is not the default to rubber-stamp.
