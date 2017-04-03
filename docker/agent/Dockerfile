# Go.cd agent install in Docker
# NAME: genivi/go-agent
#
# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# For design comments and rant, see server version instead.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
FROM phusion/baseimage:latest

LABEL maintainer "Gunnar Andersson <gand@acm.org>"

ENV GO_SERVER="go.genivi.org"

# Need git to fetch the provisioning script, the rest is done by the script
# Clean as much as possible before committing keeps the docker image size down.
RUN apt-get update ;\
    apt-get install -y git sudo ;\
    apt-get clean ;\
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
#ADD dummy /tmp/dummy

# Fetch script git repo
RUN git clone http://github.com/genivigo/gocd-setup.git /root/gocd-setup 2>&1 && ls /root/gocd-setup

# Run the actual provisioning script -
RUN cd /root/gocd-setup && ./go-agent-setup.sh

# Clean up
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix go-agent settings
RUN sed -ie 's/DAEMON=Y/DAEMON=N/' /etc/default/go-agent ;\
    sed -ie "s!GO_SERVER.*!GO_SERVER_URL=https://${GO_SERVER}:443/go!" /etc/default/go-agent ;\
    sed -ie 's/export GO_SERVER$/export GO_SERVER_URL/' /etc/default/go-agent

# Add service script for "runit" i.e the init/pid 1 used by phusion/baseimage
RUN mkdir /etc/service/go-agent
ADD go-agent.runit.sh /etc/service/go-agent/run

# Use baseimage-docker's init system as default command
CMD ["/sbin/my_init"]

