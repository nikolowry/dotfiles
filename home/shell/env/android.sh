#!/usr/bin/env bash

# Arch Linux
if [[ -d /opt/android-sdk ]]; then
    export ANDROID_SDK_ROOT=/opt/android-sdk
    export ANDROID_HOME=$ANDROID_SDK_ROOT
# macOS
elif [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
    export ANDROID_HOME=$ANDROID_SDK_ROOT
fi

if [[ -n "$ANDROID_HOME" ]]; then
    env-path add "$ANDROID_HOME/platform-tools" -t
    env-path add "$ANDROID_HOME/tools" -t
    env-path add "$ANDROID_HOME/tools/bin" -t
fi
