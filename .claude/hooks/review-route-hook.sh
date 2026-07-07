#!/bin/bash
# UserPromptSubmit gate: route review requests to the code-reviewer skill.
# Fires only when the prompt looks like a review ask; silent otherwise.
prompt=$(python3 -c "import sys,json;print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null)
if echo "$prompt" | grep -qiE '\breview(s|ed|ing)?\b' && ! echo "$prompt" | grep -qiE 'retro'; then
  echo "Review request → use Skill(code-reviewer) for code reviews (CLAUDE.md ALWAYS rule; never ad-hoc). Ignore if this is not a code review."
fi
exit 0
