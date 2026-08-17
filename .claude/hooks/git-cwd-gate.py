#!/usr/bin/env python3
"""PreToolUse advisory: `cd <path> && git …` should be `git -C <path> …`.

Fires only when a Bash command runs a `cd <path>` and then a `git` call in the
same command (via && / ; / |) where that git call does not already carry `-C`.
Injects a one-line reminder as additionalContext; never blocks, exits 0 on any
error. Reads a PreToolUse payload on stdin.

Targets failure class: cwd-reliance/cd-git-wrong-repo
Retro 2026-08-16. A `cd <repo> && git …` chain (and the shared cwd it leaves for
sibling parallel Bash calls) has put a git mutation against the wrong repo — a
kmono push that ran inside the Rails checkout and no-op'd, nearly shipping a
stale PR (s09), and a user-rejected `cd && git pull` (s11). The user's global
CLAUDE.md already says to prefer `git -C <path>`; this reinforces it at the point
of action, where it was applied correctly elsewhere in the same session but not
here. Scope note: this catches the compound form only; a *bare* `git push` that
inherits a sibling parallel call's cwd cannot be correlated from one command and
is left to discipline.
"""
import json
import os
import re
import shlex
import sys

OPERATORS = {"&&", "||", ";", "|", "&", "\n"}
GIT_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}
ENV_ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")

# Cheap pre-filter: both a `cd` and a `git` must be present before we parse.
LOOKS_RELEVANT = re.compile(r"\bcd\s+\S")

REMINDER = (
    "cd <path> && git … detected. Prefer `git -C <path> …`: it is cwd-independent "
    "and safe when parallel Bash calls share a cwd (a sibling `cd` has run a git "
    "mutation against the wrong repo). This is the CLAUDE.md rule — apply it here."
)


def tokenise(command):
    lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    return list(lexer)


def split_segments(tokens):
    segments = [[]]
    for token in tokens:
        if token in OPERATORS:
            segments.append([])
        else:
            segments[-1].append(token)
    return [seg for seg in segments if seg]


def git_has_dashC(segment):
    """True if this segment is a `git` call already carrying -C."""
    index = 0
    while index < len(segment) and ENV_ASSIGNMENT.match(segment[index]):
        index += 1
    if index >= len(segment) or os.path.basename(segment[index]) != "git":
        return None  # not a git invocation
    index += 1
    while index < len(segment):
        token = segment[index]
        if not token.startswith("-"):
            break
        name = token.partition("=")[0]
        if name == "-C":
            return True
        if name in GIT_OPTS_WITH_VALUE and "=" not in token:
            index += 2
        else:
            index += 1
    return False


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    try:
        if payload.get("tool_name") != "Bash":
            return 0
        command = payload.get("tool_input", {}).get("command")
        if not isinstance(command, str) or not LOOKS_RELEVANT.search(command):
            return 0

        segments = split_segments(tokenise(command))
        saw_cd = False
        fire = False
        for segment in segments:
            if segment[0] == "cd" and len(segment) > 1:
                saw_cd = True
                continue
            if not saw_cd:
                continue
            dashC = git_has_dashC(segment)
            if dashC is False:  # a git call after a cd, without -C
                fire = True
                break
        if not fire:
            return 0

        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": REMINDER,
            }
        }))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
