# ---------------------------------------------------------------------
#  --- SETTINGS ---
#
#  (These can also be passed via the environment)
#
# NOTE: For SELinux (Fedora, etc) also remember to uncomment the chcon line below!!
#
# The pipelines storage should be a large disk location (host path) where
# build sandboxes are stored, i.e. all intermediate and final build files!
# We need to make sure it exist, and that the "go" user inside the
# container can write to it.  For now this is done automatically below -
# making it writable for all.  Once you know the uid of the container user,
# you could limit the user if you wish.

PIPELINES_STORAGE ?= /home/go/go-agent-pipelines

# Set a unique name here
CONTAINER_HOSTNAME ?= docssite-agent

# This is the default location. If you can place it on SSD (~120GB) then
# that's an even better option - otherwise just leave it.
YOCTO_CACHE ?= ${PIPELINES_STORAGE}/__yocto_cache

# ---------------------------------------------------------------------
#  Other settings, normally not changed

IMAGE_NAME ?= genivi/go-agent
CONTAINER_NAME ?= docssite-agent

# This is a special version of the agent - you can ignore it for now.
CONTAINER_NAME_VBOX ?= go-agent-vbox
CONTAINER_HOSTNAME_VBOX ?= go-agent-vbox

# This is a special version that supports running QEMU in container - for
# executing automated system tests with QEMU.  Only the run command differs
CONTAINER_NAME_QEMU ?= go-agent-qemu
CONTAINER_HOSTNAME_QEMU ?= yournamehere-go-qemu-agent

default:
	@echo "make [build|build_vbox|run|run_vbox|clean|logs|shell|stop|kill]"

build:
	docker build --tag=${IMAGE_NAME}:latest .

buildnew:
	docker build --no-cache --tag=${IMAGE_NAME}:latest .

run:
	sudo mkdir -p "${PIPELINES_STORAGE}" "${YOCTO_CACHE}"
	# Make writable, because we don't know the uid of go user.  Better fix this inside of container later.
	sudo chmod 777 "${PIPELINES_STORAGE}" "${YOCTO_CACHE}"
	# Uncomment and run the chcon if running Fedora or other selinux enabled system! Otherwise, there's no write access
	#sudo chcon -Rt svirt_sandbox_file_t "${PIPELINES_STORAGE}" "${YOCTO_CACHE}"
	@echo "Running:  docker run <hostname setup> -d -ti --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest (with volumes -- see Makefile)"
	docker run -h "${CONTAINER_HOSTNAME}" -d -ti -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" -v "${YOCTO_CACHE}:/var/cache/yocto" --name=${CONTAINER_NAME} ${IMAGE_NAME}:latest /sbin/my_init /bin/bash || true

# QEMU variant -- the image is the same as the standard one, only run
# command differs
run_qemu:
	@echo "Running:  docker run <hostname setup> -d -ti --name=${CONTAINER_NAME_QEMU} ${IMAGE_NAME}:latest (with volumes -- see Makefile)"
	docker run -h "${CONTAINER_HOSTNAME_QEMU}" -d -ti --cap-add=NET_ADMIN --device=/dev/net/tun --device=/dev/kvm -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" -v "${YOCTO_CACHE}:/var/cache/yocto" --name=${CONTAINER_NAME_QEMU} ${IMAGE_NAME}:latest /sbin/my_init /bin/bash || true

# Variant with Virtualbox installation (needs Virtualbox installed and also the host vboxdrv mounted into container)
build_vbox:
	docker build -f Dockerfile.vbox --tag=${IMAGE_NAME}_vbox:latest .

run_vbox:
	@echo "Running:  docker run [hostname setup] -d -ti --name=${CONTAINER_NAME_VBOX} ${IMAGE_NAME}_vbox:latest [with volumes -- see Makefile]"
	docker run -h "${CONTAINER_HOSTNAME_VBOX}" -d -ti -v /dev/vboxdrv:/dev/vboxdrv -v "${PIPELINES_STORAGE}:/var/lib/go-agent/pipelines" -v "${YOCTO_CACHE}:/var/cache/yocto" --name=${CONTAINER_NAME_VBOX} ${IMAGE_NAME}_vbox:latest /sbin/my_init /bin/bash || true

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
	docker kill ${CONTAINER_NAME}
	docker rm ${CONTAINER_NAME}

