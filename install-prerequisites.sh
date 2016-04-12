#!/bin/sh

type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo yum install -y unzip git
      ;;
   deb)
      sudo apt-get update
      sudo apt-get install -y unzip git
      ;;
   *)
      fail "Could not determine rpm/deb type?"
      ;;
esac

