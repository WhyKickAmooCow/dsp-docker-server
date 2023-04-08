# Installation

Run

```
docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save -e STEAM_USER=username -e STEAM_PASS=password -e STEAM_AUTH=2FA-token localhost/dsp-server
```

To install the DSP Server to the ./game directory. Then you can run:

```
docker run --rm -v $(pwd)/game:/game -v $(pwd)/save:/save localhost/dsp-server
```

In order to run the server/
