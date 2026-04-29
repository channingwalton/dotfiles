---
name: task-note-update
description: Append a Decision Log entry, rewrite Current State, or resolve an Open Question on the active task note in Channing's vault. Use when the user says "log this decision", "update the task note", "add to the decision log", "current state has changed", "answer to the open question is X", or otherwise asks to capture, record, or log something about the task being worked on.
---

# Task Note Update

Maintains the running record on a Patchwork task note. Conventions live in the global `CLAUDE.md` "Task Notes" section — this skill implements the propose-then-write loop.

## When to use

The user is working on a task tracked in their Obsidian vault and wants something captured durably: a decision just made, a change in approach, or the resolution of an open question.

If the active task note path isn't already known from the session, **ask** before drafting anything. Don't guess.

## Procedure

1. **Confirm what's being captured.** If unclear, ask which section the update belongs in:
   - Decision Log — direction change, rejected approach, tradeoff made.
   - Current State — "where we are now" has changed.
   - Open Questions — new question to track, or resolving an existing one.

2. **Get today's date** via `date +%Y-%m-%d` in bash. Never hardcode.

3. **Draft the change.**

   **Decision Log entry** — insert newest-first at the top of the list:
   ```
   - **YYYY-MM-DD** — <what changed>. **Why:** <reason>. **Rejected:** <alternative considered, one-line why-not>.
   ```
   The **Why** is mandatory. If the user hasn't articulated it, ask before drafting.

   **Current State** — overwrite the existing block. Three to five sentences covering: where we are now, the active approach, what's blocking. Update the `*Updated: YYYY-MM-DD*` line. Fold any still-relevant content from the previous version into the new one; do not append.

   **Open Question resolution** — write the destination first (a Decision Log entry, a Current State edit, or a pointer to a spun-out task). Then remove the question from the Open Questions list. The *destination* is what removes the question — not just having an answer.

4. **Show the proposed change** as a diff or as the full new section, and ask for confirmation. Do not write without explicit go-ahead.

5. **Apply** with the `Edit` tool for surgical changes (preferred). Use `Write` only if rewriting the whole file is unavoidable.

## Format rules (mirror of CLAUDE.md)

- One decision per Decision Log entry; if two decisions were made together, write two entries.
- Decision Log is append-only and dated. Do not edit or delete prior entries.
- Current State is overwrite-only and has no internal history.
- Open Questions are ephemeral and should empty over time.
- Use British spelling.

## Anti-patterns

- Writing without confirmation. The Decision Log's value is the user's trust in it; silent writes erode that.
- Decision Log entries without a **Why** — refuse to write, ask first.
- Echoing JIRA content into the task note. Link, don't copy.
- Merging "what" and "why" into prose. Keep the bold labels.
- Hardcoding dates instead of running `date`.
