#!/bin/sh

CRUISE_CONFIG_DIR=/var/lib/go-server/db/config.git/

# Backup (push) server config to git repo
cd $CRUISE_CONFIG_DIR
git push backup master
