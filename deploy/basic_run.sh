#!/bin/sh

echo "basic_run script"

# source install
echo "- source install"
source /home/docker/workspace/install/setup.bash

# roslaunch basic headless gazebo
# TODO actually launch headless launch file (provide with repo?)
echo "- roslaunch basic headless gazebo"
vglrun ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
