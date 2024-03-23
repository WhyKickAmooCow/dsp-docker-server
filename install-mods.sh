#!/bin/bash

set -e

# Installation Script
# Modified from https://raw.githubusercontent.com/AlienXAXS/DSPNebulaDocker/main/scripts/Install%20Script.sh

BEPINEX_PLUGINS=("nebula/NebulaMultiplayerMod" "nebula/NebulaMultiplayerModApi" "PhantomGamers/IlLine" "CommonAPI/CommonAPI" "starfi5h/BulletTime" "xiaoye97/LDBTool" "CommonAPI/DSPModSave")

if [[ ! -z "$ADDITIONAL_PLUGINS" ]]
then
    readarray -t -d "," tmpArray < <(printf $ADDITIONAL_PLUGINS)
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
ASSET=$(echo ${LATEST_JSON} | jq '.assets[] | select(.name | test("^BepInEx_x86"))')
DOWNLOAD_LINK=$(echo ${ASSET} | jq '.browser_download_url')
FILE_NAME=$(echo "${ASSET}" | jq '.name')
echo "## Attempting to download BepInEx from $DOWNLOAD_LINK"
curl -s -OL $DOWNLOAD_LINK
echo "## Installing BepInEx"
unzip -qq -o "./$FILE_NAME"
echo "##   -> Done"
rm -rf $FILE_NAME
mkdir -p $DSP_INSTALL_PATH/BepInEx/plugins
mkdir -p $DSP_INSTALL_PATH/BepInEx/patchers

#Download Required Mods
echo "## Downloading BepInEx Plugins..."
mkdir -p $HOME/temp
cd $HOME/temp

for i in ${BEPINEX_PLUGINS[@]}; do
    TS_ASSET=$(curl --silent "https://thunderstore.io/api/experimental/package/$i/")
    TS_ASSET_VERSION=$(echo $TS_ASSET | jq -r .latest.version_number)
    TS_ASSET_NAME=$(echo $TS_ASSET | jq -r .name)
    TS_DL_URL=$(echo $TS_ASSET | jq -r .latest.download_url)
    echo "## Attempting to download $TS_ASSET_NAME v$TS_ASSET_VERSION from Thunderstore.io"
    curl -s -L $TS_DL_URL -o "$TS_ASSET_NAME.zip"
    
    echo "## Extracting $TS_ASSET_NAME.zip"
    mkdir -p "$HOME/temp/$TS_ASSET_NAME"
    unzip -qq -o "./$TS_ASSET_NAME.zip" -d "$HOME/temp/$TS_ASSET_NAME"
    rm -rf "./$TS_ASSET_NAME.zip"
    
    # Check for a "plugins" or "patchers" sub directory.
    CWD="$HOME/temp/$TS_ASSET_NAME"
    echo "##  -> Installing"
    if [ -d "$CWD/plugins" ]
    then
        mkdir -p "$DSP_INSTALL_PATH/BepInEx/plugins/$TS_ASSET_NAME"
        cp -rf $CWD/plugins/* "$DSP_INSTALL_PATH/BepInEx/plugins/$TS_ASSET_NAME/"
    else
        cp -rf $CWD $DSP_INSTALL_PATH/BepInEx/plugins
    fi
    
    if [ -d "$CWD/patchers" ]
    then
        echo "##  -> Installing Patcher"
        mkdir -p "$DSP_INSTALL_PATH/BepInEx/patchers/$TS_ASSET_NAME"
        cp -rf $CWD/patchers/* "$DSP_INSTALL_PATH/BepInEx/patchers/$TS_ASSET_NAME/"
    fi
    
    echo "##  -> Done"
done

rm -rf $HOME/temp

echo "## MOD INSTALL COMPLETE"