#!/usr/bin/env bash

# Arch Linux
if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
    unset NPM_CONFIG_PREFIX
    source /usr/share/nvm/init-nvm.sh
# macOS Homebrew
elif [[ -e /opt/homebrew/opt/nvm/nvm.sh ]]; then
    unset NPM_CONFIG_PREFIX
    source /opt/homebrew/opt/nvm/nvm.sh
fi
