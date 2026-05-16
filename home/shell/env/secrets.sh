#!/usr/bin/env bash

# Load machine-specific secrets if the file exists
# shellcheck source=/dev/null
[[ -f "$HOME/.env.secrets" ]] &&
    source "$HOME/.env.secrets"
