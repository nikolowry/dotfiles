#!/usr/bin/env bash

[[ $(command -v go) ]] &&
    export GOPATH=$HOME/.go &&
    env-path add "$GOPATH" -t
