FROM harbor.momar.xyz/driving_swarm/base

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN curl -sSL http://get.gazebosim.org | sh && apt-get update &&\
    apt-get install -y \
      ros-foxy-gazebo-ros-pkgs \
      ros-foxy-cartographer ros-foxy-cartographer-ros \
      ros-foxy-navigation2 ros-foxy-nav2-bringup \
      ros-foxy-turtlebot3-msgs ros-foxy-turtlebot3

RUN echo "export TURTLEBOT3_MODEL=burger" >> /etc/profile

USER docker
