#!/usr/bin/env bash

[[ $(pidof mpd) ]] &&
    [[ $(command -v mpc) ]] &&
    [[ ! $(mpc current) ]] &&
    mpc searchplay filename "$(mpc listall | shuf -n 1)" &>/dev/null &&
    mpc pause &>/dev/null
