CONTAINER_NAME ?= go-server
IMAGE_NAME ?= genivi/go-server

# External IP / Ports
GO_SERVER_IP ?= 127.0.0.1
# Port 8153 which is HTTP and therefore normally mapped to 80
GO_SERVER_PORT_80_8153 ?= 80
# Port 8154 which is HTTPS and therefore normally mapped to 443
GO_SERVER_PORT_443_8154 ?= 443

# This is a large disk location (host path) where artifacts volume will be # mapped to
# 1. Make sure it exists!
# 2. Make sure the "go" user inside container can write to it on the host
# (make it writable by all and then when uid is known you can create
# limits)
ARTIFACT_STORAGE ?= /mnt/go/go-server-artifacts

# Same principle for pipelines (but they don't require quite as much
# storage -- this is where the server clones the git repos to monitor
# them for changes but build results are not here - they are on go *agents*
# and in artifacts dir.
PIPELINES_STORAGE ?= /mnt/go/go-server-pipelines

# Recommend not changing this - it's easier to remember if the same
# is used on host and in container.  The container uses /gousers
USERFILE_STORAGE ?= /gousers

default:
	@echo "make [build|run|clean|logs|shell|stop|kill]"

build:
	@echo "VVVV"
	@echo "NOTE - YOU MUST READ AND RENAME .github.readthis first!"
	@echo "Abort this (CTRL-C) if you have not (waiting 4 seconds...)"
	@echo "^^^^"
	@sleep 4
	docker build --tag=${IMAGE_NAME}:latest .


run:
	docker run -d -ti -v ${USERFILE_STORAGE}:/gousers \
	   -v ${ARTIFACT_STORAGE}:/var/lib/go-server/artifacts \
	   -v ${PIPELINES_STORAGE}:/var/lib/go-server/pipelines \
	   --name=${CONTAINER_NAME} -p 8153-8154:8153-8154 \
	   -p ${GO_SERVER_IP}:${GO_SERVER_PORT_80_8153}:8153 \
	   -p ${GO_SERVER_IP}:${GO_SERVER_PORT_443_8154}:8154 ${IMAGE_NAME}:latest \
	   /sbin/my_init /bin/bash
	@echo
	@echo "OK - now running.  IMPORTANT! Now replace ${USERFILE_STORAGE}/users with an appropriate password file containing your existing users."
	@echo "If you have no existing users, make sure the file is empty"
	@echo 
	@echo 'Go server seems to reset the password file location on first run - waiting 30 seconds and setting it to what we want.'
	sleep 30
	docker exec ${CONTAINER_NAME} sed -i 's@passwordFile path="/.*"@passwordFile path="${USERFILE_STORAGE}/users"@' /etc/go/cruise-config.xml
	@echo
	@echo "OK it should be done.  If not, attach and check that passwordFile is set to ${USERFILE_STORAGE} in /etc/go/cruise-config.xml"
	@echo
	@echo "To attach to the container, run:"
	@echo "docker attach ${CONTAINER_NAME}"
	@echo "Then to leave the attached terminal, do not exit - use CTRL-P CTRL-Q!"
	@echo

clean:
	@echo "docker rm -v ${CONTAINER_NAME}"
	@docker rm -v ${CONTAINER_NAME} >/dev/null || echo "Container removed already"
	@echo docker rmi ${IMAGE_NAME}:latest 
	@docker rmi ${IMAGE_NAME}:latest 2>/dev/null || echo "Image removed already"

logs:
	docker logs -f ${CONTAINER_NAME}

shell:
	docker exec -it ${CONTAINER_NAME} /bin/bash

stop:
	docker stop ${CONTAINER_NAME}

kill:
	docker kill ${CONTAINER_NAME} || docker rm ${CONTAINER_NAME}
	docker rm -v ${CONTAINER_NAME}

