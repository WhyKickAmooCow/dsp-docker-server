#!/bin/bash

set -e

if [ ! -f "$DSP_INSTALL_PATH" ] || [ "$1" = "update" ]
then
    install-dsp
fi

xvfb-run wine ${INSTALL_PATH}/DSPGAME.exe ${LAUNCH_ARGS} -load-latest