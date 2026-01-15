#!/bin/bash
# Wrapper for session-start hook that outputs proper JSON for Claude Code

NODE_PATH="/Users/channing/.nvm/versions/node/v25.2.0/bin/node"
HOOK_PATH="/Users/channing/.claude/hooks/core/session-start.js"

# Capture the hook output, strip ANSI codes
output=$("$NODE_PATH" "$HOOK_PATH" 2>&1 | sed 's/\x1b\[[0-9;]*m//g')

# Output as JSON that Claude Code expects
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(echo "$output" | jq -Rs .)
  }
}
EOF

exit 0
