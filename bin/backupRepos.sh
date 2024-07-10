#!/bin/bash
set -e

echo "Repo backup starting at $(date)"

export DOCUMENTS=$HOME_DIR/Documents
export ARCHIVE=$DOCUMENTS/Archive/Code/git

# GIT mirrors created with git clone --mirror https://github.com/lancewalton/treelog.git
# to see what dir is being processed, put the following before the -exec: -exec echo {} \;
find ${ARCHIVE} -name "*.git" -type d -exec $HOME/.nix-profile/bin/git -C {} remote update \;

echo "Repo backup Complete at $(date)"
