#!/usr/bin/env bash

mkdir -p "$HOME/.npm"
export NPM_CONFIG_PREFIX=$HOME/.npm
env-path add "$HOME/.npm/bin"
