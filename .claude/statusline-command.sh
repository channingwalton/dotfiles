#!/usr/bin/env bash
# Claude Code status line — based on robbyrussell zsh theme
# Receives JSON on stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
dir=$(basename "$cwd")
model=$(echo "$input" | jq -r '.model.display_name // ""')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Git info from the cwd
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
dirty=$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)

# ANSI colours (dimmed-friendly)
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Directory
printf "${CYAN}%s${RESET}" "$dir"

# Git
if [ -n "$branch" ]; then
  printf " ${BLUE}git:(${RED}%s${BLUE})${RESET}" "$branch"
  if [ -n "$dirty" ]; then
    printf " ${YELLOW}✗${RESET}"
  fi
fi

# Model
if [ -n "$model" ]; then
  printf " %s" "$model"
fi

# Context remaining
if [ -n "$remaining" ]; then
  printf " ctx:%.0f%%" "$remaining"
fi

printf '\n'
