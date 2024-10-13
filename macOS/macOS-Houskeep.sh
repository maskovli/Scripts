#!/bin/bash

# Housekeeping script for macOS with Progress Indicators
# Author: Marius
# Ensure this script is executable with: chmod +x script_name.sh

# Define total number of tasks
TOTAL_TASKS=7
CURRENT_TASK=0

increment_progress() {
  CURRENT_TASK=$((CURRENT_TASK + 1))
  PERCENT=$((CURRENT_TASK * 100 / TOTAL_TASKS))
  echo "Progress: $PERCENT% completed."
}

# Ensure 'pv' is installed
if ! command -v pv &> /dev/null; then
    echo "The 'pv' utility is not installed. Installing it now..."
    brew install pv
fi

# Clear user-level caches
echo "Clearing user caches..."
CACHE_FILES=$(find ~/Library/Caches/* | wc -l)
if [ "$CACHE_FILES" -gt 0 ]; then
  find ~/Library/Caches/* | pv -lep -s $CACHE_FILES | xargs rm -rf
else
  echo "No cache files found."
fi
increment_progress

# Clear user application logs
echo "Clearing user application logs..."
LOG_FILES=$(find ~/Library/Logs/* | wc -l)
if [ "$LOG_FILES" -gt 0 ]; then
  find ~/Library/Logs/* | pv -lep -s $LOG_FILES | xargs rm -rf
else
  echo "No log files found."
fi
increment_progress

# Remove user temporary files
echo "Removing user temporary files..."
TEMP_FILES=$(find ~/Library/Application\ Support/Caches/* | wc -l)
if [ "$TEMP_FILES" -gt 0 ]; then
  find ~/Library/Application\ Support/Caches/* | pv -lep -s $TEMP_FILES | xargs rm -rf
else
  echo "No temporary files found."
fi
increment_progress

# Clear DNS cache
echo "Flushing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
increment_progress

# Rebuild Spotlight index (optional, remove if unnecessary)
echo "Rebuilding Spotlight index..."
sudo mdutil -E /
increment_progress

# Run periodic system maintenance scripts
echo "Running periodic maintenance scripts..."
sudo periodic daily weekly monthly
increment_progress

echo "Housekeeping completed!"
increment_progress

echo "All tasks completed. It is recommended to restart your Mac."
