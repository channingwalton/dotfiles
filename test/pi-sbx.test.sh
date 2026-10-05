#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT/bin/pi-sbx"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

HOST="$TMP_DIR/host"       # HOME on the host
SANDBOX="$TMP_DIR/sandbox" # the sandbox's /home/agent
mkdir -p "$HOST" "$SANDBOX" "$TMP_DIR/project" "$TMP_DIR/stub"

# Fake sbx: exec runs the command here, with the sandbox's /home/agent at
# $SANDBOX; run is logged instead of starting pi.
cat > "$TMP_DIR/stub/sbx" <<'STUB'
#!/usr/bin/env bash
case $1 in
exec)
  shift
  while [[ $1 == -* ]]; do
    [[ $1 == -w ]] && shift
    shift
  done
  shift # sandbox name
  cd "$SANDBOX" && exec "${@//\/home\/agent/$SANDBOX}"
  ;;
run) echo "$*" >> "$RUNS" ;;
esac
STUB
# macOS tar lacks GNU tar's --warning, which the sandbox's tar takes.
cat > "$TMP_DIR/stub/tar" <<'STUB'
#!/usr/bin/env bash
args=()
for a in "$@"; do [[ $a == --warning=* ]] || args+=("$a"); done
exec /usr/bin/tar "${args[@]}"
STUB
chmod +x "$TMP_DIR/stub/sbx" "$TMP_DIR/stub/tar"

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

# run — runs the script, leaving output in $TMP_DIR/out and status in $STATUS
run() {
  STATUS=0
  : > "$TMP_DIR/runs"
  HOME="$HOST" PATH="$TMP_DIR/stub:$PATH" SANDBOX="$SANDBOX" RUNS="$TMP_DIR/runs" \
    "$SCRIPT" "$TMP_DIR/project" > "$TMP_DIR/out" 2>&1 || STATUS=$?
}

put() { mkdir -p "$(dirname "$1")" && printf '%s\n' "$2" > "$1"; }
has() { [[ $(cat "$SANDBOX/$1") == "$2" ]]; }
missing() { [[ ! -e "$SANDBOX/$1" ]]; }

# A first run with no host configuration must still start pi.
run
check "no-config first run exits 0"             test "$STATUS" -eq 0
check "no-config first run starts pi"           test -s "$TMP_DIR/runs"

put "$HOST/.pi/agent/settings.json" v1
put "$HOST/.pi/agent/auth.json" host-login
put "$HOST/.pi/agent/git/github.com/example/pkg/index.ts" host-source
put "$HOST/.pi/agent/npm/package.json" host-manifest
put "$HOST/.agents/skills/kept/SKILL.md" kept
put "$HOST/.agents/skills/old/SKILL.md" old
put "$HOST/.agents/skills/old/references/notes.md" old

# First run, into an empty sandbox home.
run
check "first run exits 0"                       test "$STATUS" -eq 0
check "first run copies config"                 has .pi/agent/settings.json v1
check "first run skips credentials"             missing .pi/agent/auth.json
check "first run skips host Git installations"  missing .pi/agent/git
check "first run skips host npm installations"  missing .pi/agent/npm
check "first run starts pi"                     test -s "$TMP_DIR/runs"

# State the sandbox makes for itself.
put "$SANDBOX/.pi/agent/auth.json" sandbox-login
put "$SANDBOX/.pi/agent/sessions/s1.jsonl" session
put "$SANDBOX/.pi/agent/mcp-oauth/server.json" oauth
put "$SANDBOX/.pi/agent/npm/node_modules/pkg/index.js" pkg
put "$SANDBOX/.pi/agent/npm/package.json" sandbox-npm-manifest
put "$SANDBOX/.pi/agent/npm/package-lock.json" sandbox-npm-lockfile
put "$SANDBOX/.pi/agent/git/github.com/example/pkg/index.ts" sandbox-source
put "$SANDBOX/.pi/agent/git/github.com/example/pkg/package.json" sandbox-manifest
put "$SANDBOX/.pi/agent/git/github.com/example/pkg/node_modules/dep/index.js" dep
# Packed refs leave empty metadata directories that Git still requires.
GIT_PACKAGE="$SANDBOX/.pi/agent/git/github.com/example/pkg"
git -C "$GIT_PACKAGE" init -q
git -C "$GIT_PACKAGE" -c user.name=Test -c user.email=test@example.invalid \
  -c core.hooksPath=/dev/null -c commit.gpgsign=false commit --allow-empty -qm fixture
