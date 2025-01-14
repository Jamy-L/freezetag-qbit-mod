# syntax=docker/dockerfile:1

FROM scratch

LABEL maintainer="Jamy-L"

RUN chmod +x /etc/s6-overlay/s6-rc.d/init-mod-qbittorrent-freezetag-add-package/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/init-mod-qbittorrent-freezetag-postinstall/run
RUN chmod +x /etc/s6-overlay/s6-rc.d/svc-mod-qbittorrent-freezetag/run

# copy local files
COPY root/ /
