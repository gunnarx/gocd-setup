#!/bin/sh

version=15.2.0-2248

# FIXME ------------

echo "Warning, script is broken because wget downloads not "
echo "allowed - try running the download manually in your"
echo "browser instead.  then performthe script steps manually"
echo "it's easy to see what needs to be done at least..."

exit 

# FIXME ------------

fail() { echo "Something went wrong - check script" ; echo $@ ; exit 1 ; }

type=
[ -e /etc/redhat-release ] && type=rpm
[ -e /etc/debian-release ] && type=deb
[ -z "$type" ] && { fail "Can't figure out rpm/deb - please check script" ; exit 1 ; }

server=go-server-${version}.noarch.${type}
agent=go-agent-${version}.noarch.${type}

wget https://download.go.cd/gocd-$type/$server || fail "download failed, (is wget installed?)"
wget https://download.go.cd/gocd-$type/$agent  || fail "download failed"

case $type in
   rpm)
      sudo rpm -iv $server
      sudo rpm -iv $agent
   ;
   deb)
      sudo dpkg -i $server
      sudo dpkg -i $agent
   *)
      fail
esac

echo 'Creating "go" user'
sudo adduser go

echo "Fixing install/log directories to be accessible for go user"
sudo chown -R go:go /var/{run,lib}/{go-agent,go-server}

echo Edit /etc/defaults/go-agent
echo Set the Go server IP address

echo Try running with 
echo sudo su go -c /etc/init.d/go-agent start

