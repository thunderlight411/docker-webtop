FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine321

# set version label
ARG BUILD_DATE
ARG VERSION
ARG XFCE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Alpine XFCE"

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/webtop-logo.png && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    chromium \
    faenza-icon-theme \
    faenza-icon-theme-xfce4-appfinder \
    faenza-icon-theme-xfce4-panel \
    mousepad \
    ristretto \
    thunar \
    util-linux-misc \
    xfce4 \
    xfce4-terminal && \
  echo "**** cleanup ****" && \
  rm -f \
    /etc/xdg/autostart/xfce4-power-manager.desktop \
    /etc/xdg/autostart/xscreensaver.desktop \
    /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop && \
  rm -rf \
    /config/.cache \
    /tmp/*

RUN apt-get update && apt-get install -y \
    pulseaudio \
    alsa-utils \
    dbus-x11 \
    libasound2 \
    libasound2-dev \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PulseAudio configuratie
RUN mkdir -p /etc/pulse
COPY default.pa /etc/pulse/default.pa

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000, 4713

VOLUME /config

# Start PulseAudio bij opstarten van de container
CMD pulseaudio --start --exit-idle-time=-1 --disallow-module-loading=no \
    --load="module-native-protocol-tcp auth-anonymous=1" \
    --load="module-zeroconf-publish" \
    --load="module-http-protocol-tcp" \
    --daemonize && \
    /init
