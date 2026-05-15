#!/usr/bin/env bash

command -v bat &>/dev/null &&
    alias cat="bat"

command -v lazygit &>/dev/null &&
    alias lg="lazygit"

command -v exa &>/dev/null &&
    alias ls="exa --group-directories-first"

command -v nvim &>/dev/null &&
    alias vim="nvim"
