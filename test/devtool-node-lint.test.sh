#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEVTOOL=${DEVTOOL_UNDER_TEST:-"$ROOT/bin/devtool"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/bin" "$TMP_DIR/project"

# Stub npm: records which script ran and exits with the configured status.
cat > "$TMP_DIR/bin/npm" <<'RUNNER'
#!/usr/bin/env bash
case "$*" in
  'run build') echo build >> "$CALLS"; exit 0 ;;
  'run lint')  echo lint  >> "$CALLS"; exit "$LINT_STATUS" ;;
  'test')      echo test  >> "$CALLS"; exit 0 ;;
  *) printf 'Unexpected arguments: %s\n' "$*" >&2; exit 99 ;;
esac
RUNNER
chmod +x "$TMP_DIR/bin/npm"

# devtool exits early when mise is not on PATH, so the no-node case needs
# one; the fixture has no mise config, so it is never run.
printf '#!/bin/sh\nexit 99\n' > "$TMP_DIR/bin/mise"
chmod +x "$TMP_DIR/bin/mise"

failures=0
cases=0
# run_case <name> <command> <package.json scripts> <lint-status> <expected-status> <expected-calls> [path]
run_case() {
  local name=$1 cmd=$2 scripts=$3 expected_status=$5 expected_calls=$6 status=0 calls
  local path=${7:-"$TMP_DIR/bin:$PATH"}
  export LINT_STATUS=$4 CALLS="$TMP_DIR/calls"
  : > "$CALLS"
  printf '{"name":"fixture","scripts":%s}\n' "$scripts" > "$TMP_DIR/project/package.json"
  (
    cd "$TMP_DIR/project"
    PATH="$path" TMPDIR="$TMP_DIR" DEVTOOL_VERBOSE=0 bash "$DEVTOOL" "$cmd"
  ) > "$TMP_DIR/output" 2>&1 || status=$?
  calls=$(paste -sd, "$CALLS")
  cases=$((cases + 1))
  if [[ $status != "$expected_status" || $calls != "$expected_calls" ]]; then
    printf 'FAIL: %s (exit %s, expected %s; calls [%s], expected [%s])\n' \
      "$name" "$status" "$expected_status" "$calls" "$expected_calls"
    sed 's/^/  | /' "$TMP_DIR/output"
    failures=$((failures + 1))
  fi
}

WITH_LINT='{"build":"x","lint":"x","test":"x"}'
WITHOUT_LINT='{"build":"x","test":"x"}'

run_case lint-failure-fails-lint        lint  "$WITH_LINT"    3 3 lint
run_case lint-success-passes-lint       lint  "$WITH_LINT"    0 0 lint
run_case missing-lint-script-is-skipped lint  "$WITHOUT_LINT" 0 0 ''
run_case lint-failure-fails-check       check "$WITH_LINT"    3 3 build,lint
run_case clean-check-runs-all-steps     check "$WITH_LINT"    0 0 build,lint,test
run_case check-without-lint-script      check "$WITHOUT_LINT" 0 0 build,test
# Only a readable package.json without a lint script skips lint.
run_case lint-runs-when-package-unreadable lint '{"lint":' 3 3 lint
# A standalone package manager can run scripts with no node on PATH.
run_case lint-runs-when-node-is-absent  lint  "$WITH_LINT"    3 3 lint "$TMP_DIR/bin:/usr/bin:/bin"

if (( failures > 0 )); then
  printf '%s/%s devtool node lint tests failed\n' "$failures" "$cases"
  exit 1
fi
printf '%s devtool node lint tests passed\n' "$cases"
