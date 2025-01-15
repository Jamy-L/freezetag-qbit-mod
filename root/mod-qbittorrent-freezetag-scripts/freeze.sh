#!/bin/bash

# Read FREEZE_CATEGORY from the environment, default to an empty string if not set
FREEZE_CATEGORY="${FREEZE_CATEGORY:-}"
DOCKER_MODS_DEBUG="${DOCKER_MODS_DEBUG:-false}"

# Function for logging with timestamps
log() {
    local message="$1"
    echo "$(date '+%m/%d/%y %H:%M:%S') [Freezetag] - $message"
}

# Function for debug logging
debug_log() {
    if [[ "$DOCKER_MODS_DEBUG" == "true" ]]; then
        log "$1"
    fi
}

# Main script logic
if [[ $# -ne 2 ]]; then
    log "ERROR: Invalid usage. Expected <torrent_category> and <torrent_path>."
    log "Usage: $0 <torrent_category> <torrent_path>"
    exit 1
fi

category="$1"
torrent_path="$2"

debug_log "Script executed with arguments: $*"

# Log if FREEZE_CATEGORY is empty
if [[ -z "$FREEZE_CATEGORY" ]]; then
    log "WARNING: FREEZE_CATEGORY is empty. No categories will be processed."
    exit 0
fi

# Check if the category matches FREEZE_CATEGORY
if [[ "$category" == "$FREEZE_CATEGORY" ]]; then
    debug_log "Category '$category' matches FREEZE_CATEGORY. Freezing torrent data..."
    freezetag freeze "$torrent_path"
    debug_log "Freeze operation completed for path: $torrent_path."
else
    debug_log "Category '$category' does NOT match FREEZE_CATEGORY. Skipping."
fi