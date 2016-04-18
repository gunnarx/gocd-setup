#!/bin/sh

# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# ---------------------------------------------------------------------------
# SETTINGS
# ---------------------------------------------------------------------------
VERSION=16.3.0-3183

GO_HOME_DIR=/var/go
CRUISE_CONFIG_DIR=/var/lib/go-server/db/config.git/
COMMANDS_DIR=/var/lib/go-server/db/command_repository
COMMANDS_DIR_NAME=genivi  # <- configurable, note it must ALSO be configured in GoCD
CRONSCRIPTS=/etc/cron.hourly

# Optional: The following URLs should point to an external git repo to which we
# will have the server push the config XML as a backup. This will be added as a
# cron job.  You can also set it to "none".

# For fetching an initial config, the SSH key may not yet be set up 
# so typically pull via HTTP...
# ... but for pushing the server must be configured with a writable URL (SSH)
# (In theory these could point to different repos) <-- FIXME To be confirmed
# does pushing to empty repo work?
CONFIG_REMOTE_FIRST_PULL=http://github.com/genivigo/server-config-backup.git
CONFIG_REMOTE_PUSH=git@github.com:genivigo/server-config-backup.git

# The second URL is intended to be a fork of the go-commands repo
# not that important but you can read more at the main repo:
# https://github.com/gocd/go-command-repo
COMMANDS_REMOTE=http://github.com/genivigo/go-command-repo.git

# ---------------------------------------------------------------------------
# Function: Misc helpers
# ---------------------------------------------------------------------------
prompt_with_default() {
   echo "Default is: $1"
   echo "(Hit return to keep default value, or type none to disable)"
   read -p "$2: " value
   value=${value:-$1}
   echo $value
}

fail() { echo "Something went wrong - check script" 1>&2 ; echo $@ 1>&2 ; exit 1 ; }

# ---------------------------------------------------------------------------
# Function: Account creation app needs "gouser" user.  
# This is kind of unique for GENIVI setup and can be skipped by others.
# ---------------------------------------------------------------------------
setup_account_creation_application() {
   echo 'Creating gouser for account-creation application'
   sudo useradd gouser -g go -d /home/gouser --uid 1501
   sudo chown -R go:go /home/gouser
}

# ---------------------------------------------------------------------------
# Function: Configure JAVA_HOME variable
# ---------------------------------------------------------------------------
# This is slightly overcomplicated and can probably be rewritten.  Also this
# might be done correctly by the post-install scripts in the deb/rpm but if it
# fails here is another attempt. Anyway, the point is to figure out JAVA_HOME
# and add it to the config file.

add_java_to_conf() {
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
}

# --------------------------------------------------------------------------
# Function: Optional setup of git URLs
# --------------------------------------------------------------------------
prompt_for_git_urls() {
   echo
   echo "First the Pull URL (must allow access without login, e.g. http(s)://my.git) : "
   prompt_with_default "$CONFIG_REMOTE_FIRST_PULL" "Pull URL"
   echo
   echo "Now the Push URL (must be an SSH login, e.g. user@my.git or ssh://user@my.git) : "
   prompt_with_default "$CONFIG_REMOTE_PUSH" "Push URL"
   echo
   echo "Finally the repo for custom commands (NOTE this also needs to be manually enabled in Go settings later)"
   prompt_with_default "$COMMANDS_REMOTE" "Commands Repo (could be PULL only, e.g. http)"
}

# ----------------------------------------------------------------
# Function: Pull initial pipeline setup (cruise-config.xml) from some existing
# git repo.
# ----------------------------------------------------------------
# Recommended - Note: you may want to pull the initial setup from some git
# even if you do not setup a writable git to store subsequent changes.
# ----------------------------------------------------------------
pull_config_from_existing_git() {

   if [ "$CONFIG_REMOTE_FIRST_PULL" != "none" ] ; then
      echo "Getting initial pipeline setup from git repo"
      cd "$CRUISE_CONFIG_DIR" || fail "config.git dir still not available?"
      sudo -u go git remote add first_pull $CONFIG_REMOTE_FIRST_PULL || fail Adding backup git remote
      sudo -u go git fetch first_pull || fail git fetch
      sudo -u go git reset first_pull/master --hard || fail git restore backup
      cd -
   else
      echo "git pull URL for initial pipeline config was not configured -- skipping"
   fi
}

