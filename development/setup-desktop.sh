#!/bin/sh

rm -f /tmp/.X0-lock

export DISPLAY=":0"
# does not work because x11vnc has problems
# use websockify instead?
sudo -Eu docker vglrun Xvfb $DISPLAY -screen 0 1920x1080x16 &
sudo -Eu docker x11vnc -nopw -rfbport 5900 -ncache 0 -display $DISPLAY -shared -forever &

#TODO start novnc and websockify
/opt/websockify/run --web="/srv/novnc/" 8080 localhost:5900 &
#nginx &

# TODO: fix own UID if workspace exists
usermod -u "$(stat -c '%u' /home/docker/workspace || echo 1000)" docker

exec sudo -Eu docker vglrun startxfce4
