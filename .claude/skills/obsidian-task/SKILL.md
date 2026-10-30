---
name: obsidian-task
description: Resolve, route and update Channing's Obsidian vault task notes — including research notes, which are tasks with task-type research. Use when the user references a task note or a Jira/GitHub/Linear issue tracked by a vault task, asks to inspect or continue task context, says "log this decision", "update the task note", "current state has changed", "answer to the open question is X", asks for a prompt to continue in a new session, or asks to start, add an experiment to, roll up, or conclude a research question.
---

# Task

One skill owns the task note: finding it, routing by `task-type`, and writing its sections. The task note is the canonical working memory for the task — what was tried, what was rejected, where it got to. Jira, GitHub and Linear hold the formal ticket.

Follow the `obsidian-vault` skill's Writing notes and Frontmatter sections throughout.

## Resolve

1. Locate the task note under `~/Documents/Notes/Projects/<project>/Tasks/`; if the user names an issue, find the matching task note first. If one exact match is not clear, ask; do not guess.
2. Read the task note in full, then the notes it links to, one hop deep.
3. Read the linked ticket or PR yourself rather than asking the user to summarise it.
4. Route by `task-type` (a few legacy notes use `task_type`; treat it the same). If missing, treat as `note`.

## Routes

- `implementation` — load the task note and linked ticket; use `software-development` for the change the user asks for.
- `investigation` — load the task note, linked ticket, and the dossier at `investigation_root` (or a sibling folder with the task note's basename; ask before creating or moving evidence); then use `investigation`, which owns the dossier and its links.
- `review` — load the task note and linked PR/ticket; then run the host's native code review as `fix-loop` describes it for this host, reporting only. Use `fix-loop` itself when the task also asks for fixes.
- `experiment` — load the task note and the research note in its `research:` field. Capture goes in the task; roll-up goes in the research note (below).
- `research` — the research note itself. See Research below.
- `note` or missing — plain capture with the sections below.

If a task type is unknown, read the note and ask how to route it.

Loading, continuing or resuming a task restores context. It is not a request for a change. Report where the task stands and its next step, then wait until the user asks for the change.

## Writing to the task note

Write only when the user asks for a change. Write directly when the content derives from work done or decisions made in this session — things the user has already seen or agreed. Apply surgically, then show the written entry, not a proposal, so it can be corrected. Ask before writing only when something material is missing or ambiguous: which note, which section, a Decision Log **Why**, or content the user has never seen. If a section below is missing, offer to add it.

**Decision Log** — newest first, append-only, one decision per entry, each with a **Why**. Ask if the Why is missing. Never edit or delete prior entries.

```
- **[[YYYY-MM-DD]]** — <what changed>. **Why:** <reason>.
```

With several facets, use sub-bullets rather than one run-on line:

```
- **[[YYYY-MM-DD]]** — <what changed>.
  - **Why:** <reason>
  - **Rejected:** <alternative considered, one-line why-not>
  - **Watch:** <risk to keep an eye on> (only if there is one)
```

**Current State** — overwrite-only. Lead with one or two plain sentences: what this is and where it stands. Then one bullet per strand with a **bold label** — subjects, active approach, blockers, inherited context. When the user asks for a prompt to resume in a fresh session, add a **Next:** bullet with the operational detail only: working directory, branch, the exact next action, file paths, commands. Set `*Updated: [[YYYY-MM-DD]]*`.

```
## Current State
*Updated: [[YYYY-MM-DD]]*

<one- to two-sentence lead>

- **<Strand>:** <detail>
- **Blocker:** <detail>
- **Next:** in `<dir>` on `<branch>`: <action>
```

**Open Questions** — ephemeral; they should empty over time. To resolve one, write the destination first (Decision Log, Current State, a spun-out task, or the research note for an experiment), then remove the question.

Older notes have a `## Next Session` block. Treat it as the Next bullet: read it when resuming, fold it into Current State on the next rewrite, and remove the block.

## Claims and status

- Write a causal or factual claim into Decision Log, Current State or a research note only once the check that establishes it has run. A claim in a note is later read as established fact.
- When a claim rests on inference, raise it as an Open Question, or state the evidence and its limit ("from the SP log only").
- Link, don't copy: never echo ticket or PR content into the task note.
- Dates are `[[YYYY-MM-DD]]` wikilinks, never bare, so they backlink to daily notes.
- `status` values are hyphenated: `in-progress`, `done`.
- Set `status: done` + `completedDate` only after the branch is **merged**. An open or approved PR is still `in-progress`.
- A task with no branch is `done` only when every strand in Current State and Open Questions is resolved. "No work needed on strand X" does not complete the task.
- When the user says "close it out" before then, propose `in-progress` with the open strand named. `done` is not the default to rubber-stamp.

## Research

A research note is a task with `task-type: research`, named by a short form of its question with no date prefix, because experiments link to it by name. It holds one question end to end: problem, hypotheses, decision log, open questions, and a Dataview table of the tasks that link to it. The project note's Research section lists research notes with a query; nothing is added to a list by hand.

Experiments are ordinary tasks with `task-type: experiment`, a `research:` wikilink to the research note, and a `[[<Research Note>]]` line under the H1. Preserve both on every update.

Division of content, the rule that matters: the experiment task holds everything specific to that run — setup, protocol, raw results, per-experiment decisions. The research note holds only what spans experiments — the question, hypotheses, distilled findings, research-level open questions. When in doubt, leave detail in the task and link it. A research note that duplicates a results table has gone wrong.

**Start** — agree a short title; create the note in `Tasks/` with the research shape from the task template (`task-type: research`, tags `task` and `research`, status `open`). Write the Problem from the user's phrasing; draft 2–4 falsifiable hypotheses and confirm them.

**Add an experiment** — create a task with the experiment frontmatter and H1 backlink. The research note's table picks it up.

**Roll up** — read each experiment's Current State, results and Decision Log. Propose an updated Findings section: short bolded claims, each attributable to an experiment, with an `*Updated: [[<date>]]*` line. Propose which experiment-level open questions have become research-level and which research questions an experiment has answered. On approval apply, then remove each promoted question from its experiment. After a Current State rewrite or a Decision Log entry on an experiment with research-level substance, offer a roll-up in one line; do not perform it unasked.

**Conclude** — confirm the question is answered or abandoned; set `status: done`, `completedDate`, and a dated Conclusion section. Then propose the Topic hubs, new or existing, that should carry the durable findings in topic-hub voice; `obsidian-connect` owns hub shape and any promotion to a domain folder. The research note stays as the archived record.

**Audit** — on request: every experiment has a resolving `research:` link and H1 backlink; every open research note has been updated since its newest experiment activity (flag stale ones).
