#!/bin/sh
rm -f /tmp/.X1-lock
export DISPLAY=:1.0
sudo -u docker vglrun Xvfb $DISPLAY -screen 0 1920x1080x16 &
sudo -u docker /usr/bin/x11vnc -display $DISPLAY -shared -forever &

export CATALINA_HOME=/usr/share/tomcat9
export CATALINA_BASE=/var/lib/tomcat9
export CATALINA_TMPDIR=/tmp JAVA_OPTS=-Djava.awt.headless=true
export GUACAMOLE_HOME=/etc/guacamole
/usr/libexec/tomcat9/tomcat-update-policy.sh
sudo -Eu tomcat sh /usr/libexec/tomcat9/tomcat-start.sh &
sudo -Eu tomcat guacd &

# TODO: fix own UID if workspace exists
usermod -u "$(stat -c '%u' /home/docker/workspace || echo 1000)" docker

exec sudo -Eu docker /ros_entrypoint.sh vglrun startxfce4
#exec vglrun cinnamon-session
