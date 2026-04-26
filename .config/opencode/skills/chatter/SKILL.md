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
chatter read <slug> [--since FILENAME] [--wait-create SEC] # → JSON array of messages
chatter wait <slug> [--timeout SEC]    [--wait-create SEC] # → exit 0 on event, 1 on timeout
```

`--wait-create SEC` (read/wait): if the thread dir doesn't exist yet, poll up to SEC seconds for it to appear before failing. Use on join when the other agent may not have posted yet.

**Root resolution** (in order):
1. `--root <path>` flag (per-call override)
2. `$CHATTER_ROOT` env var (session-wide override)
3. `./agent-chatter` (default — scopes chats to the current project)

Run from the project's working directory so chats land in `./agent-chatter/{slug}/`. Both agents must agree on root — same CWD, or both export the same `CHATTER_ROOT`. Use the helper — don't hand-roll JSON or filenames.

**Requirements:** `python3` in `PATH`. Uses `fswatch` (macOS) or `inotifywait` (Linux) for `wait`; falls back to 2s polling otherwise. Filename order is the protocol order; `created_at` (UTC ISO 8601) is diagnostic only.

## Agent identity

Pick a stable `agent-id` for this conversation, in order:

1. User-specified (e.g. "join as `codex-reviewer`").
2. Host name alone: `claude-code`, `codex`, `opencode`. If the thread already has a message from that host (different session), ask the user for a discriminator (e.g. `claude-code-2`).
3. Ask the user if genuinely unknown.

## Start vs join

| Action | Steps |
|---|---|
| **Start** | slug = `{yyyyMMdd-HHmm}-{kebab-topic}` → `chatter post <slug> <you> "<opening>"` (creates dir) → loop |
| **Join** | `chatter read <slug> --wait-create 60` to catch up (waits if the other agent hasn't posted yet; on timeout the slug is wrong — ask the user, don't auto-create) → set `LAST_SEEN` to the last filename → loop |

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
- Auto-create on join — wait with `--wait-create` for the other agent's first post; only ask the user if it times out.
- Forge another agent's `from` field.
- Paste large files into `content` — summarise, reference the path.
