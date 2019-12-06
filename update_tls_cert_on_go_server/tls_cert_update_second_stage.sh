#!/bin/sh -e

# Set to true to activate pausing
pause_between_commands=false

# Location of keytool in official GoCD docker base image (Alpine based)
keytool=keytool

# Just a wrapper around echo, starting with !
log() {
	echo "! $@"
}

# This wrapper just allows us to pause between commands if desired
# (And to echo each command, if this was not enabled already)
c() {
	$pause_between_commands && log "About to run (in container):"
	echo "+ $@"
	$pause_between_commands && read -p "Hit Return to continue" x
	eval $@
}

c "cd /etc/letsencrypt/live/go.genivi.org"
c "openssl rsa -des3 -in privkey.pem -out privkey.key.new -passout pass:serverKeystorepa55w0rd" 
c "openssl pkcs12 -inkey privkey.key.new -in fullchain.pem -export -out fullchain.pkcs12 -passin pass:serverKeystorepa55w0rd -passout pass:serverKeystorepa55w0rd" 

c "cd /godata/config" 
c "$keytool -importkeystore -noprompt \
  -srckeystore /etc/letsencrypt/live/go.genivi.org/fullchain.pkcs12 \
  -srcstoretype PKCS12 -destkeystore keystore -srcalias 1 -destalias cruise \
  -srcstorepass serverKeystorepa55w0rd \
  -deststorepass serverKeystorepa55w0rd \
  -destkeypass serverKeystorepa55w0rd"

c "chown -R root /etc/letsencrypt" 
c "chmod -R 700 /etc/letsencrypt" 
c "chmod 755 /etc/letsencrypt/ /etc/letsencrypt/live /etc/letsencrypt/live/go.genivi.org" 
 
c "cd /etc/letsencrypt/live/go.genivi.org" 
c "chmod 400 privkey* fullchain* chain* cert*" 
 
c "chown go:go /etc/letsencrypt/live/go.genivi.org/keystore" 
c "chmod 600 /etc/letsencrypt/live/go.genivi.org/keystore" 
 
log "Trying to restart (kill) server"
log "NOTE: This will likely cause the container entrypoint to end and the container to stop"
log "Start the container again after this operation"
set +e

# Nice kill process
pid=$(ps aux | grep "[j]ava -server" | awk '{print $1}')

if [ -z "$pid" ] ; then
   log Process not running.
else
   log "Server process is pid $pid.  Kill with SIGQUIT"
   c "kill -15 $pid"
fi
sleep 2

# ... We might not even get this far, because the main container process is
# the server we are stopping.  When it stops, the container stops (as it is set
# up now) 

# OK, force kill process since nice kill seems to have failed
pid=$(ps aux | grep "[j]ava -server" | awk '{print $1}')

if [ -z "$pid" ] ; then
   log Process not running.
else
   log "Server process is pid $pid.  Kill with SIGKILL"
   c "kill -9 $pid"
fi
sleep 2

# ... I am quite certain we do not get this far, for the reason described above.
# The calling script will run "docker start <container> to get it running again.
# If for some reason the container is indeed running still, we restart the server process
log "OK, running entrypoint again"
c "/docker-entrypoint.sh &" 
log "Waiting for startup..."
c "sleep 10" 
log "Processes- check if it looks OK:"
c "ps aux" 

