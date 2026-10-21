#!/usr/bin/env python3
"""PreToolUse gate: outward writes must carry checked claims.

Fires only when a write is about to leave the machine — a Jira, Confluence or
Linear issue, comment or document, a GitHub PR/issue/release text, a Slack
message. Holds the first attempt with a short checklist for the model, and lets
the identical re-issue through without asking the user; any internal error exits
0 silently. settings.json routes every MCP tool here, so the tool-name suffix
alone decides, whichever server exposes it.

Targets failure class: assert-before-check/unverified-claim-into-outward-artefact
Retro 2026-08-09. Replaces the task-note-update-scoped rule, which could not fire
for any of the six observed leaks (all went to Jira, GitHub, colleague drafts, or
memory files rather than a vault note).
"""
import hashlib
import json
import os
import re
import shlex
import sys
import time

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
COMMAND_START = r"(?:\A|[\n;|&({]|\$\(|\bxargs(?:\s+-\S+)*\s+)\s*"
WRAPPERS = r"(?:(?:timeout\s+\S+|env|command|nice|nohup|time)\s+|[A-Za-z_]\w*=\S*\s+)*"
GH_REPO_FLAG = r"(?:(?:-R|--repo)(?:\s+|=)\S+\s+)*"
GH_WRITE = (
    r"(?:(?:pr|issue)\s+(?:comment|create|edit|review)\b"
    # close/merge/reopen only write prose when given a comment or body
    r"|(?:pr|issue)\s+(?:close|merge|reopen)\b[^\n;|&]*\s(?:-c|--comment|-b|--body|-F|--body-file)\b"
    r"|release\s+(?:create|edit)\b"
    # Every `gh api` is a candidate. gh_writes reads its words, quote-aware,
    # to decide the endpoint and read vs write; a regex reaching for the
    # endpoint either swallowed a later command or stopped at a quoted `|`.
    r"|api\b)"
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
    "4. An absence, coverage or comparison claim (\"no other caller\", \"all "
    "checked\", \"better than X\") names the search scope or the baseline it "
    "was measured against.\n"
    "This has produced inverted security guidance, a wrong version and "
    "procedure, and two retracted claims in shared artefacts."
)

HELD = (
    "\n\nThis call was held once so the text can be checked before it leaves. "
    "If every claim passes, re-issue the identical call to send it; otherwise "
    "revise the text first."
)

# A held call stays re-issuable this long.
HOLD_SECONDS = 600
# A re-issue needs a model turn; anything sooner came in the same batch.
REISSUE_SECONDS = 2
STATE_DIR = os.environ.get("OUTWARD_GATE_STATE") or os.path.expanduser(
    "~/.cache/claude/outward-write-gate"
)

GH_REPO_FLAGS = ("-R", "--repo")


SEPARATORS = ";&|()\n"
# REST endpoints whose writes carry no prose. Every other write is held: an
# allowlist of prose endpoints missed contents, descriptions, milestones,
# statuses, commits and profiles one review at a time.
PROSE_FREE_ENDPOINT = re.compile(
    r"(?:^|/)(?:git/refs(?:/.*)?|actions/workflows/[^/]+/dispatches"
    r"|actions/runs/\d+/(?:rerun|rerun-failed-jobs|cancel|approve)"
    r"|user/starred/.+|subscription|notifications(?:/.*)?|reactions(?:/\d+)?)/?$"
)
REDIRECT = re.compile(r"^(?:<<-?|<<<|<>|>>|>\||>&|<&|&>>|&>|<|>)$")
GRAPHQL_ENDPOINT = re.compile(r"^(?:/?graphql|https?://[^/]+(?:/api(?:/v3)?)?/graphql)/?$")
# `gh api` flags that take a value, by what the value is.
API_VALUE_FLAGS = {
    "-X": "method", "--method": "method",
    "-f": "field", "-F": "field", "--field": "field", "--raw-field": "field",
    "--input": "input",
    "-H": "other", "--header": "other", "-q": "other", "--jq": "other",
    "-t": "other", "--template": "other", "--cache": "other",
    "--hostname": "other", "-p": "other", "--preview": "other",
}


