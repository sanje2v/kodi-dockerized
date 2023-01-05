#!/bin/bash

export DISPLAY=:1.0
export XSPICE_PORT=5900
export PULSEAUDIO_RUNDIR=/tmp/pulseaudio_rundir
export PULSE_STATE_PATH=$PULSEAUDIO_RUNDIR/client/pulsestate
export PULSE_RUNTIME_PATH=$PULSEAUDIO_RUNDIR/client/pulserun
export PULSEAUDIO_PLAYBACKDIR=$PULSEAUDIO_RUNDIR/client/playback

# CAUTION: If 'PULSEAUDIO_PLAYBACKDIR' is updated, please also copy new value to 'SpicePlaybackFIFODir' setting in 'xspice/spiceqxl.xorg.conf'.


if [[ $$ -ne 1 ]]; then
  echo "ERROR: This process must be run first to get a PID of 1."
  exit 1;
fi

kill_kodi_if_running() {
  kodi_pid=$(pidof kodi.bin)
  if [[ ! -z "$kodi_pid" ]]; then
    echo "INFO: Stopping Kodi..."
    kill -SIGINT $kodi_pid
    /usr/bin/sleep 2;
  fi
}

kill_pulseaudio_if_running() {
  pulseaudio_pid=$(pidof pulseaudio)
  if [[ ! -z "$pulseaudio_pid" ]]; then
    echo "INFO: Stopping PulseAudio..."
    kill -SIGINT $pulseaudio_pid
    /usr/bin/sleep 2;
  fi
}


kill_Xorg_if_running() {
  Xorg_pid=$(pidof Xorg)
  if [[ ! -z "$Xorg_pid" ]]; then
    echo "INFO: Found Xorg running! Killing it first."
    kill -SIGINT $Xorg_pid
    /usr/bin/sleep 2;
  fi
  rm -rf /tmp/.X1-lock /tmp/.X11-unix;
}

# SIGINT/TERM-handler
int_term_handler() {
  echo "INFO: Caught signal for container to stop."
  kill_kodi_if_running
  kill_pulseaudio_if_running
  kill_Xorg_if_running

  exit 143; # 128 + 15 -- SIGTERM
}

# Setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; int_term_handler' SIGINT
trap 'kill ${!}; int_term_handler' SIGTERM

# Check for Xspice, PulseAudio and then Kodi
if [[ ! -f /usr/bin/Xspice ]]; then
  echo "ERROR: Xspice binary not found in '/usr/bin'!"
  exit 1;
fi
if [[ ! -f /usr/bin/pulseaudio ]]; then
  echo "ERROR: PulseAudio binary not found in '/usr/bin'!"
  exit 1;
fi
if [[ ! -f /usr/bin/kodi ]]; then
  echo "ERROR: Kodi binary not found in '/usr/bin'!"
  exit 1;
fi

############### Script start
kill_kodi_if_running
kill_pulseaudio_if_running
kill_Xorg_if_running

rm -rf $PULSEAUDIO_RUNDIR

/usr/bin/su - kodi --whitelist-environment=PULSEAUDIO_PLAYBACKDIR -c "mkdir -p $PULSEAUDIO_PLAYBACKDIR"
/usr/bin/Xspice --port $XSPICE_PORT --disable-ticketing --audio-fifo-dir=$PULSEAUDIO_PLAYBACKDIR $DISPLAY > /dev/null 2>&1 &

/usr/bin/sleep 2

/usr/bin/su - kodi --whitelist-environment=DISPLAY,PULSEAUDIO_PLAYBACKDIR -c \
"/usr/bin/dbus-run-session -- pulseaudio -L \
\"module-pipe-sink sink_name=fifo file=$PULSEAUDIO_PLAYBACKDIR/audio.pcm format=s16 rate=48000 channels=2\" --daemonize && \
/usr/bin/kodi --standalone"

echo "INFO: READY"

# Wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
