---
allowed-tools: Bash(git *), Bash(gh *), Bash(devtool *)
description: Commit, push, open a PR, and watch for CI issues
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commit messages (for style matching): !`git log --oneline -10`

## Your task

Based on the above changes:

### Phase 1 — Commit and PR

1. If there are no changes to commit, stop and tell the user.
2. If on main, create a new branch with a descriptive name based on the changes.
3. Stage all relevant changes (never stage files that likely contain secrets like .env, credentials.json, etc.).
4. Create a single commit with a concise, conventional commit message. End the message with:
   `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`
5. Push the branch to origin with `-u`.
6. Create a pull request using `gh pr create` with a short title and a body containing:
   - `## Summary` with 1-3 bullet points
   - `## Test plan` with a checklist
7. Print the PR URL to the user.

### Phase 2 — Watch and fix

8. Run `gh pr checks <pr-number> --watch --fail-fast` to wait for CI checks to complete.
9. If all checks pass, report success and stop.
10. If any checks fail:
    a. Fetch the failed check logs using `gh run view <run-id> --log-failed`.
    b. Analyse the failure and fix the code.
    c. Run `devtool check` locally to verify the fix.
    d. Commit the fix (reference the failed check in the commit message), push, and go back to step 8.
    e. After 3 fix attempts, stop and report the remaining failures to the user instead of retrying.
