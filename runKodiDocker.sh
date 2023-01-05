#!/bin/bash
docker build --build-arg HOST_UID=$(id -u) -f Dockerfile -t kodi .

mkdir -p ~/.config/kodi
docker run --detach --rm --publish 5900:5900 --publish 32400:8080 \
           -v ~/.config/kodi:/home/kodi/.kodi:rw \
           -v /dev/dri/by-path:/dev/dri/by-path:ro \
           --device /dev/dri/renderD128 \
           -e LIBVA_DRIVER_NAME=i965 -e GST_GL_WINDOW=x11 -e GST_VAAPI_DRM_DEVICE=/dev/dri/renderD128 \
           --name kodi kodi
