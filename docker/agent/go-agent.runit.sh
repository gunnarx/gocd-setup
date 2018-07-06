#!/bin/sh
service cron start &

# We start a qemu inside the docker container
# to run our acceptance tests on it.
#
# We configure qemu to connect to a virtual
# tunel network, which means that we can
# can access it with its own subdomain.
#
# Normally qemu sets this up for us, but it
# requires root permission to do this when
# running inside the container but the qemu
# is run by the go user.
#
# That is why we create the virtual network
# interface here and the go user can use it
# later on.
/usr/sbin/tunctl -t tap0 -u go
/bin/ip addr add 192.168.7.1/24 dev tap0
/bin/ip link set tap0 up

# Set group permission on kvm device
chown root:kvm /dev/kvm

/sbin/setuser go /usr/share/go-agent/agent.sh

