ARG key-file=ssh_key
ARG run-file=basic_run.sh

FROM harbor.momar.xyz/driving_swarm/turtlebot

ARG DEBIAN_FRONTEND=noninteractive

USER root


# copy ssh-key

COPY deploy/${key-file} /home/docker/.ssh/ssh_key
# no need to run ssh-agent -s?
RUN ssh-add /home/docker/.ssh/ssh_key

# basic run script

COPY deploy/${run-file} /usr/local/bin/deploy.sh


# overwrite ENTRYPOINT with additional run-file

ENTRYPOINT ["/ros_entrypoint.sh", "/usr/local/bin/setup-workspace.sh", "/usr/local/bin/deploy.sh"]


USER docker 
