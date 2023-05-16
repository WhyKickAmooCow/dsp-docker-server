#!/bin/bash

set -e

if [ ! -f "$DSP_INSTALL_PATH/DSPGAME.exe" ]
then
    install-dsp
elif [ "$1" != "" ]
then
    case "$1" in
        update)
            install-dsp update
            ;;
        update_mods)
            install-mods
            ;;
        *)
            echo "Unknown argument $1"
            exit 1
            ;;
    esac
fi

mkdir -p $DSP_INSTALL_PATH/BepInEx/config
for f in /config/*
do
    cat $f | envsubst > $DSP_INSTALL_PATH/BepInEx/config/${f##*/}
done

if [ ! -f "/save/_lastexit_.dsv" ]
then
    if [ -z ${SEED} ]
    then
        SEED=$(shuf -i 0-99999999 -n 1)
    fi

    SAVE="-newgame $SEED $STAR_COUNT $RESOURCE_MUTLIPLIER"
else
    SAVE=-load-latest
fi

xvfb-run wine "$DSP_INSTALL_PATH/DSPGAME.exe" $LAUNCH_ARGS $SAVE