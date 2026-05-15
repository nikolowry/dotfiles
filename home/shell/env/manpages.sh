#!/usr/bin/env bash

export MANROFFOPT='-c'

LESS_TERMCAP_mb=$(
    tput bold
    tput setaf 2
)
LESS_TERMCAP_md=$(
    tput bold
    tput setaf 6
)
LESS_TERMCAP_me=$(tput sgr0)

export LESS_TERMCAP_mb
export LESS_TERMCAP_md
export LESS_TERMCAP_me
