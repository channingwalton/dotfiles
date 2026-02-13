#!/bin/bash
set -e

echo "Unison backup starting at $(date)"

export ARCHIVE=$HOME/Documents/Archive/Code/unison
mkdir -p "$ARCHIVE"

# Track whether .unisonHistory exists before we start
original_dir="$(pwd)"
had_history=false
[ -f "$original_dir/.unisonHistory" ] && had_history=true

# Create temp directory for UCM to write scratch.u
temp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$temp_dir"
  if [ "$had_history" = false ] && [ -f "$original_dir/.unisonHistory" ]; then
    rm -f "$original_dir/.unisonHistory"
  fi
}
trap cleanup EXIT

# Discover all projects from UCM
echo "Discovering projects..."
# Strip ANSI codes and parse project names
projects=$(echo "project.list" | ucm 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -E '^\s*[0-9]+\.' | sed 's/^[[:space:]]*[0-9]*\.[[:space:]]*//')

if [ -z "$projects" ]; then
  echo "No projects found or UCM command failed"
  exit 1
fi

echo "Found $(echo "$projects" | wc -l | tr -d ' ') projects"

# Iterate through each project
while IFS= read -r project; do
  [ -z "$project" ] && continue

  # Create safe filename (replace @ and / with underscores)
  safe_name="${project//@/}"
  safe_name="${safe_name//\//_}"

  # Run UCM in temp dir so scratch.u is created there
  cd "$temp_dir"
  rm -f scratch.u
  echo "edit.namespace ." | ucm --project "$project/main" >/dev/null 2>&1 || true

  if [ -f scratch.u ]; then
    cp scratch.u "$ARCHIVE/${safe_name}.u"
    echo "  $project -> ${safe_name}.u"
  else
    echo "  $project -> (skipped: empty or no main branch)"
  fi

  cd "$OLDPWD"
done <<<"$projects"

echo "Unison backup complete at $(date)"
