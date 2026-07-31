#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/git-push-gate.py"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Two real repositories so bare `git push` has a branch to resolve.
make_repo() {
  local path=$1 branch=$2
  mkdir -p "$path"
  git -C "$path" init --quiet --initial-branch="$branch"
  git -C "$path" commit --quiet --allow-empty -m init
}

make_repo "$TMP_DIR/on-main" main
make_repo "$TMP_DIR/on-feature" RH-8453

PASS=0
FAIL=0

# expect <name> <expected-decision> <cwd> <command>
# expected-decision of "none" means the hook must stay silent.
expect() {
  local name=$1 expected=$2 cwd=$3 command=$4
  local payload output actual

  payload=$(COMMAND="$command" CWD="$cwd" python3 -c '
import json, os
print(json.dumps({
    "hook_event_name": "PreToolUse",
    "tool_name": "Bash",
    "cwd": os.environ["CWD"],
    "tool_input": {"command": os.environ["COMMAND"]},
}))')

  output=$(printf '%s' "$payload" | python3 "$HOOK" 2>&1) || {
    printf 'FAIL %-46s hook exited non-zero: %s\n' "$name" "$output"
    FAIL=$((FAIL + 1))
    return
  }

  if [[ -z $output ]]; then
    actual=none
  else
    actual=$(printf '%s' "$output" | python3 -c '
import json, sys
print(json.load(sys.stdin)["hookSpecificOutput"]["permissionDecision"])' 2>/dev/null) || actual="unparseable:$output"
  fi

  if [[ $actual == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL %-46s expected %-6s got %s\n' "$name" "$expected" "$actual"
    FAIL=$((FAIL + 1))
  fi
}

MAIN=$TMP_DIR/on-main
FEATURE=$TMP_DIR/on-feature

# --- explicit refspecs -------------------------------------------------
expect "feature branch by name"        allow "$FEATURE" "git push -u origin RH-8453"
expect "main by name"                  ask   "$FEATURE" "git push origin main"
expect "main with trailing pipe"       ask   "$FEATURE" "git push origin main 2>&1 | tail -5"
expect "feature with trailing pipe"    allow "$FEATURE" "git push -u origin RH-8453 2>&1 | tail -5"
expect "force-with-lease to feature"   allow "$FEATURE" "git push --force-with-lease origin RH-8453"
expect "force to main"                 ask   "$FEATURE" "git push --force origin main"
expect "leading plus force to main"    ask   "$FEATURE" "git push origin +main"
expect "HEAD colon main"               ask   "$FEATURE" "git push origin HEAD:main"
expect "HEAD colon feature"            allow "$FEATURE" "git push origin HEAD:RH-8453"
expect "refs/heads/main"               ask   "$FEATURE" "git push origin HEAD:refs/heads/main"
expect "refs/heads/feature"            allow "$FEATURE" "git push origin HEAD:refs/heads/RH-8453"
expect "branch merely prefixed main"   allow "$FEATURE" "git push origin maintenance"
expect "multiple refspecs incl. main"  ask   "$FEATURE" "git push origin RH-8453 main"

# --- bare push resolves the current branch -----------------------------
expect "bare push while on main"       ask   "$MAIN"    "git push"
expect "bare push while on feature"    allow "$FEATURE" "git push"
expect "push origin while on main"     ask   "$MAIN"    "git push origin"
expect "push -u origin HEAD on main"   ask   "$MAIN"    "git push -u origin HEAD"

# --- directory redirection ---------------------------------------------
expect "git -C into main repo"         ask   "$FEATURE" "git -C $MAIN push"
expect "git -C into feature repo"      allow "$MAIN"    "git -C $FEATURE push"
expect "cd then bare push"             allow "$MAIN"    "cd $FEATURE && git push"
expect "env prefix then push to main"  ask   "$FEATURE" "GIT_TRACE=1 git push origin main"

# --- deletes and bulk pushes -------------------------------------------
expect "delete main by flag"           ask   "$FEATURE" "git push --delete origin main"
expect "delete feature by flag"        allow "$FEATURE" "git push --delete origin RH-8453"
expect "delete main by empty source"   ask   "$FEATURE" "git push origin :main"
expect "push --all"                    ask   "$FEATURE" "git push --all origin"
expect "push --mirror"                 ask   "$FEATURE" "git push --mirror origin"

# --- value-taking options must not be read as refspecs -----------------
expect "--repo consumes its value"     allow "$FEATURE" "git push --repo main origin RH-8453"
expect "-o consumes its value"         allow "$FEATURE" "git push -o main origin RH-8453"

# --- compound commands --------------------------------------------------
expect "commit then push to feature"   allow "$FEATURE" "git add -A && git commit -m wip && git push -u origin RH-8453"
expect "commit then push to main"      ask   "$FEATURE" "git add -A && git commit -m wip && git push origin main"

# --- the hook must stay out of the way ----------------------------------
expect "plain git status"              none  "$FEATURE" "git status --short"
expect "git log mentioning push"       none  "$FEATURE" "git log --oneline --grep=push"
expect "gh pr create"                  none  "$FEATURE" "gh pr create --title x --body y"
expect "unrelated command"             none  "$FEATURE" "ls -la"

# --- heredoc commit bodies must never be dragged into the parser --------
# Prose commit messages carry apostrophes, which break shell tokenising.
# None of these are pushes, so the hook must stay silent rather than
# fail safe into a prompt on an ordinary commit.
heredoc_plain=$(printf '%s\n' "git commit -F - <<'EOF'" "fix the ticket's handler" "EOF")
heredoc_push_word=$(printf '%s\n' "git commit -a -F - <<'EOF'" "service-plans: session-aware deletes" "" "The ticket's wording says push, but this doesn't push." "EOF")
heredoc_staged=$(printf '%s\n' "git add -A && git commit -F - <<'EOF'" "make the two paths atomic" "" "Before P1.1 both of these were a single statement; we don't push here." "EOF")
expect "heredoc commit, apostrophe"    none  "$FEATURE" "$heredoc_plain"
expect "heredoc commit says push"      none  "$FEATURE" "$heredoc_push_word"
expect "staged heredoc commit"         none  "$FEATURE" "$heredoc_staged"

pr_body=$(printf '%s\n' "gh pr create --repo acme/x --base main --head RH-8453 --body-file - <<'EOF'" "The ticket's text implies we push to main. It doesn't." "EOF")
expect "gh pr body mentioning main"    none  "$FEATURE" "$pr_body"

# --- untrusted or unparseable input -------------------------------------
expect "unbalanced quote around push"  ask   "$FEATURE" "git push origin \"RH-8453"
expect "unknown repo path for -C"      ask   "$FEATURE" "git -C $TMP_DIR/absent push"

# Non-Bash tools and malformed payloads must produce no decision.
non_bash=$(printf '%s' '{"hook_event_name":"PreToolUse","tool_name":"Read","tool_input":{"file_path":"/tmp/x"}}' | python3 "$HOOK")
if [[ -z $non_bash ]]; then PASS=$((PASS + 1)); else
  printf 'FAIL %-46s expected none  got %s\n' "non-Bash tool" "$non_bash"; FAIL=$((FAIL + 1))
fi

malformed=$(printf '%s' 'not json at all' | python3 "$HOOK")
if [[ -z $malformed ]]; then PASS=$((PASS + 1)); else
  printf 'FAIL %-46s expected none  got %s\n' "malformed payload" "$malformed"; FAIL=$((FAIL + 1))
fi

printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[[ $FAIL -eq 0 ]]
