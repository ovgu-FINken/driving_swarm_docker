FROM harbor.momar.xyz/driving_swarm/base

ARG GAZEBO_VERSION=9

USER root

RUN curl -sSL http://get.gazebosim.org | sh &&\
    apt-get install -y \
      libgazebo$GAZEBO_VERSION-dev gazebo$GAZEBO_VERSION \
      ros-dashing-gazebo-ros-pkgs \
      ros-dashing-cartographer ros-dashing-cartographer-ros \
      ros-dashing-navigation2 ros-dashing-nav2-bringup

RUN mkdir /opt/turtlebot3_ws && cd /opt/turtlebot3_ws &&\
    wget https://raw.githubusercontent.com/ROBOTIS-GIT/turtlebot3/ros2/turtlebot3.repos &&\
    vcs import src < turtlebot3.repos &&\
    /ros_entrypoint.sh colcon build --symlink-install &&\
    echo "source ~/turtlebot3_ws/install/setup.bash" >> /etc/profile &&\
    echo "export ROS_DOMAIN_ID=30 #TURTLEBOT3" >> /etc/profile

RUN cd /opt/driving_swarm_infrastructure &&\
    vcs import src < repo-files/turtlebot3.repos &&\
    /ros_entrypoint.sh rosdep install --ignore-src &&\
    /ros_entrypoint.sh colcon build --symlink-install

USER docker
