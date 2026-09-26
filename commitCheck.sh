#!/usr/bin/env bash
# Commit check for this repo, run by `devtool check`: every test/*.test.sh.
# Runs them all, then fails if any failed.
set -uo pipefail
cd "$(dirname "$0")" || exit

failed=()
for t in test/*.test.sh; do
  echo "== $t"
  bash "$t" || failed+=("$t")
done

if (( ${#failed[@]} > 0 )); then
  printf 'Failed: %s\n' "${failed[@]}" >&2
  exit 1
fi
