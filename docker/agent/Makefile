# This should be a large disk location (host path) where build sandboxes are
# stored, i.e. all intermediate and final build files!
# 1. Make sure it exists!
# 2. Make sure the "go" user inside container can write to it on the host
# (make it writable by all and then when uid is known you can create
# limits)
PIPELINES_STORAGE ?= /mnt/go/go-agent-pipelines

IMAGE_NAME ?= genivi/go-agent
CONTAINER_NAME ?= go-agent
CONTAINER_NAME_VBOX ?= go-agent-vbox
#CONTAINER_HOSTNAME ?= go-agent_docker
#CONTAINER_HOSTNAME_VBOX ?= go-agent-vbox_docker

default:
	@echo "make [build|build_vbox|run|run_vbox|clean|logs|shell|stop|kill]"

build:
	docker build --tag=${IMAGE_NAME}:latest .

buildnew:
	docker build --no-cache --tag=${IMAGE_NAME}:latest .

run:
	@echo "Running:  docker run <hostname setup> -d --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest (with volumes -- see Makefile)"
	@test -n "${CONTAINER_HOSTNAME}" && docker run -h "${CONTAINER_HOSTNAME}" -d -ti -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest /sbin/my_init /bin/bash || true
	@test -z "${CONTAINER_HOSTNAME}" && echo "No ${CONTAINER_HOSTNAME} defined -> random" && docker run -d -ti -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest /sbin/my_init /bin/bash || true

# Variant with Virtualbox installation (needs Virtualbox installed and also the host vboxdrv mounted into container)
build_vbox:
	docker build -f Dockerfile.vbox --tag=${IMAGE_NAME}_vbox:latest .

run_vbox:
	@echo "Running:  docker run [hostname setup] -d --name=${CONTAINER_NAME_VBOX} ${IMAGE_NAME}_vbox:latest [with volumes -- see Makefile]"
	@test -n "${CONTAINER_HOSTNAME_VBOX}" && docker run -h "${CONTAINER_HOSTNAME_VBOX}" -d -v /dev/vboxdrv:/dev/vboxdrv -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=${CONTAINER_NAME_VBOX} ${IMAGE_NAME}_vbox:latest /sbin/my_init /bin/bash || true
	@test -z "${CONTAINER_HOSTNAME_VBOX}" && echo "No ${CONTAINER_HOSTNAME_VBOX} defined -> random" && docker run -d -v /dev/vboxdrv:/dev/vboxdrv -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" --name=${CONTAINER_NAME_VBOX} ${IMAGE_NAME}_vbox:latest /sbin/my_init /bin/bash || true 


clean:
	@echo "docker rm -v ${CONTAINER_NAME}"
	@docker rm -v ${CONTAINER_NAME} >/dev/null || echo "Container removed already"
	@echo docker rmi ${IMAGE_NAME}:latest 
	@docker rmi ${IMAGE_NAME}:latest 2>/dev/null || echo "Image removed already"


logs:
	docker logs -f go-agent

shell:
	docker exec -it go-agent /bin/bash

stop:
	docker stop go-agent

kill:
	docker kill go-agent
	docker rm go-agent

