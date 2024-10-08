FROM ghcr.io/whykickamoocow/steamcmd-wine:main

RUN usermod -l dsp ubuntu \
    && groupmod -n dsp ubuntu \
    && usermod -d /home/dsp -m dsp

RUN mkdir /game \
    && mkdir /save \
    && mkdir /config \
    && chown -R dsp:dsp /game /save /config

USER dsp
ENV USER dsp
ENV HOME /home/dsp
WORKDIR $HOME

ENV WINEPREFIX=$HOME/.wine
ENV WINEDLLOVERRIDES="mscoree=n,b;mshtml=n,b;winhttp=n,b"
ENV WINEDEBUG=fixme-all,err-d3d_shader

RUN winetricks -q dotnet48

COPY config/ /config/
RUN mkdir -p "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program"
RUN ln -s /save "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program/Save"
COPY ["appdata/", "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program/"]

# Looks weird, but means that it can cache installing dotnet rather then needing to reinstall it every damn time I change the entrypoint or install scripts.
USER root
COPY --chmod=777 bin/* /usr/bin/

ARG NUSHELL_VER="0.97.1"
RUN mkdir -p /home/dsp/.config/nushell/ \
    && wget -q https://raw.githubusercontent.com/nushell/nushell/${NUSHELL_VER}/crates/nu-utils/src/sample_config/default_config.nu -O /home/dsp/.config/nushell/config.nu \
    && wget -q https://raw.githubusercontent.com/nushell/nushell/${NUSHELL_VER}/crates/nu-utils/src/sample_config/default_env.nu -O /home/dsp/.config/nushell/env.nu \
    && cd /tmp \
    && wget -q https://github.com/nushell/nushell/releases/download/${NUSHELL_VER}/nu-${NUSHELL_VER}-x86_64-unknown-linux-gnu.tar.gz \
    && tar -xzf nu* \
    && cd nu*-linux-gnu \
    && mv nu* /usr/bin \
    && chmod +x /usr/bin/nu

RUN chown -R dsp:dsp /home/dsp/.config/nushell \
    && echo '/usr/bin/nu' >> /etc/shells \
    && usermod --shell /usr/bin/nu dsp \
    && ls /usr/bin/nu_plugin* \
    | xargs -I{} su -c 'plugin add {}' dsp \
    && rm -rf /tmp/*

USER dsp

#
# Server config env vars
#

ENV LAUNCH_ARGS="-batchmode -nographics -server"

ENV GENERATE_CONFIG=true

ENV DSP_INSTALL_PATH=/game

## BulletTime
# Minimum UPS in client of multiplayer game
ENV MIN_UPS=50

## Nebula Multiplayer
# ENV SERVER_NAME
# ENV SERVER_PASSWORD
ENV PORT=8469
ENV ENABLE_NGROK=false
# ENV NGROK_TOKEN
#ENV NGROK_REGION
ENV SYNC_UPS=true
ENV SYNC_SOIL=false
ENV REMOTE_ACCESS=false
# ENV REMOTE_ACCESS_PASSWORD
ENV AUTO_PAUSE=true

ENV SEED=-1
ENV STAR_COUNT=-1
ENV RESOURCE_MUTLIPLIER=-1

ENV PEACE_MODE=false
ENV SANDBOX_MODE=false

ENV COMBAT_AGGRESSIVENESS=1
ENV COMBAT_INITIAL_LEVEL=0
ENV COMBAT_INITIAL_GROWTH=1
ENV COMBAT_INITIAL_COLONIZE=1
ENV COMBAT_MAX_DENSITY=1
ENV COMBAT_GROWTH_SPEED_FACTOR=1
ENV COMBAT_POWER_THREAT_FACTOR=1
ENV COMBAT_BATTLE_THREAT_FACTOR=1
ENV COMBAT_BATTLE_EXP_FACTOR=1

ENV REQUIRED_PLUGINS=nebula-NebulaMultiplayerMod,nebula-NebulaMultiplayerModApi,PhantomGamers-IlLine,CommonAPI-CommonAPI,starfi5h-BulletTime,xiaoye97-LDBTool,CommonAPI-DSPModSave


#
# Weston runtime setup
#

ENV XDG_RUNTIME_DIR=/tmp/dsp
RUN mkdir /tmp/dsp && chmod 0700 /tmp/dsp
RUN mkdir /tmp/.X11-unix

ENV DISPLAY=:0

ENTRYPOINT [ "/usr/bin/entrypoint.nu" ]
