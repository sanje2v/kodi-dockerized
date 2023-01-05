#FROM ubuntu:22.04
FROM ubuntu:20.04
ARG TZ=Australia/Sydney
ARG HOST_UID=1000
ARG DEBIAN_FRONTEND=noninteractive


USER root
WORKDIR /root

# Install required packages
RUN apt update -y && apt upgrade -y
RUN apt install -y i965-va-driver xserver-xspice xserver-xorg-video-qxl curl samba-common-bin libasound2 alsa-utils pulseaudio
RUN apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
                   gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-vaapi \
                   gstreamer1.0-libav gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:team-xbmc/ppa && apt update -y
RUN apt install kodi -y

# Tools for debugging
RUN apt install -y gstreamer1.0-tools sudo nano wget htop vainfo intel-gpu-tools binutils git pciutils

# Set timezone
RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
RUN apt install -y tzdata
RUN dpkg-reconfigure tzdata

# Copy required files into proper locations
COPY xspice/spiceqxl.xorg.conf /etc/X11/
COPY pulseaudio/client.conf /etc/pulse/
COPY pulseaudio/default.pa /etc/pulse/
COPY entrypoint.sh .

# Create kodi user
RUN useradd --create-home --uid $HOST_UID --groups cdrom,audio,video,plugdev,users,dialout,dip,render --user-group kodi

# Run entrypoint script to run XSpice, PulseAudio and Kodi
CMD ["/bin/bash", "./entrypoint.sh"]
