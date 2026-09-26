#!/usr/bin/env python3
"""PreToolUse gate: outward writes must carry checked claims.

Fires only when a write is about to leave the machine — a Jira, Confluence or
Linear issue, comment or document, a GitHub PR/issue/release text, a Slack
message. Asks for confirmation with a short checklist; any internal error exits
0 silently. settings.json routes every MCP tool here, so the tool-name suffix
alone decides, whichever server exposes it.

Targets failure class: assert-before-check/unverified-claim-into-outward-artefact
Retro 2026-08-09. Replaces the task-note-update-scoped rule, which could not fire
for any of the six observed leaks (all went to Jira, GitHub, colleague drafts, or
memory files rather than a vault note).
"""
import json
import re
import sys

MCP_WRITE = re.compile(
    r"(addCommentToJiraIssue|editJiraIssue|createJiraIssue|addWorklogToJiraIssue"
    r"|updateConfluencePage|createConfluencePage|createConfluenceFooterComment"
    r"|createConfluenceInlineComment"
    r"|slack_send_message|slack_send_message_draft|slack_schedule_message"
    r"|slack_update_canvas|slack_create_canvas"
    r"|save_comment|save_issue|save_document|save_status_update|save_release_note"
    r"|save_diff_comment|submit_diff_review)$"
)

# `gh` must sit in command position — start of string, after a shell
# operator, newline or subshell opener, optionally behind a wrapper
# (timeout, env, VAR=value …). Without this anchor the pattern also matches
# its own description quoted inside a heredoc, which it did on first use.
COMMAND_START = r"(?:\A|[\n;|&({]|\$\(|\bxargs\s+)\s*"
WRAPPERS = r"(?:(?:timeout\s+\S+|env|command|nice|nohup|time)\s+|[A-Za-z_]\w*=\S*\s+)*"
GH_REPO_FLAG = r"(?:(?:-R|--repo)(?:\s+|=)\S+\s+)*"
GH_WRITE = (
    r"(?:(?:pr|issue)\s+(?:comment|create|edit|review)\b"
    # close/merge/reopen only write prose when given a comment or body
    r"|(?:pr|issue)\s+(?:close|merge|reopen)\b[^\n;|&]*\s(?:-c|--comment|-b|--body|-F|--body-file)\b"
    r"|release\s+(?:create|edit)\b"
    r"|api\b[^\n]*\b(?:comments|issues|pulls)\b"
    r"|api\s+graphql\b[^\n]*\bmutation\b)"
)
SLACK_API = r"curl\b[^\n]*(?:hooks\.slack\.com/|slack\.com/api/(?:chat|files|canvases)\.)"
BASH_WRITE = re.compile(
    COMMAND_START + WRAPPERS + r"(?:gh\s+" + GH_REPO_FLAG + GH_WRITE + r"|" + SLACK_API + r")"
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

        # `ask`, not `additionalContext`. Retro 2026-09-20: as an advisory this
        # gate was INEFFECTIVE for three consecutive windows, and the reason is
        # structural rather than a wording problem — additionalContext reaches
        # the model only after the payload has been composed, so it can prompt a
        # retraction but never prevent the claim. Observed shape every time:
        # publish, self-audit, patch in place ~60s later, with one false claim
        # left permanently in an external ticket's edit history. Asking suspends
        # the call while the text can still be changed.
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": REMINDER,
            }
        }))
    except Exception:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
