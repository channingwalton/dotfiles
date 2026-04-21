---
name: chatter
description: Use when the user asks you to start, join, or continue a conversation with another agent via chatter / agent-chat — any mention of chatters, agent-chat, or "talk to <agent> about X".
---

# chatter

Filesystem-based multi-agent chat. Messages are JSON files in a shared thread directory. No network.

Core behaviour: **loop** — read new messages → reply if useful → wait → repeat → exit when resolved or silent.

## The helper

All filesystem mechanics live in the bundled CLI:

```sh
CHATTER=~/.claude/skills/chatter/chatter

$CHATTER post <slug> <agent-id> <content> [--reply-to ID]   # → prints filename
$CHATTER read <slug> [--since FILENAME]                     # → JSON array of messages
$CHATTER wait <slug> [--timeout SEC]                        # → exit 0 on event, 1 on timeout
```

Thread root: `$CHATTER_ROOT` or `~/dev/agent-chat`. Each thread is `$ROOT/{slug}/` containing message files. Use the helper — don't hand-roll JSON or filenames.

## Agent identity

Pick a stable `agent-id` for this conversation, in order:

1. User-specified (e.g. "join as `codex-reviewer`").
2. `{host}-{short6}` where `host` is the tool (`claude-code`, `codex`, `opencode`) and `short6` is 6 hex chars of a per-session uuid, e.g. `claude-code-a3f91c`. Prevents collisions when two sessions of the same host join one thread.
3. Ask the user if genuinely unknown.

## Start vs join

| Action | Steps |
|---|---|
| **Start** | slug = `{yyyyMMddHHmmss}-{kebab-topic}` → `$CHATTER post <slug> <you> "<opening>"` (creates dir) → loop |
| **Join** | Verify `$ROOT/{slug}/` exists (ask user if not, don't auto-create) → `$CHATTER read <slug>` to catch up → set `LAST_SEEN` to the last filename → loop |

## The loop

Track `LAST_SEEN` as a shell variable.

```
timeout_count = 0
iterations = 0
MAX_ITERATIONS = 20

while iterations < MAX_ITERATIONS:
    iterations += 1
    msgs = chatter read <slug> --since $LAST_SEEN
    new = [m for m in msgs if m.from != self]

    if new:
        LAST_SEEN = last(msgs).id + ".json"
        if any_substantive(new):                     # claim/question/proposal/disagreement; acks don't count
            timeout_count = 0
        if you_have_something_substantive_to_add:
            f = chatter post <slug> <you> "..." --reply-to <last.id>
            LAST_SEEN = f
        if conversation_resolved:                    # explicit sign-off, question answered, nothing left
            break
    else:
        if not chatter wait <slug> --timeout 30:
            timeout_count += 1
            if timeout_count >= 2:                   # two silences after last substantive exchange = done
                break
```

After `wait` returns, **always re-run `read`** — the wake may have fired on a `.tmp` or your own write.

### Judgement

- **Reply?** Only when adding info, disagreement, a clarifying question, or a next step. Silence = fine.
- **Resolved?** Original question answered, decision made, or both sides had their say. Explicit sign-offs are strong signals.
- **Circling?** If you and the other agent restate the same points, call it out and propose a conclusion.

## Report to user

- **Before loop:** thread slug, path, your agent-id.
- **After exit:** why (resolution / silence / iteration cap), brief outcome, thread path for review.

## Don't

- Hand-roll JSON or filenames — use `$CHATTER post`.
- Skip the `from != self` filter — you'll reply to yourself.
- Forget to update `LAST_SEEN` after each `read`/`post` — you'll re-process the same message.
- Auto-create on join — ask the user.
- Forge another agent's `from` field.
- Paste large files into `content` — summarise, reference the path.
