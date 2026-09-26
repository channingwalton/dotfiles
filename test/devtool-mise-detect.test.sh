#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEVTOOL=${DEVTOOL_UNDER_TEST:-"$ROOT/bin/devtool"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
CALLS=$TMP_DIR/calls

# Stubs: mise records the task it is asked to run; npm records the script;
# commitCheck.sh records that it ran.
mkdir -p "$TMP_DIR/with-mise" "$TMP_DIR/without-mise"
cat > "$TMP_DIR/with-mise/mise" <<'STUB'
#!/bin/sh
[ "$1" = run ] && echo "mise $2" >> "$CALLS"
exit 0
STUB
cat > "$TMP_DIR/without-mise/npm" <<'STUB'
#!/bin/sh
echo "npm $2" >> "$CALLS"
STUB
cp "$TMP_DIR/without-mise/npm" "$TMP_DIR/with-mise/npm"
chmod +x "$TMP_DIR"/with-mise/* "$TMP_DIR"/without-mise/*

commit_check() {
  printf '#!/bin/sh\necho commitCheck >> "$CALLS"\n' > "$1/commitCheck.sh"
  chmod +x "$1/commitCheck.sh"
}

# The dotfiles layout: ~/.config is a symlink into the dotfiles repo, so the
# global mise config is also reachable as <repo>/.config/mise/config.toml.
HOME_DIR=$TMP_DIR/home
DOTFILES=$TMP_DIR/dotfiles
mkdir -p "$HOME_DIR" "$DOTFILES/.config/mise"
touch "$DOTFILES/.config/mise/config.toml"
ln -s "$DOTFILES/.config" "$HOME_DIR/.config"
commit_check "$DOTFILES"
commit_check "$HOME_DIR"

# A project whose .config/mise/config.toml is its own, not the global one.
PROJECT=$TMP_DIR/project
mkdir -p "$PROJECT/.config/mise"
touch "$PROJECT/.config/mise/config.toml"

# A plain node project.
NODE=$TMP_DIR/node
mkdir -p "$NODE"
echo '{"scripts":{"build":"x"}}' > "$NODE/package.json"

failures=0
cases=0
# run_case <name> <dir> <command> <path-dir> <xdg-config-home> <expected-status> <expected-calls>
run_case() {
  local name=$1 dir=$2 cmd=$3 path_dir=$4 xdg=$5 expected_status=$6 expected_calls=$7
  local status=0 calls
  : > "$CALLS"
  (
    cd "$dir"
    env -u MISE_GLOBAL_CONFIG_FILE -u MISE_CONFIG_DIR \
      HOME="$HOME_DIR" XDG_CONFIG_HOME="$xdg" PATH="$path_dir:/usr/bin:/bin" \
      CALLS="$CALLS" TMPDIR="$TMP_DIR" DEVTOOL_VERBOSE=0 bash "$DEVTOOL" "$cmd"
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

WITH=$TMP_DIR/with-mise
WITHOUT=$TMP_DIR/without-mise

run_case no-mise-on-path-still-detects      "$NODE"     compile "$WITHOUT" ""                   0 "npm build"
run_case global-config-via-symlink-ignored  "$DOTFILES" check   "$WITH"    "$HOME_DIR/.config"  0 commitCheck
run_case global-config-in-home-ignored      "$HOME_DIR" check   "$WITH"    ""                   0 commitCheck
run_case project-local-config-still-counts  "$PROJECT"  check   "$WITH"    "$HOME_DIR/.config"  0 "mise commit-check"

if (( failures > 0 )); then
  printf '%s/%s devtool mise detection tests failed\n' "$failures" "$cases"
  exit 1
fi
printf '%s devtool mise detection tests passed\n' "$cases"
