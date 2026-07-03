# Supacode CLI

Control Supacode from the terminal. Use when running Supacode CLI commands, managing worktrees, tabs, and surfaces programmatically, or when inside a Supacode terminal session.

## CRITICAL: ID Tracking

**NEVER call `supacode tab new` or `supacode surface split` without capturing
the output.** They print the new UUID to stdout. Without it you cannot target
the resource afterward.

**NEVER omit `-t`/`-s` when targeting a created resource.** The env vars point
to your own shell, not to anything you created.

For new tabs, surface ID = tab ID.

### Correct:

```sh
TAB_ID=$(supacode tab new -i "npm start")
SPLIT_ID=$(supacode surface split -t "$TAB_ID" -s "$TAB_ID" -d v -i "npm test")
supacode surface close -t "$TAB_ID" -s "$SPLIT_ID"
supacode tab close -t "$TAB_ID"
```

### WRONG:

```sh
supacode tab new -i "npm start"           # BAD: not captured
supacode surface split -d v -i "test"     # BAD: missing -t/-s, targets your shell
```

Flags: `-w` (worktree), `-t` (tab), `-s` (surface), `-r` (repo), `-c` (script UUID for `worktree run`/`stop`), `-i` (input), `-d` (direction), `-n` (new ID).
Env var defaults only target your own shell session. Pass explicit IDs for created resources.