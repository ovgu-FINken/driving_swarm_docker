ARG ROS_VERSION=foxy
FROM ros:$ROS_VERSION

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
      python3-pip \
      python3-colcon-common-extensions \
      python3-vcstool \
      curl \
      libasio-dev liblog4cxx-dev libxaw7 libx11-dev

RUN git clone https://github.com/ovgu-FINken/driving_swarm_infrastructure.git /opt/driving_swarm_infrastructure
RUN cd /opt/driving_swarm_infrastructure &&\
    /ros_entrypoint.sh colcon build --symlink-install

RUN useradd -m docker -s /usr/bin/bash -G sudo &&\
	{ echo "docker"; echo "docker"; } | passwd docker &&\
	sed -Ei 's/^(%sudo.*\) )ALL$/\1NOPASSWD: ALL/' /etc/sudoers
ADD https://gist.githubusercontent.com/moqmar/28dde796bb924dd6bfb1eafbe0d265e8/raw/f24336f8f2cf7281a095d2b81e50bd2ec4464b22/.bashrc /home/docker/.bashrc
ENV HOME=/home/docker
WORKDIR /home/docker
USER docker
