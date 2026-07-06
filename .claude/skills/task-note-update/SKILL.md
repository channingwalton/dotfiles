---
name: task-note-update
description: Append a Decision Log entry, rewrite Current State, or resolve an Open Question on the active task note in Channing's vault. Use when the user says "log this decision", "update the task note", "add to the decision log", "current state has changed", "answer to the open question is X", or otherwise asks to capture, record, or log something about the task being worked on.
---

# Task Note Update

Maintains `Current State`, `Decision Log`, and `Open Questions` via a propose-then-write loop.

## When to use

Use when the user wants a task-note decision, state change, or open-question resolution captured durably.

## Procedure

1. Resolve the active task note. If one exact match is not clear, ask; do not guess.

2. If unclear, ask which section changes: `Decision Log`, `Current State`, or `Open Questions`.

3. Get today's date via `date +%Y-%m-%d` in bash. Never hardcode.

4. Draft the change.

   **Decision Log entry** — insert newest-first at the top of the list:
   ```
   - **[[YYYY-MM-DD]]** — <what changed>. **Why:** <reason>. **Rejected:** <alternative considered, one-line why-not>.
   ```
   `Why` is mandatory. Ask if missing.

   **Current State** — overwrite the block. Three to five sentences covering current position, active approach, and blockers. Update `*Updated: [[YYYY-MM-DD]]*`.

   **Open Question resolution** — write the destination first (`Decision Log`, `Current State`, or spun-out task), then remove the question.

5. Show the proposed diff or full new section and ask for confirmation. Do not write without explicit go-ahead.

6. Apply surgically once confirmed.

If the user asks to update both task note and dossier, update dossier files directly under the investigation workflow, but still draft task-note changes and wait for approval.

## Format rules

- One decision per Decision Log entry.
- Decision Log is append-only and dated. Do not edit or delete prior entries.
- Current State is overwrite-only.
- Open Questions are ephemeral and should empty over time.
- Use British spelling.
- Dates are Obsidian wikilinks `[[YYYY-MM-DD]]` — never bare `YYYY-MM-DD` — so they backlink to daily notes.
- Frontmatter `status` values are hyphenated: `in-progress` / `done` (never `in progress`).
- Set `status: done` + `completedDate` only after the branch is **merged** — a PR being open or approved is still `in-progress`. For tasks with no branch (investigations), `done` additionally requires every strand in Current State / Open Questions to be resolved; "no work needed on strand X" is not task-complete. When the user says "close it out", propose `in-progress` with the open strand named — do not offer `done` as a default to rubber-stamp.

## Anti-patterns

- Writing without confirmation.
- Treating a broad "yes" as approval to write exact text that has not been shown.
- Decision Log entries without a **Why**.
- Echoing JIRA content into the task note. Link, don't copy.
- Hardcoding dates instead of running `date`.
