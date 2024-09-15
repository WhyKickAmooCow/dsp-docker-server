#!/usr/bin/env nu

let bepinex_plugins = do {
    let required = $env.REQUIRED_PLUGINS | split row ',' | each {|plugin| modstring_to_record $plugin}
    let additional_plugins = $env.ADDITIONAL_PLUGINS?
    if $additional_plugins != null {
        print $additional_plugins
        $required ++ (($additional_plugins | split row ',') | each {|plugin| modstring_to_record $plugin})
    } else {
        $required
    }
}

def modstring_to_record [modstring: string] -> record<namespace: string, name: string, version: string> {
    let split = $modstring | split row '-'
    let retval = {namespace: $split.0, name: $split.1}
    if $split.2? != null {
        $retval | insert version $split.2
    } else {
        $retval
    }
}

def get_or_default [input, key, default: any = null] {
    if ($input | get -i $key) != null {
        $input | get $key
    } else {
        $default
    }
}

def main [...args] {
    match ($args.0?) {
        "update" => {
            install_game (get_or_default $args 1 "" | into string) (get_or_default $args 2 "" | into string) (get_or_default $args 3 "" | into string)
            install_mods $bepinex_plugins
        },
        "update_mods" => {
            install_mods $bepinex_plugins
        },
        _ => {
            if ($"($env.DSP_INSTALL_PATH)/DSPGAME.exe" | path exists) {
                if (echo $args | length) > 0 {
                    error make {msg: $"Unknown argument ($args.0)"}
                }
            } else {
                main update $args.0? $args.1? $args.2?
            }
        }
    }

    run_game
}

def install_game [username: string, password: string, code: string] {
    if ($username | is-empty) {
        error make {msg: "You are required to provide a steam login that owns Dyson Sphere Program"}
    }

    steamcmd +force_install_dir $env.DSP_INSTALL_PATH +login $username $password $code +@sSteamCmdForcePlatformType windows +app_update 1366540 validate +quit

    http get https://gitlab.com/Mr_Goldberg/goldberg_emulator/-/jobs/4247811307/artifacts/raw/release/steam_api64.dll | save -f $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_api64.dll"

    mkdir $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_settings"
    touch $"($env.DSP_INSTALL_PATH)/DSPGAME_Data/Plugins/steam_settings/disable_networking.txt"

    "1366540" | save -f $"($env.DSP_INSTALL_PATH)/steam_appid.txt"
}

def install_mods [mods] {
    print "Installing BepInEx"

    rm -rf $"($env.DSP_INSTALL_PATH)/BepInEx"

    cd $env.DSP_INSTALL_PATH
    let latest_json = http get https://api.github.com/repos/BepInEx/BepInEx/releases/latest
    let asset = $latest_json.assets | where name =~ ^BepInEx_win_x64 | first

    http get $asset.browser_download_url | save $asset.name
    unzip -qq -o $asset.name
    rm $asset.name

    print $"Installing Mods: ($mods)"

    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/plugins"
    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/patchers"

    mkdir /tmp/dsp-mods

    for mod in $mods {
        cd /tmp/dsp-mods

        print $"Installing ($mod):"
        
        let asset = http get https://thunderstore.io/api/experimental/package/($mod.namespace)/($mod.name)/($mod.version?)
        let version = if $mod.version? != null {$mod.version} else {$asset.latest.version_number}
        let download_url = if $mod.version? != null {$asset.download_url} else {$asset.latest.download_url}

        print $"Downloading ($asset.name):($version) from ($download_url)"

        http get $download_url | save $"($asset.name).zip"
        mkdir $asset.name
        unzip -qq -o $"($asset.name).zip" -d $asset.name
        rm -f $"($asset.name).zip"

        cd $asset.name

        if ("./plugins" | path exists) {
            mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/($asset.name)"
            cp -rf ./plugins/* $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/($asset.name)"
        } else {
            cp -rf ./ $"($env.DSP_INSTALL_PATH)/BepInEx/plugins/"
        }

        if ("./patchers" | path exists) {
            mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/patchers/($asset.name)"
            cp -rf ./patchers/* $"($env.DSP_INSTALL_PATH)/BepInEx/patchers/($asset.name)/"
        }
    }
}


def run_game [] {
    mkdir $"($env.DSP_INSTALL_PATH)/BepInEx/config"

    if ($env.GENERATE_CONFIG? | into bool) {
        for file in (ls /config/) {
            open --raw $file.name | envsubst | save -f $"($env.DSP_INSTALL_PATH)/BepInEx/config/($file.name | path basename)"
        }
    }

    mut save = -load-latest
    if (ls /save | length) == 0 {
        $save = "-newgame-cfg"
    }

    if $env.SAVE? != null {
        $save = $env.SAVE
    }

    bash -c "weston --xwayland -B headless &"
    wine $"($env.DSP_INSTALL_PATH)/DSPGAME.exe" ...($env.LAUNCH_ARGS | split row ' ') ...($save | split row ' ')
}