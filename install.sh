#!/bin/bash

set -e

# Installation Script
# Modified from https://raw.githubusercontent.com/AlienXAXS/DSPNebulaDocker/main/scripts/Install%20Script.sh
## Define variables

# Reset
Color_Off='\033[0m'       # Text Reset;

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Check if SteamGuard is enabled
if [ -z "$1" ]
then
    echo -e "[${Red}ERROR${Color_Off}] You are required to provide a steam login that owns Dyson Sphere Program."
    exit 1
fi

## install game using steamcmd
steamcmd +force_install_dir $DSP_INSTALL_PATH +login $1 $2 $3 +@sSteamCmdForcePlatformType windows +app_update 1366540 validate +quit

## Install Goldberg Steam Emu
echo "## Installing Goldberg Steam Emu"
rm -f $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_api64.dll
curl -s -L "https://gitlab.com/Mr_Goldberg/goldberg_emulator/-/jobs/2987292049/artifacts/raw/steam_api64.dll" -o "$DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_api64.dll"
echo "##  -> Applying Settings"
mkdir -p $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_settings
touch $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_settings/disable_networking.txt
echo "1366540" > $DSP_INSTALL_PATH/steam_appid.txt
echo "##  -> Done"

echo "## GAME INSTALL COMPLETE"

install-mods