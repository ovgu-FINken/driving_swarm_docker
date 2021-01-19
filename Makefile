.PHONY: no-cache dind

development: turtlebot development.Dockerfile development/*
	docker-compose build ${OPTIONS} development

turtlebot: base turtlebot.Dockerfile
	docker-compose build ${OPTIONS} turtlebot

base: docker-compose.yml base.Dockerfile base/*
	docker-compose build ${OPTIONS} base

no-cache:
	make development OPTIONS=--no-cache

dind:
	docker run --rm -d --name driving_swarm_docker -v "$PWD:/driving_swarm_docker" --privileged docker:dind
	docker exec -w /driving_swarm_docker driving_swarm_docker sh -c 'apk add --no-cache make docker-compose && make'
	#docker exec driving_swarm_docker docker push ...
	docker stop driving_swarm_docker
