#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DEVTOOL=${DEVTOOL_UNDER_TEST:-"$ROOT/bin/devtool"}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT=$TMP_DIR/project
mkdir -p "$PROJECT"
touch "$PROJECT/build.gradle.kts"

# Stub gradlew: `tasks --all --quiet` prints $TASKS_FILE; anything else is recorded.
cat > "$PROJECT/gradlew" <<'STUB'
#!/usr/bin/env bash
if [[ "$*" == "tasks --all --quiet" ]]; then
  cat "$TASKS_FILE"
else
  args=()
  for a in "$@"; do [[ $a == --quiet ]] || args+=("$a"); done
  echo "${args[*]}" >> "$CALLS"
fi
STUB
chmod +x "$PROJECT/gradlew"

# A realistic large build lists thousands of tasks. Put the task being looked
# up first, then ~200 KB more, so grep -q exits while the list is still being
# written to it.
tasks_file() {
  local file=$TMP_DIR/tasks-$1
  shift
  printf '%s\n' "$@" > "$file"
  for i in $(seq 1 4000); do
    printf 'module%s:someGeneratedTask%s - A task description that pads the listing\n' "$i" "$i"
  done >> "$file"
  echo "$file"
}

failures=0
cases=0
# run_case <name> <tasks-file> <command...> -- <expected-calls>
run_case() {
  local name=$1 tasks=$2 status=0 calls
  shift 2
  local args=()
  while [[ $1 != -- ]]; do args+=("$1"); shift; done
  local expected=$2
  export TASKS_FILE=$tasks CALLS=$TMP_DIR/calls
  : > "$CALLS"
  (
    cd "$PROJECT"
    TMPDIR="$TMP_DIR" DEVTOOL_VERBOSE=0 bash "$DEVTOOL" "${args[@]}"
  ) > "$TMP_DIR/output" 2>&1 || status=$?
  calls=$(paste -sd, "$CALLS")
  cases=$((cases + 1))
  if [[ $status != 0 || $calls != "$expected" ]]; then
    printf 'FAIL: %s (exit %s; calls [%s], expected [%s])\n' "$name" "$status" "$calls" "$expected"
    sed 's/^/  | /' "$TMP_DIR/output"
    failures=$((failures + 1))
  fi
}

ROOT_KTLINT=$(tasks_file root-ktlint "ktlintCheck - Check Kotlin code style.")
SUB_KTLINT=$(tasks_file sub-ktlint "app:ktlintCheck - Check Kotlin code style.")
NO_KTLINT=$(tasks_file no-ktlint "build - Assembles and tests this project.")
# Gradle lists tasks that have no description as the bare name
BARE_KTLINT=$(tasks_file bare-ktlint "ktlintCheck")
COMPILE=$(tasks_file compile "compileKotlin - Compiles the main Kotlin source.")
SUB_TEST=$(tasks_file sub-test "app:test - Runs the test suite.")

# Run each case several times: a race that loses only sometimes must still fail.
for attempt in 1 2 3; do
  run_case "root ktlint found in a large task list ($attempt)"  "$ROOT_KTLINT" lint -- "ktlintCheck"
  run_case "compileKotlin found in a large task list ($attempt)" "$COMPILE" compile -- "compileKotlin"
  run_case "subproject test target found ($attempt)"             "$SUB_TEST" test app -- ":app:test"
done
run_case "subproject-only ktlint is found"  "$SUB_KTLINT" lint -- "ktlintCheck"
run_case "no ktlint task skips lint"         "$NO_KTLINT"  lint -- ""
run_case "task without a description found"  "$BARE_KTLINT" lint -- "ktlintCheck"

if (( failures > 0 )); then
  printf '%s/%s devtool gradle tests failed\n' "$failures" "$cases"
  exit 1
fi
printf '%s devtool gradle tests passed\n' "$cases"
