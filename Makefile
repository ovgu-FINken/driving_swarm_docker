# final deployment-stage
build-dev: build-bot development.Dockerfile development_ssh.Dockerfile development/* #development/ssh*
	docker-compose build ${OPTIONS} development
	docker-compose build ${OPTIONS} development_ssh
	@ touch $@

build-dep: build-bot deploy.Dockerfile deploy/* #deploy/ssh/*
	docker-compose build ${OPTIONS} deploy
	@ touch $@

# intermediate turtlebot3-stage
build-bot: build-base turtlebot.Dockerfile
	docker-compose build ${OPTIONS} turtlebot
	@ touch $@

build-slim: build-base turtleslim.Dockerfile
	docker-compose build ${OPTIONS} turtleslim
	@ touch $@

# base ros-stage+
build-base: base.Dockerfile base/*
	docker-compose build ${OPTIONS} base
	@ touch $@

# full build
.images:
	docker-compose build base
	docker-compose build turtlebot
	docker-compose build deploy
	docker-compose build development

.dind:
	docker run --rm -d --name driving_swarm_docker -v "$PWD:/driving_swarm_docker" --privileged docker:dind
	docker exec -w /driving_swarm_docker driving_swarm_docker sh -c 'apk add --no-cache make docker-compose && make'
	#docker exec driving_swarm_docker docker push ...
	#docker stop driving_swarm_docker
