ARG ROS_VERSION=foxy
FROM ros:$ROS_VERSION
ARG GUAC_VERSION=1.2.0
ARG TOMCAT_VERSION=9

WORKDIR /root
ARG DEBIAN_FRONTEND=noninteractive

# Unminimize

RUN yes | unminimize && apt-get install -y man-db

# VNC Server

RUN apt-get update &&\
    apt-get install -y --no-install-recommends xvfb x11vnc

# Cinnamon, without gnome-backgrounds dependency (which is a 50 MB download)

COPY development/gnome-backgrounds-equivs.deb /tmp/gnome-backgrounds.deb
RUN apt-get install -y --no-install-recommends /tmp/gnome-backgrounds.deb cinnamon adwaita-icon-theme-full feh
RUN apt-get install -y --no-install-recommends \
      dbus-x11 gnome-keyring \
      tilix epiphany-browser \
      wget curl \
      vim-tiny nano \
      evince file-roller \
      htop fd-find silversearcher-ag less
# fdfind the-silver-searcher
# htop: hide user threads & alias top to htop
# wallpaper for cinnamon
# missing icons
RUN rm /tmp/gnome-backgrounds.deb
COPY development/wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg

# Apache Guacamole (VNC Webapp)

# client:
RUN apt-get install -y tomcat$TOMCAT_VERSION
ADD --chown=tomcat http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/$GUAC_VERSION/binary/guacamole-$GUAC_VERSION.war /var/lib/tomcat$TOMCAT_VERSION/webapps/guacamole.war
COPY --chown=tomcat development/guacamole-user-mapping.xml /etc/guacamole/user-mapping.xml
COPY --chown=tomcat development/guacamole-index.html /var/lib/tomcat$TOMCAT_VERSION/webapps/ROOT/index.html
# guacd:
ADD --chown=tomcat https://downloads.apache.org/guacamole/$GUAC_VERSION/source/guacamole-server-$GUAC_VERSION.tar.gz /tmp/guacamole-server.tar.gz
RUN apt-get -y install gcc g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev \
      libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev \
      freerdp2-dev libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev \
      libssl-dev libvorbis-dev libwebp-dev &&\
    cd /tmp && tar xvf guacamole-server.tar.gz && cd guacamole-server-* &&\
    ./configure && make && make install && ldconfig &&\
    cd / && rm -rf /tmp/guacamole-server*

# VS Codium

RUN wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/vscodium.gpg &&\
    echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list &&\
    sudo apt-get update &&\
    sudo apt-get -y install codium

# Setup Script

COPY development/setup-desktop.sh /
CMD ["/setup-desktop.sh"]

# Setup User

RUN apt-get install -y fish
RUN useradd -m docker -s /usr/bin/fish -G sudo &&\
	{ echo "docker"; echo "docker"; } | passwd docker &&\
	sed -Ei 's/^(%sudo.*\) )ALL$/\1NOPASSWD: ALL/' /etc/sudoers
COPY development/setup-session.sh /home/docker/.config/
COPY development/setup-session.desktop /home/docker/.config/autostart/
COPY development/applications /home/docker/.local/share/applications
COPY development/cinnamon-configs /home/docker/.cinnamon/configs
COPY development/cinnamon-menus /home/docker/.config/menus
RUN chown -R docker. /home/docker
WORKDIR /home/docker
ENV HOME=/home/docker
