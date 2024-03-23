#!/usr/bin/env nu

let bepinex_plugins = [
                                    "nebula/NebulaMultiplayerMod", 
                                    "nebula/NebulaMultiplayerModApi",
                                    "PhantomGamers/IlLine",
                                    "CommonAPI/CommonAPI",
                                    "starfi5h/BulletTime",
                                    "xiaoye97/LDBTool",
                                    "CommonAPI/DSPModSave"
                                    ]

def safe_get [list, index: int, default: any = null] {
    if ($list | length) > $index {
        return ($list | get $index)
    } else {
        return $default
    }
}

def main [...args] {
    match (safe_get $args 0) {
        "update" => {
            install_game (safe_get $args 1) (safe_get $args 2) (safe_get $args 3)
            install_mods $bepinex_plugins
        },
        "update_mods" => {
            install_mods $bepinex_plugins
        },
        _ => {
            # if (($"($env.DSP_INSTALL_PATH)/DSPGAME.exe" | path exists) and ($args | length) > 0) {
            #     error make {msg: $"Unknown argument ($args.0)"}
            # } else {
            install_game (safe_get $args 0 "") (safe_get $args 1 "") (safe_get $args 2 "")
            install_mods $bepinex_plugins
            # }
        } 
    }

    run_game
}

def install_game [username: string, password: string, code: string] {
    if ($username | is-empty) {
        error make{msg: "You are required to provide a steam login that owns Dyson Sphere Program"}
    }

    steamcmd +force_install_dir $env.DSP_INSTALL_PATH +login $username $password $code +@sSteamCmdForcePlatformType windows +app_update 1366540 validate +quit

    rm -f $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_api64.dll"
    curl -s -L "https://gitlab.com/Mr_Goldberg/goldberg_emulator/-/jobs/2987292049/artifacts/raw/steam_api64.dll" -o $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_api64.dll"

    mkdir $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_settings"
    touch $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_settings/disable_networking.txt"

    "1366540" | save -f $"($env.DSP_INSTALL_PATH)/steam_appid.txt"
}

def install_bepinex [] {
    rm -rf $"($env.DSP_INSTALL_PATH)/BepInEx"
    cd $env.DSP_INSTALL_PATH

    let latest_json = (http get https://api.github.com/repos/BepInEx/BepInEx/releases/latest).content | from json
    let asset = $latest_json.assets | where name =~ ^BepInEx_x86

    curl -s -OL $asset.browser_download_url
    unzip -qq -o $asset.name
}

def install_mods [mods: list<string>] {
    "Installing Mods:"

    for mod in $mods {
        echo $"- ($mod)"
    }

    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/plugins"
    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/patchers"

    mkdir /tmp/dsp-mods

    for mod in $mods {
        cd /tmp/dsp-mods

        let asset = http get $"https://thunderstore.io/api/experimental/package/($mod)/"
        
        curl -s -L $asset.latest.download_url -o $"($asset.name).zip"
        mkdir $asset.name
        unzip -qq -o $"($asset.name).zip" -d $asset.name
        rm -rf $"($asset.name).zip"

        cd $asset.name

        if ("./plugins" | path exists) {
            mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/($asset.name)"
            cp -rf ./plugins/* $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/($asset.name)"
        } else {
            cp -rf ./ $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/"
        }

        if ("patchers" | path exists) {
            mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/patchers/($asset.name)"
            cp -rf ./patchers/* $"($env.DSP_INSTALL_PATH)/BepInEx/patchers/($asset.name)/"
        }
    }
}


def run_game [] {
    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/config"

    for file in (ls /config/) {
        open --raw $file.name | envsubst | save $"($env.DSP_INSTALL_PATH)/BepInEx/config/($file.name | path basename)"
    }

    mut save = -load-latest
    if (ls /save | length)  == 0 {
        mut seed = []

        for i in 0..8 {
            $seed ++= (random int 0..9)
        }

        $save = $"-newgame ($seed | str join) ($env.STAR_COUNT) ($env.RESOURCE_MUTLIPLIER)"
    }

    xvfb-run wine $"($env.DSP_INSTALL_PATH)/DSPGAME.exe" $env.LAUNCH_ARGS $save
}