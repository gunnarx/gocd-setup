#!/bin/sh

# Backup (push) server config to git repo
su go -c "cd $CRUISE_CONFIG_DIR && git push backup master"

