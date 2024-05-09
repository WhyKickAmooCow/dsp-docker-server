| :warning: Notice                                                                                                                                                              |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Closing the server doesn't appear to automatically save the game in this container. It should still autosave, but use commands after enabling remote access to save manually. |

# About

This is a Dyson Sphere Program game server running inside a docker container. This is accomplished using WINE and using Goldberg's Steam Emu to allow launching the game straight from the exe without steam installed. This requires you to already own the game in Steam and to provide login details so the game can be downloaded. You can of course set up your DSP game with the mods you want and then patch it with Goldberg's yourself and put it in the ./game folder if you don't trust / dont want to provide login details.

# Installation

To install the DSP Server to the ./game directory run:

```
# Make the directories we are going to mount so that Docker doesn't create them (they would be owned by root).
mkdir ./game
mkdir ./save

# Only requires username, then it will ask for password and token while running. If you want to run it without interactivity then give it the password and 2FA token.
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master username [password] [2FA-token]
```

Then in order to run the server normally you can run:

```
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

To update the server run:

```
# To Update the game.
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master update username [password] [2FA-token]
# To only update the mods.
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master update_mods
```

# Environment Variables

| Name                    | Default                                                        | Description                                                                                                                                            |
| ----------------------- | -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| WINEDLLOVERRIDES        | mscoree=n,b;mshtml=n,b;winhttp=n,b                             | WINEDLLOVERRIDES as in WINE.                                                                                                                           |
| DSP_INSTALL_PATH        | /game                                                          | Where in the container DSP should be installed to.                                                                                                     |
| LAUNCH_ARGS             | -batchmode -nographics -server                                 | Arguments to pass to DSP when launching the game.                                                                                                      |
| REQUIRED_PLUGINS        | nebula-NebulaMultiplayerMod,nebula-NebulaMultiplayerModApi,... | Comma delimited list of plugins to install to the server. In the format namespace-name[-version]                                                       |
| ADDITIONAL_PLUGINS      |                                                                | Comma delimited list of additional plugins to install to the server.                                                                                   |
| ADDITIONAL_INSTALL_ARGS |                                                                | Additional install arguments to pass to steamcmd when installing DSP (e.g. -beta 0.9.x)                                                                |
| MIN_UPS                 | 50                                                             | Minimum UPS of client of multiplayer game (BulletTime).                                                                                                |
| SERVER_NAME             |                                                                |                                                                                                                                                        |
| SERVER_PASSWORD         |                                                                | [Nebula Docs](https://github.com/hubastard/nebula/wiki/Setup-Headless-Server#config-options)                                                           |
| PORT                    | 8469                                                           | The port for the server to listen on                                                                                                                   |
| ENABLE_NGROK            | false                                                          | [Nebula Ngrok Docs](https://github.com/hubastard/nebula/wiki/Hosting-and-Joining#ngrok-support)                                                        |
| NGROK_TOKEN             |                                                                | [Nebula Ngrok Docs](https://github.com/hubastard/nebula/wiki/Hosting-and-Joining#ngrok-support)                                                        |
| NGROK_REGION            |                                                                | [Nebula Ngrok Docs](https://github.com/hubastard/nebula/wiki/Hosting-and-Joining#ngrok-support)                                                        |
| SYNC_UPS                | true                                                           | [Nebula Docs](https://github.com/hubastard/nebula/wiki/About-Nebula#shared-resources)                                                                  |
| SYNC_SOIL               | false                                                          | [Nebula Docs](https://github.com/hubastard/nebula/wiki/About-Nebula#shared-resources)                                                                  |
| REMOTE_ACCESS           | false                                                          | [Nebula Docs](https://github.com/hubastard/nebula/wiki/Setup-Headless-Server#config-options)                                                           |
| REMOTE_ACCESS_PASSWORD  |                                                                | [Nebula Docs](https://github.com/hubastard/nebula/wiki/Setup-Headless-Server#config-options)                                                           |
| AUTO_PAUSE              | true                                                           | [Nebula Docs](https://github.com/hubastard/nebula/wiki/Setup-Headless-Server#config-options)                                                           |
| STAR_COUNT              | 64                                                             | When creating a new save, how large the cluster should be.                                                                                             |
| RESOURCE_MUTLIPLIER     | 1.0                                                            | What the resource multiplier should be when creating a new save.                                                                                       |
| SEED                    |                                                                | If left blank, randomly generated. An integer seed for when creating a new save.                                                                       |
| GENERATE_CONFIG         | true                                                           | Whether to overwrite the game configs at runtime, substituting environment variables into the file.                                                    |
| SAVE                    |                                                                | Manually specify what to use for save game related [CLI args](https://github.com/NebulaModTeam/nebula/wiki/Setup-Headless-Server#nebula-cli-arguments) |

# Credits

https://github.com/AlienXAXS/DSPNebulaDocker - This project uses a slimmed down version of their install script (particularly for installing the plugins).
