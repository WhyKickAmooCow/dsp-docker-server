# About

This is a Dyson Sphere Program game server running inside a docker container. This is accomplished using WINE and using Goldberg's Steam Emu to allow launching the game straight from the exe without steam installed. This requires you to already own the game in Steam and to provide login details so the game can be downloaded. You can of course set up your DSP game with the mods you want and then patch it with Goldberg's yourself and put it in the ./game folder if you don't trust / dont want to provide login details.

# Installation

To install the DSP Server to the ./game directory run:

```
# Make the directories we are going to mount so that Docker doesn't create them (they would be owned by root).
mkdir ./game
mkdir ./save

docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

Then in order to run the server normally you can run:

```
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

To update the server run:

```
docker run -it --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master update
```

# Environment Variables

| Name               | Default                            | Description                                                                               |
| ------------------ | ---------------------------------- | ----------------------------------------------------------------------------------------- |
| WINEDLLOVERRIDES   | mscoree=n,b;mshtml=n,b;winhttp=n,b | WINEDLLOVERRIDES as in WINE                                                               |
| DSP_INSTALL_PATH   | /game                              | Where in the container DSP should be installed to                                         |
| LAUNCH_ARGS        | -batchmode -nographics -server     | Arguments to pass to DSP when launching the game                                          |
| ADDITIONAL_PLUGINS |                                    | Plugins additional to Nebula Multiplayer (and its dependencies) to install to the server. |

# Credits

https://github.com/AlienXAXS/DSPNebulaDocker - This project uses a slimmed down version of their install script (particularly for installing the plugins).
