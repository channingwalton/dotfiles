---
name: meta-retrospective
description: Consolidate findings across many persisted retrospectives. Use when the user asks for a "monthly retro", "meta retro", "what's been recurring", "review the retros", or any cross-session review. Reads the retro archive in $RETROSPECTIVE_DIR rather than a single session transcript. Pairs with the single-session `retrospective` skill, which produces the per-session retros this skill aggregates.
---

# Meta-Retrospective

## Overview

The `retrospective` skill reflects on **one** session and prints its output inline. This skill works across **many** persisted retros: it finds themes that recur, then turns the strongest ones into concrete skill edits — the same audit → sort → propose → confirm → apply loop, applied to files instead of a transcript.

It reads a retro archive on disk. The shared `retrospective` skill writes that archive when `RETROSPECTIVE_DIR` is set (its opt-in persistence) — this skill only consumes it. Aggregating across sessions is a personal practice, which is why it lives here rather than in the shared skill.

## The archive

Per-session retros accumulate in `$RETROSPECTIVE_DIR` as `YYYY-MM-DD-HHMMSS.md` files, written by the `retrospective` skill. If that env var was never set, there is nothing to aggregate — set it and run a few single-session retros first.

## When to Use

Triggers: "monthly retro", "meta retro", "what's been recurring", "review the retros", "what keeps coming up across sessions".

**Not for** a single session — that's the `retrospective` skill.

## Preconditions

- `RETROSPECTIVE_DIR` must be set and contain prior retro files. If unset or empty, stop and say so — do not invent an archive.
- Establish the window: ask which retros to include if the user didn't specify (e.g. last month, last 10 retros, all).

## The Process

Run the base loop from the `retrospective` skill — **audit → sort → propose → confirm → apply** — over the persisted retro files. What changes:

1. **AUDIT** — Read every retro file in the window. Build two lists: themes that recur across multiple retros (worked / didn't), each with the file references that contributed.
2. **SORT** — Reorder by priority:
   1. **Consolidate** — multiple existing rules saying nearly the same thing. Propose merging.
   2. **Promote** — same finding surfaced in N sessions but still living as a one-line rule. Propose a new skill file.
   3. **Procedure candidate** — recurring multi-step recipe still buried in prose. Propose extraction.
   4. **One-line edits** — only if a recurring finding doesn't fit the above.
3. **PROPOSE / CONFIRM / APPLY** — unchanged from the base skill, including its Propose format, Output Shape, and Red Flags.

## Bias to design against

Sprawl. A monthly retro that suggests 10 changes will overwhelm. Cap proposals at the top 3-5 by recurrence count; surface the rest as a "noted but not actioned" appendix.

## Meta

This skill is itself subject to retrospection. If a meta-retro surfaces a gap in *this* skill, edit `SKILL.md` here. Same loop.
