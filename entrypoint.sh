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


mkdir -p $DSP_INSTALL_PATH/BepInEx/config
for f in $HOME/config/*
do
    cat $f | envsubst > $DSP_INSTALL_PATH/BepInEx/config/${f##*/}
done

xvfb-run wine "$DSP_INSTALL_PATH/DSPGAME.exe" $LAUNCH_ARGS -load-latest