#!/bin/bash
set -euo pipefail

mkdir -p ~/workspace/src
cd ~/workspace
if ! compgen -G "*.repos" >/dev/null; then
  echo 'repositories:' > dependencies.repos
  echo '  driving_swarm_infrastructure:' >> dependencies.repos
  echo '    type: git' >> dependencies.repos
  echo '    url: https://github.com/ovgu-FINken/driving_swarm_infrastructure.git' >> dependencies.repos
  echo '    version: master' >> dependencies.repos
  echo '  turtlebot3/turtlebot3_simulations:' >> dependencies.repos
  echo '    type: git' >> dependencies.repos
  echo '    url: https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git' >> dependencies.repos
  echo '    version: ros2' >> dependencies.repos
fi
if ! [ -d .git ]; then
  git init
fi
if ! [ -f .gitignore ]; then
  echo 'build/' > .gitignore
  echo 'install/' >> .gitignore
  echo 'log/' >> .gitignore
  echo '.ssh/' >> .gitignore
fi

cat *.repos | vcs import src
sudo rosdep install -i --from-path src --rosdistro foxy -y
colcon build

set +euo pipefail

source ~/.rosrc
if [ $# -gt 0 ]; then exec "$@"; fi
