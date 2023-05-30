#!/bin/bash

set -e

# Installation Script
# Modified from https://raw.githubusercontent.com/AlienXAXS/DSPNebulaDocker/main/scripts/Install%20Script.sh

BEPINEX_PLUGINS=("nebula/NebulaMultiplayerMod" "nebula/NebulaMultiplayerModApi" "PhantomGamers/IlLine" "CommonAPI/CommonAPI" "starfi5h/BulletTime" "xiaoye97/LDBTool" "CommonAPI/DSPModSave")

if [[ ! -z "$ADDITIONAL_PLUGINS" ]]
then
    readarray -t -d ";" tmpArray < <(printf $ADDITIONAL_PLUGINS)
    BEPINEX_PLUGINS+=( "${tmpArray[@]}" )
fi

tmpMsg=""
for i in ${BEPINEX_PLUGINS[@]}; do
    tmpMsg+="$i,"
done

echo "Will download the following plugins: $tmpMsg"

rm -rf $DSP_INSTALL_PATH/BepInEx

## Install BepInEx from GitHub
cd $DSP_INSTALL_PATH

LATEST_JSON=$(curl --silent "https://api.github.com/repos/BepInEx/BepInEx/releases/latest")
DOWNLOAD_LINK=$(echo ${LATEST_JSON} | jq .assets | jq -r .[].browser_download_url | grep -i x64)
FILE_NAME=$(echo "${DOWNLOAD_LINK##*/}")
echo "## Attempting to download BepInEx from $DOWNLOAD_LINK"
curl -OL $DOWNLOAD_LINK > /dev/null
echo "## Installing BepInEx"
unzip -o "./$FILE_NAME" > /dev/null
echo "##   -> Done"
rm -fR $FILE_NAME
mkdir -p $DSP_INSTALL_PATH/BepInEx/plugins
mkdir -p $DSP_INSTALL_PATH/BepInEx/patchers

#Download Required Mods
echo "## Downloading BepInEx Plugins..."
mkdir -p $HOME/temp
cd $HOME/temp

for i in ${BEPINEX_PLUGINS[@]}; do
    TS_ASSET=$(curl --silent "https://dsp.thunderstore.io/api/experimental/package/$i/")
    TS_ASSET_VERSION=$(echo $TS_ASSET | jq .latest.version_number | sed 's/"//g')
    TS_ASSET_NAME=$(echo $TS_ASSET | jq .name | sed 's/"//g')
    TS_DL_URL=$(echo $TS_ASSET | jq .latest.download_url | sed 's/"//g')
    echo "## Attempting to download $TS_ASSET_NAME v$TS_ASSET_VERSION from Thunderstore.io"
    curl -L $TS_DL_URL --output "$TS_ASSET_NAME.zip" 2> /dev/null
    
    echo "## Extracting $TS_ASSET_NAME.zip"
    mkdir -p "$HOME/temp/$TS_ASSET_NAME"
    unzip -o "./$TS_ASSET_NAME.zip" -d "$HOME/temp/$TS_ASSET_NAME" > /dev/null
    rm -fR "./$TS_ASSET_NAME.zip"
    
    # Check for a "plugins" or "patchers" sub directory.
    CWD="$HOME/temp/$TS_ASSET_NAME"
    echo "##  -> Installing"
    if [ -d "$CWD/plugins" ]
    then
        mkdir -p "$DSP_INSTALL_PATH/BepInEx/plugins/$TS_ASSET_NAME"
        cp -fr $CWD/plugins/* "$DSP_INSTALL_PATH/BepInEx/plugins/$TS_ASSET_NAME/"
    else
        cp -fr $CWD $DSP_INSTALL_PATH/BepInEx/plugins
    fi
    
    if [ -d "$CWD/patchers" ]
    then
        echo "##  -> Installing Patcher"
        mkdir -p "$DSP_INSTALL_PATH/BepInEx/patchers/$TS_ASSET_NAME"
        cp -fr $CWD/patchers/* "$DSP_INSTALL_PATH/BepInEx/patchers/$TS_ASSET_NAME/"
    fi
    
    echo "##  -> Done"
done

rm -rf $HOME/temp

echo "## MOD INSTALL COMPLETE"