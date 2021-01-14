ARG ROS_VERSION=foxy

FROM ros:$ROS_VERSION

ARG DEBIAN_FRONTEND=noninteractive
ARG VIRTUALGL_VERSION=2.6.5


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

RUN curl -Lo /tmp/virtualgl.deb https://sourceforge.net/projects/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    apt-get install -y /tmp/virtualgl.deb && \
    rm /tmp/virtualgl.deb &&\
    chmod u+s /usr/lib/libvglfaker.so && \
    chmod u+s /usr/lib/libdlfaker.so

# Try for newest mesa-libs

RUN echo "deb http://ppa.launchpad.net/kisak/kisak-mesa/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list &&\
    echo "deb-src http://ppa.launchpad.net/kisak/kisak-mesa/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB8B81E14DA65431D7504EA8F63F0F2B90935439 &&\
	apt-get update &&\
    apt-get install -y \
    libgl1-mesa-glx libgl1-mesa-dri \
    mesa-utils
RUN usermod -a -G video docker


# Add to .rosrc (ENTRYPOINT has no sourced files)

RUN echo "#!/usr/bin/env bash\n# ROS-Specific initialisation of env-variables etc." >> /home/docker/.rosrc &&\
    echo "\nsource /home/docker/workspace/install/setup.bash" >> /home/docker/.rosrc &&\
    echo "export ROS_DOMAIN_ID=42 #SWARMLAB" >> /home/docker/.rosrc


# .bashrc

ADD --chown=docker https://gist.githubusercontent.com/moqmar/28dde796bb924dd6bfb1eafbe0d265e8/raw/f24336f8f2cf7281a095d2b81e50bd2ec4464b22/.bashrc /home/docker/.bashrc

RUN echo "\n###############\n## ROS stuff ##\n###############" >> /home/docker/.bashrc &&\
    echo "\ncd ~/workspace && source install/setup.bash" >> /home/docker/.bashrc &&\
    echo "echo 'Tip: use setup-workspace.sh to quickly install dependencies & build your workspace'" >> /home/docker/.bashrc 
    #&&\
    # Not needed, as done in setup-workspace
    # echo "\nexport ROS_DOMAIN_ID=42 #SWARMLAB" >> /home/docker/.bashrc


ENV HOME=/home/docker
WORKDIR /home/docker
USER docker


# entrypoint with cloning and building workspace

ENTRYPOINT ["/ros_entrypoint.sh", "/usr/local/bin/setup-workspace.sh"]
CMD ["bash"]
