# Dockerized Kodi
This project builds a dockerized version of [Kodi Media Center](https://kodi.tv) to run on a serverless system. We can then access Kodi's UI using [Remote Viewer](https://virt-manager.org/download) (or any other program that supports XSpice) from any other computer.

Software used are:
1. Docker
2. XSpice
3. PulseAudio

## Getting Started
In your headless server machine, install [Docker](https://www.docker.com). Then run `runKodiDocker.sh`. From you client machine, you should then be able to access Kodi's UI using [virt-viewer](https://virt-manager.org/download).

If you restart your server, you will need to manually restart the container.

## TODOs
- [ ] Support for automatically restarting container
- [ ] Virtual display driver that supports DRI2 so that XSpice and Kodi can use iGPU video (de)ncode
