---
status: in-progress
priority: normal
task-type: implementation
projects:
  - "[[Rostering]]"
dateCreated: 2026-09-28T10:14:02+01:00
dateModified: 2026-10-02T16:40:11+01:00
tags:
  - task
---
# [[2026-09-28 101402 RH-7012 Chunk the leave entitlement import]]
[[Importers]] [[Leave Entitlements]]

[RH-7012](https://example.atlassian.net/browse/RH-7012)

## Current State
*Updated: [[2026-10-02]]*

The leave entitlement import fails on large trust files because it runs in one transaction; we are reshaping it to commit in chunks.

- **Symptom:** imports over ~20k rows hit the 30s statement timeout and roll back completely.
- **Approach:** split the import into fixed-size chunks, each in its own transaction.
- **Open strand:** chunk size not yet chosen.

## Next Session
*Updated: [[2026-10-02]]*
In `~/dev/rostering` on `rh-7012-chunked-import`.

1. Prototype chunked commits in `LeaveEntitlementImporter`.
2. Time a 20k-row import at chunk sizes 100, 500 and 1000.

## Decision Log
- **[[2026-10-01]]** — Keep the existing CSV parser rather than switching to a streaming parser. **Why:** parsing is not the bottleneck; the transaction is.
- **[[2026-09-29]]** — Reproduce against a copy of production data, not synthetic fixtures. **Why:** the timeout only appears with real row distributions.

## Open Questions
- What chunk size keeps each transaction well under the 30s timeout?
- Does a partially imported file need to be resumable, or is re-running from the start acceptable?

## Context
- Importer entry point: `LeaveEntitlementImporter.run`
- Timeout configured in `db.statement-timeout`
