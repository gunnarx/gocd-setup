#!/bin/sh

COMMANDS_DIR=/var/lib/go-server/db/command_repository
COMMANDS_DIR_NAME=genivi

# Pull down new custom commands, if they were added to git repo
su go -c "cd $COMMANDS_DIR/$COMMANDS_DIR_NAME && git pull origin master"
