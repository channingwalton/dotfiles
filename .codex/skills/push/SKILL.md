---
name: push
description: "Commit, push, and open a PR. Use when the user says push, commit, open a PR, or asks to ship the current changes."
---

# Push

Commit the working changes, push the branch, open a PR.

## Gather context

Run these and read the output (keep the diff cheap — stat first, cap the body):

- `git status`
- `git diff HEAD --stat` — changed files + line counts
- `git diff HEAD | head -c 6000` — capped diff body; if a file is truncated and you need its detail for the message, diff that one path explicitly
- `git branch --show-current`
- `git log --oneline -10` — for commit-message style

## Task

1. No changes to commit → stop and tell the user.
2. On `main` → create a branch with a descriptive name from the changes. Before `git checkout -b <name>`, run `git branch --list <name>` and `gh pr list --head <name> --state all`. If the branch exists locally or the name has a closed PR, surface it and ask whether to archive (rename), force-push, or pick a new name. Never silently overwrite.
3. Stage relevant changes. Never stage likely-secret files (`.env`, `credentials.json`, etc.).
4. Single commit, concise conventional message. End with:
   `Co-Authored-By: Claude <noreply@anthropic.com>`
5. Push with `git push -u origin <branch>`.
6. `gh pr create` with a short title and a body containing:
   - `## Summary` — 1-3 bullets
   - `## Test plan` — a checklist
7. Print the PR URL.
