#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEVTOOL=${DEVTOOL_UNDER_TEST:-"$ROOT/bin/devtool"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT=$TMP_DIR/project
mkdir -p "$PROJECT" "$TMP_DIR/with-jscpd" "$TMP_DIR/without-jscpd"

# The project's own check: exits with $CHECK_STATUS.
printf '#!/bin/sh\nexit "$CHECK_STATUS"\n' > "$PROJECT/commitCheck.sh"
# Stub jscpd: prints a marker and exits with $JSCPD_STATUS.
printf '#!/bin/sh\necho "STUB DUPLICATE REPORT"\nexit "$JSCPD_STATUS"\n' > "$TMP_DIR/with-jscpd/jscpd"
chmod +x "$PROJECT/commitCheck.sh" "$TMP_DIR/with-jscpd/jscpd"

failures=0
cases=0
# run_case <name> <path-dir> <check-status> <jscpd-status> <expected-exit> <output-must-match> <output-must-not-match>
run_case() {
  local name=$1 path_dir=$2 expected_status=$5 want=$6 unwanted=$7 status=0
  (
    cd "$PROJECT"
    CHECK_STATUS=$3 JSCPD_STATUS=$4 PATH="$path_dir:/usr/bin:/bin" TMPDIR="$TMP_DIR" \
      DEVTOOL_VERBOSE=0 bash "$DEVTOOL" check
  ) > "$TMP_DIR/output" 2>&1 || status=$?
  cases=$((cases + 1))
  if [[ $status != "$expected_status" ]] || ! grep -q -- "$want" "$TMP_DIR/output" ||
    { [[ -n $unwanted ]] && grep -q -- "$unwanted" "$TMP_DIR/output"; }; then
    printf 'FAIL: %s (exit %s, expected %s)\n' "$name" "$status" "$expected_status"
    sed 's/^/  | /' "$TMP_DIR/output"
    failures=$((failures + 1))
  fi
}

WITH=$TMP_DIR/with-jscpd
WITHOUT=$TMP_DIR/without-jscpd

run_case "passing check prints the duplicate report" "$WITH" 0 0 0 "STUB DUPLICATE REPORT" ""
run_case "duplicates found do not fail the check"    "$WITH" 0 1 0 "devtool check: OK" ""
run_case "missing jscpd is noted, check still passes" "$WITHOUT" 0 0 0 "jscpd not found" ""
run_case "failing check exits before the report"     "$WITH" 5 0 5 "command failed" "STUB DUPLICATE REPORT"

if (( failures > 0 )); then
  printf '%s/%s devtool cpd report tests failed\n' "$failures" "$cases"
  exit 1
fi
printf '%s devtool cpd report tests passed\n' "$cases"
