images:
	docker-compose build base
	docker-compose build bots
	docker-compose build dev
dind:
	docker run --rm -d --name driving_swarm_docker -v "$PWD:/driving_swarm_docker" --privileged docker:dind
	docker exec -w /driving_swarm_docker driving_swarm_docker sh -c 'apk add --no-cache make docker-compose && make'
	#docker exec driving_swarm_docker docker push ...
	#docker stop driving_swarm_docker