# ----------------------------------------------------------------
# Function: Configure a backup git repo to backup config file changes to
# git (recommended)
# ----------------------------------------------------------------
configure_cruise_config_git_storage() {

   if [ "$CONFIG_REMOTE_PUSH" != "none" ] ; then

      cd "$CRUISE_CONFIG_DIR" || fail "config.git dir still not available?"
      sudo -u go git remote add backup $CONFIG_REMOTE_PUSH || fail Adding backup git remote
      sudo -u go git config push.default simple || fail git config push
      cd -

      # Replace the actually used config (in /etc/go) with the one taken from backup
      sudo cp cruise-config.xml /etc/go/
      echo "Adding hourly crontab job to push config changes"

      # Set up cron job for hourly backups
      sudo install -m 755 ./go-config-cronjob.sh $CRONSCRIPTS/ || fail "Copying config cronscript"

      # Set up SSH key
      if [ -f $GO_HOME_DIR/.ssh/id_rsa ] ; then
         echo "SSH key exists -- skipping"
      else
         sudo -u go mkdir -p -m 700 $GO_HOME_DIR/.ssh  || fail "Creating .ssh dir"
         sudo -u go ssh-keygen -f $GO_HOME_DIR/.ssh/id_rsa -N "" || fail "Creating ssh keys"
         echo
         echo "Here is the public key for git access -- add it to GitHub or your git server"
         echo
         echo "*** WARNING ***"
         echo "*** WARNING *** The private key is stored without passphrase -  So unless you can control accessindividually per repository, make sure to use an account for this purpose only."
         echo "*** WARNING ***"
         echo
         cat $GO_HOME_DIR/.ssh/id_rsa.pub || fail "cat pub key"
         echo
      fi

   else
      echo "git push URL for backups was not configured -- skipping"
   fi

}

# ----------------------------------------------------------------
# Function: Pull custom commands repo from some URL
# (optional / not really required)
# ----------------------------------------------------------------
configure_commands_repo() {
   if [ "$COMMANDS_REMOTE" != "none" ] ; then
      sudo mkdir -p "$COMMANDS_DIR" || fail "mkdir commands dir"
      sudo chown go:go "$COMMANDS_DIR" || fail "chown commands dir"
      sudo chmod 755 "$COMMANDS_DIR"   || fail "chmod commands dir"
      pushd "$COMMANDS_DIR" || fail "cd commands dir"

      # Set up cron job for hourly updates, if command repo changes
      sudo -u go git clone $COMMANDS_REMOTE $COMMANDS_DIR_NAME || fail "Can't clone commands repo"
      cd "$COMMANDS_DIR_NAME" || fail "cd to commands git dir"
      popd

      sudo install -m 755 ./go-command-cronjob.sh $CRONSCRIPTS/ || fail "Copying command cronscript"
   else
      echo "git pull URL for commands repo was not configured -- skipping"
   fi
}


# MAIN SCRIPT STARTING

# ---------------------------------------------------------------------------
# Download and install (helper script)
# ---------------------------------------------------------------------------
echo Downloading go-server installation
path=$(./download.sh server $VERSION)

# ---------------------------------------------------------------------------
# Install Java, git and stuff.  N.B.: Java version is coded into helper script.
# ---------------------------------------------------------------------------
./install-java.sh
./install-prerequisites.sh

# ---------------------------------------------------------------------------
# Install the rpm/deb previously downloaded
# ---------------------------------------------------------------------------
type=$(./rpm-or-deb.sh)
case $type in
   rpm)
      sudo rpm -iv $path || fail "RPM install failed"
      ;;
   deb)
      sudo dpkg -i $path || fail "DEB install failed"
      ;;
   *)
      fail "Unsupported package type - fix script"
      ;;
esac

# ---------------------------------------------------------------------------
# Setting up directories
# ---------------------------------------------------------------------------

# User/group go is created by rpm/deb package already...
# This is needed for zip install only

# echo 'Creating "go" user'
# sudo groupadd go --gid 1500
# sudo useradd go -g go --uid 1500 -d /var/go

# Most (all?) these dirs are likely created by deb/rpm installation
# but creating them just in case.
echo "Fixing install/log directories to be accessible for go user"
sudo mkdir -m 755 -p /var/{log,lib,run}/go-server $GO_HOME_DIR || fail "Can't create /var/... directories"
sudo chown -R go:go /var/{log,lib,run}/go-server $GO_HOME_DIR || fail "Can't chown a directory"


# --------------------------------------------------------------------------
# Run server once to go through initialization
# --------------------------------------------------------------------------

add_java_to_conf

echo
echo "Starting go-server to make it go through initialization"
sudo service go-server start >/dev/null 2>&1 &

echo "While we wait, set up the git remote for the pipeline configuration"

prompt_for_git_urls  # <- this user interactive is useful to do while we wait for the long startup

# By now the init should be done but loop until we see the config dir ready
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

# FIXME: This does not actually set up the application currently
# it only creates the user and home dir...
setup_account_creation_application # <- optional

# Optional functions - comment them if you don't need them.
configure_cruise_config_git_storage
configure_commands_repo

service go-server status
echo "Try starting with"
echo "sudo service go-server start"
echo "otherwise with:"
echo 'sudo -u go /etc/init.d/go-server start'

