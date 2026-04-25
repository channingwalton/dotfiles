---
name: chatter
description: Use when the user asks you to start, join, or continue a conversation with another agent via chatter / agent-chat — any mention of chatters, agent-chat, or "talk to <agent> about X".
---

# chatter

Filesystem-based multi-agent chat. Messages are markdown files (YAML frontmatter + body) in a shared thread directory. No network.

Core behaviour: **loop** — read new messages → reply if useful → wait → repeat → exit when resolved or silent.

## The helper

All filesystem mechanics live in a `chatter` script bundled with this skill (next to `SKILL.md`). **Resolve its absolute path once at session start** and reuse — examples below show it as bare `chatter`.

```sh
chatter post <slug> <agent-id> <content> [--reply-to ID]   # → prints filename
chatter read <slug> [--since FILENAME]                     # → JSON array of messages
chatter wait <slug> [--timeout SEC]                        # → exit 0 on event, 1 on timeout
```

**Root resolution** (in order):
1. `--root <path>` flag (per-call override)
2. `$CHATTER_ROOT` env var (session-wide override)
3. `./agent-chatter` (default — scopes chats to the current project)

Run from the project's working directory so chats land in `./agent-chatter/{slug}/`. Both agents must agree on root — same CWD, or both export the same `CHATTER_ROOT`. Use the helper — don't hand-roll JSON or filenames.

## Agent identity

Pick a stable `agent-id` for this conversation, in order:

1. User-specified (e.g. "join as `codex-reviewer`").
2. Host name alone: `claude-code`, `codex`, `opencode`. If the thread already has a message from that host (different session), ask the user for a discriminator (e.g. `claude-code-2`).
3. Ask the user if genuinely unknown.

## Start vs join

| Action | Steps |
|---|---|
| **Start** | slug = `{yyyyMMdd-HHmm}-{kebab-topic}` → `chatter post <slug> <you> "<opening>"` (creates dir) → loop |
| **Join** | Verify `<root>/{slug}/` exists (ask user if not, don't auto-create) → `chatter read <slug>` to catch up → set `LAST_SEEN` to the last filename → loop |

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
        LAST_SEEN = last(msgs).id + ".md"
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

- Hand-roll JSON or filenames — use `chatter post`.
- Skip the `from != self` filter — you'll reply to yourself.
- Forget to update `LAST_SEEN` after each `read`/`post` — you'll re-process the same message.
- Auto-create on join — ask the user.
- Forge another agent's `from` field.
- Paste large files into `content` — summarise, reference the path.
