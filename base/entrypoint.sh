#!/bin/bash
set -e

for DRM in /dev/dri/card*; do
  if /opt/VirtualGL/bin/eglinfo "$DRM" > /dev/null; then
    export VGL_DISPLAY="$DRM"
    break
  fi
done

eval $(ssh-agent)
if [ -d ~docker/workspace/.ssh ] && [ -n "$(ls ~docker/workspace/.ssh)" ]; then ssh-add ~docker/workspace/.ssh/*; fi

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"

if [ "$#" -gt 0 ]; then
  exec "$@"
fi
