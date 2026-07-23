---
name: task-note-update
description: Append a Decision Log entry, rewrite Current State, or resolve an Open Question on the active task note in Channing's vault. Use when the user says "log this decision", "update the task note", "add to the decision log", "current state has changed", "answer to the open question is X", asks for a prompt to continue the task in a new session, or otherwise asks to capture, record, or log something about the task being worked on.
---

# Task Note Update

Maintains `Current State`, `Decision Log`, and `Open Questions`. Writes directly when the content is already established in the session; asks first only when something material is missing or ambiguous.

## When to use

Use when the user wants a task-note decision, state change, or open-question resolution captured durably.

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

   **Current State** — overwrite the block. A one- to two-sentence plain-language lead (the headline: what this is and where it stands), then a short bulleted list of the distinct strands, one per bullet with a **bold label** — subjects, active approach, blockers, inherited context. Do not pack every strand into the lead; that dense paragraph is the wall of text being fixed. Update `*Updated: [[YYYY-MM-DD]]*`. Every Current State rewrite also rewrites `## Next Session` (below).

   ```
   ## Current State
   *Updated: [[YYYY-MM-DD]]*

   <one- to two-sentence lead>

   - **<Strand>:** <detail>
   - **Blocker:** <detail>
   ```

   **Next Session** — a ready-to-paste prompt to resume the task in a fresh session. Rewritten only alongside Current State, never independently. Operational content only: the exact next action, branch, file paths, commands, and constraints agreed in-session. Do not restate Current State or Open Questions — the resuming session reads those anyway. Put any working directory / branch on a lead line; the steps are a **numbered markdown list**, one action per item — never inline `(1)… (2)…` enumerations.

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

- Write for a reader scanning the note, not a transcript. Prefer real markdown lists over dense prose; keep sentences short; give each distinct fact its own line or bullet rather than chaining clauses.
- Never use inline pseudo-lists — `(1)… (2)…`, `(a)… (b)…`, or semicolon-chained runs — where a numbered or bulleted markdown list belongs.
- One decision per Decision Log entry.
- Decision Log is append-only and dated. Do not edit or delete prior entries.
- Do not write a causal or factual claim into Decision Log, Current State or a research note unless the check that establishes it has been run. If it rests on inference, write it as an Open Question, or state the evidence and its limit ("from the SP log only") — four unverified claims were written into notes in one fortnight and one is still standing.
- Current State is overwrite-only.
- Next Session is overwrite-only and changes only alongside Current State; its date must match Current State's.
- Open Questions are ephemeral and should empty over time.
- Use British spelling.
- Dates are Obsidian wikilinks `[[YYYY-MM-DD]]` — never bare `YYYY-MM-DD` — so they backlink to daily notes.
- Frontmatter `status` values are hyphenated: `in-progress` / `done` (never `in progress`).
- Set `status: done` + `completedDate` only after the branch is **merged** — a PR being open or approved is still `in-progress`. For tasks with no branch (investigations), `done` additionally requires every strand in Current State / Open Questions to be resolved; "no work needed on strand X" is not task-complete. When the user says "close it out", propose `in-progress` with the open strand named — do not offer `done` as a default to rubber-stamp.

## Anti-patterns

- Asking for confirmation on content already established in the session — write it and show what was written.
- Writing invented or reconstructed content the user has never seen without asking first.
- Silent writes — every write must be followed by showing the entry as written.
- Walls of text — a Current State or Decision Log entry that packs multiple distinct strands into one dense paragraph. Use a lead sentence plus bulleted strands / sub-bullets instead.
- Inline pseudo-lists — `(1)… (2)…` or `(a)… (b)…` where a numbered or bulleted markdown list belongs.
- Decision Log entries without a **Why**.
- Echoing JIRA content into the task note. Link, don't copy.
- Hardcoding dates instead of running `date`.
- A Next Session prompt that restates state instead of giving the next concrete action.
- Rewriting Next Session on a Decision Log or Open Question update — it moves only with Current State.
- Duplicating a research note's Findings into an experiment task, or editing the research note directly during a task update — roll-up is a separate, offered step.
