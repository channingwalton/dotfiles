#!/usr/bin/env bash

# Stop and start this as a launch daemon in /Library/LaunchDaemons
# sudo launchctl load -w /System/Library/LaunchDaemons/org.channing.mirror.plist

echo "Running mirror..."
 
RSYNC="/opt/homebrew/bin/rsync"
INCLUDE="/Users/channing/dotfiles/bin/mirror.include"

# rsync options
# -v increase verbosity
# -a turns on archive mode (recursive copy + retain attributes)
# -r still needed because files-from is being used
# -x don't cross device boundaries (ignore mounted volumes)
# -E preserve executability
# -S handle spare files efficiently
# --delete deletes any files that have been deleted locally
# --exclude-from reference a list of files to exclude
# -n dry-run 

echo "Start rsync $(date)"

echo "Channing"
echo "Checking for unfriendly files ..."
find /Users/channing/Documents -name '*[<>:"/\\|?*]*'
find /Users/channing/Pictures -name '*[<>:"/\\|?*]*'
find /Users/channing/Dropbox -name '*[<>:"/\\|?*]*'

$RSYNC -arRxE -S --timeout=3600 --human-readable --force --delete-excluded --delete --prune-empty-dirs --files-from="${INCLUDE}" "/Users/channing/" "192.168.1.2::Mirror/channing"

echo "Shireen"
echo "Checking for unfriendly files ..."
find /Users/Shireen/Desktop -name '*[<>:"/\\|?*]*'
find /Users/Shireen/Documents -name '*[<>:"/\\|?*]*'

$RSYNC -arRxEz -S --timeout=3600 --human-readable --force --delete-excluded --delete --prune-empty-dirs --files-from="${INCLUDE}" "/Users/shireen/" "192.168.1.2::Mirror/shireen"

echo "Angelica"
echo "Checking for unfriendly files ..."
find /Users/Angelica/Desktop -name '*[<>:"/\\|?*]*'
find /Users/Angelica/Documents -name '*[<>:"/\\|?*]*'

$RSYNC -arRxEz -S --timeout=3600 --human-readable --force --delete-excluded --delete --prune-empty-dirs --files-from="${INCLUDE}" "/Users/angelica/" "192.168.1.2::Mirror/angelica"

echo "Jeanette"
echo "Checking for unfriendly files ..."
find /Users/jeanette/Desktop -name '*[<>:"/\\|?*]*'
find /Users/jeanette/Documents -name '*[<>:"/\\|?*]*'

$RSYNC -arRxEz -S --timeout=3600 --human-readable --force --delete-excluded --delete --prune-empty-dirs --files-from="${INCLUDE}" "/Users/jeanette/" "192.168.1.2::Mirror/jeanette"
 
echo "End rsync $(date)"
  
exit 0
