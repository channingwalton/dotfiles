#!/usr/bin/env python3
"""PreToolUse gate for `git push`.

Pushes to a protected branch require confirmation; every other push is
approved without a prompt. Anything this script cannot parse with
confidence falls back to asking.

Reads a PreToolUse hook payload on stdin and writes a permission decision
on stdout. Emitting nothing leaves the normal permission rules in charge.
"""

import json
import os
import re
import shlex
import subprocess
import sys

PROTECTED_BRANCHES = {"main"}

# Cheap pre-filter so the common case (any Bash call that is not a push)
# costs one regex and nothing else. It deliberately refuses to cross a
# newline or a shell operator, so prose inside a `git commit -F -` heredoc
# cannot drag an ordinary commit into the parser below.
LOOKS_LIKE_PUSH = re.compile(r"\bgit\b[^\n;|&]*?\bpush\b")

OPERATORS = {"&&", "||", ";", "|", "&", "\n"}

ENV_ASSIGNMENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")

# `git` options that consume the following token.
GIT_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}

# `git push` options that consume the following token.
PUSH_OPTS_WITH_VALUE = {"--repo", "-o", "--push-option", "--receive-pack", "--exec"}


def decide(decision, reason):
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": decision,
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.stdout.write("\n")
    sys.exit(0)


def abstain():
    """Emit no decision, leaving the configured permission rules to apply."""
    sys.exit(0)


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
    return [segment for segment in segments if segment]


def current_branch(cwd):
    try:
        result = subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if result.returncode != 0:
        return None
    branch = result.stdout.strip()
    # A detached HEAD reports "HEAD" and has no branch to compare against.
    return branch if branch and branch != "HEAD" else None


def normalise_ref(ref):
    ref = ref.lstrip("+")
    for prefix in ("refs/heads/", "heads/"):
        if ref.startswith(prefix):
            return ref[len(prefix) :]
    return ref


def parse_git_invocation(segment):
    """Return (subcommand, args, chdir) for a git call, or None if not one."""
    index = 0
    while index < len(segment) and ENV_ASSIGNMENT.match(segment[index]):
        index += 1
    if index >= len(segment):
        return None
    if os.path.basename(segment[index]) != "git":
        return None
    index += 1

    chdir = None
    while index < len(segment):
        token = segment[index]
        if not token.startswith("-"):
            break
        name, sep, inline = token.partition("=")
        if name in GIT_OPTS_WITH_VALUE:
            if sep:
                value = inline
                index += 1
            else:
                if index + 1 >= len(segment):
                    return None
                value = segment[index + 1]
                index += 2
            if name == "-C":
                chdir = value
        else:
            index += 1

    if index >= len(segment):
        return None
    return segment[index], segment[index + 1 :], chdir


def push_targets(args, cwd):
    """Branch names this push would write to, or None if undeterminable."""
    deleting = False
    positional = []
    index = 0
    while index < len(args):
        token = args[index]
        if token.startswith("-") and token != "-":
            name, sep, _ = token.partition("=")
            if name in ("--all", "--mirror"):
                # Pushes every branch, which includes the protected ones.
                return None
            if name in ("--delete", "-d"):
                deleting = True
                index += 1
                continue
            if name in PUSH_OPTS_WITH_VALUE and not sep:
                index += 2
                continue
            index += 1
            continue
        positional.append(token)
        index += 1

    # First positional is the remote; the rest are refspecs.
    refspecs = positional[1:] if positional else []

    if not refspecs:
        if deleting:
            return None
        branch = current_branch(cwd)
        return None if branch is None else [branch]

    targets = []
    for refspec in refspecs:
        if deleting:
            destination = refspec
        elif ":" in refspec:
            destination = refspec.rsplit(":", 1)[1]
        else:
            destination = refspec
        destination = normalise_ref(destination)
        if not destination:
            return None
        if destination == "HEAD":
            branch = current_branch(cwd)
            if branch is None:
                return None
            destination = branch
        targets.append(destination)
    return targets


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        abstain()

    if payload.get("tool_name") != "Bash":
        abstain()

    command = payload.get("tool_input", {}).get("command")
    if not isinstance(command, str) or not LOOKS_LIKE_PUSH.search(command):
        abstain()

    cwd = payload.get("cwd") or os.getcwd()

    try:
        segments = split_segments(tokenise(command))
    except ValueError:
        decide("ask", "Could not parse this command; confirming the push manually.")

    protected_hits = []
    saw_push = False
    for segment in segments:
        # `cd X && git push` moves the repo the bare push would resolve against.
        if segment[0] == "cd" and len(segment) > 1:
            cwd = segment[1] if os.path.isabs(segment[1]) else os.path.join(cwd, segment[1])
            continue

        invocation = parse_git_invocation(segment)
        if invocation is None:
            continue
        subcommand, args, chdir = invocation
        if subcommand != "push":
            continue

        saw_push = True
        target_cwd = cwd
        if chdir:
            target_cwd = chdir if os.path.isabs(chdir) else os.path.join(cwd, chdir)

        targets = push_targets(args, target_cwd)
        if targets is None:
            decide("ask", "Could not determine the target branch; confirming the push manually.")
        protected_hits.extend(t for t in targets if t in PROTECTED_BRANCHES)

    if not saw_push:
        abstain()

    if protected_hits:
        branches = ", ".join(sorted(set(protected_hits)))
        decide("ask", f"Pushes to protected branch: {branches}.")

    decide("allow", "Push targets a non-protected branch.")


if __name__ == "__main__":
    main()
