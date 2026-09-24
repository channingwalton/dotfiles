#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEVTOOL=${DEVTOOL_UNDER_TEST:-"$ROOT/bin/devtool"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/bin" "$TMP_DIR/project"

cat > "$TMP_DIR/bin/mise" <<'RUNNER'
#!/usr/bin/env bash
set -euo pipefail
case "$*" in
  'tasks info commit-check'|'--show commit-check') [[ $PRIMARY_EXISTS == 1 ]] ;;
  '--show check') [[ $FALLBACK_EXISTS == 1 ]] ;;
  'run commit-check'|'commit-check')
    echo commit-check >> "$CALLS"
    [[ $PRIMARY_EXISTS == 1 ]] || exit 1
    exit "$PRIMARY_STATUS"
    ;;
  'run check'|'check')
    echo check >> "$CALLS"
    [[ $FALLBACK_EXISTS == 1 ]] || exit 1
    exit "$FALLBACK_STATUS"
    ;;
  *) printf 'Unexpected arguments: %s\n' "$*" >&2; exit 99 ;;
esac
RUNNER
chmod +x "$TMP_DIR/bin/mise"
ln -s mise "$TMP_DIR/bin/just"

failures=0
cases=0
run_case() {
  local runner=$1 name=$2 expected_status=$7 expected_calls=$8 status=0
  export PRIMARY_EXISTS=$3 FALLBACK_EXISTS=$4 PRIMARY_STATUS=$5 FALLBACK_STATUS=$6
  export CALLS="$TMP_DIR/calls"
  : > "$CALLS"
  rm -f "$TMP_DIR/project/mise.toml" "$TMP_DIR/project/justfile"
  if [[ $runner == mise ]]; then
    touch "$TMP_DIR/project/mise.toml"
  else
    touch "$TMP_DIR/project/justfile"
  fi
  (
    cd "$TMP_DIR/project"
    PATH="$TMP_DIR/bin:$PATH" TMPDIR="$TMP_DIR" DEVTOOL_VERBOSE=0 bash "$DEVTOOL" check
  ) > "$TMP_DIR/output" 2>&1 || status=$?
  cases=$((cases + 1))
  if [[ $status != "$expected_status" || $(cat "$CALLS") != "$expected_calls" ]]; then
    printf 'FAIL: %s %s (exit %s, expected %s)\n' "$runner" "$name" "$status" "$expected_status"
    cat "$CALLS" "$TMP_DIR/output"
    failures=$((failures + 1))
  fi
}

for runner in mise just; do
  run_case "$runner" prefers-commit-check 1 1 0 0 0 commit-check
  run_case "$runner" falls-back-to-check 0 1 0 0 0 check
  run_case "$runner" primary-failure-is-preserved 1 1 7 0 7 commit-check
  run_case "$runner" fallback-failure-is-preserved 0 1 0 8 8 check
done
run_case mise no-task-fails 0 0 0 0 1 check
run_case just no-recipe-fails 0 0 0 0 1 ''

if (( failures > 0 )); then
  printf '%s/%s devtool check tests failed\n' "$failures" "$cases"
  exit 1
fi
printf '%s devtool check tests passed\n' "$cases"
