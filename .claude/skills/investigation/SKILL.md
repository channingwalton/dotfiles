---
name: investigation
description: "Create and maintain local evidence dossiers for messy investigations, data corrections, incident follow-ups, or reconciliation work where evidence spans local CSV/XLSX/log artefacts, a vault task note, Jira/GitHub tickets, Slack threads, code branches, and repeated simulation/live runs. Use when the user asks to organise an investigation folder, keep run evidence up to date, trace where numbers came from, build a manifest or event log, or prevent a large task note from becoming the only source of reasoning."
---

# Investigation

## Principle

Keep the task note readable and the evidence traceable.

- Task note: `Current State`, `Decision Log`, and `Open Questions`.
- Dossier: evidence story, artefact index, and optional worker/entity examples.
- Artefacts: raw inputs and generated outputs, kept in stable folders.

Do not move, rewrite, or normalise evidence files unless the user explicitly asks.

## Shape

Core dossier files:

```text
README.md
event-log.md
manifest.md
```

Optional:

- `case-studies.md` for worker/entity/account examples.

Prefer numbered artefact folders such as `0001`, `0002`, `0003` when files represent successive attempts, runs, transforms, or comparisons. Use date folders only when the date is the real identity of the evidence.

## Existing Dossier

Before editing, read:

- task note `Current State`, `Decision Log`, and `Open Questions`
- dossier `README.md`
- dossier `event-log.md`
- dossier `manifest.md`
- `case-studies.md`, if present

Update existing records; do not recreate structure.

## Event Log

Use `event-log.md` as the chronological investigation story. Add one entry for every meaningful decision, run, transform, comparison, Slack/Jira update, or conclusion.

Format:

```markdown
## YYYY-MM-DD [HH:MM] - <type> - <short title>

**Artefacts:** `0001/input.csv`, `0001/result.csv`

**What happened:** <one or two sentences>

**Outcome:** <counts or observed result when useful>

**Conclusion:** <what this means>

**Links:** <Slack/Jira/PR links when useful>
```

Keep it concise. Put file inventory, row counts, status, and optional checksums in `manifest.md`. Only include counts in `event-log.md` when they affect interpretation.

For decisions, use `type = decision` and include `Why`, `Rejected`, or `Evidence` when useful. The task note `Decision Log` remains canonical for approved task decisions.

## Manifest

Use `manifest.md` as the artefact index.

Default columns:

`Path | Type | Role | Source / Command | Rows / Files | SHA-256 | Status | Notes`

Rules:

- Paths are relative to the external artefact root or dossier root documented in `README.md`.
- Status is usually `active`, `superseded`, or `unknown`.
- `SHA-256` is optional; leave it blank unless exact byte identity matters.
- Use parser-safe row counts for CSVs.
- If a number cannot be reproduced from a file or command, mark it unproven.

Useful commands:

```bash
date +%F
wc -l "path/to/file.csv"
ruby -rcsv -e 'puts CSV.read(ARGV[0], headers: true).length' "path/to/file.csv"
shasum -a 256 "path/to/file.csv"
```

## Linking

Keep navigation simple:

- Task note links to dossier `README.md`, `event-log.md`, `manifest.md`, and any other key dossier files.
- Dossier `README.md` links back to the task note and each top-level dossier file.
- Link Slack/Jira/GitHub by permalink; do not paste whole threads.
- Link raw or bulky artefacts from `manifest.md`; link them from Markdown only when directly discussed.

## Update Ritual

After every new run, transform, comparison, or evidence reorganisation:

1. Put new files in the documented artefact folder scheme.
2. Add or update `manifest.md`.
3. Append `event-log.md`.
4. Mark superseded artefacts in `manifest.md`.
5. Update Markdown links if files moved or names changed.

When investigation work produces code, a job, script, migration, one-off command, PR, or commit, record branch, commit SHA, PR URL, entrypoint, inputs, outputs, and verification in `event-log.md`; index consumed or produced artefacts in `manifest.md`.

## Verification

Before finishing:

- Check referenced local files exist, unless intentionally external.
- Check `event-log.md` is chronological and not a raw log dump.
- Check `manifest.md` has path, role/source, row/file count where useful, status, and notes.
- Run `git status --short` when the dossier lives in a Git repository.
- State remaining provenance gaps.
