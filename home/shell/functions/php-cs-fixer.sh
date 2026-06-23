#!/usr/bin/env bash

php-cs-fixer() {
    local local_bin
    local_bin=$(find_up "vendor/bin/php-cs-fixer")

    if [ -n "$local_bin" ]; then
        "$local_bin" "$@"
    else
        command php-cs-fixer "$@"
    fi
}
