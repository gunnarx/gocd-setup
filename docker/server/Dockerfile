# Go.cd server install in Docker
# NAME: genivi/go-server
#
# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# This seemingly does about the same as github/gocd/gocd-docker(*) but 
# nowadays the script does a whole lot more.
#
# Most of all I think it is ~bad~ to hide provisioning inside Dockerfiles.
# The steps should be reusable in other environments too.  If you want to
# do the installation on bare metal, or in Vagrant, or whatever - then a
# bourne shell script(s) is more reusable.
#
# There are some special settings for this go-cd and yes, those additions
# could have been layered on top of for example the gocd/gocd-docker Docker
# image.  That would be quite nice. But see above :)
#
# Anyway, phusion baseimage seem to get it right with respect to an actual
# good base container, so let's start there.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
FROM gocd/gocd-server:v19.1.0

LABEL maintainer "Gunnar Andersson <gandersson@genivi.org>"

# Required packages (for manipulating the TLS certificates)
USER root
RUN apk add openssl

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
ADD dummy /tmp/dummy

# Fetch script git repo
RUN git clone -b v2.0 http://github.com/gunnarx/gocd-setup.git /tmp/gocd-setup 2>&1 && ls /tmp/gocd-setup

# Run the actual provisioning script -
RUN cd /tmp/gocd-setup && git rev-parse HEAD
RUN cd /tmp/gocd-setup && ./go-server-setup.sh

# Store OAUTH user/token used for Pull-Request plugin
ADD .github /var/go/.github
RUN chown go /var/go/.github ; chmod 700 /var/go/.github

# Ports
EXPOSE 8153 8154

# Use baseimage-docker's init system as default command
CMD ["/docker-entrypoint.sh"]

