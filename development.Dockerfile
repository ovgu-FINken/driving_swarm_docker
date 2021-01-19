FROM harbor.momar.xyz/driving_swarm/turtlebot

ARG DEBIAN_FRONTEND=noninteractive
ARG NODE_VERSION=12.x
ARG NOVNC_VERSION=1.1.0
ARG WEBSOCKIFY_VERSION=0.8.0

USER root

# Unminimize

RUN yes | unminimize &&\
    apt-get update &&\
    apt-get install -y man-db


# Dev-Packages

#RUN apt-get update &&\
#    apt-get install -y --no-install-recommends\


# VNC Server

RUN apt-get install -y --no-install-recommends \
      x11vnc xvfb x11-xserver-utils
	  #novnc websockify
      # TODO work with nginx (theia!)

# novnc + websockify

COPY development/nginx.conf /etc/nginx/conf.d/novnc.conf
RUN curl -fsSL https://github.com/novnc/noVNC/archive/v${NOVNC_VERSION}.tar.gz | tar -xzf - -C /opt &&\
    curl -fsSL https://github.com/novnc/websockify/archive/v${WEBSOCKIFY_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/noVNC-${NOVNC_VERSION} /opt/noVNC &&\
    mkdir -p /srv/novnc &&\
    mv /opt/websockify-${WEBSOCKIFY_VERSION} /opt/websockify &&\
	ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html &&\
    ln -s /opt/noVNC /srv/novnc &&\
    cd /opt/websockify && make


# Cinnamon, without gnome-backgrounds dependency (which is a 50 MB download)
#COPY development/gnome-backgrounds-equivs.deb /tmp/gnome-backgrounds.deb
#RUN apt-get install -y --no-install-recommends /tmp/gnome-backgrounds.deb cinnamon adwaita-icon-theme-full feh
#RUN rm /tmp/gnome-backgrounds.deb
#COPY development/wallpaper.jpg /usr/share/backgrounds/wallpaper.jpg


# xfce-desktop
# TODO configs

RUN apt-get install -y --no-install-recommends \
      xfce4 thunar ristretto mousepad mpv \
      xfce4-screenshooter \
      # TODO add config
      xfce4-whiskermenu-plugin xfce4-cpugraph-plugin \
      pop-icon-theme


# utilities

RUN apt-get install -y --no-install-recommends \
      dbus-x11 gnome-keyring \
      tilix epiphany-browser \
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
RUN apt-get install -y openjdk-14-jre # Required for XML files etc.


# Setup Script

COPY development/setup-desktop.sh /usr/local/bin/setup-desktop.sh
# This is better (user can build, starts if not able to build etc.)
ENTRYPOINT []
CMD ["/vgl_entrypoint.sh", "/usr/local/bin/setup-desktop.sh"]


# Setup User

COPY development/setup-session.sh /home/docker/.config/
COPY development/setup-session.desktop /home/docker/.config/autostart/
COPY development/applications /home/docker/.local/share/applications

# TODO xfce4-configs
# COPY ...

RUN chown -R docker /home/docker/
