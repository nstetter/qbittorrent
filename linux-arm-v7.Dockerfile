FROM ghcr.io/hotio/base@sha256:ae0043af03f4c7e7bc3be94dc2bf8d4044b9825b4b9ead4cec6ae7ed501a75c3

ARG DEBIAN_FRONTEND="noninteractive"

ENV VPN_ENABLED="false" VPN_LAN_NETWORK="" VPN_CONF="wg0" VPN_ADDITIONAL_PORTS="" WEBUI_PORTS="8080/tcp,8080/udp" PRIVOXY_ENABLED="false" S6_SERVICES_GRACETIME=180000

EXPOSE 8080

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

ARG FULL_VERSION

RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        gnupg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && echo "deb [arch=armhf] http://ppa.launchpad.net/qbittorrent-team/qbittorrent-unstable/ubuntu focal main" | tee /etc/apt/sources.list.d/qbitorrent.list && \
    apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        qbittorrent-nox=${FULL_VERSION} \
        privoxy \
        ipcalc \
        iptables \
        iproute2 \
        openresolv \
        wireguard-tools && \
# clean up
    apt purge -y gnupg && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG VUETORRENT_VERSION
RUN curl -fsSL "https://github.com/wdaan/vuetorrent/releases/download/v${VUETORRENT_VERSION}/vuetorrent.zip" > "/tmp/vuetorrent.zip" && \
    unzip "/tmp/vuetorrent.zip" -d "${APP_DIR}" && \
    rm "/tmp/vuetorrent.zip" && \
    chmod -R u=rwX,go=rX "${APP_DIR}/vuetorrent"

COPY root/ /
