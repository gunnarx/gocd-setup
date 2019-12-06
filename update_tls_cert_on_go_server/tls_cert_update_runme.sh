#!/bin/bash -e

CONTAINER_NAME=go-server

# Set to true to activate pausing
pause_between_commands=false

# Make sure we are inside this same dir
MYDIR="$(readlink -f "$(dirname "$0")")"
cd "$MYDIR"             # Go there

# Just a wrapper around echo, starting with *
log() {
	echo "* $@"
}

# This wrapper just allows us to pause between commands if desired
# (And to echo each command, if this was not enabled already)
c() {
	$pause_between_commands && log "About to run (on host):"
	echo "+ $@"
	$pause_between_commands && read -p "Hit Return to continue" x
	eval $@
}

start_container_if_needed() {
   name=$1
   set +e # Allow test to fail without failing scripts
   found=false
   docker ps
   docker ps | fgrep -q $name && found=true
   set -e # Back to strict error checking
   if $found ; then
      log "$name seems to be running already"
   else
      c "docker start $name"
   fi
}

# Just in case container is not running:
start_container_if_needed $CONTAINER_NAME

log "Copying letsencrypt directory structure into the container"
c "sudo tar -l -cf - /etc/letsencrypt | docker exec -i $CONTAINER_NAME /bin/tar xvf -"
log Copying helper script into container
c "docker cp tls_cert_update_second_stage.sh $CONTAINER_NAME:/tmp/"
log Now time to run helper script inside container
set +e
c "docker exec -i $CONTAINER_NAME /tmp/tls_cert_update_second_stage.sh"

echo "...please wait..."
sleep 5
log "Inner script is done. Let's (re)start the container:"
start_container_if_needed $CONTAINER_NAME

sleep 2
log "OK, if all went well, the go-server web page will be up in 10-15 seconds"
echo https://go.genivi.org

echo "...please wait..."
sleep 5

log "Replacing front page"
cd "$MYDIR"
c ../hotfix-auth-page/fix-auth-page.sh
