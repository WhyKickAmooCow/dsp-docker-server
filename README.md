# Installation

Run

```
# Make the directories we are going to mount so that Docker doesn't create them (they would be owned by root).
mkdir ./game
mkdir ./save

docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token ghcr.io/whykickamoocow/dsp-docker-server:master
```

To install the DSP Server to the ./game directory. Then you can run:

```
docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -p 8469:8469 ghcr.io/whykickamoocow/dsp-docker-server:master
```

In order to run the server.
