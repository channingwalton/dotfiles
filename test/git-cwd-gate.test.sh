#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/git-cwd-gate.py"

PASS=0
FAIL=0

# expect <expected: fire|none> <command>
expect() {
  local expected=$1 command=$2 output actual
  output=$(COMMAND="$command" python3 -c '
import json, os
print(json.dumps({"tool_name": "Bash", "tool_input": {"command": os.environ["COMMAND"]}}))' |
    python3 "$HOOK")
  if [[ -z $output ]]; then actual=none; else actual=fire; fi
  if [[ $actual == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL expected %-4s got %-4s %s\n' "$expected" "$actual" "$command"
    FAIL=$((FAIL + 1))
  fi
}

# --- cd then git without an absolute -C ---
expect fire 'cd /x && git status'
expect fire 'cd /x; git pull'
expect fire 'cd /x && GIT_PAGER=cat git log -1'
expect fire 'cd /x && git add a && git commit -m ok'
# A heredoc commit message with an apostrophe made shlex raise, and the gate
# failed open on the commonest mutating form (retro 2026-10-05).
expect fire $'cd /x && git add a && git commit -F - <<\'EOF\'\nfix: don\'t break\nEOF'
expect fire $'cd /x && git commit -F - <<EOF\nit\'s "quoted\nEOF'
expect fire $'cd /x && git commit -F - <<END-MSG\nit\'s\nEND-MSG'
# An unbalanced quote: decide on the tokens before it, not on a looser regex.
expect fire $'cd /x\ngit commit -m "it\'s'
expect fire $'cd /x\ngit status'
# A comment ends at its own line, not at the end of the command.
expect fire $'cd /x  # go to repo\ngit status'
expect fire $'# switch\ncd /x\ngit status'
expect fire $'cd /x && echo a#b\ngit status'
# A newline inside quotes is data; the command after the closing quote still counts.
expect fire $'cd /x && python -c "\nimport json; print(\'a\')"; git status --short'
expect none $'git -C /x commit -m "subject\n\ncd /y && git push in prose"'
# Heredoc forms: a backslash delimiter, two bodies on one line.
expect fire $'cd /x && cat <<\\EOF\nit\'s\nEOF\ngit status'
expect fire $'cd /x && cat <<A <<B\na\nA\nb\'s\nB\ngit status'
# ANSI-C quoting: \' inside $'…' does not close the string.
expect fire $'cd /x && echo $\'it\\\'s\'\ngit status'
# A quoted ~ or single-quoted $ is not expanded: the path is relative to the cwd.
expect fire 'cd /x && git -C "~/x" status'
expect fire "cd /x && git -C '\$HOME/x' status"
expect none 'cd /x && git -C "$HOME/x" status'
# `-C .`, a relative -C, or one derived from the cwd is still cwd-dependent.
expect fire 'cd /x; git -C . status'
expect fire 'cd /x && git -C sub status'
expect fire 'cd /x && git -C "$PWD" status'
expect fire 'cd /x && git -C "$(pwd)" status'
expect fire 'cd /x && git -C $(pwd) status'

# --- fine ---
expect none 'git -C /x status'
expect none 'cd /x && git -C /x status'
expect none 'cd /x && git -C ~/x status'
expect none 'cd /x && git -C "$REPO" status'
expect none $'cd /x && git -C /x commit -m $\'it\\\'s\''
expect none 'cd /x && ls'
expect none 'git status'
expect none $'python3 - <<\'EOF\'\nprint("cd x && git status")\nEOF'
expect none $'cat > notes.md <<\'EOF\'\nRun cd x && git pull, don\'t forget\nEOF'

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d git-cwd-gate tests passed\n' "$PASS"
