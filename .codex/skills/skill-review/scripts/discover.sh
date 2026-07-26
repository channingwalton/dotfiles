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
# - ~/.claude/skills             : local authored skills
# - ~/.claude/commands           : authored skills exposed as slash commands
# - ~/dev/personal/skills/skills : the published dev repo (canonical source for
#                                  published skills; the installed copies under
#                                  ~/.agents/skills are NOT the source)
# Output: one tab-separated line per skill: "<base>\t<SKILL.md path>".
#
# A missing base is reported on stderr, never skipped silently: the dev-repo path
# moved once and the silent `continue` dropped five skills from an entire audit
# without leaving a trace.
set -euo pipefail

for base in "$HOME/.claude/skills" "$HOME/.claude/commands" "$HOME/dev/personal/skills/skills"; do
  if [ ! -d "$base" ]; then
    printf 'discover.sh: WARNING: source not found, its skills are MISSING from this audit: %s\n' "$base" >&2
    continue
  fi
  # `-type d ! -type l` excludes symlinks (a symlink is type l, never type d),
  # which keeps the scan on authored source and off install targets.
  find "$base" -mindepth 1 -maxdepth 1 -type d ! -type l 2>/dev/null | sort | while read -r d; do
    f="$d/SKILL.md"
    [ -f "$f" ] && printf '%s\t%s\n' "$base" "$f"
  done
done
