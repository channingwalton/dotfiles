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

# A heredoc body is data, not commands, and an apostrophe in it made shlex raise
# — the gate then failed open on `git commit -F - <<'EOF'`, the commonest
# mutating form (retro 2026-10-05). Keep the opening line, drop body and end.
HEREDOC = re.compile(
    r"<<-?\s*\\?(['\"]?)([^\s'\"<>;&|()\\]+)\1([^\n]*)\n.*?\n[ \t]*\2[ \t]*(?=\n|$)", re.S
)

# `-C` values that still depend on the cwd: `$PWD`, `$OLDPWD`, `$(pwd)`.
CWD_DERIVED = re.compile(r"^\$(?:\{?(?:PWD|OLDPWD)\b|\(|$)")

# shlex drops quotes, but a quoted `~` or a single-quoted `$` is not expanded:
# `-C "~/x"` and `-C '$HOME/x'` are relative paths.
LITERAL_C = re.compile(r"(?:^|\s)-C\s*(?:[\"']~|'\$)")

REMINDER = (
    "cd <path> && git … detected. Prefer `git -C <path> …`: it is cwd-independent "
    "and safe when parallel Bash calls share a cwd (a sibling `cd` has run a git "
    "mutation against the wrong repo). This is the CLAUDE.md rule — apply it here."
)


def normalise(command):
    """Unquoted newlines become `;` and unquoted comments go, so one shlex pass
    sees the commands the shell would run. Quoted text, newlines included, is
    left alone: a multi-line `python -c "…"` or commit message is data."""
    out = []
    quote = None
    previous = " "
    index = 0
    while index < len(command):
        char = command[index]
        if quote:
            out.append(char)
            if char == quote:
                quote = None
            elif char == "\\" and quote == '"' and index + 1 < len(command):
                index += 1
                out.append(command[index])
        elif char == "\\" and index + 1 < len(command):
            index += 1
            out.append(" " if command[index] == "\n" else "\\" + command[index])
        elif command.startswith("$'", index):
            # ANSI-C string: `\'` does not close it, and shlex cannot read it,
            # so it becomes one opaque word.
            index += 2
            while index < len(command) and command[index] != "'":
                index += 2 if command[index] == "\\" else 1
            out.append("ANSI_C_STRING")
        elif char in "'\"":
            quote = char
            out.append(char)
        elif char == "#" and previous in " \t\n;&|(":
            while index < len(command) and command[index] != "\n":
                index += 1
            continue  # the newline, if any, is handled on the next pass
        else:
            out.append(" ; " if char == "\n" else char)
        previous = char
        index += 1
    return "".join(out)


def tokenise(command):
    """Tokens up to any unbalanced quote."""
    lexer = shlex.shlex(normalise(command), posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    lexer.commenters = ""
    tokens = []
    try:
        for token in lexer:
            tokens.append(token)
    except ValueError:
        pass  # an unbalanced quote: decide on what came before it
    return tokens


def split_segments(tokens):
    segments = [[]]
    for token in tokens:
        if token in OPERATORS:
            segments.append([])
        else:
            segments[-1].append(token)
    return [seg for seg in segments if seg]


def strip_heredocs(command):
    # Repeat: with `cmd <<A <<B` the second opener is kept on the first pass.
    for _ in range(10):
        stripped = HEREDOC.sub(lambda m: "<<" + m.group(2) + m.group(3), command)
        if stripped == command:
            break
        command = stripped
    return command


def git_has_dashC(segment):
    """True if this segment is a `git` call carrying an absolute -C.

    `-C .`, a relative path, or `$PWD`/`$(pwd)` after a `cd` still depends on
    the cwd, so it counts as missing.
    """
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
            path = segment[index + 1] if index + 1 < len(segment) else ""
            if path.startswith("$"):
                return not CWD_DERIVED.match(path)
            return path.startswith(("/", "~"))
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

        command = LITERAL_C.sub(
            lambda m: m.group(0)[:-1] + "./" + m.group(0)[-1], strip_heredocs(command)
        )
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
            if dashC is False:  # a git call after a cd, without an absolute -C
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
