#!/usr/bin/env bash

echo "basic_run script"

# TODO better gpu-check
#echo "- check glxinfo-renderer"
#echo "  $(vglrun glxinfo | grep renderer)"

# done in setup-workspace
#echo "- source .rosrc"
#source /home/docker/.rosrc

echo "- check TURTLEBOT3_MODEL"
echo "  $TURTLEBOT3_MODEL"

# roslaunch basic headless gazebo
# TODO actually launch headless launch file (provide with repo?)
echo "- roslaunch basic headless gazebo"
#vglrun ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py
