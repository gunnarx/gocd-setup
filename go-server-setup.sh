#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

version=16.3.0-3183

fail() { echo "Something went wrong - check script" ; echo $@ ; exit 1 ; }

set -x
path=$(./go-download.sh server $version)
type=$(./rpm-or-deb.sh)

case $type in
   rpm)
      sudo yum install -y java-1.7.0-openjdk unzip
      sudo rpm -iv $file || fail "RPM install failed"
      ;;
   deb)
      sudo apt-get update
      sudo apt-get install -y openjdk-7-jre unzip
      sudo dpkg -i $file || fail "DEB install failed"
      ;;
   *)
      fail
      ;;
esac

#echo 'Creating "go" user'
#sudo groupadd go --gid 1500
#sudo useradd go -g go -uid 1500
echo 'Creating gouser'
sudo useradd gouser -g go -uid 1501 # For account creation
#sudo mkdir -p /home/go
#sudo chown -R go:go /home/go

echo "Fixing install/log directories to be accessible for go user"
sudo chown -R go:go /var/log/go-server || fail "Can't chown directories log"
sudo chown -R go:go /var/lib/go-server || fail "Can't chown directories lib"
sudo chown -R go:go /var/run/go-server || fail "Can't chown directories run"

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

if [ -f /var/go/.ssh/id_rsa ] ; then
   echo "SSH key exists -- skipping"
else
   sudo su go -c 'mkdir -p /var/go/.ssh'
   sudo su go -c 'chmod 700 /var/go/.ssh'
   sudo su go -c 'ssh-keygen -f /var/go/.ssh/id_rsa -N ""' || fail "Creating ssh keys failed"
   echo
   echo "Here is the public key for git access -- add it to Github."
   echo
   cat /var/go/.ssh/id_rsa.pub
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

