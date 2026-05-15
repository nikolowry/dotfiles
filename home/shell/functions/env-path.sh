#!/usr/bin/env bash

env-path() {
    [[ ! $2 ]] && return

    PATH_PREV=$(echo $PATH | sed "s|${2}:||g" |
        sed "s|${2}||g" |
        sed "s|^:||g" |
        sed "s|:$||g")

    if [[ $1 == "add" ]]; then
        #Check to see if flag pased to add to tail or start of path
        if [[ $3 == "-t" ]] || [[ $3 == "--tail" ]]; then
            export PATH=$PATH_PREV:$2
        else
            export PATH=$2:$PATH_PREV
        fi
    fi

    if [[ $1 == "remove" ]]; then
        export PATH=$PATH_PREV
    fi
}
