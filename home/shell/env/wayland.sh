#!/usr/bin/env bash

[[ $XDG_SESSION_TYPE == wayland ]] &&
    export QT_QPA_PLATFORM=wayland &&
    export MOZ_ENABLE_WAYLAND=1
