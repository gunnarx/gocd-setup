# (C) 2015, Gunnar Andersson
# License: CC-BY-4.0 (for baseimage refer to phusion/baseimage)

# This does basically the same as github/gocd/gocd-docker(*) but I happen
# to think it is -evil- to hide provisioning inside Dockerfiles.
# All that work should be reusable in other environments too!  
# If you want to do the installation on bare metal, or in Vagrant, or
# whatever - then bourne shell script(s) are reusable.
#
# So for that reason, here's me reinventing the provisioning steps :) or
# actually I had done it already before since Dockerizing the server was
# not my primary approach.
#
# ...and Docker syntax is freaking bizarre too :) </rant>
#
# (*) There are some special settings for this go-cd.  These additions
# could have been layered on top of for example the gocd/gocd-docker
# Docker image.  That would be nice.  But see above.
#
# Anyway, phusion baseimage seem to get it right with respect to an actual
# good base container, so let's start there.

# Baseimage:  Credits: https://github.com/phusion/baseimage-docker/
FROM phusion/baseimage:0.9.17

# Need git to fetch the provisioning script, the rest is done by the script
# Clean as much as possible before committing keeps the docker image size  down.
RUN apt-get update ;\
    apt-get install -y git ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# xuser is just a guy that keeps stuff around...
# It's where I first look for stuff in my containers when 
# I have forgotten what they actually do ;)
# I should probably remove it, it doesn't add to security
# to keep unused users around...
RUN useradd xuser --home-dir=/home/xuser --create-home ;\
    chmod 700 /home/xuser

# Touching a dummy file forces cache invalidation so
# that git-clone is re-run.  Useful during development
ADD dummy /tmp/dummy

# Fetch script into xuser home dir
RUN su xuser -c "git clone http://github.com/gunnarx/gocd-setup.git /home/xuser/gocd-setup" 2>&1 && ls /home/xuser/gocd-setup

# The actual provisioning script - 
# TODO add typical cleanup to end of script so we don't have to do it here
RUN cd /home/xuser/gocd-setup && ./go-server-setup.sh

# Clean up
RUN apt-get clean ;\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ports
EXPOSE 8153 8154

# Add service script for baseimage's init "runit"
RUN sed -ie "s/DAEMON=Y/DAEMON=N/" /etc/default/go-server
RUN mkdir /etc/service/go-server
ADD go-server.runit.sh /etc/service/go-server/run

# Use baseimage-docker's init system as default command
CMD ["/sbin/my_init"]

