#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/.claude/hooks/outward-write-gate.py"
SETTINGS="$ROOT/.claude/settings.json"

PASS=0
FAIL=0

STATES=$(mktemp -d)
trap 'rm -rf "$STATES"' EXIT

# decision <state dir> <tool_name> [command] [description] [session] [agent] -> deny|none
# Real Bash payloads carry a description, which the model rewrites freely;
# a subagent's payload shares the session id and adds its agent_id.
decision() {
  local state=$1 tool=$2 command=${3:-} description=${4:-Run it} session=${5:-s1} agent=${6:-} output
  output=$(TOOL="$tool" COMMAND="$command" DESCRIPTION="$description" SESSION="$session" AGENT="$agent" python3 -c '
import json, os
tool_input = {"command": os.environ["COMMAND"]}
if os.environ["TOOL"] == "Bash":
    tool_input["description"] = os.environ["DESCRIPTION"]
payload = {"tool_name": os.environ["TOOL"], "tool_input": tool_input, "session_id": os.environ["SESSION"]}
if os.environ["AGENT"]:
    payload["agent_id"] = os.environ["AGENT"]
print(json.dumps(payload))' |
    OUTWARD_GATE_STATE="$state" python3 "$HOOK")
  if [[ -z $output ]]; then
    echo none
  else
    printf '%s' "$output" | python3 -c '
import json, sys
print(json.load(sys.stdin)["hookSpecificOutput"]["permissionDecision"])'
  fi
}

# A model turn passes between a hold and its re-issue: age the markers by a
# minute, past the same-batch window and inside the hold.
model_turn() {
  python3 -c '
import os, sys, time
for e in os.listdir(sys.argv[1]):
    p = os.path.join(sys.argv[1], e); t = time.time() - 60; os.utime(p, (t, t))' "$1"
}

