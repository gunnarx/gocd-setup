#!/bin/sh

# Could be smarter maybe...

type=
[ -x "$(which apt-get 2>/dev/null)" ] && type=deb
[ -x "$(which yum 2>/dev/null)" ] && type=rpm
[ -x "$(which dnf 2>/dev/null)" ] && type=rpm
[ -e /etc/redhat-release ] && type=rpm
[ -e /etc/debian-release ] && type=deb
[ -z "$type" ] && { fail "Can't figure out rpm/rpm - please check script" ; exit 1 ; }

echo $type
