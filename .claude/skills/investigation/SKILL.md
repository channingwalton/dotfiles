---
name: investigation
description: "Create and maintain local evidence dossiers for messy investigations, data corrections, incident follow-ups, or reconciliation work where evidence spans local artefacts, a vault task note, tickets, Slack threads, code branches, and repeated runs. Use when the user asks to organise an investigation folder, keep run evidence up to date, trace where numbers came from, build a manifest or event log, or keep evidence out of a large task note."
---

# Investigation

Keep the task note readable and the evidence traceable.

## Shape

Core dossier files:

- `README.md` - entry point and links
- `event-log.md` - chronological story
- `manifest.md` - artefact index

Optional: `case-studies.md` for worker/entity/account examples.

Prefer numbered artefact folders such as `0001`, `0002`, `0003` when files represent successive attempts, runs, transforms, or comparisons. Use date folders only when the date is the real identity of the evidence.

Do not move, rewrite, or normalise evidence files unless the user explicitly asks.

## Before Editing

Before editing, read:

- task note `Current State`, `Decision Log`, and `Open Questions`
- dossier `README.md`
- dossier `event-log.md`
- dossier `manifest.md`
- `case-studies.md`, if present

Update existing records; do not recreate structure.

## Event Log

Add one concise entry for every meaningful decision, run, transform, comparison, Slack/Jira update, or conclusion.

Format:

```markdown
## YYYY-MM-DD [HH:MM] - <type> - <short title>

**Artefacts:** `0001/input.csv`, `0001/result.csv`

**What happened:** <one or two sentences>

**Outcome:** <counts or observed result when useful>

**Conclusion:** <what this means>

**Links:** <Slack/Jira/PR links when useful>
```

Put file inventory, row counts, statuses, and checksums in `manifest.md` unless they affect interpretation.

For decisions, use `type = decision` and include `Why`, `Rejected`, or `Evidence` when useful. The task note `Decision Log` remains canonical for approved task decisions.

## Manifest

Use `manifest.md` as the artefact index.

Default columns:

`Path | Type | Role | Source / Command | Rows / Files | SHA-256 | Status | Notes`

Rules:

- Paths are relative to the documented artefact root.
- Status is usually `active`, `superseded`, or `unknown`.
- `SHA-256` is optional unless byte identity matters.
- Use parser-safe row counts for CSVs.
- Mark unreproducible numbers as unproven.

## Linking

- Task note links to dossier `README.md`, `event-log.md`, `manifest.md`, and any other key dossier files.
- Dossier `README.md` links back to the task note and each top-level dossier file.
- Link Slack/Jira/GitHub by permalink; do not paste whole threads.
- Link raw or bulky artefacts from `manifest.md`.

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

- Referenced local files exist, unless intentionally external.
- `event-log.md` is chronological and not a raw log dump.
- `manifest.md` records path, role/source, row/file count where useful, status, and notes.
- `git status --short` checked when the dossier lives in a Git repository.
- Remaining provenance gaps stated.
