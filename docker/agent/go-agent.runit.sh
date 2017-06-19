#!/bin/sh
service cron start &
/sbin/setuser go /usr/share/go-agent/agent.sh

