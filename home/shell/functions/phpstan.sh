#!/usr/bin/env bash

phpstan() {
    local local_bin
    local_bin=$(find_up "vendor/bin/phpstan")

    if [ -n "$local_bin" ]; then
        "$local_bin" "$@"
    else
        command phpstan "$@"
    fi
}
