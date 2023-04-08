FROM steamcmd/steamcmd:latest

RUN	useradd -m -d /home/dsp -s /bin/bash dsp

ENV	DEBIAN_FRONTEND=noninteractive

RUN	dpkg --add-architecture i386

RUN	apt update
RUN apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    cabextract \
    git \
    gnupg \
    gosu \
    gpg-agent \
    locales \
    p7zip \
    pulseaudio \
    pulseaudio-utils \
    sudo \
    tzdata \
    unzip \
    wget \
    curl \
    winbind \
    xvfb \
    xauth \
    zenity

ARG WINE_BRANCH="stable"
RUN curl https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && echo "deb https://dl.winehq.org/wine-builds/ubuntu/ $(grep VERSION_CODENAME= /etc/os-release | cut -d= -f2) main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-${WINE_BRANCH}

RUN rm -rf /var/lib/apt/lists/*

ADD --chmod=777 https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks /usr/bin/winetricks

COPY --chmod=777 install.sh /usr/bin/install-dsp
COPY --chmod=777 entrypoint.sh /usr/bin/entrypoint

RUN mkdir /game
RUN chown -R dsp:dsp /game

RUN mkdir /save
RUN chown -R dsp:dsp /save

USER dsp
ENV HOME /home/dsp
WORKDIR $HOME

ENV WINEPREFIX=$HOME/.wine
ENV WINEDLLOVERRIDES="mscoree=n,b;mshtml=n,b;winhttp=n,b"

RUN winetricks -q dotnet45

RUN mkdir -p $HOME/Dyson\ Sphere\ Program
RUN ln -s /save $HOME/Dyson\ Sphere\ Program/Save

ENV LAUNCH_ARGS="-batchmode -nographics -server"

ENV DSP_INSTALL_PATH=/game

ENTRYPOINT [ "/usr/bin/entrypoint" ]
