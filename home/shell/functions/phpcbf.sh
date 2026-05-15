#!/usr/bin/env bash

# The Golden PHPCBF Wrapper
phpcbf() {
    local local_bin
    local_bin=$(find_up "vendor/bin/phpcbf")

    if [ -n "$local_bin" ]; then
        "$local_bin" "$@"
    else
        command phpcbf "$@"
    fi
}
