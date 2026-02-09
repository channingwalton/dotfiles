---
name: fix-loop
description: Iterative review-fix cycle that eliminates all critical issues. Runs code-reviewer, fixes critical findings, verifies tests pass, and repeats until clean or max iterations reached.
user_invocable: true
---

# Fix Loop

Autonomous review-fix cycle that iterates until all critical issues are resolved.

## Input

One of:
- File path(s) to review
- Directory to scan
- No argument (defaults to recently changed files via `git diff --name-only HEAD~3`)

## Workflow

```
🔍 REVIEW (code-reviewer) → 🔧 FIX (fixer) → 🔁 LOOP (max 5) → 💾 COMMIT?
```

### Agents

| Step | Agent | Purpose |
|------|-------|---------|
| REVIEW | `code-reviewer` | Find issues (read-only) |
| FIX | `fixer` | Apply fixes + verify tests |

### Constraints

- **Max iterations:** 5
- **Fix target:** Critical (🔴) findings only
- **Scope narrows** each iteration — only re-review files the fixer changed
- **Test gate** — fixer verifies tests pass before returning

---

## Execution

### Step 1: Determine Scope

If no files specified, run `git diff --name-only HEAD~3` to find recently changed files.

### Step 2: Review-Fix Loop

Set `iteration = 1` and `scope = <initial files>`.

**LOOP** while `iteration <= 5`:

1. **🔍 REVIEW (iteration N)** — Announce: `🔍 REVIEW iteration N/5`
   - Spawn the `code-reviewer` agent against `scope`
   - Receive the findings report

2. **TRIAGE** — Extract only 🔴 **Critical** findings from the report
   - If **zero** critical findings → break to Step 3
   - List the critical findings for visibility

3. **🔧 FIX (iteration N)** — Announce: `🔧 FIX iteration N/5 — addressing N critical issue(s)`
   - Spawn the `fixer` agent, passing it:
     - The list of 🔴 Critical findings (with file paths and line numbers)
     - The review context
   - Receive the fix report (fixed, unfixable, files modified, test status)

4. **NARROW SCOPE** — Set `scope` to only the files listed in the fixer's "Files Modified" output
   - If no files were modified (all unfixable) → break to Step 3

5. **INCREMENT** — `iteration += 1`

**END LOOP**

### Step 3: Final Report

Announce: `✅ FIX LOOP COMPLETE`

Aggregate findings from all iterations:

```markdown
# Fix Loop Report

## Iterations: N/5

## Resolved (🔴 Critical)
- [file:line] [issue] — fixed in iteration N

## Remaining (🔴 Critical)
- [file:line] [issue] — reason not fixed

## Noted (🟡 Warning / ℹ️ Suggestion)
- [file:line] [issue] — from iteration N (not actioned)

## Test Status: ✅ All passing / ⚠️ See notes
```

### Step 4: Commit

Ask the user: **Commit these changes?**

If yes → invoke the `commit-helper` agent.

---

## Announce Phase Transitions

```
🔍 REVIEW iteration 1/5 — reviewing N file(s)
🔧 FIX iteration 1/5 — addressing N critical issue(s) [fixer agent]
🔁 LOOP — N critical issue(s) remain, narrowing scope to N file(s)
✅ FIX LOOP COMPLETE — 0 critical issues after N iteration(s)
```
