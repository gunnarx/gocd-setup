#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

version=16.3.0-3183
GO_HOME_DIR=/var/go

fail() { echo "Something went wrong - check script" 1>&2 ; echo $@ 1>&2 ; exit 1 ; }

set -x
path=$(./download.sh server $version)

# Install Java (see script for version)
./install-java.sh

type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo rpm -iv $path || fail "RPM install failed"
      ;;
   deb)
      sudo dpkg -i $path || fail "DEB install failed"
      ;;
   *)
      fail "Could not determin rpm/deb type?"
      ;;
esac

#echo 'Creating "go" user'
echo 'Creating gouser'
sudo groupadd go --gid 1500
sudo useradd go -g go --uid 1500 -d /var/go
sudo useradd gouser -g go --uid 1501 # For account creation
#sudo chown -R go:go /home/go

sudo mkdir -p /var/log/go-server

# (All these dirs should exist after deb/rpm installation)
echo "Fixing install/log directories to be accessible for go user"
sudo chown -R go:go /var/{log,lib,run}/go-server /var/go || fail "Can't chown a directory"
sudo chmod 755 /var/{log,lib,run}/go-server /var/go || fail "Can't chmod a directory"

sudo cp /etc/default/go-server /tmp/newconf.$$ || fail "copying conf"
sudo chmod 666 /tmp/newconf.$$ || fail "conf?"

javadir=$(ls /usr/lib/jvm | egrep "java-.*-openjdk-.*$" | head -1)
java_home=/usr/lib/jvm/$javadir/jre
[ -d "$java_home" ] || fail "Could not figure out JAVA_HOME directory - please check the script"
[ -x "$java_home/bin/java" ] || fail "Could not find java executable in JAVA_HOME ($java_home) - please check the script"

export JAVA_HOME="$java_home"
cat <<EEE >>/tmp/newconf.$$
export JAVA_HOME="$java_home"
EEE

sudo cp /tmp/newconf.$$ /etc/default/go-server || fail "Putting conf back in /etc again"

echo
echo "If this is a server install, generating ssh-key for git pushes from
server (config files are git pushed as a backup)."

sudo mkdir -p $GO_HOME_DIR

if [ -f $GO_HOME_DIR/.ssh/id_rsa ] ; then
   echo "SSH key exists -- skipping"
else
   sudo su go -c 'mkdir -p $GO_HOME_DIR/.ssh'
   sudo su go -c 'chmod 700 $GO_HOME_DIR/.ssh'
   sudo su go -c 'ssh-keygen -f $GO_HOME_DIR/.ssh/id_rsa -N ""' || fail "Creating ssh keys failed"
   echo
   echo "Here is the public key for git access -- add it to Github."
   echo
   cat $GO_HOME_DIR/.ssh/id_rsa.pub
   echo
fi

echo "Starting go-server to make it create the directories etc."
sudo service go-server start &
echo "Initialization takes a while... waiting 15 seconds before continuing"
echo -n "15.."
sleep 1
echo "14... have patience"
sleep 14
echo "Stopping go-server"
sudo service go-server stop

echo "Setting up a remote to push config file backups"
CONFIG_REMOTE=git@github.com:genivigo/server-config-backup.git

# SSH key may not yet be set up, so pull via HTTP this time
CONFIG_REMOTE_PULL=http://github.com/genivigo/server-config-backup.git

cd /var/lib/go-server/db/config.git || fail "config.git not yet created. (we didn't wait long enough?)"
sudo su go -c "git remote add backup $CONFIG_REMOTE" || fail "Adding backup git remote"
sudo su go -c "git remote add first_pull $CONFIG_REMOTE_PULL" || fail "Adding backup git remote"
sudo su go -c "git config push.default simple" || fail "git config push"
sudo su go -c "git fetch first_pull" || fail "git fetch"
sudo su go -c "git reset first_pull/master --hard" || fail "git restore backup"

# Replace default config with the one taken from backup
sudo cp cruise-config.xml /etc/go/

echo "Adding hourly crontab job to push config changes"
CRONSCRIPT=/etc/cron.hourly/go-config-push-backup
sudo cat <<XXX >$CRONSCRIPT || fail "Creating cronscript"
#!/bin/sh

# Backup (push) server config to git repo
su go -c "cd /var/lib/go-server/db/config.git && git push backup master"

# Pull down new custom commands, if they were added to git repo
su go -c "cd /var/lib/go-server/db/command_repository/genivi && git pull origin master"
XXX
sudo chmod 755 $CRONSCRIPT || fail "Chmodding cronscript"

service go-server status
echo "Try starting with"
echo "sudo service go-server start"
echo "otherwise with:"
echo 'sudo su go -c "/etc/init.d/go-server start"'

