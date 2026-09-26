#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT/bin/backupRepos.sh"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE_REL=Documents/Archive/Code/git
commit() { git -C "$1" -c user.name=t -c user.email=t@t commit --quiet --allow-empty -m "$2"; }

# A source repo, and a fake HOME holding a mirror of it plus one whose
# remote no longer exists.
make_home() {
  local home=$1
  mkdir -p "$home/$ARCHIVE_REL"
  git clone --quiet --mirror "$TMP_DIR/source" "$home/$ARCHIVE_REL/good.git"
  git init --quiet --bare "$home/$ARCHIVE_REL/broken.git"
  git -C "$home/$ARCHIVE_REL/broken.git" remote add --mirror=fetch origin "$TMP_DIR/missing.git"
}

git init --quiet --initial-branch=main "$TMP_DIR/source"
commit "$TMP_DIR/source" first

PASS=0
FAIL=0
check() {
  local name=$1; shift
  if "$@"; then
    PASS=$((PASS + 1))
  else
    printf 'FAIL %s\n' "$name"
    sed 's/^/     | /' "$TMP_DIR/out"
    FAIL=$((FAIL + 1))
  fi
}

# run <home> — runs the script, leaving output in $TMP_DIR/out and status in $STATUS
run() {
  STATUS=0
  # Run through the shebang: updates calls it directly, under macOS /bin/bash 3.2.
  HOME=$1 "$SCRIPT" > "$TMP_DIR/out" 2>&1 || STATUS=$?
}

mirror_has_latest() {
  [[ $(git -C "$1/$ARCHIVE_REL/good.git" rev-parse main) == $(git -C "$TMP_DIR/source" rev-parse main) ]]
}

# All mirrors reachable: success, and the mirror is brought up to date.
make_home "$TMP_DIR/ok"
rm -rf "$TMP_DIR/ok/$ARCHIVE_REL/broken.git"
commit "$TMP_DIR/source" second
run "$TMP_DIR/ok"
check "all reachable exits 0"                  test "$STATUS" -eq 0
check "all reachable updates the mirror"       mirror_has_latest "$TMP_DIR/ok"

# One dead remote: non-zero, names it, and still updates the others.
make_home "$TMP_DIR/mixed"
commit "$TMP_DIR/source" third
run "$TMP_DIR/mixed"
check "dead remote exits non-zero"             test "$STATUS" -ne 0
check "dead remote is named in the output"     grep -q 'broken.git' "$TMP_DIR/out"
check "dead remote does not claim completion"  bash -c "! grep -q 'Complete' '$TMP_DIR/out'"
check "other mirrors still update"             mirror_has_latest "$TMP_DIR/mixed"

# A fetch that reads stdin (ssh, credential helpers) must not swallow the
# list of mirrors still to update.
mkdir -p "$TMP_DIR/stdin/$ARCHIVE_REL/a.git" "$TMP_DIR/stdin/$ARCHIVE_REL/b.git" "$TMP_DIR/stub"
cat > "$TMP_DIR/stub/git" <<'STUB'
#!/bin/sh
cat > /dev/null
echo "$2" >> "$UPDATED"
STUB
chmod +x "$TMP_DIR/stub/git"
: > "$TMP_DIR/updated"
STATUS=0
HOME="$TMP_DIR/stdin" PATH="$TMP_DIR/stub:$PATH" UPDATED="$TMP_DIR/updated" \
  "$SCRIPT" > "$TMP_DIR/out" 2>&1 < /dev/null || STATUS=$?
check "stdin-reading fetch updates every mirror" test "$(wc -l < "$TMP_DIR/updated")" -eq 2

# No archive directory: non-zero rather than a silent no-op.
mkdir -p "$TMP_DIR/empty"
run "$TMP_DIR/empty"
check "missing archive exits non-zero"         test "$STATUS" -ne 0

if (( FAIL > 0 )); then
  printf '%d passed, %d failed\n' "$PASS" "$FAIL"
  exit 1
fi
printf '%d backupRepos tests passed\n' "$PASS"
