#!/bin/bash

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

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

BEPINEX_PLUGINS=("nebula/NebulaMultiplayerMod" "nebula/NebulaMultiplayerModApi" "PhantomGamers/IlLine" "CommonAPI/CommonAPI" "starfi5h/BulletTime" "xiaoye97/LDBTool" "CommonAPI/DSPModSave")

if [[ ! -z "$ADDITIONAL_PLUGINS" ]]
then
    read -a tmpArray <<< $ADDITIONAL_PLUGINS
    BEPINEX_PLUGINS=("${BEPINEX_PLUGINS[@]}" "${tmpArray[@]}")
fi

tmpMsg=""
for i in ${!BEPINEX_PLUGINS[@]}; do
    tmpMsg+="${BEPINEX_PLUGINS[$i]},"
done

echo "Will download the following plugins: $tmpMsg"

## Check if SteamGuard is enabled
if [ -z ${STEAM_PASS} ]
then
    echo -e "[${Red}ERROR${Color_Off}] You are required to provide a steam login that owns Dyson Sphere Program."
    exit 1
fi

if [ "${STEAM_AUTH}" == "" ]
then
    STEAM_AUTH="123456abcdef"
fi

echo -e "[${Green}Steam Guard Checker${Color_Off}] Checking if the account has Steam Guard, please wait..."
if [[ -z "${HOME}/SGC_Stage1" ]]
then
    rm -f ${HOME}/SGC_Stage1
    echo -e "[${Green}Steam Guard Checker${Color_Off}] Removed previous SGC_Stage1"
fi
steamcmd +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +log_files_always_flush 1 +@ShutdownOnFailedCommand 1 +quit 2>&1 > ${HOME}/SGC_Stage1
LastExitState=$?
LastExitMessage=$(tail -1 "${HOME}/SGC_Stage1" | cut -d "(" -f2)
LastExitMessage=${LastExitMessage::-1}

if ! [ $LastExitState -eq 0 ]
then
    case $LastExitMessage in
        "Invalid Password")
            echo -e "[${Green}Steam Guard Checker${Color_Off}] ${Red}Fatal Error!${Color_Off}"
            echo -e "[${Green}Steam Guard Checker${Color_Off}] ${Red}Invalid Steam Login Credentials!${Color_Off}"
            exit 1
            ;;
        
        "Invalid Login Auth Code")
            echo -e "[${Green}Steam Guard Checker${Color_Off}] ${Red}Your account has Steam Guard!${Color_Off}"
            ;;
        
        *)
            echo -e "[${Green}Steam Guard Checker${Color_Off}] ${Red}Fatal Error - Got unknown response from SteamCMD${Color_Off}"
            echo -e "[${Green}Steam Guard Checker${Color_Off}] ${Red}Response: ${LastExitMessage}, Report this to the script developer.${Color_Off}"
            exit 1
            ;;
    esac
fi

if [ $LastExitState -eq 5 ] && [ "$LastExitMessage" == "Invalid Login Auth Code" ]
then
    echo -e "[${Green}Steam Guard Checker${Color_Off}] Generating Steam Guard Key for account ${STEAM_USER}!"
    if [[ -z "${HOME}/SGC_Stage2" ]]
    then
        rm -f ${HOME}/SGC_Stage2
        echo -e "[${Green}Steam Guard Checker${Color_Off}] Removed previous SGC_Stage2"
    fi
    steamcmd +login ${STEAM_USER} ${STEAM_PASS} +log_files_always_flush 1 +@ShutdownOnFailedCommand 1 +quit 2>&1 > ${HOME}/SGC_Stage2 &
    
    WaitingForSteamCMD=0
    echo -e "[${Green}Steam Guard Checker${Color_Off}] Waiting for key to generate...!"
    while [ $WaitingForSteamCMD -le 10 ]
    do
        if grep -q "Steam Guard" "${HOME}/SGC_Stage2"; then
            echo -e "[${Green}Steam Guard Checker${Color_Off}] Key Generated - Check your emails!"
            break
        fi
        sleep 1
        ((WaitingForSteamCMD++))
    done
    
    #killall steamcmd 2>&1 > /dev/null
    #echo -e "[${Green}Steam Guard Checker${Color_Off}] SteamCMD Process Terminated!"
    
    if [ ${WaitingForSteamCMD} == 10 ]
    then
        echo -e "[${Red}ERROR${Color_Off}] Operation timed out waiting for SteamCMD to generate an auth token."
        exit 1
    fi
else
    echo -e "[${Green}Steam Guard Checker${Color_Off}] Success: Steam Guard Checks Passed!"
fi

## install game using steamcmd
steamcmd +force_install_dir $DSP_INSTALL_PATH +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +@sSteamCmdForcePlatformType windows +app_update 1366540 validate +quit

## Install Goldberg Steam Emu
echo "## Installing Goldberg Steam Emu"
rm -f $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_api64.dll
curl -L "https://gitlab.com/Mr_Goldberg/goldberg_emulator/-/jobs/2987292049/artifacts/raw/steam_api64.dll" --output "$DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_api64.dll" 2> /dev/null
echo "##  -> Applying Settings"
mkdir -p $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_settings
touch $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_settings/disable_networking.txt
echo "1366540" > $DSP_INSTALL_PATH/DSPGAME_Data/Plugins/steam_appid.txt
echo "##  -> Done"

## Install BepInEx from GitHub
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
mkdir -p $DSP_INSTALL_PATH/temp
cd $DSP_INSTALL_PATH/temp
for i in ${!BEPINEX_PLUGINS[@]}; do
    TS_ASSET=$(curl --silent "https://dsp.thunderstore.io/api/experimental/package/${BEPINEX_PLUGINS[$i]}/")
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

mkdir -p $HOME/Dyson\ Sphere\ Program/Achievement
mkdir -p $HOME/Dyson\ Sphere\ Program/Blueprint
mkdir -p $HOME/Dyson\ Sphere\ Program/Save

rm -rf $HOME/temp

echo "## INSTALL COMPLETE"