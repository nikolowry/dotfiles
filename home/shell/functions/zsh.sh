#!/usr/bin/env bash

zsh() {
    if [[ $1 == "reload" ]]; then
        source "$HOME/.zshrc"
    else
        command zsh "$@"
    fi
}
