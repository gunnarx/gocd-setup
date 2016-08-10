#!/bin/sh

type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo yum install -y unzip git curl
      ;;
   deb)
      sudo apt-get update
      sudo apt-get install -y unzip git curl
      ;;
   *)
      fail "Could not determine rpm/deb type?"
      ;;
esac

