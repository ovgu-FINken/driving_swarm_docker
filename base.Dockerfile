ARG ROS_VERSION=foxy

FROM ros:$ROS_VERSION

ARG DEBIAN_FRONTEND=noninteractive

# apts & commands (vcstool etc. in ros:foxy)

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
      python3-pip \
      curl nano openssh-client

# script for using vcstool, rosdep and colcon to setup the workspace

COPY base/setup-workspace.sh /usr/local/bin/setup-workspace.sh

# add docker user

RUN useradd -m docker -s /usr/bin/bash -G sudo &&\
	{ echo "docker"; echo "docker"; } | passwd docker &&\
	sed -Ei 's/^(%sudo.*\) )ALL$/\1NOPASSWD: ALL/' /etc/sudoers


# GPU-support for Intel (and AMD?)

RUN cd /home/docker/ &&\
    curl -L --output virtualgl.deb https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb && \
    dpkg -i virtualgl.deb && \
    rm virtualgl.deb
RUN apt-get install -y \
    libgl1-mesa-glx libgl1-mesa-dri \
    mesa-utils
RUN usermod -a -G video docker


# profile

RUN echo "source /home/docker/workspace/install/setup.bash" >> /etc/profile &&\
    echo "export ROS_DOMAIN_ID=42 #SWARMLAB" >> /etc/profile


# .bashrc

ADD --chown=docker https://gist.githubusercontent.com/moqmar/28dde796bb924dd6bfb1eafbe0d265e8/raw/f24336f8f2cf7281a095d2b81e50bd2ec4464b22/.bashrc /home/docker/.bashrc

# TODO what is this even needed for?
#RUN echo 'if ! [ -f ~/.ssh/id_ed25519 ]; then ssh-keygen -t ed25519 -C "" -N "" -f ~/.ssh/id_ed25519; fi' >> /home/docker/.bashrc

RUN echo "cd ~/workspace && source install/setup.bash" >> /home/docker/.bashrc
RUN echo "echo 'Tip: use setup-workspace.sh to quickly install dependencies & build your workspace'" >> /home/docker/.bashrc


ENV HOME=/home/docker
WORKDIR /home/docker
USER docker


# entrypoint with cloning and building workspace

ENTRYPOINT ["/ros_entrypoint.sh", "/usr/local/bin/setup-workspace.sh"]
CMD ["bash"] 
