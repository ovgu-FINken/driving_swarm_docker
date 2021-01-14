#!/bin/sh
printf "1\nn\nn\nn\nx" | vglserver_config

rm -f /tmp/.X1-lock
#rm -f /tmp/.X11-unix/X0
export DISPLAY=":0"
export VGL_DISPLAY="$DISPLAY"
sudo -Eu docker vglrun Xvfb $DISPLAY -screen 0 1920x1080x16 &
#vglrun Xvfb $DISPLAY -screen 0 1920x1080x16 &
sudo -Eu docker /usr/bin/x11vnc -ncache 0 -display $DISPLAY -shared -forever &
#/usr/bin/x11vnc -display $DISPLAY -shared -forever &

export CATALINA_HOME=/usr/share/tomcat9
export CATALINA_BASE=/var/lib/tomcat9
export CATALINA_TMPDIR=/tmp JAVA_OPTS=-Djava.awt.headless=true
export GUACAMOLE_HOME=/etc/guacamole
/usr/libexec/tomcat9/tomcat-update-policy.sh
sudo -Eu tomcat sh /usr/libexec/tomcat9/tomcat-start.sh &
sudo -Eu tomcat guacd &

# TODO: fix own UID if workspace exists
usermod -u "$(stat -c '%u' /home/docker/workspace || echo 1000)" docker

#exec sudo -Eu docker /ros_entrypoint.sh vglrun startxfce4
exec sudo -Eu docker vglrun startxfce4
