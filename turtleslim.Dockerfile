FROM harbor.momar.xyz/driving_swarm/base

ARG DEBIAN_FRONTEND=noninteractive

USER root


RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
      # installs gazebo11 (and is not needed?) ros-foxy-gazebo-ros-pkgs \
      ros-foxy-cartographer ros-foxy-cartographer-ros \
      ros-foxy-navigation2 ros-foxy-nav2-bringup \
      ros-foxy-turtlebot3 ros-foxy-turtlebot3-msgs \
      ros-foxy-turtlebot3-navigation2 ros-foxy-turtlebot3-cartographer

USER docker
