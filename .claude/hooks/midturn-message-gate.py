#!/usr/bin/env python3
"""Stop gate: answer the messages the user sent while the agent worked.

A message typed while the agent works joins the turn between tool calls, and no
prompt hook fires for it. On 2026-10-27 one said "I don't want my pi config in
my dotfiles"; the agent worked on, then asked whether to add the config to the
dotfiles. At the first stop of a turn that holds such messages, block once and
quote them; `stop_hook_active` lets the next stop through. Any internal error
exits 0 silently.

Targets failure class: midturn-message/dropped (retro 2026-10-30).
"""
import json
import re
import sys

REMINDER = re.compile(r"<system-reminder>.*?</system-reminder>", re.S)
QUOTE_CHARS = 300


def human_text(event):
    """The text of a message the user typed, or None."""
    if event.get("isMeta") or event.get("isCompactSummary"):
        return None
    if (event.get("origin") or {}).get("kind", "human") != "human":
        return None
    content = (event.get("message") or {}).get("content")
    if isinstance(content, list):
        if any(b.get("type") == "tool_result" for b in content if isinstance(b, dict)):
            return None
        content = " ".join(
            b.get("text", "") for b in content if isinstance(b, dict) and b.get("type") == "text"
        )
    text = REMINDER.sub("", content or "").strip()
    return text or None


def midturn_messages(lines):
    """Messages that joined the current turn while the agent was working."""
    working = False  # the last agent event was a tool call or its result
    found = []
    for line in lines:
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if event.get("isSidechain"):
            continue
        kind = event.get("type")
        if kind == "assistant":
            content = (event.get("message") or {}).get("content") or []
            blocks = [b.get("type") for b in content if isinstance(b, dict)]
            if "tool_use" in blocks:
                working = True
            elif "text" in blocks:
                working = False
            continue
        if kind == "attachment":
            attachment = event.get("attachment") or {}
            if attachment.get("type") == "queued_command" and working:
                prompt = attachment.get("prompt")
                prompt = prompt.strip() if isinstance(prompt, str) else ""
                # Task notifications and agent hand-backs queue the same way.
                if prompt and not prompt.startswith("<") and prompt not in found:
                    found.append(prompt)
            continue
        if kind != "user":
            continue
        content = (event.get("message") or {}).get("content")
        results = [
            b for b in content if isinstance(b, dict) and b.get("type") == "tool_result"
        ] if isinstance(content, list) else []
        if results:
            # A declined call ends the turn with no closing text.
            working = not any(
                "The user doesn't want to proceed" in json.dumps(b.get("content"))
                for b in results
            )
            continue
        text = human_text(event)
        if text is None:
            continue
        if text.startswith("[Request interrupted"):
            working = False
            continue
        if text.startswith("<"):
            # A slash command starts a turn; harness notices are not the user's words.
            if text.startswith(("<command-", "<local-command-")):
                found = []
                working = False
            continue
        if working:
            if text not in found:
                found.append(text)
        else:
            found = []
    return found


def main() -> int:
    try:
        payload = json.load(sys.stdin)
        if payload.get("stop_hook_active"):
            return 0
        with open(payload["transcript_path"], encoding="utf-8", errors="ignore") as transcript:
            messages = midturn_messages(transcript)
    except Exception:
        return 0
    if not messages:
        return 0
    quoted = "\n".join(
        "- «" + (m if len(m) <= QUOTE_CHARS else m[:QUOTE_CHARS] + "…") + "»" for m in messages
    )
    print(json.dumps({
        "decision": "block",
        "reason": (
            "Before you stop: the user sent these messages while you worked, and "
            "they joined this turn:\n" + quoted + "\n"
            "If your reply already answers each one and follows any instruction "
            "in it, stop now and add nothing. Otherwise answer what is missing; "
            "if a message changed the task, say what you changed."
        ),
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
