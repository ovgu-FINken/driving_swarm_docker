FROM harbor.momar.xyz/driving_swarm/base

ARG DEBIAN_FRONTEND=noninteractive
USER root

RUN curl -sSL http://get.gazebosim.org | sh && apt-get update &&\
    apt-get install -y \
      ros-foxy-gazebo-ros-pkgs \
      ros-foxy-cartographer ros-foxy-cartographer-ros \
      ros-foxy-navigation2 ros-foxy-nav2-bringup \
      ros-foxy-turtlebot3-msgs ros-foxy-turtlebot3

RUN echo "source ~/turtlebot3_ws/install/setup.bash" >> /etc/profile &&\
    echo "export ROS_DOMAIN_ID=30 #TURTLEBOT3" >> /etc/profile

USER docker
