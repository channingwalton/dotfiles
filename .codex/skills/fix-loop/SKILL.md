---
name: fix-loop
description: Iterative Codex-native review-fix cycle that eliminates critical issues. Use when the user says "review and fix", "find and fix bugs", "clean up the code", "fix all issues", "review then fix", or any request that combines finding problems with resolving them automatically.
---

# Fix Loop

Autonomous review-fix cycle that iterates until all critical issues are resolved.

The value of this skill is that it separates *finding* problems from *fixing* them. First review in a read-only, disconfirming posture. Then apply minimal targeted fixes. Do not rationalise away findings because you are about to edit the code.

## Input

One of:

- File path(s) to review
- Directory to scan
- No argument — automatically determines scope

## Execution

### Step 1: Determine Scope

Determine which files to review, in priority order:

1. If the user specified files/directories, use those
2. If there are uncommitted changes: `git diff --name-only` (unstaged) + `git diff --name-only --staged` (staged)
3. If there are recent commits: `git diff --name-only HEAD~3`
4. If none of the above apply, ask the user what to review

### Step 2: Baseline Test Check

Run `devtool check` before making any changes. Record the result — this is needed later to distinguish pre-existing failures from regressions introduced by fixes. Do not skip this step — "the diff is small" or "I just ran tests" are not exceptions; the baseline exists for cases where the fixer changes more than expected.

### Step 3: Review-Fix Loop

Set `iteration = 1` and `scope = <initial files>`.

**LOOP** while `iteration <= 3`:

Three iterations is the cap because experience shows that if critical findings persist beyond 3 cycles, the remaining issues typically need human judgement rather than automated fixing. The cap prevents wasted cycles.

1. **REVIEW (iteration N)** — Announce: `Review iteration N/3`
   - Use the `code-reviewer` skill locally against the current scope.
   - If the user explicitly asked for subagents, a bounded `explorer` can do read-only review and a separate `worker` can own the fix. Otherwise do the loop locally.
   - Produce concrete findings with file paths and line numbers.

2. **TRIAGE** — Extract only **Critical** findings from the report
   - If **zero** critical findings, break — the loop is done
   - List the critical findings for visibility
   - Only critical findings are actioned because warnings and suggestions are judgement calls best left to the author. Automating fixes for subjective issues risks introducing changes the user disagrees with.

3. **FIX (iteration N)** — Announce: `Fix iteration N/3 — addressing N critical issue(s)`
   - Fix only the critical findings.
   - Use `apply_patch` for manual edits.
   - Preserve user changes and avoid unrelated refactors.
   - Record fixed, unfixable, files modified, and test status.

4. **NARROW SCOPE** — Set `scope` to the files listed in the fixer's "Files Modified" output
   - If the fixer modified files *not* in the original scope, include those too — fixes can introduce issues in new files
   - If no files were modified (all findings were unfixable), break to the final report

5. **INCREMENT** — `iteration += 1`

**END LOOP**

### Step 4: Final Report

Announce: `Fix loop complete`

```markdown
# Fix Loop Report

## Iterations: N/3

## Resolved (Critical)
- [file:line] [issue] — fixed in iteration N

## Remaining (Critical)
- [file:line] [issue] — reason not fixed

## Noted (Warning / Suggestion)
- [file:line] [issue] — from iteration N (not actioned)

## Test Status
[Compare against baseline from Step 2. Report regressions vs pre-existing failures.]
```

Do not commit. Callers decide when to commit.
