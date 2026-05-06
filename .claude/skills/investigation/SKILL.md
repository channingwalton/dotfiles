---
name: investigation
description: "Create and maintain local evidence dossiers for messy production investigations, datafixes, incident follow-ups, or reconciliation work where evidence spans local CSV/XLSX/log artefacts, a vault task note, Jira/GitHub tickets, Slack threads, code branches, and repeated dry/prod runs. Use when the user asks to organise an investigation folder, keep run evidence up to date, trace where numbers came from, build a manifest/run log/data lineage, or prevent a large task note from becoming the only source of reasoning."
---

# Investigation

## Principle

Keep reasoning and provenance searchable; keep raw artefacts in place. Do not move, rewrite, or normalise evidence files unless the user explicitly asks.

The dossier answers:

- What happened?
- Which files prove it?
- Which command produced each result?
- Which decisions changed the approach?
- Which artefacts are current vs superseded?
- Which Slack/Jira/vault statements support the public numbers?

## Folder Shape

Create or maintain these files at the investigation root:

```text
README.md
manifest.md
timeline.md
reasoning-log.md
data-lineage.md
run-log.md
task-note-evidence.md
open-questions.md
case-studies.md
Data/
```

Use `Data/` for raw exports, generated inputs, run outputs, logs, and bulky evidence. Prefer `Data/Runs/` for dry-run, prod-run, and rerun inputs/results. Keep the Markdown dossier files at the investigation root.

Default to a local evidence folder with links back to vault/Jira/Slack. If routed from a vault task with `task_type: investigation`, use its `investigation_root` or same-basename sibling folder beside the task note.

## Existing Dossier First

Before editing an existing dossier, read the current `README.md`, `manifest.md`, `run-log.md`, `reasoning-log.md`, `data-lineage.md`, `task-note-evidence.md`, and `open-questions.md` if present. Update the existing records instead of recreating structure.

## Linking

When the dossier lives beside a vault task note:

- Add a Markdown link from the task note to `./<task-basename>/README.md`.
- Add a Markdown link from `README.md` back to `../<task-basename>.md`.
- Link from `README.md` to every top-level dossier Markdown file.
- Add task-note and README backlinks at the top of each top-level dossier Markdown file.
- Keep raw or bulky artefacts linked from `manifest.md`; link from Markdown only when the artefact is directly discussed.
- Treat the task note `## Decision Log` as canonical for approved task decisions.
- Use `reasoning-log.md` for evidence-backed investigation reasoning and provenance; do not duplicate the task Decision Log.

## Manifest

Use `manifest.md` as the artefact index. Paths should be relative to the investigation root, so files under the data folder look like `Data/Runs/2026-05-06-run.csv`.

Required Markdown table columns:

`Path | Type | Role | Source / Command | Rows / Files | SHA-256 | Status | Notes`

Status values:

- `active` - current source of truth or still relevant.
- `superseded` - retained evidence, no longer the current source.
- `unknown` - provenance not yet established.

Use `type` for artefact shape or origin, such as `raw-csv`, `result-csv`, `analysis-csv`, `raw-folder`, or `external-vault-note`.

Use parser-safe commands for counts/checksums:

```bash
date +%F
wc -l "path/to/file.csv"
shasum -a 256 "path/to/file.csv"
ruby -rcsv -e 'puts CSV.read(ARGV[0], headers: true).length' "path/to/file.csv"
```

Use `rows_or_files` as data rows for CSVs when possible; say `file lines` if the file is malformed or line-wrapped.

## Run Log

Append one entry per dry run, prod run, rerun, data migration, or verification pass.

Each entry should include:

- date and optional time
- input path
- output path
- command
- code branch/PR/SHA if known
- headline counts
- conclusion
- Slack/Jira link where the result was reported
- whether this run supersedes another run

When parsing result counts, prefer a structured CSV parser over text splitting if fields may contain commas.

## Reasoning Log

Use `reasoning-log.md` for reasoning changes, not every event. The task note `## Decision Log` remains canonical for approved user-visible decisions.

Format:

```markdown
## YYYY-MM-DD - <decision>

**Reasoning:** <what changed>

**Why:** <evidence-backed reason>

**Rejected:** <alternative and why not>

**Evidence:** <local file, task-note lines, Slack/Jira/PR link>
```

One decision per entry. Do not hide multiple decisions in one paragraph.

## Data Lineage

Use `data-lineage.md` to map:

- raw exports
- lookup/account files
- scripts or manual transforms
- correction inputs
- result files
- comparison/gap-analysis outputs

Record provenance gaps explicitly. If a number cannot be reproduced from a file or command, mark it unproven rather than repeating it as fact.

## Task Note Evidence

If a vault task note contains commands, counts, Slack links, or conclusions, index it in `task-note-evidence.md`.

Workflow:

1. Read the task note in full.
2. Capture its path and SHA-256 in `manifest.md`.
3. Use `nl -ba` to cite line numbers.
4. Group evidence by run/date, not by raw note order.
5. Warn that line numbers drift if the task note changes.

Command:

```bash
nl -ba "$TASK_NOTE" | sed -n '1,220p'
shasum -a 256 "$TASK_NOTE"
```

Respect vault-task rules: if updating the task note itself, draft the change and wait for confirmation unless the user explicitly asked you to write it.

## Slack, Jira, GitHub

Link external discussions; do not paste whole threads.

Capture:

- permalink
- date
- participants if relevant
- exact decision, claim, or approval
- related local artefact or run

Use Jira/GitHub for formal ticket/PR state. Use the dossier for the reasoning trail and evidence archive.

## Case Studies

Use `case-studies.md` for worker/customer/example-level analysis while the examples fit in one file. Create `case-studies/` only when separate per-worker files are needed.

Each case should capture:

- source message or ticket link
- export row or file reference
- Patchwork row/query result reference
- current interpretation
- whether the issue is logic, missing source data, manual data, or expected limitation

## Update Ritual

After every new run or important data transform:

1. Put the input/output under `Data/`, usually `Data/Runs/`, with a date prefix.
2. Add/update `manifest.md`.
3. Append `run-log.md`.
4. Mark superseded artefacts.
5. Add a decision only if the reasoning changed.
6. Update `data-lineage.md` if the transform chain changed.
7. Update `task-note-evidence.md` if the task note contains run evidence.
8. Then write the Slack/Jira summary from the dossier.

## Verification

Before finishing:

- Validate `manifest.md` has the required table columns.
- Check referenced local files exist, unless intentionally external.
- Check new Markdown is concise and not raw log dumping.
- Run `git status --short` when the dossier lives in a Git repository.
- State any provenance gaps.

Validation command:

```bash
ruby -e 'header = File.readlines("manifest.md").find { |l| l.start_with?("| Path |") }; abort "missing manifest header" unless header&.include?("SHA-256"); puts "ok"'
```
