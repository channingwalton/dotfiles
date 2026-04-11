#!/bin/bash
# gh-activity.sh — Detailed GitHub activity summary
# Requires: gh CLI authenticated, jq
# Usage: gh-activity.sh [YYYY-MM-DD]

set -euo pipefail

DATE="${1:-$(date +%Y-%m-%d)}"
SINCE="${DATE}T00:00:00Z"
# macOS date for tomorrow
TOMORROW=$(date -j -v+1d -f "%Y-%m-%d" "$DATE" +"%Y-%m-%dT00:00:00Z" 2>/dev/null || \
  date -d "$DATE +1 day" +"%Y-%m-%dT00:00:00Z")
USER="channingwalton"

echo "# GitHub Activity for $DATE"
echo ""


# --- PRs authored (with commit messages) ---
echo "## Pull Requests Authored"
PR_OUTPUT=$(gh api graphql -f query="
query {
  search(query: \"author:$USER updated:>=$DATE type:pr\", type: ISSUE, first: 20) {
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
  ] | if length == 0 then ["- (no new commits today)"] else . end | join("\n"))' 2>&1)
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
  search(query: \"reviewed-by:$USER updated:>=$DATE type:pr -author:$USER\", type: ISSUE, first: 20) {
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
  "- [\(.reviews.nodes[-1].state)] \(.repository.nameWithOwner): \(.title)\n  \(.url)"' 2>&1)
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
}" --jq '.data.viewer.contributionsCollection.commitContributionsByRepository[] | .repository.nameWithOwner' 2>&1)

if [ -n "$REPOS" ]; then
  while IFS= read -r repo; do
    COMMITS=$(gh api "repos/$repo/commits?author=$USER&since=$SINCE&per_page=20" \
      --jq '.[] | "- " + (.commit.message | split("\n")[0])' 2>&1) || true
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
  search(query: \"involves:$USER updated:>=$DATE type:issue\", type: ISSUE, first: 10) {
    nodes {
      ... on Issue {
        title url state
        repository { nameWithOwner }
      }
    }
  }
}" --jq '.data.search.nodes[] |
  "- [\(.state)] \(.repository.nameWithOwner): \(.title)\n  \(.url)"' 2>&1)
if [ -n "$ISSUE_OUTPUT" ]; then
  echo "$ISSUE_OUTPUT"
else
  echo "(none)"
fi
