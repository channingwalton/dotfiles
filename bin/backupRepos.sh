#!/bin/bash
set -e

echo "Repo backup starting at $(date)"

export DOCUMENTS=$HOME/Documents
export ARCHIVE=$DOCUMENTS/Archive/Code/git

if [[ ! -d $ARCHIVE ]]; then
  echo "Repo backup FAILED: no archive at $ARCHIVE" >&2
  exit 1
fi

# GIT mirrors created with git clone --mirror https://github.com/lancewalton/treelog.git
# Update every mirror even when one fails, then report the failures.
# The list arrives on fd 3 so a fetch that reads stdin cannot consume it.
total=0
failed=()
while IFS= read -r -d '' repo <&3; do
  total=$((total + 1))
  git -C "$repo" remote update || failed+=("$repo")
done 3< <(find "$ARCHIVE" -name "*.git" -type d -print0)

if (( ${#failed[@]} > 0 )); then
  echo "Repo backup FAILED for ${#failed[@]} of $total repos at $(date):" >&2
  printf '  %s\n' "${failed[@]}" >&2
  exit 1
fi

echo "Repo backup Complete at $(date): $total repos updated"
