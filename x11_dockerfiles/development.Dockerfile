FROM harbor.momar.xyz/driving_swarm/turtlebot

ARG DEBIAN_FRONTEND=noninteractive
ARG GUAC_VERSION=1.2.0
ARG TOMCAT_VERSION=9
ARG NODE_VERSION=14.x

USER root


# Unminimize

RUN yes | unminimize &&\
    apt-get install -y man-db


# Dev-Packages
RUN apt-get update &&\
    apt-get install -y --no-install-recommends\
    gcc g++


# VNC Server

RUN apt-get update && \
    apt-get install -y --no-install-recommends  x11vnc xvfb x11-xserver-utils


# Cinnamon, without gnome-backgrounds dependency (which is a 50 MB download)
#COPY development/gnome-backgrounds-equivs.deb /tmp/gnome-backgrounds.deb
#RUN apt-get install -y --no-install-recommends /tmp/gnome-backgrounds.deb cinnamon adwaita-icon-theme-full feh
#RUN rm /tmp/gnome-backgrounds.deb
#COPY development/wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg


# xfce-desktop
# TODO configs

RUN apt-get install -y --no-install-recommends \
    xfce4 thunar ristretto mousepad mpv


# desktop utilities

RUN apt-get install -y --no-install-recommends \
      dbus-x11 gnome-keyring \
      tilix epiphany-browser \
      wget \
      vim-tiny feh \
      evince file-roller \
      htop fd-find silversearcher-ag less


#TODO replace with novnc + websockify
# Apache Guacamole (VNC Webapp)

# client:
RUN apt-get install -y tomcat$TOMCAT_VERSION
ADD --chown=tomcat http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/$GUAC_VERSION/binary/guacamole-$GUAC_VERSION.war /var/lib/tomcat$TOMCAT_VERSION/webapps/guacamole.war
COPY --chown=tomcat development/guacamole-user-mapping.xml /etc/guacamole/user-mapping.xml
COPY --chown=tomcat development/guacamole-index.html /var/lib/tomcat$TOMCAT_VERSION/webapps/ROOT/index.html
# guacd:
ADD --chown=tomcat https://downloads.apache.org/guacamole/$GUAC_VERSION/source/guacamole-server-$GUAC_VERSION.tar.gz /tmp/guacamole-server.tar.gz
RUN apt-get -y --no-install-recommends install libcairo2-dev libjpeg-turbo8-dev libpng-dev \
      libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev \
      freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev \
      libssl-dev libvorbis-dev libwebp-dev &&\
    cd /tmp && tar xvf guacamole-server.tar.gz && cd guacamole-server-* &&\
    ./configure && make && make install && ldconfig &&\
    cd / && rm -rf /tmp/guacamole-server*


# Theia (VS Code-like IDE)
#RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - &&\
#    DISTRO="$(lsb_release -s -c)" &&\
#    echo "deb https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list &&\
#    echo "deb-src https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list &&\
#    apt-get update
#RUN apt-get install nodejs
#COPY development/theia.package.json /opt/theia/package.json
#RUN cd /opt/theia && npm install && npm run theia build


# Setup Script

COPY development/setup-desktop.sh /usr/local/bin/setup-desktop.sh
# This is better (user can build, starts if not able to build etc.)
#ENTRYPOINT ["/usr/local/bin/setup-desktop.sh"]
ENTRYPOINT ["/usr/local/bin/setup-desktop.sh"]
#CMD ["/usr/local/bin/setup-desktop.sh"]


# Setup User

COPY development/setup-session.sh /home/docker/.config/
COPY development/setup-session.desktop /home/docker/.config/autostart/
COPY development/applications /home/docker/.local/share/applications
#COPY development/cinnamon-configs /home/docker/.cinnamon/configs
#COPY development/cinnamon-menus /home/docker/.config/menus
RUN chown -R docker /home/docker/