def tokens(segment):
    """Shell words of one command, stopping at the first unquoted separator.

    Returns the words and whether the command is opaque: an unquoted `$(…)` or
    `<(…)` hides what it produces, and can hide every word after it.
    Redirections (`2>&1`, `>/dev/null`) are dropped with their target: stopping
    at their `&` hid the field flags after them. `#` is literal, as mid-word in
    bash. An unclosed quote raises ValueError; callers treat that as a write.
    """
    lexer = shlex.shlex(segment, posix=True, punctuation_chars=SEPARATORS + "<>")
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    lexer.commenters = ""
    out = []
    opaque = False
    redirect_target = False
    for word in lexer:
        if word.count("`") % 2:
            # An unquoted backtick substitution, split by its inner spaces.
            opaque = True
        if not (word and set(word) <= set(SEPARATORS + "<>")):
            if redirect_target:
                redirect_target = False
            else:
                out.append(word)
            continue
        if word in ("<(", ">("):
            opaque = True
            continue
        if REDIRECT.match(word):
            # `2>&1` drops its fd; `5 >out` keeps 5, an argument.
            if out and out[-1].isdigit() and out[-1] + word in segment:
                out.pop()
            redirect_target = True
            continue
        # A separator, alone or run together with a redirection (`;>`).
        if word.startswith("(") and out and out[-1].endswith("$"):
            opaque = True
        break
    return out, opaque


def parse_api(args):
    """Split `gh api` arguments into method, field values, input, positionals,
    and every flag value."""
    method = None
    fields = []
    inputs = False
    positionals = []
    values = []
    i = 0
    while i < len(args):
        word = args[i]
        kind = value = None
        if word in API_VALUE_FLAGS and i + 1 < len(args):
            kind, value = API_VALUE_FLAGS[word], args[i + 1]
            i += 1
        elif word.startswith("--") and word.split("=", 1)[0] in API_VALUE_FLAGS:
            flag, _, value = word.partition("=")
            kind = API_VALUE_FLAGS[flag]
        elif word.startswith("-") and not word.startswith("--") and len(word) > 2:
            # A short-flag cluster such as `-fbody=x`, `-iXPOST` or `-if body=x`:
            # the first value-taking flag takes the rest of the word or the next.
            for j, char in enumerate(word[1:], 1):
                if "-" + char in API_VALUE_FLAGS:
                    kind, value = API_VALUE_FLAGS["-" + char], word[j + 1:]
                    if not value and i + 1 < len(args):
                        value = args[i + 1]
                        i += 1
                    break
        elif not word.startswith("-"):
            positionals.append(word)
        if value is not None:
            values.append(value)
        if kind == "method":
            method = value
        elif kind == "field":
            fields.append(value)
        elif kind == "input":
            inputs = True
        i += 1
    return method, fields, inputs, positionals, values


def unresolved(word):
    """A shell expansion the hook cannot see through."""
    return "$" in word or "`" in word


def may_split(word):
    """A word that is wholly an expansion, which may split into several words.

    `$EP`, `$FLAGS` and `${args[@]}` can carry flags; `repos/$repo/pulls` can't
    in practice, and holding it held seven loops of plain reads in one window.
    """
    return re.fullmatch(r"\$(?:\w+|[@*]|\{[^}]*\})|`[^`]*`", word) is not None


def shell_in_query(query):
    """Whether a GraphQL query holds something the shell, not GraphQL, expands."""
    if "`" in query or re.search(r"\$(?![A-Za-z_])", query):
        return True
    declared = set(re.findall(r"\$(\w+)\s*:", query))
    return any(name not in declared for name in re.findall(r"\$(\w+)", query))


def is_help(words):
    # Only as a flag: `-b -h` posts the body "-h".
    return any(
        word in ("--help", "-h") and (i == 0 or not words[i - 1].startswith("-"))
        for i, word in enumerate(words)
    )


