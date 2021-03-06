FROM ovgudrivingswarm/base:latest

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
      ros-foxy-cartographer ros-foxy-cartographer-ros \
      ros-foxy-navigation2 ros-foxy-nav2-bringup \
      ros-foxy-turtlebot3 ros-foxy-turtlebot3-msgs \
      ros-foxy-turtlebot3-navigation2 ros-foxy-turtlebot3-cartographer

USER docker
