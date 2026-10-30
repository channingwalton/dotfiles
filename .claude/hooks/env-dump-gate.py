#!/usr/bin/env python3
"""PreToolUse gate: no whole-environment dumps in Bash.

`env` and `printenv` with no operand print every variable. A multi-line value,
such as an armoured private key, prints whole even through `cut -d= -f1`,
because its continuation lines carry no `=`. On 2026-10-23 this put two fresh
GPG private keys into a transcript. The gate denies the dump and names safe
forms. Any internal error exits 0 silently.

Targets failure class: secret-exposure/env-dump-into-transcript (retro 2026-10-30).
"""
import json
import re
import shlex
import sys

SEPARATORS = ";&|()\n"
# Words after which the next word is in command position.
KEYWORDS = {"do", "then", "else", "elif", "!", "{", "time", "command", "exec", "sudo"}
# `env` options that take a value, and those that do not.
ENV_VALUE_FLAGS = {"-u", "--unset", "-C", "--chdir", "-P", "-S", "--split-string"}
HEREDOC = re.compile(r"<<-?\s*(['\"]?)(\w+)\1")

REASON = (
    "Whole-environment dump blocked. `env` and `printenv` with no operand print "
    "every variable, and a multi-line value such as a private key prints whole, "
    "even through `cut -d= -f1`. Instead:\n"
    "- list names: awk 'BEGIN { for (k in ENVIRON) print k }' | sort\n"
    "- test one variable: [ -n \"${NAME-}\" ] && echo set\n"
    "- print one value that is not a secret: printenv NAME"
)


def split_heredocs(command):
    """The command without its heredoc bodies, and the bodies that are scripts.

    A body is data, such as a PR body quoting `env | cut`, unless it starts with
    a shell `#!` line: the 2026-10-23 leak was a stand-in script written by a
    heredoc and run later in the same command.
    """
    out = []
    scripts = []
    ends = []
    body = None
    for line in command.split("\n"):
        if ends:
            if line.strip() == ends[0]:
                ends.pop(0)
                if body and re.match(r"#!.*\b(?:ba|z)?sh\b", body[0]):
                    scripts.append("\n".join(body[1:]))
                body = None
            else:
                body = (body or []) + [line]
            continue
        out.append(line)
        ends.extend(m.group(2) for m in HEREDOC.finditer(line))
    return "\n".join(out), scripts


def words(command):
    lexer = shlex.shlex(command, posix=True, punctuation_chars=SEPARATORS)
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    lexer.commenters = ""
    return list(lexer)


def is_dump(name, args):
    """Whether `env ARGS` or `printenv ARGS` prints the whole environment."""
    i = 0
    while i < len(args):
        word = args[i]
        if word and set(word) <= set(SEPARATORS):
            break
        if name == "env" and word in ENV_VALUE_FLAGS:
            i += 2
            continue
        if word.startswith("-"):
            i += 1
            continue
        # An operand: a variable name for printenv; an assignment or a command for env.
        if name == "printenv" or "=" not in word:
            return False
        i += 1
    # `env | grep -o '^NAME…'` prints only the matched names.
    rest = args[i + 1:i + 3] if i < len(args) and args[i] == "|" else []
    if rest and rest[0] in ("grep", "rg") and len(rest) > 1 and re.fullmatch(r"-[A-Za-z]*o[A-Za-z]*", rest[1]):
        return False
    return True


def dumps(command):
    command = command.replace("\\\n", " ")
    command, scripts = split_heredocs(command)
    # Inside an unquoted heredoc, the script's own `$(` is written `\$(`.
    if any(dumps(s.replace("\\$", "$").replace("\\`", "`")) for s in scripts):
        return True
    # A substitution inside double quotes is one word to the lexer. Single
    # quotes hold literal text.
    live = re.sub(r"'[^']*'", "''", command)
    for inner in re.findall(r"\$\(([^()]*)\)|`([^`]*)`", live):
        if any(part and part != command and dumps(part) for part in inner):
            return True
    ws = words(command)
    start = True
    for i, word in enumerate(ws):
        if word and set(word) <= set(SEPARATORS):
            start = True
            continue
        if start and word in KEYWORDS:
            continue
        if start and re.fullmatch(r"[A-Za-z_]\w*=\S*", word):
            continue
        if start and word.rsplit("/", 1)[-1] in ("env", "printenv"):
            if is_dump(word.rsplit("/", 1)[-1], ws[i + 1:]):
                return True
        start = False
    return False


def main() -> int:
    try:
        payload = json.load(sys.stdin)
        if payload.get("tool_name") != "Bash":
            return 0
        command = (payload.get("tool_input") or {}).get("command") or ""
        if not dumps(command):
            return 0
    except Exception:
        return 0
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": REASON,
        }
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
