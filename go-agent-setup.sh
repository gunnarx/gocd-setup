#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

# SETTINGS
version=16.3.0-3183

D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

fail() { echo "Something went wrong - check script" ; echo $@ ; exit 1 ; }

# GET AGENT
file=$(./go-download.sh agent $version)

[ -f "$file" ] || fail "No go-agent installation archive found"

echo "Fixing install/log directories to be accessible for go user"
sudo mkdir -p /var/{log,lib}/go-agent
sudo chown -R go:go /var/{log,lib}/go-agent

[ -f go-agent.conf ] || fail "Can't find go-agent.conf in this directory - giving up"

echo Copying default conf to /etc/default/go-agent
sudo cp go-agent.conf /etc/default/go-agent

# This tries to figure out the actual path to openJDK, which includes
# the minor-version number and such things that might change in the future.
java_home=/usr/lib/jvm/$(ls /usr/lib/jvm/ | egrep 'java-.*-openjdk-.*$' | head -1)/jre

[ -d "$java_home" ] || fail "Could not figure out JAVA_HOME directory - please check the script"
[ -x "$java_home/bin/java" ] || fail "Could not find java executable in JAVA_HOME ($java_home) - please check the script"

echo "Adding JAVA_HOME to config file"
cp /etc/default/go-agent /tmp/newconf.$$
sudo chmod 666 /tmp/newconf.$$
cat <<EEE >>/tmp/newconf.$$
export JAVA_HOME="$java_home"
EEE

echo GO_SERVER is set to:
fgrep GO_SERVER= /tmp/newconf.$$

# OK, put it back and just in case, fix up permissions and stuff
sudo mv /tmp/newconf.$$ /etc/default/go-agent
sudo chown root:root /etc/default/go-agent
sudo chmod 644 /etc/default/go-agent

echo "Done.  Try running agent with: "
echo 'sudo su go -c "/etc/init.d/go-agent start"'

