#!/bin/bash
# gh-activity.sh — Detailed GitHub activity summary
# Requires: gh CLI authenticated, jq
# Usage: gh-activity.sh [YYYY-MM-DD]

set -euo pipefail

# Ensure Homebrew binaries (gh) are on PATH for non-login shells (e.g. scheduled runs)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

DATE="${1:-$(date +%Y-%m-%d)}"

# Local midnight at the start of DATE plus $2 days, as a UTC timestamp for the API
# (UTC midnight would drop the first hour of the day during BST). macOS, then GNU date.
local_midnight_utc() {
  date -j -u -r "$(date -j -v+"$2"d -f "%Y-%m-%d %H:%M:%S" "$1 00:00:00" +%s)" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null ||
    date -u -d "$1 00:00 +$2 day" +%Y-%m-%dT%H:%M:%SZ
}
SINCE=$(local_midnight_utc "$DATE" 0)
TOMORROW=$(local_midnight_utc "$DATE" 1)
USER="channingwalton"

echo "# GitHub Activity for $DATE"
echo ""


# --- PRs authored (with commit messages) ---
echo "## Pull Requests Authored"
PR_OUTPUT=$(gh api graphql -f query="
query {
  search(query: \"author:$USER updated:>=$SINCE type:pr\", type: ISSUE, first: 20) {
    nodes {
      ... on PullRequest {
        title url state
        repository { nameWithOwner }
        additions deletions
        commits(last: 20) {
          nodes { commit { message committedDate } }
        }
      }
    }
  }
}" --jq '.data.search.nodes[] |
  "### \(.repository.nameWithOwner) — \(.title)\nState: \(.state) | \(.url)\n+\(.additions) -\(.deletions)\nCommits:\n" +
  ([.commits.nodes[] |
    select(.commit.committedDate >= "'"$SINCE"'") |
    "- " + (.commit.message | split("\n")[0])
  ] | if length == 0 then ["- (no new commits today)"] else . end | join("\n"))')
if [ -n "$PR_OUTPUT" ]; then
  echo "$PR_OUTPUT"
else
  echo "(none)"
fi
echo ""

# --- PR reviews ---
echo "## PR Reviews"
REVIEW_OUTPUT=$(gh api graphql -f query="
query {
  search(query: \"reviewed-by:$USER updated:>=$SINCE type:pr -author:$USER\", type: ISSUE, first: 20) {
    nodes {
      ... on PullRequest {
        title url state
        repository { nameWithOwner }
        reviews(author: \"$USER\", last: 5) {
          nodes { state submittedAt }
        }
      }
    }
  }
}" --jq '.data.search.nodes[] |
  select(.reviews.nodes | length > 0) |
  "- [\(.reviews.nodes[-1].state)] \(.repository.nameWithOwner): \(.title)\n  \(.url)"')
if [ -n "$REVIEW_OUTPUT" ]; then
  echo "$REVIEW_OUTPUT"
else
  echo "(none)"
fi
echo ""


# --- Commits by repo (including private, with messages) ---
echo "## Commits by Repository"

REPOS=$(gh api graphql -f query="
query {
  viewer {
    contributionsCollection(from: \"$SINCE\", to: \"$TOMORROW\") {
      commitContributionsByRepository {
        repository { nameWithOwner }
        contributions(first: 10) {
          nodes { commitCount }
        }
      }
    }
  }
}" --jq '.data.viewer.contributionsCollection.commitContributionsByRepository[] | .repository.nameWithOwner')

if [ -n "$REPOS" ]; then
  while IFS= read -r repo; do
    COMMITS=$(gh api "repos/$repo/commits?author=$USER&since=$SINCE&until=$TOMORROW&per_page=20" \
      --jq '.[] | "- " + (.commit.message | split("\n")[0])') || true
    if [ -n "$COMMITS" ]; then
      echo "### $repo"
      echo "$COMMITS"
      echo ""
    fi
  done <<< "$REPOS"
else
  echo "(none)"
fi

# --- Issues ---
echo "## Issues"
ISSUE_OUTPUT=$(gh api graphql -f query="
query {
  search(query: \"involves:$USER updated:>=$SINCE type:issue\", type: ISSUE, first: 10) {
    nodes {
      ... on Issue {
        title url state
        repository { nameWithOwner }
      }
    }
  }
}" --jq '.data.search.nodes[] |
  "- [\(.state)] \(.repository.nameWithOwner): \(.title)\n  \(.url)"')
if [ -n "$ISSUE_OUTPUT" ]; then
  echo "$ISSUE_OUTPUT"
else
  echo "(none)"
fi
