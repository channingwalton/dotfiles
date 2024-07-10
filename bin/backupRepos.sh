#!/bin/bash
set -e

# Stop and start this as a launch daemon in ~/Library/LaunchAgents
# launchctl load -w ~/Library/LaunchDaemons/org.channing.repos.plist

echo "Repo backup starting at $(date)"

export HOME_DIR=/Users/channing
export DOCUMENTS=$HOME_DIR/Documents
export ARCHIVE=$DOCUMENTS/Archive/Code/git

# GIT mirrors created with git clone --mirror https://github.com/lancewalton/treelog.git
# to see what dir is being processed, put the following before the -exec: -exec echo {} \;
find ${ARCHIVE} -name "*.git" -type d -exec $HOME_DIR/.nix-profile/bin/git -C {} remote update \;

# finished
echo "Repo backup Complete at $(date)"
