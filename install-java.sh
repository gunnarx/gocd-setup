#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo yum install -y java-1.8.0-openjdk
      ;;
   deb)
      sudo apt-get update
      sudo apt-get install -y openjdk-8-jre
      ;;
   *)
      fail "Could not determin rpm/deb type?"
      ;;
esac

