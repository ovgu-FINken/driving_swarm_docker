# Driving Swarm: Docker

This repository contains all files to get started with one of the following things:

- [x] Develop for Driving Swarm (the easy way) using docker
- [x] Deploy virtualized containers for a Driving Swarm application (for simulation)
- [ ] Deploy virtualized containers on (real) turtlebots

## Prerequisites

- A Linux environment
- [`docker`](https://docs.docker.com/engine/install/)
- For GPU-support: A somewhat current version of Mesa
- For nvidia-GPU-support check [here](#nvidia)
- For Windows check [here](#running-on-windows)

## Quickstart

This gets the pre-built image from `https://hub.docker.com`, you do not need to clone this repo.
All you need is to install [docker](https://docs.docker.com/engine/install/).
Then, just run the following command to start the development container with the directory `./workspace` mounted as `~/workspace`:

```bash
docker run --name ros-development -d -h ros-development \
  --device=/dev/dri \
  -p 127.0.0.1:1800:1800 \
  -p 127.0.0.1:1900:1900 \
  -p 127.0.0.1:5900:5900 \
  -v "$PWD/workspace:/home/docker/workspace" \
  ovgudrivingswarm/development
```

You can now access Theia (an IDE-like code editor) with your browser at `http://127.0.0.1:1900`
and a virtual desktop environment at `http://127.0.0.1:1800` (or with any VNC client (like [Remmina](https://remmina.org/)) at `127.0.0.1:5900`).

- To stop the container, run `docker stop ros-development`
- To restart it, run `docker start ros-development`
- To remove it completely, stop it and then run `docker rm ros-development`.

**For Linux users:** to avoid permission issues, don't change the path `/home/docker/workspace` to anything else.

## Start with docker-compose

This is only needed when making changes to the Dockerfiles or when developing one yourself.

You will additionally need [Git](https://git-scm.com/downloads) and [Docker Compose](https://docs.docker.com/compose/install/).

To start a docker-container named `image`:
```bash
git clone git@github.com:ovgu-FINken/driving_swarm_docker.git
cd driving_swarm_docker
docker-compose up image
```

- To access a shell in a running container, you can use `docker-compose exec image bash`.
- You can also create a temporary container and run a command in it with `docker-compose run --rm image bash`

### Using make and manual builds

Manually building will take a long time.

To build a specific image with docker-compose use:

```bash
git clone git@github.com:ovgu-FINken/driving_swarm_docker.git
cd driving_swarm_docker
docker-compose build image
```

You can also just run `make image` to make the respective image.

## GPU Acceleration

By default (and using the command above), GPU-acceleration is enabled.
If you want to disable GPU acceleration, pass `-e DISABLE_GPU=1` to your start command.

### Intel, AMD

This should just work, if you have a somewhat recent version of Mesa installed in your Linux environment.

### nvidia

- Using nvidia-GPUs with nouveau (the free driver for Linux) GPU-support should just work
- Using nvidia-GPUs with the proprietary driver, you need [nvidia-docker](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)
- On Windows you need:
  - [WSL2](https://docs.microsoft.com/de-de/windows/wsl/install-win10)
  - [CUDA on WSL](https://developer.nvidia.com/cuda/wsl)
  - [WSL2 docker-backend](https://docs.docker.com/docker-for-windows/wsl/)

Then, instead of `docker run` in the launch command [above](#quickstart), use `nvidia-docker run --gpus all`.

## Running on Windows
This should theoretically run on Windows, it has **not been tested yet** however.

You will need the [WSL2](https://docs.microsoft.com/de-de/windows/wsl/install-win10) and [docker on WSL2](https://docs.docker.com/docker-for-windows/wsl/) for running on Windows.

Furthermore you will need to:
- Replace the `$PWD` in the [command](#quickstart) with `%cd%`
- ...

