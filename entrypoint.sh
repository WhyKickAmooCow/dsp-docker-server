#!/bin/bash

set -e

if [ ! -f "$DSP_INSTALL_PATH/DSPGAME.exe" ]
then
    install-dsp
fi

if [ "$1" = "update" ]
then
    install-dsp update
fi

xvfb-run wine "$DSP_INSTALL_PATH/DSPGAME.exe" $LAUNCH_ARGS -load-latest