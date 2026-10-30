#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/env-dump-gate.py"
SETTINGS="$ROOT/.claude/settings.json"

PASS=0
FAIL=0

# expect <expected: deny|none> <command>
expect() {
  local expected=$1 command=$2 output actual
  output=$(COMMAND="$command" python3 -c '
import json, os
print(json.dumps({"tool_name": "Bash", "tool_input": {"command": os.environ["COMMAND"]}}))' |
    python3 "$HOOK")
  if [[ -z $output ]]; then
    actual=none
  else
    actual=$(printf '%s' "$output" | python3 -c '
import json, sys
print(json.load(sys.stdin)["hookSpecificOutput"]["permissionDecision"])')
  fi
  if [[ $actual == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL expected %-4s got %-4s %s\n' "$expected" "$actual" "$command"
    FAIL=$((FAIL + 1))
  fi
}

# --- dumps (the 2026-10-23 leak and the forms seen since September) ---
expect deny 'env | cut -d= -f1'
expect deny "env | cut -d= -f1 | grep -E 'IDENTITY|TRUENAS' | sort"
expect deny "env | grep -i MISE | head -20"
expect deny "jq . ~/.docker/config.json; echo ---; env | grep -i -E 'proxy|docker'"
expect deny 'env'
expect deny 'printenv'
expect deny 'printenv | sort'
expect deny 'env -0 | tr "\0" "\n"'
expect deny 'FOO=1 env | wc -l'
expect deny 'sudo env'
expect deny '/usr/bin/env | head'
expect deny 'echo "$(env)" > /tmp/x'
expect deny 'for d in a b; do env | grep "$d"; done'
expect deny 'cd /repo && env | sort'

# --- not dumps ---
expect none 'env FOO=bar node script.js'
expect none 'env -i PATH=/usr/bin sh -c true'
expect none 'env -u SECRET make test'
expect none '/usr/bin/env python3 x.py'
expect none 'printenv HOME'
expect none 'for v in A B; do printenv "$v" | wc -c; done'
expect none "awk 'BEGIN { for (k in ENVIRON) print k }' | sort"
expect none 'git diff --stat -- env'
expect none 'cd env && ls'
expect none 'grep -n env setup.sh'
expect none "python3 -c 'import os; print(sorted(os.environ))'"
# A shell script written by a heredoc is about to run.
expect deny "cat > run.sh <<'EOF'
#!/usr/bin/env bash
env | cut -d= -f1
EOF
chmod +x run.sh"
expect none "cat > notes.md <<'EOF'
env | cut -d= -f1 leaked the keys
EOF"
expect none 'echo "use env | cut with care"'
expect none "gh pr comment 1 --body 'never run \`env | cut -d= -f1\`'"
expect none "gh pr create --body-file - <<'EOF'
The leak came from \`env | cut -d= -f1\`.
EOF"
expect deny 'echo "names: `env | cut -d= -f1`"'
# The 2026-10-23 leak: a stand-in script written by a heredoc, then run.
expect deny 'B=/tmp/fakebin
cat > "$B/node" <<EOF
#!/bin/bash
case "\$*" in
  *main.ts*) echo "env names: \$(env | cut -d= -f1 | sort | tr "\n" " ")"; exit 0 ;;
esac
EOF
chmod +x "$B/node"; PATH="$B:$PATH" just deploy'
expect none "env | grep -o '^TRUENAS_[A-Z_]*'"
expect none "env | rg -o '^TRUENAS[A-Z_]*' | sort"
expect none "env | grep -oE '^(OPENAI|CODEX)[A-Z_]*'"

# --- routing ---
if python3 -c '
import json, re, sys
hooks = json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]
matchers = [h["matcher"] for h in hooks if any("env-dump-gate" in c["command"] for c in h["hooks"])]
sys.exit(0 if any(re.fullmatch(m, "Bash") for m in matchers) else 1)' "$SETTINGS"; then
  PASS=$((PASS + 1))
else
  printf 'FAIL settings matcher does not route Bash to the hook\n'
  FAIL=$((FAIL + 1))
fi

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d env-dump-gate tests passed\n' "$PASS"
