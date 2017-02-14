#!/bin/sh

[ $(whoami) != "go" ] && { echo "Please run as user go" ; exit 1 ; }

cat ./crontab | crontab -
