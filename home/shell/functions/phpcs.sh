#!/usr/bin/env bash

# The Golden PHPCS Wrapper
phpcs() {
    local local_bin
    local_bin=$(find_up "vendor/bin/phpcs")

    if [ -n "$local_bin" ]; then
        # Found it locally! Run the project binary.
        "$local_bin" "$@"
    else
        # Not in a project. Fall back to the global binary.
        command phpcs "$@"
    fi
}
