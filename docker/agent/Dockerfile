# Go.cd agent install in Docker
# NAME: genivi/go-agent
#
# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# For design comments and rant, see server version instead.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
FROM phusion/baseimage:latest

LABEL maintainer "Gunnar Andersson <gandersson@genivi.org>"

ENV GO_SERVER="go.genivi.org"

# Location of yocto cache for downloads/sstate inside container
ENV YOCTO_CACHE=/var/cache/yocto

# Need git to fetch the provisioning script, the rest is done by the script
# Clean as much as possible before committing keeps the docker image size down.
RUN apt-get update ;\
    apt-get install -y git sudo qemu-system-x86 uml-utilities;\
    apt-get clean ;\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
#ADD dummy /tmp/dummy

# Fetch script git repo
RUN git clone http://github.com/genivigo/gocd-setup.git -b lava_agent /root/gocd-setup 2>&1 && ls /root/gocd-setup

# Run the actual provisioning script -
RUN cd /root/gocd-setup && ./go-agent-setup.sh

# Not sure why this isn't being run on first install..  Anyway let's try
# running it explicitly from here.  If the script is there it should work,
# if not the docker build will fail, which is good so we know.
ENV DEBIAN_FRONTEND=noninteractive
RUN /etc/cron.hourly/go-agent-config-cronjob

# Clean up
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix go-agent settings
RUN sed -ie 's/DAEMON=Y/DAEMON=N/' /etc/default/go-agent ;\
    sed -ie "s!GO_SERVER.*!GO_SERVER_URL=https://${GO_SERVER}:443/go!" /etc/default/go-agent ;\
    sed -ie 's/export GO_SERVER$/export GO_SERVER_URL/' /etc/default/go-agent

# Add service script for "runit" i.e the init/pid 1 used by phusion/baseimage
# and other needed dirs
RUN mkdir -p /etc/service/go-agent "$YOCTO_CACHE"
ADD go-agent.runit.sh /etc/service/go-agent/run

RUN usermod -a -G kvm go

# Install keys & credentials
RUN mkdir -p /var/go/.ssh ;\
    chown go:go /var/go/.ssh ;\
    chmod 700 /var/go/.ssh

ADD cip_lava_lab_cred /var/go/cip_lava_lab_cred
RUN chown go /var/go/cip_lava_lab_cred

ADD id_rsa /var/go/.ssh/id_rsa
ADD id_rsa.pub /var/go/.ssh/id_rsa.pub
RUN chown -R go /var/go/.ssh/* ;\
    chmod 400 /var/go/.ssh/id_rsa* ;\
    chmod 400 /var/go/cip_lava_lab_cred

# Accept host key
RUN su go -c "echo quit | sftp -i /var/go/.ssh/id_rsa -o StrictHostKeyChecking=no go_artifact_upload@docs.projects.genivi.org" || true

# Use baseimage-docker's init system as default command
CMD ["/sbin/my_init"]

