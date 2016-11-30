#!/bin/sh

[ $(id -u) -eq 0 ] || { echo "Please make sure you run as root for installation" ; exit 1 ; }
type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      yum install -y unzip git curl
      ;;
   deb)
      apt-get update
      apt-get install -y unzip git curl
      ;;
   *)
      fail "Could not determine rpm/deb type?"
      ;;
esac

