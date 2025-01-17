#!/bin/bash

# Function for logging with timestamps
log() {
    echo "[Freezetag] $(date '+%m/%d/%y %H:%M:%S') $1" >&2
}

# Function for debug logging
debug_log() {
    if [[ "$DOCKER_MODS_DEBUG" == "true" ]]; then
        echo "[Freezetag] DEBUG: $(date '+%m/%d/%y %H:%M:%S') $1" >&2
    fi
}

# Read FREEZE_CATEGORY from the environment, default to an empty string if not set
CATEGORY="${FTAG_DL_CATEGORY:-}"
DOCKER_MODS_DEBUG="${DOCKER_MODS_DEBUG:-false}"
UMASK="${FTAG_UMASK:-}"


# Main script logic
if [[ $# -ne 2 ]]; then
    log "ERROR: Invalid usage. Expected <torrent_category> and <torrent_path>."
    log "Usage: $0 <torrent_category> <torrent_path>"
    exit 1
fi

category="$1"
torrent_path="$2"

debug_log "Script executed with arguments: $*"

# Log if CATEGORY is empty
if [[ -z "$CATEGORY" ]]; then
    log "WARNING: FREEZE_CATEGORY is empty. No categories will be processed."
    exit 0
fi

# Function to set permissions according to the umask for files that don't have .ftag extension
set_permissions() {
    if [ -d "$1" ]; then # If it's a directory, process all files inside it
        for item in "$1"/*; do
            [ -e "$item" ] || continue # Skip in case of empty directories
            set_permissions "$item"  # Recursively process subdirectories
        done

        # Default permissions for directories is 777
        default_permissions=777
        final_permissions=$((default_permissions & ~UMASK))
        chmod $final_permissions "$1"
        debug_log "Applied umask to directory: $1 with permissions $final_permissions"

    elif [ -f "$1" ] && [[ "$1" != *.ftag ]]; then # Process files (but not .ftag)
        # Default permissions for files is 666
        default_permissions=666
        final_permissions=$((default_permissions & ~UMASK))
        chmod $final_permissions "$1"
        debug_log "Applied umask to file: $1 with permissions $final_permissions"
    fi
}


# Check if the category matches CATEGORY
if [[ "$category" == "$CATEGORY" ]]; then
    debug_log "Category '$category' matches FTAG_CATEGORY $CATEGORY. Freezing torrent data..."
    freezetag freeze "$torrent_path"
    debug_log "Freeze operation completed for path: $torrent_path."


    # Set the umask for the category if specified
    if [[ -n "$CUMASK" ]]; then
        debug_log "Setting umask $UMASK for path: $torrent_path."

        # Recursively find files and apply the set_permissions function
        export -f set_permissions
        export -f debug_log
        find "$torrent_path" -type f -exec bash -c 'set_permissions "$0"' {} \;
    fi


else
    debug_log "Category '$category' does NOT match FTAG_CATEGORY $CATEGORY. Skipping."
fi