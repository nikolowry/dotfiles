#!/usr/bin/env bash

# Helper function to climb the directory tree looking for a specific path
find_up() {
    local dir="$PWD"
    local target="$1"

    # Keep looping until we hit the system root directory
    while [ "$dir" != "/" ]; do
        # If the file exists and is executable (-x), echo the path and exit
        if [ -x "$dir/$target" ]; then
            echo "$dir/$target"
            return 0
        fi
        # Go up one directory level
        dir="$(dirname "$dir")"
    done

    return 1
}
