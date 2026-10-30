#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/midturn-message-gate.py"
SETTINGS="$ROOT/.claude/settings.json"

PASS=0
FAIL=0

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# transcript <file> <event>... — each event is one of:
#   human:<text>  queued:<text>  call  result  declined  text  interrupt
transcript() {
  local file=$1
  shift
  python3 -c '
import json, sys
out = []
for spec in sys.argv[1:]:
    kind, _, text = spec.partition(":")
    if kind == "human":
        out.append({"type": "user", "origin": {"kind": "human"}, "message": {"role": "user", "content": text}})
    elif kind == "queued":
        out.append({"type": "attachment", "attachment": {"type": "queued_command", "prompt": text}})
    elif kind == "call":
        out.append({"type": "assistant", "message": {"content": [{"type": "tool_use", "id": "t", "name": "Bash", "input": {}}]}})
    elif kind == "result":
        out.append({"type": "user", "message": {"content": [{"type": "tool_result", "tool_use_id": "t", "content": "ok"}]}})
    elif kind == "declined":
        out.append({"type": "user", "message": {"content": [{"type": "tool_result", "tool_use_id": "t", "content": "The user doesn'"'"'t want to proceed with this tool use."}]}})
    elif kind == "text":
        out.append({"type": "assistant", "message": {"content": [{"type": "text", "text": "done"}]}})
    elif kind == "interrupt":
        out.append({"type": "user", "message": {"content": [{"type": "text", "text": "[Request interrupted by user]"}]}})
print("\n".join(json.dumps(e) for e in out))' "$@" > "$file"
}

# expect <expected: block|none> <stop_hook_active: true|false> <event>...
expect() {
  local expected=$1 active=$2 file actual output
  shift 2
  file=$(mktemp "$WORK/t.XXXXXX")
  transcript "$file" "$@"
  output=$(printf '{"transcript_path": "%s", "stop_hook_active": %s}' "$file" "$active" | python3 "$HOOK")
  if [[ -z $output ]]; then
    actual=none
  else
    actual=$(printf '%s' "$output" | python3 -c 'import json, sys; print(json.load(sys.stdin)["decision"])')
  fi
  if [[ $actual == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL expected %-5s got %-5s %s\n' "$expected" "$actual" "$*"
    FAIL=$((FAIL + 1))
  fi
}

# --- a message typed while the agent worked ---
expect block false 'human:fix it' call result "human:don't put it in my dotfiles" call result text
expect block false 'human:fix it' call 'queued:why not run it locally?' result text
expect block false 'human:fix it' call result 'human:one' call result 'human:two' text
# --- the second stop goes through ---
expect none true 'human:fix it' call result "human:don't put it in my dotfiles" call result text
# --- no message joined this turn ---
expect none false 'human:fix it' call result text
expect none false 'human:fix it' text
# --- a message from an earlier turn ---
expect none false 'human:a' call result 'human:mid' text 'human:b' call result text
# --- a turn that ended by interrupt or declined call ---
expect none false 'human:a' call interrupt 'human:b' call result text
expect none false 'human:a' call declined 'human:b' call result text
# --- harness notices are not the user's words ---
expect none false 'human:a' call result 'human:<task-notification>x</task-notification>' text
expect none false 'human:a' call 'queued:<task-notification>x</task-notification>' result text
expect none false 'human:a' call 'queued:<agent-message from="x">done</agent-message>' result text
# --- a broken payload exits quietly ---
if [[ -z $(printf '{"transcript_path": "/nonexistent"}' | python3 "$HOOK") ]]; then
  PASS=$((PASS + 1))
else
  printf 'FAIL missing transcript printed output\n'
  FAIL=$((FAIL + 1))
fi

# --- routing ---
if python3 -c '
import json, sys
hooks = json.load(open(sys.argv[1]))["hooks"]["Stop"]
sys.exit(0 if any("midturn-message-gate" in c["command"] for h in hooks for c in h["hooks"]) else 1)' "$SETTINGS"; then
  PASS=$((PASS + 1))
else
  printf 'FAIL settings do not run the hook at Stop\n'
  FAIL=$((FAIL + 1))
fi

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d midturn-message-gate tests passed\n' "$PASS"
