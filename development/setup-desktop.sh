#!/bin/sh

rm -f /tmp/.X0-lock

vglrun=vglrun
if [ "$DISABLE_GPU" = "1" ]; then
	vglrun=""
fi

export DISPLAY=":100"
sudo -Eu docker env VGL_DISPLAY=egl $vglrun Xvfb $DISPLAY -screen 0 1920x1080x16 &
{ sleep 2; sudo -Eu docker x11vnc -nopw -rfbport 5900 -ncache 0 -display $DISPLAY -shared -forever; } &

# start NoVNC
/opt/websockify/run --web="/srv/novnc/" 1800 localhost:5900 &

# start Theia
exec sudo -Eu docker sh -c "cd /opt/theia && exec yarn start /home/docker/workspace" &

# TODO: fix own UID if workspace exists
usermod -u "$(stat -c '%u' /home/docker/workspace || echo 1000)" docker

exec sudo -Eu docker env VGL_DISPLAY=egl DISPLAY=$DISPLAY $vglrun startxfce4
