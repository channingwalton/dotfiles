---
name: fabric
description: Use when the user asks you to start, join, or continue a conversation with another agent via fabric-fs / agent-chat — any mention of fabric-fs, agent-chat, threads under ~/dev/agent-chat/, or "talk to <agent> about X".
---

# fabric-fs-converse

Filesystem-based multi-agent chat. You exchange messages with other agents by writing JSON files into a shared thread directory. No network.

Core behaviour: **loop** — read new messages → reply if useful → wait → repeat → exit when resolved or silent.

## Paths

- Thread: `~/dev/agent-chat/threads/{slug}/`
  - `meta.json` — thread metadata
  - `messages/` — one JSON file per message
- Cursor: `~/.fabric-fs/cursors/{agent-id}/{slug}`

## Agent identity

Pick a stable `agent-id` for this conversation, in order:

1. User-specified (e.g. "join as `codex-reviewer`").
2. `{host}-{short6}` where `host` is the tool (`claude-code`, `codex`, `opencode`) and `short6` is the first 6 hex chars of a per-session uuid, e.g. `claude-code-a3f91c`. Prevents collisions when two sessions of the same host join one thread.
3. Ask the user if genuinely unknown.

## Start vs join

| Action | Steps |
|---|---|
| **Start** | slug = `{yyyyMMddHHmmss}-{kebab-topic}` (e.g. `20260421143022-fabric-skill-chat`) → `mkdir -p threads/{slug}/messages` → write `meta.json` if missing → post opening message → loop |
| **Join** | Verify dir exists (ask user if not, don't auto-create) → read `meta.json` → read all messages to catch up → loop |

`meta.json`:

```json
{"schema_version":1,"slug":"{slug}","title":"{title}","participants":["{you}","{other}"],"created_at":{unix_ms},"created_by":"{you}"}
```

## Posting a message

Filename: `{unix_ms}-{agent-id}-{uuid}.json` where `unix_ms` is 13-digit zero-padded and `uuid` is 6 hex chars.

Payload:

```json
{"id":"{filename without .json}","thread":"{slug}","from":"{you}","reply_to":"{id or null}","created_at":{unix_ms},"content":"{message}"}
```

**Always write to `.{filename}.tmp` first, then `mv` to final.** Never write the final path directly — other agents must never see a partial file. Use heredoc or `python3 -c` for the write to avoid quoting issues; validate JSON before rename.

## Reading new messages

```sh
CURSOR=$(cat ~/.fabric-fs/cursors/{agent-id}/{slug} 2>/dev/null || echo "")
ls ~/dev/agent-chat/threads/{slug}/messages/ | grep -v '^\.' | sort
```

Keep filenames lex-greater than `$CURSOR` (13-digit ms prefix = lex-sort == time-sort). Drop messages where `from == your agent-id`. After processing, write the last filename seen (including your own) to the cursor.

If a non-dotfile fails to parse as JSON, it's a protocol violation (someone skipped tmp-then-rename). Log it, skip the file, and continue — don't retry, don't add a grace period. Silent retries mask real bugs.

## Waiting

Check OS with `uname`, then:

- Linux: `inotifywait -q -e create -t 60 .../messages/`
- macOS: `timeout 60 fswatch -1 -l 0.5 --event Created .../messages/`
- Neither installed: poll `ls` every few seconds up to 30s; tell user once that installing `inotify-tools` / `fswatch` helps.

Exit 0 = file appeared; non-zero = timeout. **Always re-run the read protocol after wake-up** — watcher may have fired on a `.tmp` or your own write.

## The loop

```
timeout_count = 0
iterations = 0
MAX_ITERATIONS = 20

while iterations < MAX_ITERATIONS:
    iterations += 1
    new = read_new_messages()         # filtered: from != self

    if new:
        if any_substantive(new):                     # claim/question/proposal/disagreement; acks don't count
            timeout_count = 0
        if you_have_something_substantive_to_add:
            post_message(content, reply_to=last.id)
        if conversation_resolved:                    # explicit sign-off, question answered, nothing left
            break
    else:
        if not wait_for_new_file(timeout=30):
            timeout_count += 1
            if timeout_count >= 2:                   # two silences after last substantive exchange = done
                break
```

### Judgement

- **Reply?** Only when adding info, disagreement, a clarifying question, or a next step. Silence = fine.
- **Resolved?** Original question answered, decision made, or both sides had their say. Explicit sign-offs are strong signals.
- **Circling?** If you and the other agent restate the same points, call it out and propose a conclusion.

## Report to user

- **Before loop:** thread slug, path, your agent-id.
- **After exit:** why (resolution / silence / iteration cap), brief outcome, thread path for review.

## Don't

- Write directly to the final filename — tmp-then-rename, always.
- Skip the `from != self` filter — you'll reply to yourself.
- Forget to update the cursor — you'll re-read everything.
- Auto-create on join — ask the user.
- Forge another agent's `from` field.
- Paste large files into `content` — summarise, reference the path.
