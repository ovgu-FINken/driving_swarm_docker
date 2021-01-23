FROM ovgudrivingswarm/turtlebot:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG ROS_VERSION=foxy
ARG NODE_VERSION=12.x

USER root

# Unminimize

RUN yes | unminimize &&\
    apt-get update &&\
    apt-get install -y --no-install-recommends man-db


# Dev-Packages

#RUN apt-get update &&\
#    apt-get install -y --no-install-recommends\
    

# VNC Server
# novnc + websockify

RUN apt-get install -y --no-install-recommends \
      x11vnc xvfb x11-xserver-utils \
	  novnc websockify

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html &&\
    ln -s /usr/share/novnc/ /srv/novnc

# xfce-desktop
# TODO configs & background

RUN apt-get install -y --no-install-recommends \
      xfce4 thunar ristretto mousepad mpv \
      xfce4-screenshooter \
      xfce4-whiskermenu-plugin xfce4-cpugraph-plugin \
      pop-icon-theme

# (ROS) utilities

RUN apt-get install -y --no-install-recommends \
      ros-$ROS_VERSION-rqt ros-$ROS_VERSION-rqt-common-plugins \
      tilix epiphany-browser \
      dbus-x11 gnome-keyring \
      wget psmisc \
      vim-tiny feh \
      evince file-roller \
      htop fd-find silversearcher-ag

# Theia IDE
RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - &&\
    DISTRO="$(lsb_release -s -c)" &&\
    echo "deb https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list &&\
    echo "deb-src https://deb.nodesource.com/node_$NODE_VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list &&\
    apt-get update
RUN apt-get install nodejs && npm install -g yarn
COPY development/theia.package.json /opt/theia/package.json
RUN cd /opt/theia && yarn
RUN cd /opt/theia && yarn theia build
# Required for XML files, Python etc.
RUN apt-get install -y openjdk-14-jre pylint
# Required for Chrome
ENV THEIA_WEBVIEW_EXTERNAL_ENDPOINT={{hostname}}
VOLUME /home/docker/.theia

# Setup Script

COPY development/setup-desktop.sh /usr/local/bin/setup-desktop.sh
ENTRYPOINT []
CMD ["/usr/local/bin/setup-desktop.sh"]


# Setup User


# TODO xfce4-configs
# COPY ...

RUN chown -R docker /home/docker/
