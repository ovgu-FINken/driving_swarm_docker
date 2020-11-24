#!/bin/sh
rm -f /tmp/.X1-lock
sudo -u docker Xvfb :1 -screen 0 1920x1080x16 &
sudo -u docker /usr/bin/x11vnc -display :1.0 -shared -forever &
export DISPLAY=:1.0

export CATALINA_HOME=/usr/share/tomcat9
export CATALINA_BASE=/var/lib/tomcat9
export CATALINA_TMPDIR=/tmp JAVA_OPTS=-Djava.awt.headless=true
export GUACAMOLE_HOME=/etc/guacamole
/usr/libexec/tomcat9/tomcat-update-policy.sh
sudo -Eu tomcat sh /usr/libexec/tomcat9/tomcat-start.sh &
sudo -Eu tomcat guacd &

# TODO: fix own UID if workspace exists
usermod -u "$(stat -c '%u' ~/workspace || echo 1000)" docker

exec sudo -Eu docker cinnamon-session