git -C "$GIT_PACKAGE" pack-refs --all --prune
GIT_HEAD=$(cat "$GIT_PACKAGE/.git/HEAD")
git_package_usable() { git -C "$GIT_PACKAGE" rev-parse --verify HEAD >/dev/null 2>&1; }

# Change the host config and run again.
put "$HOST/.pi/agent/settings.json" v2
rm -rf "$HOST/.agents/skills/old"
run
check "second run exits 0"                      test "$STATUS" -eq 0
check "changed file is updated"                 has .pi/agent/settings.json v2
check "unchanged file is still there"           has .agents/skills/kept/SKILL.md kept
check "file deleted on host is deleted"         missing .agents/skills/old/SKILL.md
check "directory deleted on host is deleted"    missing .agents/skills/old
check "sandbox login is kept"                   has .pi/agent/auth.json sandbox-login
check "sandbox sessions are kept"               has .pi/agent/sessions/s1.jsonl session
check "sandbox MCP OAuth state is kept"         has .pi/agent/mcp-oauth/server.json oauth
check "sandbox node_modules are kept"           has .pi/agent/npm/node_modules/pkg/index.js pkg
check "sandbox npm manifest is kept"            has .pi/agent/npm/package.json sandbox-npm-manifest
check "sandbox npm lockfile is kept"            has .pi/agent/npm/package-lock.json sandbox-npm-lockfile
check "sandbox Git source is kept"              has .pi/agent/git/github.com/example/pkg/index.ts sandbox-source
check "sandbox Git manifest is kept"            has .pi/agent/git/github.com/example/pkg/package.json sandbox-manifest
check "sandbox Git metadata is kept"            has .pi/agent/git/github.com/example/pkg/.git/HEAD "$GIT_HEAD"
check "sandbox Git dependencies are kept"       has .pi/agent/git/github.com/example/pkg/node_modules/dep/index.js dep
check "sandbox Git repository is usable"        git_package_usable

# Removal failures must abort the refresh before pi starts.
put "$SANDBOX/.agents/skills/blocked/SKILL.md" blocked
chmod a-w "$SANDBOX/.agents/skills/blocked"
run
chmod u+w "$SANDBOX/.agents/skills/blocked"
check "cleanup failure exits nonzero"           test "$STATUS" -ne 0
check "cleanup failure does not start pi"       test ! -s "$TMP_DIR/runs"
rm -rf "$SANDBOX/.agents/skills/blocked"

# No source roots still means refreshing the previous config away.
rm -rf "$HOST/.pi" "$HOST/.agents"
run
check "removed host roots exits 0"              test "$STATUS" -eq 0
check "removed host roots still starts pi"      test -s "$TMP_DIR/runs"
check "removed host settings disappear"         missing .pi/agent/settings.json
check "removed host skills disappear"           missing .agents
check "no host roots preserves login"           has .pi/agent/auth.json sandbox-login
check "no host roots preserves sessions"        has .pi/agent/sessions/s1.jsonl session
check "no host roots preserves OAuth state"     has .pi/agent/mcp-oauth/server.json oauth
check "no host roots preserves npm packages"    has .pi/agent/npm/node_modules/pkg/index.js pkg
check "no host roots preserves npm manifest"    has .pi/agent/npm/package.json sandbox-npm-manifest
check "no host roots preserves npm lockfile"    has .pi/agent/npm/package-lock.json sandbox-npm-lockfile
check "no host roots preserves Git packages"    has .pi/agent/git/github.com/example/pkg/index.ts sandbox-source
check "no host roots preserves Git repository"  git_package_usable

# With no sandbox state to preserve, even the old config roots disappear.
rm -rf "$SANDBOX/.pi" "$SANDBOX/.agents"
put "$SANDBOX/.pi/agent/settings.json" stale
put "$SANDBOX/.agents/skills/stale/SKILL.md" stale
run
check "config-only cleanup exits 0"             test "$STATUS" -eq 0
check "config-only cleanup starts pi"           test -s "$TMP_DIR/runs"
check "config-only cleanup removes pi root"     missing .pi
check "config-only cleanup removes agents root" missing .agents

printf 'pi-sbx: %d passed, %d failed\n' "$PASS" "$FAIL"
((FAIL == 0))
