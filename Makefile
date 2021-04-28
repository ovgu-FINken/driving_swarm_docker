# final development-stage
build-development: build-turtlebot development.Dockerfile development/*
	docker-compose build ${OPTIONS} development
	@ touch $@

# intermediate turtlebot3-stage
build-turtlebot: build-turtlebot-slim turtlebot.Dockerfile
	docker-compose build ${OPTIONS} turtlebot
	@ touch $@

build-turtlebot-slim: build-base turtlebot-slim.Dockerfile
	docker-compose build ${OPTIONS} turtlebot-slim
	@ touch $@

# base ros-stage
build-base: base.Dockerfile base/*
	docker-compose build ${OPTIONS} base
	@ touch $@

.no-cache:
	make build-development OPTIONS=--no-cache
