#!/bin/sh

type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo yum install -y java-1.8.0-openjdk unzip
      ;;
   deb)
      sudo apt-get update
      sudo apt-get install -y openjdk-8-jre unzip
      ;;
   *)
      fail "Could not determine rpm/deb type?"
      ;;
esac

