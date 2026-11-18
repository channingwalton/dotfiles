#!/usr/bin/env python3
"""PreToolUse gate: a `git commit` must not add a reference to the private vault.

Fires on a Bash command that runs `git commit`. It scans what the commit can
add — the added lines of `git diff HEAD`, and the untracked files — for a
reference to the Obsidian vault. On a match it denies the call once and lists
the lines; the identical re-issue passes, for the case where the reference is
intended. The vault and dotfiles repositories are skipped: they refer to the
vault on purpose. Never asks the user; exits 0 on any error (fails open).
Reads a PreToolUse payload on stdin.

Targets failure class: privacy/private-reference-into-shared-repo
Retro 2026-11-15. A README sentence that pointed at vault notes was committed
and pushed to a team repository ("No one else on my team has access to my
vault"). The agent read the sentence twice before the commit, so standing
guidance did not reach the point of action; this check runs there.
"""
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
import time

HOME = os.path.expanduser("~")
SKIP_REPOS = [os.path.join(HOME, "Documents", "Notes"), os.path.join(HOME, "dotfiles")]

# The paths are case-sensitive: a test fixture `Documents/notes.txt` is not the
# vault (4 false holds in a replay of 309 commits). The phrases are not.
PRIVATE = re.compile(
    r"Documents/Notes\b"
    r"|\bProjects/(?:TXPLabs|Archive)\b"
    r"|\bobsidian://"
    r"|(?i:\bvault notes?\b|\b(?:my|your|Channing's) vault\b)"
)

LOOKS_RELEVANT = re.compile(r"\bgit\b[^\n;|&]*\bcommit\b")
HEREDOC = re.compile(
    r"<<-?\s*\\?(['\"]?)([^\s'\"<>;&|()\\]+)\1([^\n]*)\n.*?\n[ \t]*\2[ \t]*(?=\n|$)", re.S
)
OPERATORS = {"&&", "||", ";", "|", "&"}
ASSIGNMENT = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
GIT_OPTS_WITH_VALUE = {"-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}

REISSUE_WINDOW = 600  # seconds in which the identical call passes
MAX_FILE = 1_000_000
MAX_UNTRACKED = 300
MAX_LISTED = 12

REASON = (
    "Private reference — other people read this repository, and they cannot "
    "open the vault. This commit would add:\n{lines}\n\n"
    "Remove or reword each reference, then commit. This call was held once; "
    "if every reference is intended, re-issue the identical call."
)


def strip_heredocs(command):
    for _ in range(10):
        stripped = HEREDOC.sub(lambda m: "<<" + m.group(2) + m.group(3), command)
        if stripped == command:
            break
        command = stripped
    return command


def segments_of(command):
    lexer = shlex.shlex(command.replace("\n", " ; "), posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    lexer.commenters = ""
    tokens = []
    try:
        for token in lexer:
            tokens.append(token)
    except ValueError:
        pass  # an unbalanced quote: decide on what came before it
    segments = [[]]
    for token in tokens:
        if token in OPERATORS:
            segments.append([])
        else:
            segments[-1].append(token)
    return [seg for seg in segments if seg]


def expand(path, variables):
    """Expand `~`, `$HOME` and a variable that the same command assigned."""
    def value(match):
        name = match.group(1) or match.group(2)
        return variables.get(name, os.environ.get(name, match.group(0)))
    return os.path.expanduser(re.sub(r"\$\{(\w+)\}|\$(\w+)", value, path))


def commit_dirs(command, cwd):
    """The directory of each `git … commit` in the command."""
    variables = {}
    current = cwd
    found = []
    for segment in segments_of(strip_heredocs(command)):
        index = 0
        while index < len(segment) and ASSIGNMENT.match(segment[index]):
            name, raw = ASSIGNMENT.match(segment[index]).groups()
            variables[name] = expand(raw, variables)
            index += 1
        words = segment[index:]
        if not words:
            continue
        if words[0] == "cd" and len(words) > 1:
            current = os.path.join(current or "", expand(words[1], variables))
            continue
        if os.path.basename(words[0]) != "git":
            continue
        directory = current
        position = 1
        while position < len(words) and words[position].startswith("-"):
            option = words[position]
            if option == "-C" and position + 1 < len(words):
                directory = os.path.join(directory or "", expand(words[position + 1], variables))
                position += 2
            elif option in GIT_OPTS_WITH_VALUE:
                position += 2
            else:
                position += 1
        if position < len(words) and words[position] == "commit" and directory:
            found.append(directory)
    return found


def git(directory, *args):
    result = subprocess.run(
        ["git", "-C", directory, *args], capture_output=True, text=True,
        errors="replace", timeout=4, check=False,
    )
    return result.stdout if result.returncode == 0 else None


def skipped(top):
    real = os.path.realpath(top)
    return any(real == os.path.realpath(repo) for repo in SKIP_REPOS)


def added_lines(top):
    """(file, text) for each line the commit can add."""
    diff = git(top, "diff", "HEAD", "-U0", "--no-color", "--no-ext-diff")
    if diff is None:  # no HEAD yet: a new repository
        diff = git(top, "diff", "--cached", "-U0", "--no-color", "--no-ext-diff") or ""
    name = "?"
    for line in diff.splitlines():
        if line.startswith("+++ "):
            name = line[6:] if line.startswith("+++ b/") else line[4:]
        elif line.startswith("+"):
            yield name, line[1:]
    untracked = git(top, "ls-files", "--others", "--exclude-standard", "-z") or ""
    for name in [n for n in untracked.split("\0") if n][:MAX_UNTRACKED]:
        path = os.path.join(top, name)
        try:
            if os.path.islink(path) or os.path.getsize(path) > MAX_FILE:
                continue
            with open(path, "rb") as handle:
                data = handle.read()
        except OSError:
            continue
        if b"\0" in data:
            continue
        for text in data.decode("utf-8", "replace").splitlines():
            yield name, text


def hits_in(top):
    hits = []
    for name, text in added_lines(top):
        match = PRIVATE.search(text)
        if match:
            start = max(0, match.start() - 80)
            excerpt = text[start:match.end() + 80].strip()
            hits.append(f"- {name}: {'…' if start else ''}{excerpt}")
    return hits


def first_sight(key):
    """True the first time this call is seen; the identical re-issue passes."""
    folder = os.path.join(tempfile.gettempdir(), "private-ref-gate")
    os.makedirs(folder, exist_ok=True)
    marker = os.path.join(folder, hashlib.sha256(key.encode()).hexdigest())
    now = time.time()
    if os.path.exists(marker) and now - os.path.getmtime(marker) < REISSUE_WINDOW:
        os.remove(marker)
        return False
    with open(marker, "w") as handle:
        handle.write(str(now))
    return True


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0
    try:
        if payload.get("tool_name") != "Bash":
            return 0
        command = payload.get("tool_input", {}).get("command")
        if not isinstance(command, str) or not LOOKS_RELEVANT.search(strip_heredocs(command)):
            return 0
        hits = []
        seen = set()
        for directory in commit_dirs(command, payload.get("cwd") or os.getcwd()):
            top = (git(directory, "rev-parse", "--show-toplevel") or "").strip()
            if not top or top in seen or skipped(top):
                continue
            seen.add(top)
            hits += hits_in(top)
        if not hits:
            return 0
        key = "\0".join([str(payload.get("session_id")), command] + hits)
        if not first_sight(key):
            return 0
        listed = hits[:MAX_LISTED]
        if len(hits) > MAX_LISTED:
            listed.append(f"- … and {len(hits) - MAX_LISTED} more")
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": REASON.format(lines="\n".join(listed)),
            }
        }))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
