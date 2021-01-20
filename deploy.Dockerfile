FROM ovgudrivingswarm/turtlebot:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG DIR_SSH=ssh
ARG FILE_RUN=basic_run.sh

USER root


# copy ssh-key & own it with chown

COPY ./"$DIR_SSH"/* /home/docker/.ssh/
RUN chown -R docker /home/docker

# basic run script

COPY deploy/"$FILE_RUN" /usr/local/bin/deploy.sh

# overwrite ENTRYPOINT with additional run-file

ENTRYPOINT ["/entrypoint.sh", "/usr/local/bin/setup-workspace.sh", "/usr/local/bin/deploy.sh"]

USER docker
