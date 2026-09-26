#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HOOK="$ROOT/git-hooks/pre-commit"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# The hook runs from the repo root and calls bin/dotfiles-audit relative to it.
REPO=$TMP_DIR/repo
mkdir -p "$REPO/bin" "$TMP_DIR/with-gitleaks" "$TMP_DIR/without-gitleaks"
CALLS=$TMP_DIR/calls

cat > "$REPO/bin/dotfiles-audit" <<'STUB'
#!/usr/bin/env bash
echo audit >> "$CALLS"
exit "$AUDIT_STATUS"
STUB

cat > "$TMP_DIR/with-gitleaks/gitleaks" <<'STUB'
#!/usr/bin/env bash
echo gitleaks >> "$CALLS"
exit "$GITLEAKS_STATUS"
STUB

chmod +x "$REPO/bin/dotfiles-audit" "$TMP_DIR/with-gitleaks/gitleaks"

PASS=0
FAIL=0

# expect <name> <gitleaks-dir> <gitleaks-status> <audit-status> <expected-exit> <expected-calls>
expect() {
  local name=$1 bin_dir=$2 gitleaks_status=$3 audit_status=$4 expected_exit=$5 expected_calls=$6
  local status=0 calls

  : > "$CALLS"
  (
    cd "$REPO"
    PATH="$bin_dir:/usr/bin:/bin" CALLS="$CALLS" \
      GITLEAKS_STATUS="$gitleaks_status" AUDIT_STATUS="$audit_status" \
      bash "$HOOK" > "$TMP_DIR/out" 2>&1
  ) || status=$?
  calls=$(paste -sd, "$CALLS")

  if [[ $status == "$expected_exit" && $calls == "$expected_calls" ]]; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL %-40s expected exit %s calls [%s], got exit %s calls [%s]\n' \
      "$name" "$expected_exit" "$expected_calls" "$status" "$calls"
    sed 's/^/     | /' "$TMP_DIR/out"
    FAIL=$((FAIL + 1))
  fi
}

WITH=$TMP_DIR/with-gitleaks
WITHOUT=$TMP_DIR/without-gitleaks

expect "clean scan and audit commit"        "$WITH"    0 0 0 "gitleaks,audit"
expect "leak found blocks before audit"     "$WITH"    1 0 1 "gitleaks"
expect "audit failure blocks commit"        "$WITH"    0 1 1 "gitleaks,audit"
expect "missing gitleaks blocks commit"     "$WITHOUT" 0 0 1 ""

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d pre-commit tests passed\n' "$PASS"
