#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/private-ref-gate.py"
SETTINGS="$ROOT/.claude/settings.json"

PASS=0
FAIL=0

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
export TMPDIR="$WORK/tmp"  # the hold markers go here, not in the real temp folder
mkdir -p "$TMPDIR"

new_repo() {
  local repo="$WORK/$1"
  git init -q "$repo"
  git -C "$repo" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m init
  printf '%s' "$repo"
}

# expect <expected: deny|none> <cwd> <command> [session]
expect() {
  local expected=$1 cwd=$2 command=$3 session=${4:-s1} output actual
  output=$(COMMAND="$command" CWD="$cwd" SESSION="$session" python3 -c '
import json, os
print(json.dumps({"tool_name": "Bash", "session_id": os.environ["SESSION"], "cwd": os.environ["CWD"],
                  "tool_input": {"command": os.environ["COMMAND"]}}))' |
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

# --- an untracked file with a vault reference (the 2026-11-09 README) ---
REPO=$(new_repo untracked)
printf 'The designs are in the vault notes *Need Graph* (Projects/TXPLabs).\n' > "$REPO/README.md"
# The in-window forms: cd + add + heredoc commit, and git -C.
expect deny / "cd $REPO && git add . && git commit -q -F - <<'EOF'
Add the exemplar
EOF"
# The identical re-issue passes, and the hold is then used up.
expect none / "cd $REPO && git add . && git commit -q -F - <<'EOF'
Add the exemplar
EOF"
expect deny / "git -C $REPO add README.md && git -C $REPO commit -q -m 'Link to the need graph'"
# A variable that the same command assigns.
expect deny / "R=$REPO; git -C \$R commit -q -m x" s2
# A bare commit uses the payload's working directory.
expect deny "$REPO" "git commit -q -m x" s3
# Not a commit: no scan.
expect none / "git -C $REPO status --short"
expect none / "git -C $REPO log --grep commit"
# "git commit" inside a heredoc body is data.
expect none / "cat > /dev/null <<'EOF'
cd $REPO && git commit -m x
EOF"

# --- a modified tracked file ---
REPO=$(new_repo tracked)
printf 'clean\n' > "$REPO/a.md"
git -C "$REPO" add a.md
git -C "$REPO" -c user.name=t -c user.email=t@example.com commit -q -m a
expect none / "git -C $REPO commit -q -m 'no change'"
printf 'see ~/Documents/Notes/Projects/x.md\n' >> "$REPO/a.md"
expect deny / "git -C $REPO commit -q -am 'add a path'"
git -C "$REPO" checkout -q a.md
printf 'see my vault for the plan\n' >> "$REPO/a.md"
expect deny / "git -C $REPO commit -q -am 'add a phrase'"
git -C "$REPO" checkout -q a.md
# A reference that is already in HEAD is not an added line.
printf 'old: Documents/Notes\n' >> "$REPO/a.md"
git -C "$REPO" -c user.name=t -c user.email=t@example.com commit -q -am old
printf 'new clean line\n' >> "$REPO/a.md"
expect none / "git -C $REPO commit -q -am 'clean change'"
# Words that are not a reference to this vault.
printf 'HashiCorp Vault holds the secrets; a vault, for example; "Documents/notes.txt": "ordinary notes"\n' >> "$REPO/a.md"
expect none / "git -C $REPO commit -q -am 'other vaults'"
# A removed line is not an added line.
git -C "$REPO" checkout -q a.md
sed -i.bak '/old: Documents/d' "$REPO/a.md" && rm "$REPO/a.md.bak"
expect none / "git -C $REPO commit -q -am 'remove the reference'"

# --- a repository with no commit yet ---
REPO="$WORK/fresh"
git init -q "$REPO"
printf 'obsidian://open?vault=Notes\n' > "$REPO/n.md"
git -C "$REPO" add n.md
expect deny / "git -C $REPO commit -q -m first"

# --- not a repository, or a binary file: fail open ---
mkdir "$WORK/plain"
expect none / "git -C $WORK/plain commit -q -m x"
REPO=$(new_repo binary)
printf 'Documents/Notes\0\1' > "$REPO/blob.bin"
expect none / "git -C $REPO commit -q -m x"

# --- the skipped repositories name the vault on purpose ---
if python3 - "$HOOK" <<'EOF'
import importlib.util, os, sys
spec = importlib.util.spec_from_file_location("gate", sys.argv[1])
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)
home = os.path.expanduser("~")
ok = gate.skipped(os.path.join(home, "Documents", "Notes")) and gate.skipped(os.path.join(home, "dotfiles"))
sys.exit(0 if ok and not gate.skipped("/tmp") else 1)
EOF
then
  PASS=$((PASS + 1))
else
  printf 'FAIL the vault and dotfiles repositories are not skipped\n'
  FAIL=$((FAIL + 1))
fi

# --- settings.json routes Bash to the hook ---
if python3 -c '
import json, re, sys
hooks = json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]
matchers = [h["matcher"] for h in hooks if any("private-ref-gate.py" in c["command"] for c in h["hooks"])]
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
printf '%d private-ref-gate tests passed\n' "$PASS"
