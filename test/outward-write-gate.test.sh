#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/outward-write-gate.py"
SETTINGS="$ROOT/.claude/settings.json"

PASS=0
FAIL=0

# expect <expected: ask|none> <tool_name> [command]
expect() {
  local expected=$1 tool=$2 command=${3:-} output actual
  output=$(TOOL="$tool" COMMAND="$command" python3 -c '
import json, os
print(json.dumps({"tool_name": os.environ["TOOL"], "tool_input": {"command": os.environ["COMMAND"]}}))' |
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
    printf 'FAIL expected %-4s got %-4s %s %s\n' "$expected" "$actual" "$tool" "$command"
    FAIL=$((FAIL + 1))
  fi
}

# The settings matcher decides whether the hook runs at all for a tool.
expect_routed() {
  local tool=$1
  if TOOL="$tool" python3 -c '
import json, os, re, sys
hooks = json.load(open(sys.argv[1]))["hooks"]["PreToolUse"]
matchers = [h["matcher"] for h in hooks if any("outward-write-gate" in c["command"] for c in h["hooks"])]
sys.exit(0 if any(re.fullmatch(m, os.environ["TOOL"]) for m in matchers) else 1)' "$SETTINGS"; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL settings matcher does not route %s to the hook\n' "$tool"
    FAIL=$((FAIL + 1))
  fi
}

# --- gh writes ---
expect ask Bash 'gh pr comment 1 -b x'
expect ask Bash 'gh -R o/r pr comment 1 -b x'
expect ask Bash 'gh --repo=o/r issue create -t x -b y'
expect ask Bash 'timeout 30 gh pr comment 1 -b x'
expect ask Bash 'GH_REPO=o/r gh issue comment 1 -b x'
expect ask Bash 'env GH_REPO=o/r gh issue comment 1 -b x'
expect ask Bash '(gh pr comment 1 -b x)'
expect ask Bash 'git push -u origin feat && gh pr create -t x -b y'
expect ask Bash 'gh pr close 1 --comment x'
expect ask Bash 'gh issue close 1 -c x'
expect ask Bash 'gh pr merge 1 --squash --body x'
expect ask Bash 'gh release create v1 --notes x'
expect ask Bash 'gh api repos/o/r/issues/1/comments -f body=x'
expect ask Bash "gh api graphql -f query='mutation{addComment(input:{}){clientMutationId}}'"
expect ask Bash 'curl -X POST https://slack.com/api/chat.postMessage -d text=x'
expect ask Bash 'curl -d @msg.json https://hooks.slack.com/services/T/B/X'

# --- not writes, or not in command position ---
expect none Bash 'gh pr view 1'
expect none Bash 'gh pr merge 1 --squash'
expect none Bash 'gh pr merge 1 --squash && git branch -c a b'
expect none Bash "gh api graphql -f query='query{viewer{login}}'"
expect none Bash $'git commit -F - <<\'EOF\'\nfix: handle gh pr comment\nEOF'
expect none Bash 'curl https://example.com'

# --- MCP writes, whichever server exposes them ---
for tool in \
  mcp__claude_ai_Slack__slack_send_message \
  mcp__claude_ai_Slack__slack_schedule_message \
  mcp__plugin_engineering_slack__slack_send_message \
  mcp__claude_ai_Atlassian_Rovo__addCommentToJiraIssue \
  mcp__claude_ai_Atlassian_Rovo__addWorklogToJiraIssue \
  mcp__plugin_engineering_atlassian__addCommentToJiraIssue \
  mcp__claude_ai_Linear__save_comment \
  mcp__claude_ai_Linear__save_issue \
  mcp__claude_ai_Linear__save_document \
  mcp__claude_ai_Linear__save_status_update \
  mcp__claude_ai_Linear__save_diff_comment \
  mcp__claude_ai_Linear__submit_diff_review; do
  expect ask "$tool"
  expect_routed "$tool"
done

# --- MCP reads ---
expect none mcp__claude_ai_Linear__get_issue
expect none mcp__claude_ai_Linear__list_comments
expect none mcp__claude_ai_Slack__slack_read_channel

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d outward-write-gate tests passed\n' "$PASS"
