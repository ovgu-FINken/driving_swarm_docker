# Driving Swarm: Docker

This repository contains all files to get started with one of the following things:

- develop for the Driving Swarm (the easy way)
- deploying virtualized containers for Driving Swarm application (for simulation, or even directly on the robots)

## Develop for the Driving Swarm (the easy way)

All you need is [Docker](https://docs.docker.com/engine/install/) - then, just run the following command to start the development container with the current directory mounted as `~/workspace`:

```bash
docker run --name ros-development -d -h ros-development \
  -p 127.0.0.1:1800:8080 \
  -p 127.0.0.1:1900:1900 \
  -p 127.0.0.1:5900:5900 \
  -v "$PWD:/home/docker/workspace" \
  -v "$HOME/.ssh:/home/docker/.ssh" \
  ovgudrivingswarm/development
```

You can now access your development environment at http://127.0.0.1:1900, or with any VNC client (like [Remmina](https://remmina.org/)) at `127.0.0.1:5900`.

To stop the container again, run `docker stop ros-development`, to start it again, run `docker start ros-development`, and to remove it completely, stop it and then run `docker rm ros-development`.

**For Windows users:** replace the `$PWD` in the command with `%cd%`.

**For Linux users:** to avoid permission issues, don't change the path `/home/docker/workspace` to anything else.

To access a shell in the container, you can use `docker-compose exec dev bash`

## Hardware Acceleration

For NVIDIA GPUs you need [nvidia-docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker), and on Windows additionally
[CUDA on WSL](https://developer.nvidia.com/cuda/wsl), as well as the [WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl/) for Docker.  
Then, instead of `docker run` inf the launch command above, use `nvidia-docker run --gpus all`.

On Intel and AMD, everything should work out of the box.

If you want to disable GPU acceleration, pass `-e DISABLE_GPU=1` to your start command.

## Build & start the container directly from the repository

This is only needed when making changes to the Docker images themselves, and will take a long time.

You will additionally need [Git](https://git-scm.com/downloads) and [Docker Compose](https://docs.docker.com/compose/install/).

```bash
git clone git@github.com:ovgu-FINken/driving_swarm_docker.git
cd driving_swarm_docker
docker-compose up --build
```
