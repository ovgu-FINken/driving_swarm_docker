ARG key_file=deploy.key
ARG run_file=basic_run.sh

FROM harbor.momar.xyz/driving_swarm/turtlebot

ARG DEBIAN_FRONTEND=noninteractive

USER root


# copy ssh-key

COPY deploy/${key_file} /home/docker/.ssh/deploy.key


# basic run script

COPY deploy/${run_file} /usr/local/bin/deploy.sh


# overwrite ENTRYPOINT with additional run-file

ENTRYPOINT ["/ros_entrypoint.sh", "/usr/local/bin/setup-workspace.sh", "/usr/local/bin/deploy.sh"]


USER docker 
