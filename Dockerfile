FROM ubuntu:20.04
ARG HOST_UID=1000
ARG DEBIAN_FRONTEND=noninteractive


USER root
WORKDIR /root
RUN apt update -y && apt upgrade -y
RUN apt install -y xserver-xspice xserver-xorg-video-qxl curl samba-common-bin libasound2 alsa-utils pulseaudio

RUN ln -fs /usr/share/zoneinfo/Australia/Sydney /etc/localtime
RUN apt install -y tzdata
RUN dpkg-reconfigure tzdata

RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:team-xbmc/ppa && apt update -y
RUN apt install kodi -y

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

RUN useradd --create-home --uid $HOST_UID --groups cdrom,audio,video,plugdev,users,dialout,dip --user-group kodi

ENTRYPOINT ["./entrypoint.sh"]
