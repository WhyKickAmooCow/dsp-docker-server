FROM ghcr.io/whykickamoocow/steamcmd-wine:main

RUN useradd -m -d /home/dsp -s /bin/bash dsp

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

ENV LAUNCH_ARGS="-batchmode -nographics -server"

ENV DSP_INSTALL_PATH=/game

### Server config env vars

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

ENV STAR_COUNT=64
ENV RESOURCE_MUTLIPLIER=1.0

COPY config/ /config/
RUN mkdir -p "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program"
RUN ln -s /save "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program/Save"
COPY ["appdata/", "/home/dsp/.wine/drive_c/users/dsp/Documents/Dyson Sphere Program/"]

# Looks weird, but means that it can cache installing dotnet rather then needing to reinstall it every damn time I change the entrypoint or install scripts.
USER root
COPY --chmod=777 bin/* /usr/bin/

ARG NUSHELL_VER="0.91.0"
RUN echo '/usr/bin/nu' >> /etc/shells \
    && usermod --shell /usr/bin/nu dsp \
    && mkdir -p /home/dsp/.config/nushell/ \
    && wget -q https://raw.githubusercontent.com/nushell/nushell/${NUSHELL_VER}/crates/nu-utils/src/sample_config/default_config.nu -O /home/dsp/.config/nushell/config.nu \
    && wget -q https://raw.githubusercontent.com/nushell/nushell/${NUSHELL_VER}/crates/nu-utils/src/sample_config/default_env.nu -O /home/dsp/.config/nushell/env.nu \
    && cd /tmp \
    && wget -q https://github.com/nushell/nushell/releases/download/${NUSHELL_VER}/nu-${NUSHELL_VER}-x86_64-linux-gnu-full.tar.gz \
    && tar -xzf nu* \
    && cd nu*-gnu-full \
    && mv nu* /usr/bin \
    && chmod +x /usr/bin/nu \
    && chown -R dsp:dsp /home/dsp/.config/nushell \
    && ls /usr/bin/nu_plugin* \
    | xargs -I{} su -c 'register {}' dsp \
    && rm -rf /tmp/*

USER dsp


ENTRYPOINT [ "/usr/bin/entrypoint.nu" ]
