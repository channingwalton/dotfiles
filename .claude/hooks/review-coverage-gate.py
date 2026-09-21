#!/usr/bin/env python3
"""PreToolUse advisory: has the code that is actually shipping been reviewed?

Fires on `git commit`, `gh pr create` and `gh pr merge`. Compares HEAD against
the SHA recorded by the last completed review pass (written by code-reviewer /
fix-loop into `<git-dir>/.claude-last-review`) and reports how many commits sit
between them.

Targets failure class: review/phase-bound-gate-misses-later-commits
Retro 2026-09-20. Revises `review/rebuilt-diff-ships-unreviewed`, which was a
prose rule in software-development §COMMIT and went INEFFECTIVE on its first
real excitation: fix-loop ran once at the end of a first task, three later
commits (including production wiring and a shared-response-body change) shipped
and MERGED unreviewed, and the completion report said "Review-fix loop clean".
Prose in a skill cannot see the commit graph; this can.

Advisory only — never blocks, exits 0 on any internal error.
"""
import json
import os
import re
import subprocess
import sys

TRIGGER = re.compile(
    r"(?:\A|[\n;|&]|\$\()\s*"
    r"(?:git\s+commit\b|gh\s+pr\s+(?:create|merge)\b)"
)

# A commit the reviewer itself is about to make (the stamp write) must not
# re-trigger; nothing to do there, but keep the matcher honest about --amend.
MARKER = ".claude-last-review"


def sh(args, cwd=None):
    try:
        r = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=5)
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception:
        return None


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    try:
        if payload.get("tool_name") != "Bash":
            return 0
        cmd = (payload.get("tool_input") or {}).get("command", "")
        if not cmd or not TRIGGER.search(cmd):
            return 0

        cwd = payload.get("cwd") or os.getcwd()
        git_dir = sh(["git", "rev-parse", "--absolute-git-dir"], cwd=cwd)
        if not git_dir:
            return 0

        head = sh(["git", "rev-parse", "HEAD"], cwd=cwd)
        if not head:
            return 0

        marker_path = os.path.join(git_dir, MARKER)
        reviewed = None
        if os.path.exists(marker_path):
            try:
                with open(marker_path) as fh:
                    reviewed = fh.read().strip().split()[0]
            except Exception:
                reviewed = None

        if reviewed == head:
            return 0  # HEAD is exactly what was reviewed; nothing to say.

        # Only speak when a review actually ran and HEAD has since moved. Firing
        # on every commit in every repo would be wallpaper: most commits never
        # warrant a review pass, and a reminder that always fires is ignored.
        if not reviewed:
            return 0

        count = sh(["git", "rev-list", "--count", f"{reviewed}..HEAD"], cwd=cwd)
        if count == "0":
            return 0
        detail = (
            f"The last recorded review was at {reviewed[:8]}; HEAD is {head[:8]}, "
            f"with {count or '?'} commit(s) in between that no review pass has seen."
        )

        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": (
                    "Review coverage check. " + detail + "\n"
                    "A review that ran earlier does not cover commits made after it — "
                    "review attaches to the code being merged, not to an approach you "
                    "replaced or a slice you reviewed first. Before reporting this work "
                    "as reviewed, run Skill(code-reviewer) over the diff that actually "
                    "ships. If you are deliberately shipping unreviewed, say so plainly "
                    "rather than describing the review loop as clean."
                ),
            }
        }))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
