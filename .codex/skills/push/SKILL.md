---
name: push
description: Commit, push, and open a PR for the current local changes. Use when the user asks to publish current work, push a branch, or open a PR from the current worktree.
---

# Push

Publish the current worktree safely.

## Workflow

1. Check `git status`, `git diff HEAD`, the current branch, and recent commit messages for context
2. If there are no changes to commit, stop and tell the user
3. If on `main` or another protected base branch, create a new descriptive branch first
4. Stage all relevant changes, but never stage likely secret-bearing files such as `.env`, credential files, auth tokens, or machine-local state
5. Create a single concise commit message that matches local style
6. Push the branch with upstream tracking
7. Open a pull request with:
   - `## Summary` with 1-3 bullets
   - `## Test plan` with a checklist
8. Report the PR URL back to the user

## Notes

- Do not add vendor or assistant co-author trailers unless the user explicitly asks
- If the user also wants CI watched or fixed, continue with the GitHub CI workflow after the PR is open
