# final development-stage
build-development: build-turtlebot development.Dockerfile development/*
	docker-compose build ${OPTIONS} development
	@ touch $@

build-deploy: build-bot deploy.Dockerfile deploy/*
	docker-compose build ${OPTIONS} deploy
	@ touch $@

# intermediate turtlebot3-stage
build-turtlebot: build-base turtlebot.Dockerfile
	docker-compose build ${OPTIONS} turtlebot
	@ touch $@

build-turtlebot-slim: build-base turtleslim.Dockerfile
	docker-compose build ${OPTIONS} turtlebot-slim
	@ touch $@

# base ros-stage
build-base: base.Dockerfile base/*
	docker-compose build ${OPTIONS} base
	@ touch $@

.no-cache:
	make build-development OPTIONS=--no-cache

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
	docker stop driving_swarm_docker
