#!/usr/bin/env python3
"""PreToolUse gate: outward writes must carry checked claims.

Fires only when a write is about to leave the machine — a Jira issue or comment,
a GitHub PR/issue comment, a Slack message. Injects a short reminder as
additionalContext. Never blocks; any internal error exits 0 silently.

Targets failure class: assert-before-check/unverified-claim-into-outward-artefact
Retro 2026-08-09. Replaces the task-note-update-scoped rule, which could not fire
for any of the six observed leaks (all went to Jira, GitHub, colleague drafts, or
memory files rather than a vault note).
"""
import json
import re
import sys

MCP_WRITE = re.compile(
    r"(addCommentToJiraIssue|editJiraIssue|createJiraIssue|updateConfluencePage"
    r"|createConfluencePage|createConfluenceFooterComment|createConfluenceInlineComment"
    r"|slack_send_message|slack_send_message_draft|slack_update_canvas|slack_create_canvas)$"
)

# `gh` must sit in command position — start of string, or after a shell
# operator/newline. Without this anchor the pattern also matches its own
# description quoted inside a heredoc, which it did on first use.
BASH_WRITE = re.compile(
    r"(?:\A|[\n;|&]|\$\(|\bxargs\s+)\s*gh\s+"
    r"(?:(?:pr|issue)\s+(?:comment|create|edit|review)\b"
    r"|api\b[^\n]*\b(?:comments|issues|pulls)\b)"
)

REMINDER = (
    "Outward write — this lands where other people read it, and can only be "
    "superseded, not withdrawn. Before sending:\n"
    "1. Every factual or causal claim in this text: name the check that "
    "established it, and confirm that check actually ran. If a check was "
    "attempted and errored, say so in the text rather than dropping the caveat.\n"
    "2. State provenance where it is not obvious — code read at file:line, a "
    "ticket comment and its date, production data and when you queried it. A "
    "figure from a stale comment or a test fixture is not current production "
    "fact.\n"
    "3. If the claim was decided in this same turn from the user's answer to a "
    "clarifying question, that is not authorisation to publish it.\n"
    "This has produced inverted security guidance, a wrong version and "
    "procedure, and two retracted claims in shared artefacts."
)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    try:
        name = payload.get("tool_name") or ""
        tool_input = payload.get("tool_input") or {}

        if name == "Bash":
            command = tool_input.get("command") or ""
            hit = bool(BASH_WRITE.search(command))
        else:
            hit = bool(MCP_WRITE.search(name))

        if not hit:
            return 0

        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": REMINDER,
            }
        }))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
