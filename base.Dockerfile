ARG ROS_VERSION=foxy

FROM ros:$ROS_VERSION

ARG DEBIAN_FRONTEND=noninteractive
ARG VIRTUALGL_VERSION=2.6.80


# apt upgrade + additional base-packages,
# buildtools, introspection tools

RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y --no-install-recommends \
      python3-pykdl
RUN apt-get install -y --no-install-recommends \
      gcc g++ \
      python3-pip \
      curl openssh-client \
      nano less &&\
    ln -s /usr/bin/python3 /usr/bin/python &&\
    ln -s /usr/bin/pip3 /usr/bin/pip


# add docker user

RUN useradd -m docker -s /usr/bin/bash -G sudo &&\
	{ echo "docker"; echo "docker"; } | passwd docker &&\
	sed -Ei 's/^(%sudo.*\) )ALL$/\1NOPASSWD: ALL/' /etc/sudoers


# GPU-support for Intel (and AMD?)

# Try for newest mesa-libs
RUN echo "deb http://ppa.launchpad.net/kisak/kisak-mesa/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list &&\
    echo "deb-src http://ppa.launchpad.net/kisak/kisak-mesa/ubuntu $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EB8B81E14DA65431D7504EA8F63F0F2B90935439 &&\
	apt-get update &&\
    apt-get install -y --no-install-recommends \
      libgl1-mesa-glx libgl1-mesa-dri \
      mesa-utils \
      libvulkan1 vulkan-utils

# video is required everywhere, render exists on Elementary OS and probably a few others
RUN groupadd -r -g 109 render && usermod -a -G render docker && usermod -a -G video docker

# Make NVIDIA work!
COPY base/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

# For virtualgl
RUN curl -fsSLo /tmp/virtualgl.deb https://s3.amazonaws.com/virtualgl-pr/dev/linux/virtualgl_${VIRTUALGL_VERSION}_amd64.deb &&\
    apt-get install -y /tmp/virtualgl.deb &&\
    rm /tmp/virtualgl.deb &&\
    chmod u+s /usr/lib/libvglfaker.so &&\
    chmod u+s /usr/lib/libdlfaker.so &&\
    printf "3\nn\nx\n" | vglserver_config

# Add to .rosrc (ENTRYPOINT has no sourced files)

RUN echo "#!/usr/bin/env bash\n# ROS-Specific initialisation of env-variables etc." >> /home/docker/.rosrc &&\
    echo "\nsource /opt/ros/foxy/setup.bash" >> /home/docker/.rosrc &&\
    echo "source /home/docker/workspace/install/setup.bash" >> /home/docker/.rosrc &&\
    echo "export ROS_DOMAIN_ID=42 #SWARMLAB" >> /home/docker/.rosrc


# .bashrc

ADD --chown=docker https://gist.githubusercontent.com/moqmar/28dde796bb924dd6bfb1eafbe0d265e8/raw/0875a60c093f6ffbaaadf1feb31d0731023e017b/.bashrc /home/docker/.bashrc

RUN echo "\ncd ~/workspace && source ~/.rosrc" >> /home/docker/.bashrc &&\
    echo 'if [ -d ~/workspace/.ssh ] && [ -n "$(ls ~/workspace/.ssh)" ]; then ssh-add ~/workspace/.ssh/*; fi' >> /home/docker/.bashrc &&\
    echo "echo 'Tip: use setup-workspace.sh to quickly install dependencies & build your workspace'" >> /home/docker/.bashrc

# scripts

# for using virtualgl / vglrun
COPY base/entrypoint.sh /entrypoint.sh
# for using vcstool, rosdep and colcon to setup the workspace
COPY base/setup-workspace.sh /usr/local/bin/setup-workspace.sh


ENV HOME=/home/docker
VOLUME /home/docker/workspace
WORKDIR /home/docker/workspace
USER docker


# entrypoint with cloning and building workspace

ENTRYPOINT ["/entrypoint.sh", "/usr/local/bin/setup-workspace.sh"]
CMD ["bash"]
