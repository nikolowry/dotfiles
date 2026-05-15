#!/usr/bin/env bash

[[ -e /usr/lib/dri/iHD_drv_video.so ]] &&
    export LIBVA_DRIVERS_PATH=/usr/lib/dri &&
    export LIBVA_DRIVER_NAME=iHD
