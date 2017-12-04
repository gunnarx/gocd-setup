#!/bin/sh -x

# Ugly but effective hot-patch of the login page.
# Please don't judge me... ;-) ;-) /Gunnar

# Modify this if you need to run "sudo docker" instead, for example
DOCKER=docker
CONTAINER=go-server
 
MYDIR=$(dirname "$0")
cd "$MYDIR"

file=genivi_chrome_1_transparent.png
dir=/var/lib/go-server/work/jetty-0.0.0.0-8153-cruise.war-_go-any-/webapp/WEB-INF/rails.new/public/assets/plugins/images
<$file $DOCKER exec -i $CONTAINER tee $dir/$file >/dev/null

file=login.vm
dir=/var/lib/go-server/work/jetty-0.0.0.0-8153-cruise.war-_go-any-/webapp/WEB-INF/vm/auth/
<$file $DOCKER exec -i $CONTAINER tee $dir/$file >/dev/null

