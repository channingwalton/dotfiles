#!/usr/bin/env bash
# watch-worktree.sh — emit one line per *settled* change in a git worktree.
#
# Designed to be driven by the Monitor tool: each stdout line becomes one
# notification. The point of the debounce is that a developer mid-thought
# saves constantly; reacting to every save is noise and interrupts flow.
# We only speak once the edit has stopped moving.
#
# Change detection is by content hash per path, never by line counts. A file
# rewritten in place keeps the same +added/-deleted totals against the
# baseline, so counts silently miss the most common edit in a live session:
# reworking a line you already changed.
#
# No dependencies beyond git and a POSIX-ish shell.

set -uo pipefail

QUIET=5          # seconds of no change before an edit counts as settled
MIN_INTERVAL=30  # floor between notifications; coalesces bursts
POLL=1           # seconds between snapshots
BASELINE=HEAD    # what diffs are measured against
MAX_FILES=8      # files named per line before eliding

usage() {
  cat <<'USAGE'
Usage: watch-worktree.sh [options]

  --quiet-seconds N   pause length that marks an edit settled (default 5)
  --min-interval N    minimum seconds between notifications (default 30)
  --poll N            seconds between snapshots (default 1)
  --baseline REF      diff against REF instead of HEAD
  -h, --help          this message

Emits one line per settled change, e.g.
  14:32:07  src/Rota.scala +12 -3 | notes.md (new)
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --quiet-seconds) QUIET="$2"; shift 2 ;;
    --min-interval)  MIN_INTERVAL="$2"; shift 2 ;;
    --poll)          POLL="$2"; shift 2 ;;
    --baseline)      BASELINE="$2"; shift 2 ;;
    -h|--help)       usage; exit 0 ;;
    *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "not inside a git worktree" >&2; exit 1; }

# Work from the repository root so that the paths git reports are the paths we
# can stat, whichever directory the session happens to start in.
cd "$(git rev-parse --show-toplevel)" || exit 1

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
prev_snap="$TMP/prev.snap"
cur_snap="$TMP/cur.snap"
untracked_list="$TMP/untracked"

# Every path that currently differs from the baseline, with a hash of its
# contents. Tab-separated so paths containing spaces survive.
snapshot() {
  {
    git diff --name-only -z "$BASELINE" 2>/dev/null
    git ls-files --others --exclude-standard -z 2>/dev/null
  } | while IFS= read -r -d '' f; do
        if [ -f "$f" ]; then
          printf '%s\t%s\n' "$f" "$(cksum < "$f")"
        else
          printf '%s\t%s\n' "$f" "absent"
        fi
      done | sort -u
}

untracked_paths() {
  git ls-files --others --exclude-standard 2>/dev/null | sort
}

counts_for() {
  git diff --numstat "$BASELINE" -- "$1" 2>/dev/null |
    awk -F'\t' 'NR == 1 { printf "+%s -%s", $1, $2 }'
}

# Report what moved since the *last notification*, not since the baseline: the
# developer wants to know what just happened, not the whole session so far.
emit() {
  untracked_paths > "$untracked_list"

  local parts=() n=0 status path label
  while IFS=$'\t' read -r status path; do
    [ -n "${path:-}" ] || continue
    n=$((n + 1))
    [ "$n" -le "$MAX_FILES" ] || continue

    if grep -qxF "$path" "$untracked_list"; then
      case "$status" in
        A) label="(new)" ;;
        *) label="(saved)" ;;
      esac
    else
      case "$status" in
        R) label="(reverted)" ;;
        *) label="$(counts_for "$path")"
           [ -n "$label" ] || label="(deleted)" ;;
      esac
    fi
    parts+=("$path $label")
  done < <(
    awk -F'\t' -v prevfile="$prev_snap" '
      # Keyed on FILENAME rather than the usual NR == FNR: with an empty first
      # file NR == FNR is still true for the first line of the second one, so a
      # session starting on a clean tree would misfile its first change.
      FILENAME == prevfile { prev[$1] = $2; next }
                           { cur[$1] = $2
                             if (!($1 in prev))       print "A\t" $1
                             else if (prev[$1] != $2) print "M\t" $1 }
      END                  { for (p in prev) if (!(p in cur)) print "R\t" p }
    ' "$prev_snap" "$cur_snap" | sort -t"$(printf '\t')" -k2
  )

  cp "$cur_snap" "$prev_snap"

  [ "$n" -gt 0 ] || return 0

  local line i=0
  line="$(date +%H:%M:%S)  "
  for p in "${parts[@]}"; do
    [ "$i" -gt 0 ] && line+=" | "
    line+="$p"
    i=$((i + 1))
  done
  [ "$n" -gt "$MAX_FILES" ] && line+=" | +$((n - MAX_FILES)) more"
  echo "$line"
}

snapshot > "$prev_snap"
cp "$prev_snap" "$cur_snap"
last_fp="$(cksum < "$cur_snap")"
last_change=0
last_emit=0
pending=0

echo "watching $(pwd) from $(git rev-parse --short "$BASELINE") (settle ${QUIET}s, min gap ${MIN_INTERVAL}s)"

while true; do
  sleep "$POLL"
  snapshot > "$cur_snap"
  fp="$(cksum < "$cur_snap")"
  now="$(date +%s)"

  if [ "$fp" != "$last_fp" ]; then
    last_fp="$fp"
    last_change="$now"
    pending=1
    continue
  fi

  [ "$pending" -eq 1 ] || continue
  [ $((now - last_change)) -ge "$QUIET" ] || continue
  [ $((now - last_emit)) -ge "$MIN_INTERVAL" ] || continue

  emit
  last_emit="$now"
  pending=0
done
