# This should be a large disk location (host path) where build sandboxes are
# stored, i.e. all intermediate and final build files!
# 1. Make sure it exists!
# 2. Make sure the "go" user inside container can write to it on the host
# (make it writable by all and then when uid is known you can create
# limits)
PIPELINES_STORAGE ?= /mnt/go/go-agent-pipelines

default:
	@echo "make [build|run|clean|logs|shell|stop|kill]"

build:
	docker build --tag=genivi/go-agent:latest .

run:
	@test -n "${CONTAINER_HOSTNAME}" && docker run -h "${CONTAINER_HOSTNAME}" -d -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=go-agent genivi/go-agent:latest || true
	@test -z "${CONTAINER_HOSTNAME}" && echo "No ${CONTAINER_HOSTNAME} defined -> random" && docker run -d -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=go-agent genivi/go-agent:latest || true
	@echo "docker run -h ${CONTAINER_HOSTNAME} -d --name=go-agent genivi/go-agent:latest"
	

clean:
	@echo "docker rm go-agent"
	@docker rm go-agent >/dev/null || echo "Container removed already"
	@echo docker rmi genivi/go-agent:latest 
	@docker rmi genivi/go-agent:latest 2>/dev/null || echo "Image removed already"

logs:
	docker logs -f go-agent

shell:
	docker exec -it go-agent /bin/bash

stop:
	docker stop go-agent

kill:
	docker kill go-agent
	docker rm go-agent

