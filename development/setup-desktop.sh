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
websockify --web="/srv/novnc/" 1800 localhost:5900 &

# fix own UID if workspace exists
# this is only included with the development image as it's the only image intended to be ran with a mounted workspace
usermod -u "$(stat -c '%u' /home/docker/workspace || echo 1000)" docker
chown -R docker /home/docker 
chown -R docker /opt/theia/plugins/vscode-cpp # https://github.com/microsoft/vscode-cpptools/issues/4643

# start Theia
{ cd /opt/theia; sudo -Eu docker yarn start /home/docker/workspace; } &


exec sudo -Eu docker env VGL_DISPLAY=egl DISPLAY=$DISPLAY $vglrun startxfce4
