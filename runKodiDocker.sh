#!/bin/bash
docker build --build-arg HOST_UID=$(id -u) -f Dockerfile -t kodi . && \
mkdir -p ~/.config/kodi && docker run -d --restart unless-stopped -p 5900:5900 -p 32400:8080 -p 9090:9090 -p 9777:9777/udp -v ~/.config/kodi:/home/kodi/.kodi --device /dev/snd --name kodi kodi