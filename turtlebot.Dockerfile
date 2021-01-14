FROM harbor.momar.xyz/driving_swarm/base

ARG DEBIAN_FRONTEND=noninteractive
ARG GAZEBO_VERSION=11

USER root


#RUN curl -sSL http://get.gazebosim.org | sh && apt-get update &&\
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" > /etc/apt/sources.list.d/gazebo-stable.list &&\
    curl https://packages.osrfoundation.org/gazebo.key | apt-key add - &&\
    apt-get update && apt-get install -y --no-install-recommends \
      gazebo"$GAZEBO_VERSION" \
      ros-foxy-gazebo-ros-pkgs \
      ros-foxy-cartographer ros-foxy-cartographer-ros \
      ros-foxy-navigation2 ros-foxy-nav2-bringup \
      ros-foxy-turtlebot3 ros-foxy-turtlebot3-msgs \
      ros-foxy-turtlebot3-navigation2  ros-foxy-turtlebot3-description \
      ros-foxy-turtlebot3-cartographer


RUN echo "export TURTLEBOT3_MODEL=burger" >> /home/docker/.rosrc 
    # &&\
    # Not needed, as done in setup-workspace
    # echo "export TURTLEBOT3_MODEL=burger" >> /home/docker/.bashrc


USER docker
