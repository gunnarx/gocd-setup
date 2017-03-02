#! /bin/sh 
cd /gocd-setup && /usr/bin/git pull && apt-get install $(cat common_build_dependencies)
