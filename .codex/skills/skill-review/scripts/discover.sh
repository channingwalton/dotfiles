#!/usr/bin/env bash
# Discover reviewable skills.
# - ~/.claude/skills: real directories only; symlinks are skipped (they point at
#   install targets for published skills, whose source lives in the dev repo).
# - ~/dev/skills/skills: the published dev repo (every subdir).
# Output: one tab-separated line per skill: "<base>\t<SKILL.md path>".
set -euo pipefail

claude_dir="$HOME/.claude/skills"
dev_dir="$HOME/dev/skills/skills"

for base in "$claude_dir" "$dev_dir"; do
  [ -d "$base" ] || continue
  # `-type d ! -type l` excludes symlinks (a symlink is type l, never type d).
  find "$base" -mindepth 1 -maxdepth 1 -type d ! -type l 2>/dev/null | sort | while read -r d; do
    f="$d/SKILL.md"
    [ -f "$f" ] && printf '%s\t%s\n' "$base" "$f"
  done
done
