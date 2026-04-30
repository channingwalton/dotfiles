---
name: push
description: Commit local changes, push a branch, and open a pull request from Codex. Use when the user asks to commit, push, create a PR, publish changes, or "yeet" work.
---

## Your task

Gather context yourself before writing:

1. `git status --short`
2. `git diff --stat` and the relevant diffs
3. `git branch --show-current`
4. `git log --oneline -10`

Then:

1. If there are no changes to commit, stop and tell the user.
2. If on `main`/`master`, create a new branch using the `codex/` prefix unless the user asked for another prefix.
3. Before creating a branch, check whether the branch or a same-head PR already exists; never silently overwrite.
4. Stage only relevant changes. Never stage likely secrets such as `.env`, credentials, tokens, auth files, or local caches.
5. Create a single concise commit unless the user asks for a different structure.
6. Push the branch to origin with upstream tracking.
7. Create a pull request with a short title and a body containing:
   - `## Summary` with 1-3 bullet points
   - `## Test plan` with a checklist
8. Report the PR URL.

Use Codex git/app directives in the final response only after each action actually succeeds.
