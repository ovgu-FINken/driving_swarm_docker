ARG ROS_VERSION=foxy
FROM ros:$ROS_VERSION

ARG GAZEBO_VERSION=9

RUN apt-get update && apt-get upgrade -y &&\
    apt-get install -y --no-install-recommends software-properties-common &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D2486D2DD83DB69272AFE98867170598AF249743 &&\
    . /etc/os-release && add-apt-repository "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable $VERSION_CODENAME main" &&\
    apt-get update && apt-get install -y libgazebo$GAZEBO_VERSION-dev gazebo$GAZEBO_VERSION

