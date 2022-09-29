#!/bin/bash

if [[ $$ -ne 1 ]]; then
  echo "ERROR: This process must be run first to get a PID of 1."
  exit 1;
fi

kill_Xorg_if_running() {
  Xorg_pid=$(pidof Xorg)
  if [[ ! -z "$Xorg_pid" ]]; then
    echo "INFO: Found Xorg running! Killing it first."
    kill -SIGINT $Xorg_pid && /usr/bin/sleep 2
  fi
  rm -rf /tmp/.X1-lock /tmp/.X11-unix;
}

# SIGINT/TERM-handler
int_term_handler() {
  echo "INFO: Caught signal for container to stop."
  echo $(curl -s --data-binary \
       '{"jsonrpc": "2.0", "method": "Application.Quit", "id": 1}' -H 'content-type: application/json;' http://localhost:9001/jsonrpc)
  /usr/bin/sleep 3

  exit 143; # 128 + 15 -- SIGTERM
}

# Setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
trap 'kill ${!}; int_term_handler' SIGINT
trap 'kill ${!}; int_term_handler' SIGTERM

# Run Xspice and then Kodi
if [[ ! -f /usr/bin/Xspice ]]; then
  echo "ERROR: Xspice binary not found in '/usr/bin'!"
  exit 1;
fi
if [[ ! -f /usr/bin/kodi ]]; then
  echo "ERROR: Kodi binary not found in '/usr/bin'!"
  exit 1;
fi

kill_Xorg_if_running
export DISPLAY=:1.0
/usr/bin/Xspice --port 5900 --disable-ticketing --exit-on-disconnect $DISPLAY > /dev/null 2>&1 &
/usr/bin/sleep 4 && /usr/bin/su - kodi --whitelist-environment=DISPLAY -c "/usr/bin/kodi --standalone" &
echo "INFO: READY"

# Wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