# expect <expected: write|none> <tool_name> [command]
# A write is denied the first time it is seen and let through when re-issued unchanged.
expect() {
  local expected=$1 tool=$2 command=${3:-} state actual
  state=$(mktemp -d "$STATES/s.XXXXXX")
  actual=$(decision "$state" "$tool" "$command" 'Post it')
  if [[ $actual == deny ]]; then
    model_turn "$state"
    actual=$(decision "$state" "$tool" "$command" 'Send it after checking')
    [[ $actual == none ]] && actual=write || actual="deny-then-$actual"
  fi
  if [[ $actual == "$expected" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL expected %-4s got %-4s %s %s\n' "$expected" "$actual" "$tool" "$command"
    FAIL=$((FAIL + 1))
  fi
}

# A revised call is a new call: held again before it can go through.
expect_revision_held() {
  local state first second
  state=$(mktemp -d "$STATES/s.XXXXXX")
  first=$(decision "$state" Bash 'gh pr comment 1 -b draft')
  second=$(decision "$state" Bash 'gh pr comment 1 -b revised')
  if [[ $first == deny && $second == deny ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL revision: expected deny deny, got %s %s\n' "$first" "$second"
    FAIL=$((FAIL + 1))
  fi
}

# expect_sequence <label> <expected decisions...> -- <session:command>...
# Runs the calls in order against one state dir, a model turn apart; the
# command `+` stands for "same as the previous call, in the same batch".
expect_sequence() {
  local label=$1 state expected=() actual=() call previous=
  shift
  while [[ $1 != -- ]]; do expected+=("$1"); shift; done
  shift
  state=$(mktemp -d "$STATES/s.XXXXXX")
  for call in "$@"; do
    if [[ ${call#*:} == + ]]; then
      call=$previous
    elif [[ -n $previous ]]; then
      model_turn "$state"
    fi
    actual+=("$(decision "$state" Bash "${call#*:}" 'Run it' "${call%%:*}")")
    previous=$call
  done
  if [[ "${actual[*]}" == "${expected[*]}" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL %s: expected %s, got %s\n' "$label" "${expected[*]}" "${actual[*]}"
    FAIL=$((FAIL + 1))
  fi
}

# A hold expires: a re-issue more than ten minutes later is held again.
expect_hold_expires() {
  local state first second
  state=$(mktemp -d "$STATES/s.XXXXXX")
  first=$(decision "$state" Bash 'gh pr comment 1 -b x')
  touch -t 202001010000 "$state"/*
  second=$(decision "$state" Bash 'gh pr comment 1 -b x')
  if [[ $first == deny && $second == deny ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL expiry: expected deny deny, got %s %s\n' "$first" "$second"
    FAIL=$((FAIL + 1))
  fi
}

# Subagents share the session id: a hold seen by one agent is not consumed by another.
expect_agents_held() {
  local state first second third
  state=$(mktemp -d "$STATES/s.XXXXXX")
  first=$(decision "$state" Bash 'gh pr comment 1 -b x' 'Run it' s1 parent)
  model_turn "$state"
  second=$(decision "$state" Bash 'gh pr comment 1 -b x' 'Run it' s1 helper)
  model_turn "$state"
  third=$(decision "$state" Bash 'gh pr comment 1 -b x' 'Run it' s1 helper)
  if [[ $first == deny && $second == deny && $third == none ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL agents: expected deny deny none, got %s %s %s\n' "$first" "$second" "$third"
    FAIL=$((FAIL + 1))
  fi
}

# A marker that vanishes mid-check (a parallel re-issue or an expiry sweep took
# it) holds the call rather than letting it through, at either step of consuming
# it, and leaves a marker so the next re-issue goes through.
expect_race_held() {
  local actual
  actual=$(python3 -c '
import importlib.util, os, sys, tempfile, time
spec = importlib.util.spec_from_file_location("gate", sys.argv[1])
gate = importlib.util.module_from_spec(spec); spec.loader.exec_module(gate)
d = tempfile.mkdtemp(); marker = os.path.join(d, "m"); now = time.time()
def old_marker():
    open(marker, "w").close(); os.utime(marker, (now - 60, now - 60))
results = [gate.consume_hold(marker, now)]          # already gone
results.append(gate.consume_hold(marker, now))      # re-marked: next re-issue passes
old_marker()
real_remove = os.remove
def vanished(path):
    real_remove(path); raise FileNotFoundError(path)
os.remove = vanished
results.append(gate.consume_hold(marker, now))      # gone as it is removed
os.remove = real_remove
open(marker, "w").close()
results.append(gate.consume_hold(marker, now))      # same batch: too young
old_marker()
results.append(gate.consume_hold(marker, now))      # a real re-issue
print(" ".join(map(str, results)), os.path.exists(marker))' "$HOOK" 2>&1 | tail -1) || true
  if [[ $actual == "False True False False True False" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL race: expected "False True False False True False", got %s\n' "$actual"
    FAIL=$((FAIL + 1))
  fi
}

# expect_tokens <command> <expected words, space-separated>
expect_tokens() {
  local actual
  actual=$(python3 -c '
import importlib.util, sys
spec = importlib.util.spec_from_file_location("gate", sys.argv[1])
gate = importlib.util.module_from_spec(spec); spec.loader.exec_module(gate)
print(" ".join(gate.tokens(sys.argv[2])[0]))' "$HOOK" "$1" 2>&1 | tail -1) || true
  if [[ $actual == "$2" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL tokens %s: expected "%s", got "%s"\n' "$1" "$2" "$actual"
    FAIL=$((FAIL + 1))
  fi
}

# An unwritable state dir lets the write through rather than holding it forever:
# without state, a re-issue can never be told apart from a first attempt.
expect_state_failure_passes() {
  local actual
  actual=$(decision /dev/null/nope Bash 'gh pr comment 1 -b x')
  if [[ $actual == none ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL unwritable state: expected none, got %s\n' "$actual"
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
expect write Bash 'gh pr comment 1 -b x'
expect write Bash 'gh -R o/r pr comment 1 -b x'
expect write Bash 'gh --repo=o/r issue create -t x -b y'
expect write Bash 'timeout 30 gh pr comment 1 -b x'
expect write Bash 'GH_REPO=o/r gh issue comment 1 -b x'
expect write Bash 'env GH_REPO=o/r gh issue comment 1 -b x'
expect write Bash '(gh pr comment 1 -b x)'
expect write Bash 'git push -u origin feat && gh pr create -t x -b y'
expect write Bash 'gh pr close 1 --comment x'
expect write Bash 'gh issue close 1 -c x'
expect write Bash 'gh pr merge 1 --squash --body x'
expect write Bash 'gh release create v1 --notes x'
expect write Bash 'gh api repos/o/r/issues/1/comments -f body=x'
expect write Bash "gh api graphql -f query='mutation{addComment(input:{}){clientMutationId}}'"
expect write Bash 'curl -X POST https://slack.com/api/chat.postMessage -d text=x'
expect write Bash 'curl -d @msg.json https://hooks.slack.com/services/T/B/X'
expect write Bash 'gh api --method PATCH repos/o/r/issues/1 -f state=closed'
expect write Bash 'gh api -XPOST repos/o/r/pulls/1/comments --input body.json'
expect write Bash 'cd repo && gh api repos/o/r/issues/1/comments -f body=x'
expect write Bash 'gh api -X GET search/issues -f q=x; gh issue comment 1 -b y'
expect_revision_held
expect_hold_expires
expect_state_failure_passes
# Forms that slipped past the first version of the read-only filter.
expect write Bash $'gh api repos/o/r/issues/1/comments \\\n  -f body=x'
expect write Bash $'gh api \\\n  repos/o/r/issues/1/comments -f body=x'
expect write Bash "gh api -X GET repos/o/r/pulls/1/comments; gh pr comment 2 -b 'see the comments'"
expect write Bash 'gh api repos/o/r/issues/1/comments -fbody=x'
expect write Bash 'gh api repos/o/r/issues/1/comments -Fbody=@msg.md'
expect write Bash 'gh pr comment 1 -b -h'
expect write Bash 'gh api graphql --input req.json'
expect write Bash 'gh api graphql -F query=@mutation.graphql'
expect write Bash 'gh api graphql -f query="$Q"'
expect write Bash $'gh api graphql -f query=\'\n  mutation { addComment(input: {}) { clientMutationId } }\''
expect write Bash "gh pr comment 1 -b 'unclosed"
expect write Bash 'gh api repos/o/r/issues/1/comments 2>&1 -f body=x'
expect write Bash "gh api -X PATCH --jq '.a|.b' repos/o/r/issues/1 -f body=x"
expect write Bash "gh api -H 'Accept: a|b' repos/o/r/issues/1/comments -f body=x"
expect write Bash 'gh api repos/o/r/issues/1/comments#x -f body=x'
expect write Bash "gh api graphql -F query='{viewer{login}}' -F body=@x.md"
expect_sequence 'the re-issue consumes the hold' deny none deny -- \
  's1:gh pr comment 1 -b x' 's1:gh pr comment 1 -b x' 's1:gh pr comment 1 -b x'
expect_sequence 'holds are per session' deny deny none -- \
  's1:gh pr comment 1 -b x' 's2:gh pr comment 1 -b x' 's2:gh pr comment 1 -b x'
expect_sequence 'same batch is held, not let through' deny deny none -- \
  's1:gh pr comment 1 -b x' 's1:+' 's1:gh pr comment 1 -b x'
expect write Bash "gh api -X POST graphql -f query='mutation{addComment(input:{}){clientMutationId}}'"
expect write Bash "gh api -H 'Accept: x' graphql -f query='mutation{addComment(input:{}){clientMutationId}}'"
# Words the parser cannot see through count as unknown, and unknown is gated.
expect write Bash 'gh api -X POST -f body=$(cat m) repos/o/r/issues/1/comments'
expect write Bash 'gh api -X POST --input <(jq -n x) repos/o/r/issues/1/comments'
expect write Bash 'EP=repos/o/r/issues/1/comments && gh api "$EP" -f body=x'
expect write Bash 'gh api graphql -f query="`cat m.graphql`"'
expect write Bash 'gh api graphql -f query=" $M"'
expect write Bash 'gh api /graphql -f query="mutation{addComment(input:{}){clientMutationId}}"'
expect write Bash 'gh api https://api.github.com/graphql -f query="mutation{x}"'
expect_agents_held
expect_race_held
# Arguments the parser cannot resolve: hidden flags, an endpoint from stdin.
expect write Bash 'FLAGS="-X POST -f body=hi"; gh api repos/o/r/issues/1/comments $FLAGS'
expect write Bash 'gh api "${args[@]}"'
expect write Bash 'echo repos/o/r/issues/1/comments | xargs gh api -f body=x'
expect write Bash 'gh api graphql -f query="query{x} $(cat m)"'
expect write Bash 'gh api -X PATCH repos/o/r/releases/1 -f body=x'
expect write Bash 'gh api -X POST repos/o/r/releases -f tag_name=v1 -f body=notes'
# Quoting is gone after parsing, so a variable endpoint may split into flags,
# and xargs may append them: both count as unknown.
expect write Bash 'EP="repos/o/r/issues/1/comments -f body=hi"; gh api $EP'
expect write Bash 'gh api "$EP"'
expect write Bash 'echo repos/o/r/issues/1/comments | xargs gh api'
expect write Bash 'gh api repos/o/r/issues/1/comments -if body=x'
expect write Bash 'gh api repos/o/r/issues/1/comments -iXPOST'
expect write Bash "gh api graphql -f query=\"{viewer{login}} \$M\" -f operationName=x"
expect write Bash 'gh api gists -f description=x -f files[a.md][content]=hi'
expect write Bash 'gh api repos/o/r/check-runs -f name=x -f output[summary]=hi'
expect write Bash 'gh api -X POST repos/o/r/git/tags -f tag=v1 -f message=notes'
# Every REST write is held unless its endpoint is known to carry no prose.
expect write Bash 'gh api -X PUT repos/o/r/contents/README.md -f message=x -f content=eA=='
expect write Bash 'gh api -X PATCH repos/o/r -f description=x'
expect write Bash 'gh api repos/o/r/milestones -f title=x'
expect write Bash 'gh api repos/o/r/statuses/abc -f state=success -f description=x'
expect write Bash 'gh api repos/o/r/git/commits -f message=x -f tree=abc'
expect write Bash 'gh api user -X PATCH -f bio=x'
expect write Bash "gh api api/graphql -f query='mutation{x}'"
expect write Bash "gh api 'graphql?x=1' -f query='mutation{x}'"
# A GraphQL $name the query never declares is the shell's, however it is quoted.
expect write Bash "gh api graphql -f query='{x}'\"\$M\""
expect write Bash "gh api graphql -f query='{viewer{login}}' -f query=\"\$M\""
expect write Bash "gh api graphql -f query=\"\$M\" ; echo 'query='"
# xargs options, a flag value that may split, an unquoted backtick.
expect write Bash 'echo 1 | xargs -I{} gh api -X POST repos/o/r/issues/{}/comments -f body=x'
expect write Bash 'xargs -n1 gh api -X POST repos/o/r/issues/1/comments -f body=x'
expect write Bash 'gh api repos/o/r/issues/1/comments -H $H'
expect write Bash "gh api \`printf 'repos/o/r/issues/1/comments -X POST'\` -f body=x"
expect_tokens 'gh api a 5 >out' 'gh api a 5'
expect_tokens 'gh api a 2>&1 -f b=c' 'gh api a -f b=c'
expect_tokens 'gh api a;>log echo -f b=c' 'gh api a'

# --- not writes, or not in command position ---
# Read-only gh api calls and --help asked the user for approval in two windows.
expect none Bash 'gh release create --help'
expect none Bash 'gh issue create -h'
expect none Bash 'gh api -X GET search/issues -f q=foo'
expect none Bash 'gh api --method=GET repos/o/r/pulls/1/comments'
expect none Bash 'gh api repos/o/r/issues/4 --jq .title'
expect none Bash 'cd repo && gh api repos/o/r/pulls/1/comments --paginate'
expect none Bash 'gh api -X POST repos/o/r/actions/workflows/ci.yml/dispatches -f ref=main'
expect none Bash "gh api repos/o/r/pulls --jq '.[] | .title' 2>&1 | head -5"
expect none Bash "gh api graphql -f query='query{repository(owner:\"o\",name:\"r\"){issues(first:1){nodes{title}}}}'"
expect none Bash "gh api graphql -f query='query(\$n:Int!){viewer{repositories(first:\$n){nodes{name}}}}' -F n=5"
expect none Bash "gh api repos/o/r/pulls/1/comments --jq '.[] | select(.user.login==\"x\") | .body'"
expect none Bash "gh api /graphql -f query='query{viewer{login}}'"
# Only the endpoint and field values decide; other words are left alone.
expect none Bash 'gh api -X POST repos/o/r/git/refs -f ref=refs/heads/x -f sha=$SHA'
expect none Bash 'gh api -X POST repos/o/r/actions/workflows/ci.yml/dispatches -f ref=$BRANCH'
expect none Bash $'gh api repos/o/r/pulls --jq \'.[] | "`\\(.title)`"\''
expect none Bash 'gh api repos/o/r/contents/src/graphql'
expect none Bash 'gh api repos/o/r/pulls||(echo fail)'
expect none Bash 'gh api repos/o/r/pulls;>log echo -f body=x'
# A variable inside a path is not a hidden flag: seven loops of reads like
# these were held in one window when it was treated as one.
expect none Bash 'gh api repos/$repo/commits/v4 --jq .sha'
expect none Bash 'for r in a b; do sha=$(gh api repos/$r/releases/tags/v1 --jq .id); done'
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
  expect write "$tool"
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
