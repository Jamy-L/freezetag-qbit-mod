#!/bin/bash

# Read FREEZE_CATEGORY from the environment, default to an empty string if not set
FREEZE_CATEGORY="${FREEZE_CATEGORY:-}"
DOCKER_MODS_DEBUG="${DOCKER_MODS_DEBUG:-false}"
CATEGORY_UMASK="${CATEGORY_UMASK:-}"

# Function for logging with timestamps
log() {
    local message="$1"
    echo "[Freezetag] $(date '+%m/%d/%y %H:%M:%S') - $message"
}

# Function for debug logging
debug_log() {
    if [[ "$DOCKER_MODS_DEBUG" == "true" ]]; then
        echo "[Freezetag] (DEBUG) $(date '+%m/%d/%y %H:%M:%S') - $message"
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

# Function to set permissions according to the umask for files that don't have .ftag extension
set_permissions() {
    if [ -d "$1" ]; then # If it's a directory, recursively process it
        for item in "$1"/*; do
            [ -e "$item" ] || continue # Skip in case of empty directories
            set_permissions "$item"
        done
    elif [ -f "$1" ] && [[ "$1" != *.ftag ]]; then # Set permission for all files but not .ftag 
        chmod $(stat --format '%a' "$1") "$1"
    fi
}

# Check if the category matches FREEZE_CATEGORY
if [[ "$category" == "$FREEZE_CATEGORY" ]]; then
    debug_log "Category '$category' matches FREEZE_CATEGORY $FREEZE_CATEGORY. Freezing torrent data..."
    freezetag freeze "$torrent_path"
    debug_log "Freeze operation completed for path: $torrent_path."


    # Set the umask for the category if specified
    if [[ -n "$CATEGORY_UMASK" ]]; then
        CURRENT_UMASK=$(umask)

        debug_log "Setting umask $CATEGORY_UMASK for path: $torrent_path."

        umask "$CATEGORY_UMASK" 
        
        # Recursively find files and apply the set_permissions function
        export -f set_permissions
        find "$torrent_path" -type f -exec bash -c 'set_permissions "$0"' {} \;
        
        umask "$CURRENT_UMASK" # Restore the original umask
        debug_log "Restored the original umask: $CURRENT_UMASK."
    fi


else
    debug_log "Category '$category' does NOT match FREEZE_CATEGORY $FREEZE_CATEGORY. Skipping."
fi