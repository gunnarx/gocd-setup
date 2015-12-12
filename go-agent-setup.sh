#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

version=15.2.0-2248

fail() { echo "Something went wrong - check script" ; echo $@ ; exit 1 ; }

type=
[ -e /etc/redhat-release ] && type=rpm && extra=".noarch"
[ -e /etc/debian-release ] && type=deb && extra=
[ -x "$(which rpm 2>/dev/null)" ] && type=rpm && extra=".noarch"
[ -x "$(which dpkg 2>/dev/null)" ] && type=deb && extra=
[ -z "$type" ] && { fail "Can't figure out rpm/deb - please check script" ; }

agent=go-agent-${version}${extra}.${type}

# The download URL seems to require an actual web browser as agent
# or something?  The redirect to the file fails otherwise.
# We need the download so here's an agent string...
agent_str="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)"

curl=$(which curl)
[ -x "$curl" ] || { echo "Can't find curl -- not installed?" ; exit 1 ; }

curl -C - -A "$agent_str" -L https://download.go.cd/gocd-$type/$agent >$agent || fail "download failed, (is curl installed?)"

case $type in
   rpm)
      sudo yum install -y java-1.7.0-openjdk
      sudo rpm -iv $agent
      ;;
   deb)
      sudo apt-get install -y openjdk-7-jre
      sudo dpkg -i $agent
      ;;
   *)
      fail
      ;;
esac

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