def gh_writes(segment):
    """Whether a matched `gh` command really writes prose.

    The regex finds candidates; this drops `--help` and read-only `gh api`
    calls, which asked the user for approval on plain GETs in two windows.
    """
    words, opaque = tokens(segment.lstrip(" \t\n;|&({$"))
    if "gh" not in words:
        return True
    rest = words[words.index("gh") + 1:]
    if is_help(rest):
        return False
    while rest and (rest[0] in GH_REPO_FLAGS or rest[0].startswith("--repo=")):
        rest = rest[2:] if rest[0] in GH_REPO_FLAGS else rest[1:]
    if not rest or rest[0] != "api":
        return True
    # From here on, unknown is gated: a held read costs one call, an ungated
    # write is the failure this hook exists for. Only the endpoint, the method
    # and the field values decide; --jq, headers and the like are left alone.
    if opaque:
        return True
    method, fields, inputs, positionals, values = parse_api(rest[1:])
    endpoint = positionals[0] if positionals else None
    # Quoting is gone by now, so an expanded word may have split into flags,
    # and xargs appends words the hook never sees.
    hidden = "xargs" in words[:words.index("gh")] or any(
        may_split(w) for w in positionals + values
    )
    if endpoint and GRAPHQL_ENDPOINT.match(endpoint):
        # Read-only only when the query is inline and visibly not a mutation,
        # and no field reads a file. A `$name` the query declares is a GraphQL
        # variable; any other `$`, or a backtick, is the shell's.
        queries = [v[len("query="):] for v in fields if v.startswith("query=")]
        if hidden or inputs or not queries or any("=@" in v for v in fields):
            return True
        return any(shell_in_query(q) or "mutation" in q for q in queries)
    if hidden or (method and unresolved(method)):
        writes = True
    else:
        writes = (method or ("POST" if fields or inputs else "GET")).upper() != "GET"
    if not writes:
        return False
    return endpoint is None or not PROSE_FREE_ENDPOINT.search(endpoint)


def bash_writes(command):
    command = command.replace("\\\n", " ")
    for m in BASH_WRITE.finditer(command):
        try:
            if gh_writes(command[m.start():]):
                return True
        except Exception:
            # The regex already matched: when parsing fails, gate it.
            return True
    return False


def first_sight(agent, name, tool_input):
    """True when this call is not already held for this agent.

    The first sighting leaves a marker and is held; the re-issue consumes the
    marker and goes through, so a later identical call is held again.
    A marker younger than REISSUE_SECONDS means the same call arrived in one
    parallel batch, before the model could have read the hold: held too.
    Keyed per agent (session, transcript and agent_id — subagents share the
    session id), so another model still sees the checklist. A marker that
    vanishes mid-check was consumed by a parallel re-issue: this call is held.
    A Bash call is keyed on its command alone: the model
    rewrites the description freely, and a re-issue must not be held again.
    """
    held = tool_input.get("command") if name == "Bash" else tool_input
    key = hashlib.sha256(
        json.dumps([agent, name, held], sort_keys=True).encode()
    ).hexdigest()
    os.makedirs(STATE_DIR, exist_ok=True)
    now = time.time()
    for entry in os.listdir(STATE_DIR):
        path = os.path.join(STATE_DIR, entry)
        try:
            if now - os.path.getmtime(path) > HOLD_SECONDS:
                os.remove(path)
        except OSError:
            pass
    marker = os.path.join(STATE_DIR, key)
    try:
        os.close(os.open(marker, os.O_CREAT | os.O_EXCL | os.O_WRONLY))
    except FileExistsError:
        return not consume_hold(marker, now)
    return True


def consume_hold(marker, now):
    """True for a real re-issue of a held call, which consumes the hold.

    False — keep holding — when the marker is younger than REISSUE_SECONDS
    (same batch), or vanishes while being checked (a parallel re-issue or an
    expiry sweep took it).
    """
    try:
        if now - os.path.getmtime(marker) < REISSUE_SECONDS:
            return False
        os.remove(marker)
    except FileNotFoundError:
        # Held now, so leave a marker already past the same-batch window: the
        # next re-issue goes through, however quick the turn.
        try:
            os.close(os.open(marker, os.O_CREAT | os.O_WRONLY))
            os.utime(marker, (now - REISSUE_SECONDS, now - REISSUE_SECONDS))
        except OSError:
            pass
        return False
    return True


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    try:
        name = payload.get("tool_name") or ""
        tool_input = payload.get("tool_input") or {}

        if name == "Bash":
            hit = bash_writes(tool_input.get("command") or "")
        else:
            hit = bool(MCP_WRITE.search(name))

        if not hit:
            return 0
    except Exception:
        return 0

    # Deny once, never ask. Retro 2026-09-20 moved this gate from
    # additionalContext to `ask`, because additionalContext reaches the model
    # only after the payload is composed. Retro 2026-10-05 found `ask` no better:
    # its reason goes to the user's prompt, not the model, and every one of 25
    # asks in the next window was approved with the claims unchanged. A deny
    # reason reaches the model before anything is sent. The user always approved
    # the ask, so the identical re-issue goes through (retro 2026-10-21).
    try:
        agent = [
            payload.get("session_id"),
            payload.get("transcript_path"),
            payload.get("agent_id"),
        ]
        held = first_sight(agent, name, tool_input)
    except Exception:
        held = False
    if held:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": REMINDER + HELD,
            }
        }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
