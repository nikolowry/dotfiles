#!/usr/bin/env bash

[[ -d "$HOME/.config/composer/vendor/bin" ]] &&
    env-path add "$HOME/.config/composer/vendor/bin" -t
