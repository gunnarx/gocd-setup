#!/bin/sh

version=15.2.0-2248

fail() { echo "Something went wrong - check script" ; echo $@ ; exit 1 ; }

type=
[ -e /etc/redhat-release ] && type=rpm
[ -e /etc/debian-release ] && type=deb
[ -z "$type" ] && { fail "Can't figure out rpm/deb - please check script" ; exit 1 ; }

server=go-server-${version}.noarch.${type}
agent=go-agent-${version}.noarch.${type}

serverurl=
agenturl=

# The download URL seems to require an actual web browser as agent
# or something, the redirect to the file fails otherwise.
# The end result is the same, so ignoring that...
agent_str="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)"

curl=$(which curl)
[ -x "$curl" ] || { echo "Can't find curl -- not installed?" ; exit 1 ; }

curl -A "$agent_str" -L https://download.go.cd/gocd-$type/$server >$server || fail "download failed, (is curl installed?)"
curl -A "$agent_str" -L https://download.go.cd/gocd-$type/$server >$server || fail "download failed, (is curl installed?)"

case $type in
   rpm)
      sudo yum install -y java-1.7.0-openjdk
      sudo rpm -iv $server
      sudo rpm -iv $agent
      ;;
   deb)
      sudo apt-get install -y openjdk-7-jre
      sudo dpkg -i $server
      sudo dpkg -i $agent
      ;;
   *)
      fail
      ;;
esac

echo 'Creating "go" user'
sudo adduser go

echo "Fixing install/log directories to be accessible for go user"
sudo chown -R go:go /var/{run,lib}/{go-agent,go-server}

echo Edit /etc/defaults/go-agent
echo Set the Go server IP address

sudo cp /etc/default/go-agent /tmp/newconf
sudo chmod 666 /tmp/newconf
java_home=/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-1.7.0-openjdk-1.7.0)/jre

cat <<EEE >>/tmp/newconf
export JAVA_HOME="$java_home"
EEE

sudo cp /tmp/newconf /etc/default/go-agent

echo Try running with 
echo 'sudo su go -c "/etc/init.d/go-agent start"'

