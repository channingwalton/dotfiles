#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"

cat > "$TMP_DIR/bin/gh" <<'FAKE_GH'
#!/usr/bin/env bash
set -euo pipefail

case "$1 $2" in
  "search prs")
    case "${GH_TEST_SCENARIO:-states}" in
      states)
        printf '%s\n' '[
          {"number":1,"repository":{"nameWithOwner":"acme/widgets"},"title":"Broken build","url":"https://github.com/acme/widgets/pull/1"},
          {"number":2,"repository":{"nameWithOwner":"acme/widgets"},"title":"Building","url":"https://github.com/acme/widgets/pull/2"},
          {"number":3,"repository":{"nameWithOwner":"acme/widgets"},"title":"Ready","url":"https://github.com/acme/widgets/pull/3"},
          {"number":4,"repository":{"nameWithOwner":"acme/widgets"},"title":"No workflow","url":"https://github.com/acme/widgets/pull/4"},
          {"number":5,"repository":{"nameWithOwner":"acme/widgets"},"title":"Cancelled","url":"https://github.com/acme/widgets/pull/5"},
          {"number":6,"repository":{"nameWithOwner":"acme/widgets"},"title":"Legacy failure","url":"https://github.com/acme/widgets/pull/6"}
        ]'
        ;;
      empty)
        printf '%s\n' '[]'
        ;;
      error)
        printf '%s\n' '[{"number":1,"repository":{"nameWithOwner":"acme/widgets"},"title":"Unknown","url":"https://github.com/acme/widgets/pull/1"}]'
        ;;
    esac
    ;;
  "pr view")
    if [[ ${GH_TEST_SCENARIO:-states} == error ]]; then
      printf '%s\n' 'API unavailable' >&2
      exit 1
    fi

    case "$3" in
      */1)
        printf '%s\n' '{"statusCheckRollup":[{"__typename":"CheckRun","conclusion":"FAILURE","name":"unit","status":"COMPLETED"}]}'
        ;;
      */2)
        printf '%s\n' '{"statusCheckRollup":[{"__typename":"CheckRun","conclusion":"","name":"lint","status":"IN_PROGRESS"}]}'
        ;;
      */3)
        printf '%s\n' '{"statusCheckRollup":[{"__typename":"StatusContext","context":"continuous-integration","state":"SUCCESS"}]}'
        ;;
      */4)
        printf '%s\n' '{"statusCheckRollup":[]}'
        ;;
      */5)
        printf '%s\n' '{"statusCheckRollup":[{"__typename":"CheckRun","conclusion":"CANCELLED","name":"deploy","status":"COMPLETED"}]}'
        ;;
      */6)
        printf '%s\n' '{"statusCheckRollup":[{"__typename":"StatusContext","context":"buildkite","state":"FAILURE"}]}'
        ;;
    esac
    ;;
  *)
    printf 'Unexpected gh arguments: %s\n' "$*" >&2
    exit 2
    ;;
esac
FAKE_GH
chmod +x "$TMP_DIR/bin/gh"

actual=$(PATH="$TMP_DIR/bin:$PATH" NO_COLOR=1 "$ROOT/bin/gh-pr-builds")
expected='FAIL       acme/widgets#1  Broken build (1 check)
           unit
PENDING    acme/widgets#2  Building (1 check)
           lint
PASS       acme/widgets#3  Ready (1 check)
NONE       acme/widgets#4  No workflow
CANCELLED  acme/widgets#5  Cancelled (1 check)
           deploy
FAIL       acme/widgets#6  Legacy failure (1 check)
           buildkite'

if [[ $actual != "$expected" ]]; then
  diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$actual")
  exit 1
fi

actual=$(PATH="$TMP_DIR/bin:$PATH" NO_COLOR=1 GH_TEST_SCENARIO=empty "$ROOT/bin/gh-pr-builds")
[[ $actual == 'No open pull requests.' ]]

if PATH="$TMP_DIR/bin:$PATH" NO_COLOR=1 GH_TEST_SCENARIO=error "$ROOT/bin/gh-pr-builds" >"$TMP_DIR/stdout" 2>"$TMP_DIR/stderr"; then
  printf '%s\n' 'Expected check lookup failure.' >&2
  exit 1
fi

grep -Fq 'Could not read checks for acme/widgets#1.' "$TMP_DIR/stderr"

printf '%s\n' 'gh-pr-builds tests passed'
