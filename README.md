# Installation

To install the DSP Server to the ./game directory run:

```
# Make the directories we are going to mount so that Docker doesn't create them (they would be owned by root).
mkdir ./game
mkdir ./save

docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

Then in order to run the server normally you can run:

```
docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

To update the server run:

```
docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master update
```
