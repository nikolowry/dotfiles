#!/usr/bin/env bash

export SAL_USE_VCLPLUGIN=gtk4

# Arch Linux
if command -v archlinux-java &>/dev/null; then
    JAVA_HOME="/usr/lib/jvm/$(archlinux-java get)"
    export JAVA_HOME
    env-path add "$JAVA_HOME/bin" -t
elif [[ -e /usr/lib/jvm/default ]]; then
    JAVA_HOME=$(realpath /usr/lib/jvm/default)
    export JAVA_HOME
    env-path add "$JAVA_HOME/bin" -t
# macOS Homebrew
elif [[ -d "/opt/homebrew/opt/openjdk" ]]; then
    export JAVA_HOME="/opt/homebrew/opt/openjdk"
    env-path add "$JAVA_HOME/bin" -t
fi
