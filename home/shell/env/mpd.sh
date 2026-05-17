#!/usr/bin/env bash

[[ $(command -v mpc) ]] &&
    [[ $(pidof mpd) ]] &&
    [[ ! $(mpc current) ]] &&
    mpc searchplay filename "$(mpc listall | shuf -n 1)" &>/dev/null &&
    mpc pause &>/dev/null
