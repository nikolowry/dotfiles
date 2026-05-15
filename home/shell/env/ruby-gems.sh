#!/usr/bin/env bash

[[ $(command -v gem) ]] &&
    GEM_PATH=$(gem environment |
        grep 'USER INSTALLATION DIRECTORY:' |
        sed -e 's|^.*:\s*||g') &&
    env-path add "$GEM_PATH/bin" -t
