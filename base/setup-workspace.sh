#!/bin/bash
set -euo pipefail

mkdir -p ~/workspace/src
cd ~/workspace
if ! compgen -G "*.repos"; then
  echo 'repositories:' > dependencies.repos
  echo '  driving_swarm_infrastructure:' >> dependencies.repos
  echo '    type: git' >> dependencies.repos
  echo '    url: https://github.com/ovgu-FINken/driving_swarm_infrastructure.git' >> dependencies.repos
  echo '    version: master' >> dependencies.repos
fi

cat *.repos | vcs import src
sudo rosdep install -i --from-path src --rosdistro foxy -y
colcon build

set +euo pipefail
source install/setup.bash
if [ $# -gt 0 ]; then exec "$@"; fi
