---
name: obsidian-research-maintainer
description: Maintain a project's Research layer in an Obsidian vault — scaffold a research note from a question, spawn experiment tasks with backlinks, roll experiment findings up into the research note, sync open questions, and on conclusion graduate durable findings into Topics. Use when the user wants to start a piece of research, add an experiment to a research question, update a research note from its experiments, review open questions, or conclude a research question. Sibling of obsidian-topic-maintainer; assumes projects under the vault have Research/, Tasks/, Topics/ (and usually Events/) sub-folders.
---

# Obsidian Research Maintainer

Maintains the **Research** layer of an Obsidian project. A research note holds one research question end to end: problem, hypotheses, links to experiments, a rolling summary of findings, and open questions. Experiments are ordinary **Tasks** (`task-type: experiment`) that link back to their research note — no separate experiment structure exists or should be invented. Supporting documents are captured in **Events** and linked from the research note.

This skill is **propose-then-apply** for anything that rewrites existing notes: show what would change and get the user's go-ahead. Creating a fresh research note or experiment task on request needs no confirmation loop.

## Vault model & conventions

- Vault root is typically `~/Documents/Notes`; projects live under `Projects/<Name>/` with `Research/`, `Tasks/`, `Topics/`, and usually `Events/`.
- `Research/Research.md` is the index hub for a project's research notes; the project note links it in its footer line.
- **Every note's H1 is a self wikilink** (`# [[Note Title]]`) followed by a parent link line — `[[Research]]` for research notes.
- British spelling. Generate any timestamp with the shell `date` command, never a guess.
- **Research note** shape (template: `Vault Metadata/Templates/Inputs/research.md`) — no date prefix in the filename; named by a short form of the question:

  ```
  ---
  status: open            # open | concluded
  projects:
    - "[[<Project>]]"
  dateCreated: <ISO8601>
  dateModified: <ISO8601>
  tags:
    - research
  ---
  # [[<Title>]]
  [[Research]]
  ## Problem / ## Hypotheses / ## Experiments / ## Findings / ## Open Questions / ## Documents
  ```

- **Experiment task** = a normal Task note (dated filename, task frontmatter) plus:

  ```
  task-type: experiment
  research:
    - "[[<Research Note>]]"
  ```

and a `[[<Research Note>]]` backlink line under its H1. The task keeps its own Current State, method, Results, Decision Log; links are one-way in prose (task → research), while the research note's **Experiments** section lists its experiment tasks with a one-line description each.

## Division of content — the important rule

- **Experiment task**: everything specific to that run — setup, protocol, raw results, per-experiment decisions, next-session notes.
- **Research note**: only what spans experiments — the question, hypotheses, distilled findings, research-level open questions.
- When in doubt, leave detail in the task and link it. A research note that duplicates a results table has gone wrong.

## Workflows

### Start a research question

1. Ask for the question if not given; agree a short title (the filename).
2. Create `Research/<Title>.md` from the template shape above (shell `date` for timestamps). Write the Problem section from the user's phrasing; draft 2–4 falsifiable Hypotheses and confirm them with the user.
3. Add the note to `Research/Research.md`'s list. Create `Research/` and `Research.md` first if the project lacks them, and add the footer link to the project note.

### Add an experiment

1. Create a Task note (dated filename, matching the project's task conventions) with `task-type: experiment` and the `research:` frontmatter + H1 backlink.
2. List it under the research note's **Experiments** section with a one-line description. Bump `dateModified`.

### Roll up findings

1. Read each linked experiment task's Current State / Results / Decision Log.
2. Propose an updated **Findings** section: short bolded claims, each attributable to an experiment, with an `*Updated: [[<date>]]*` line. Propose which experiment-level open questions have become research-level (move up) and which research questions an experiment has answered (mark or remove, noting the answer in Findings).
3. On approval, apply and bump `dateModified`. Never edit the experiment tasks during roll-up except to fix a missing backlink.

### Conclude a research question

1. Confirm with the user that the question is answered or abandoned; set `status: concluded` and add a dated **Conclusion** section summarising the answer.
2. **Graduate durable findings into Topics**: propose one or more Topic hubs (new or existing) that should carry the evergreen knowledge, in topic-hub voice — concept prose, no experiment enumeration, `## See also` links. Defer to the obsidian-topic-maintainer skill's conventions for hub shape and any promotion to a domain folder.
3. The research note stays in `Research/` as the archived record; the Topic carries the knowledge forward.

### Audit

On request, check across a project: every `task-type: experiment` task has a resolving `research:` link and H1 backlink; every research note's Experiments list matches the tasks that claim it; every open research note has been updated since its newest experiment activity (flag stale ones); `Research.md` lists every research note. Report, then fix approved items.

## Notes

- Do not create per-research sub-folders, an Experiments/ folder, or any structure beyond `Research/` — experiments are Tasks, documents are Events.
- Generalises across projects: point it at any `Projects/<Name>/` and offer to scaffold `Research/` if absent.
