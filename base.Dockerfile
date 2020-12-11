ARG ROS_VERSION=foxy
FROM ros:$ROS_VERSION

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install \
      python3-pip \
      python3-colcon-common-extensions \
      python3-vcstool \
      curl nano openssh-client

COPY base/setup-workspace.sh /usr/local/bin/setup-workspace.sh

RUN useradd -m docker -s /usr/bin/bash -G sudo &&\
	{ echo "docker"; echo "docker"; } | passwd docker &&\
	sed -Ei 's/^(%sudo.*\) )ALL$/\1NOPASSWD: ALL/' /etc/sudoers
ADD --chown=docker https://gist.githubusercontent.com/moqmar/28dde796bb924dd6bfb1eafbe0d265e8/raw/f24336f8f2cf7281a095d2b81e50bd2ec4464b22/.bashrc /home/docker/.bashrc
RUN echo 'if ! [ -f ~/.ssh/id_ed25519 ]; then ssh-keygen -t ed25519 -C "" -N "" -f ~/.ssh/id_ed25519; fi' >> /home/docker/.bashrc
RUN echo "cd ~/workspace && source install/setup.bash" >> /home/docker/.bashrc
RUN echo "echo 'Tip: use setup-workspace.sh to quickly install dependencies & build your workspace'" >> /home/docker/.bashrc
ENV HOME=/home/docker
WORKDIR /home/docker
USER docker

ENTRYPOINT ["/ros_entrypoint.sh", "/usr/local/bin/setup-workspace.sh"]
CMD ["bash"] 
