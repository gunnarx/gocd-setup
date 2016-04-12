#!/bin/sh
# (C) 2015 Gunnar Andersson
# License: CC-BY-4.0 (https://creativecommons.org/licenses/by/4.0/)

version=16.3.0-3183
GO_HOME_DIR=/var/go
CRUISE_CONFIG_DIR=/var/lib/go-server/db/config.git/
COMMANDS_DIR=/var/lib/go-server/db/command_repository
COMMANDS_DIR_NAME=genivi

# The following URLs should point to an external git repo to which
# we will have the server push the config XML as a backup.
# This will be added as a cron job.  You can also set it to "none"

# SSH key may not yet be set up when we install so pull via HTTP...
# ... but for pushing the server must be configured with a writable URL (SSH)
# (In theory these could point to different repos) <-- FIXME To be confirmed does pushing to empty repo work?
CONFIG_REMOTE_FIRST_PULL=http://github.com/genivigo/server-config-backup.git
CONFIG_REMOTE_PUSH=git@github.com:genivigo/server-config-backup.git
COMMANDS_REMOTE=http://github.com/genivigo/go-command-repo.git

prompt_with_default() {
  echo "Default is: $1"
  echo "(Hit return to keep default value, or type none to disable)"
  read -p "$2: " value
  value=${value:-$1}
  echo $value
}

fail() { echo "Something went wrong - check script" 1>&2 ; echo $@ 1>&2 ; exit 1 ; }

path=$(./download.sh server $version)

# Install Java (see script for version), and git and stuff
#./install-java.sh
./install-prerequisites.sh

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

# User/group go is created by rpm/deb package already...
# This is needed for zip install only

# echo 'Creating "go" user'
# sudo groupadd go --gid 1500
# sudo useradd go -g go --uid 1500 -d /var/go

# (All these dirs should exist after deb/rpm installation)
echo "Fixing install/log directories to be accessible for go user"
sudo mkdir -p /var/{log,lib,run}/go-server /var/go # Just in case
sudo chown -R go:go /var/{log,lib,run}/go-server /var/go || fail "Can't chown a directory"
sudo chmod 755 /var/{log,lib,run}/go-server /var/go || fail "Can't chmod a directory"

echo 'Creating gouser for account-creation application'
sudo useradd gouser -g go -d /home/gouser --uid 1501
sudo chown -R go:go /home/gouser

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

sudo mkdir -p $GO_HOME_DIR

if [ -f $GO_HOME_DIR/.ssh/id_rsa ] ; then
   echo "SSH key exists -- skipping"
else
   sudo -u go mkdir -p $GO_HOME_DIR/.ssh
   sudo -u go chmod 700 $GO_HOME_DIR/.ssh
   sudo -u go ssh-keygen -f $GO_HOME_DIR/.ssh/id_rsa -N "" || fail Creating ssh keys failed
   echo
   echo "Here is the public key for git access -- add it to Github."
   echo
   cat $GO_HOME_DIR/.ssh/id_rsa.pub
   echo
fi

echo "Starting go-server to make it go through initialization"
sudo service go-server start >/dev/null 2>&1 &

echo
echo "While we wait, set up the git remote for the pipeline configuration"
echo "First the Pull URL (must allow access without login, e.g. http(s)://my.git) : "
prompt_with_default "$CONFIG_REMOTE_FIRST_PULL" "Pull URL"
echo
echo "Now the Push URL (must be an SSH login, e.g. user@my.git or ssh://user@my.git) : "
prompt_with_default "$CONFIG_REMOTE_PUSH" "Push URL"
echo
echo "Finally the repo for custom commands (NOTE this also needs to be manually enabled in Go settings later)"
prompt_with_default "$COMMANDS_REMOTE" "Commands Repo (could be PULL only, e.g. http)"


echo
echo Checking for directory $CRUISE_CONFIG_DIR
echo "Note: Total waiting time should not be more than 30 seconds or so."
[ ! -d $CRUISE_CONFIG_DIR ] && echo "still not there... waiting until I see it"
while [ ! -d $CRUISE_CONFIG_DIR ] ; do
  echo -n "."
  sleep 1
done

echo "OK init is done.  Stopping go-server."
sudo service go-server stop

if [ "$CONFIG_REMOTE_PUSH" != "none" ] ; then
   cd "$CRUISE_CONFIG_DIR" || fail "config.git still not created. (we didn\'t wait long enough?)"
   sudo -u go git remote add backup $CONFIG_REMOTE_PUSH || fail Adding backup git remote
   sudo -u go git remote add first_pull $CONFIG_REMOTE_FIRST_PULL || fail Adding backup git remote
   sudo -u go git config push.default simple || fail git config push
   sudo -u go git fetch first_pull || fail git fetch
   sudo -u go git reset first_pull/master --hard || fail git restore backup

   # Replace the actually used config (in /etc/go) with the one taken from backup
   sudo cp cruise-config.xml /etc/go/
   echo "Adding hourly crontab job to push config changes"
   CRONSCRIPT=/etc/cron.hourly/go-config-push-backup

   sudo cat <<"XXX" >$CRONSCRIPT || fail "Creating cronscript"
   #!/bin/sh

   # Backup (push) server config to git repo
   su go -c "cd $CRUISE_CONFIG_DIR && git push backup master"
XXX
   sudo chmod 755 $CRONSCRIPT || fail "Chmodding cronscript"

fi

if [ "$COMMANDS_REMOTE" != "none" ] ; then
   sudo mkdir -p "$COMMANDS_DIR" || fail "mkdir commands dir"
   sudo chown go:go "$COMMANDS_DIR" || fail "chown commands dir"
   sudo chmod 755 "$COMMANDS_DIR"   || fail "chmod commands dir"
   cd "$COMMANDS_DIR" || fail "cd commands dir"

   sudo -u go git clone $COMMANDS_REMOTE $COMMANDS_DIR_NAME || fail "Can't clone commands repo"
   cd "$COMMANDS_DIR_NAME" || fail "cd to commands git dir"

   sudo cat <<"XXX" >>$CRONSCRIPT || fail "Appending cronscript"

   # Pull down new custom commands, if they were added to git repo
   su go -c "cd $COMMANDS_DIR/$COMMANDS_DIR_NAME && git pull origin master"
XXX
fi

service go-server status
echo "Try starting with"
echo "sudo service go-server start"
echo "otherwise with:"
echo 'sudo -u go /etc/init.d/go-server start'

