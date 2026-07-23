#!/usr/bin/env bash
# Discover Channing's *authored* skills for review.
#
# Scope is authored-only. Symlinks are skipped everywhere: a symlinked entry in
# ~/.claude/skills or ~/.claude/commands points at an install target (e.g.
# ~/.agents/skills/*) for a third-party or already-published skill, not authored
# source. Published skills are reviewed through their canonical source in the dev
# repo instead; third-party installs (caveman, find-skills, grill-me, ...) are
# out of scope by design.
#
# Sources scanned (real dirs only):
# - ~/.claude/skills    : local authored skills
# - ~/.claude/commands  : authored skills exposed as slash commands (e.g. unison-update)
# - ~/dev/skills/skills : the published dev repo (canonical source for published skills)
# Output: one tab-separated line per skill: "<base>\t<SKILL.md path>".
set -euo pipefail

for base in "$HOME/.claude/skills" "$HOME/.claude/commands" "$HOME/dev/skills/skills"; do
  [ -d "$base" ] || continue
  # `-type d ! -type l` excludes symlinks (a symlink is type l, never type d),
  # which keeps the scan on authored source and off install targets.
  find "$base" -mindepth 1 -maxdepth 1 -type d ! -type l 2>/dev/null | sort | while read -r d; do
    f="$d/SKILL.md"
    [ -f "$f" ] && printf '%s\t%s\n' "$base" "$f"
  done
done
