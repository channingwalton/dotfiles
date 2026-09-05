---
name: task
description: "Resolve Channing's Obsidian task context and route the requested action. Use when the user references a task note or a Jira/GitHub issue tracked by one, resumes task work, or asks to capture task state."
---

# Task

Router for vault-backed task work. The task note is the canonical entry point; the user's current request determines what work to perform. Task metadata and saved next steps provide context, not authorisation for additional actions.

## Resolve

1. Locate the task note under `~/Documents/Notes/Projects/<project>/Tasks/`; if the user names a Jira/GitHub issue, find the matching task note first.
2. Read the task note in full.
3. Read linked Jira or GitHub issue if present.
4. Read frontmatter for context using `task-type` (a few legacy notes use `task_type`; treat it the same). If missing, treat as `note`.
5. When resuming work and the note has a `## Next Session` block, use its next steps only where consistent with the current request. If its date is older than Current State's `*Updated:*`, it is stale — ignore it and say so.

## External Data

When dossier updates are authorised, stage long ticket/PR descriptions, comment threads, or diffs into the dossier and reference by path rather than the task note. For read-only requests, use temporary working files for fetched material.

## Task Note Rules

Do not write unless the user explicitly asks. For `Current State`, `Decision Log`, or `Open Questions`, use `task-note-update`.

Whatever the section — including hand-written ones like `Design`, `Hypotheses`, or `Context` — write for a reader scanning the note: prefer real markdown lists over dense prose, keep sentences short, give each distinct fact its own bullet, and never use inline `(1)… (2)…` / `(a)… (b)…` pseudo-lists where a real list belongs.

## Frontmatter

- Default: `task-type: note`
- Investigation: `task-type: investigation` plus `investigation_root: ./<same-basename>/README.md`
- Experiment: `task-type: experiment` plus a `research:` wikilink to its research note

If `investigation_root` is missing, look for a sibling folder with the same basename as the task note. Create or move evidence within the user's authorised scope; ask only if the intended location or move is unclear.

## Routes

Load the task note and linked ticket, plus `investigation_root` for investigations or the linked research note for experiments. Then route by the requested action, regardless of `task-type`:

- Explain, summarise, or report status: answer from the context without changing task artefacts or starting an implementation workflow.
- Implement or fix software: use `software-development`.
- Review code: use `code-reviewer`.
- Create or maintain an evidence dossier: use `investigation`.
- Capture task state or decisions: use `task-note-update`.
- Roll experiment findings into research: use `obsidian-research-maintainer`.
- Other vault work: use `vault` as needed.

For an unknown task type, infer the relevant context from the note and request. Ask only when a material ambiguity prevents the requested work.

## Investigation Links

For investigation tasks:

- Frontmatter uses `investigation_root` for machine routing.
- Body links to the dossier README and key dossier files near the top link block or under `## Context` / `## Related`.
- Dossier details belong to the `investigation` skill.
