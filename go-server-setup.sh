#!/bin/bash

# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# ---------------------------------------------------------------------------
# SETTINGS
# ---------------------------------------------------------------------------
GO_HOME_DIR=/var/go
CRUISE_CONFIG_DIR=/go-server/config/
COMMANDS_DIR=/go-server/db/command_repository
COMMANDS_DIR_NAME=genivi  # <- configurable, note it must ALSO be configured in GoCD
CRONSCRIPTS=/root/
CRONTAB=/etc/crontab
PASSWORD_FILE=/gousers/users

# Optional: The following URLs should point to an external git repo to which we
# will have the server push the config XML as a backup. This will be added as a
# cron job.  You can also set it to "none".

# For fetching an initial config, the SSH key may not yet be set up 
# so typically pull via HTTP...
# ... but for pushing the server must be configured with a writable URL (SSH)
# (In theory these could point to different repos) <-- FIXME To be confirmed
# does pushing to empty repo work?

# If not set in environment already...
[ -z "$CONFIG_REMOTE_FIRST_PULL" ] && CONFIG_REMOTE_FIRST_PULL=http://github.com/genivigo/server-config-backup.git
[ -z "$CONFIG_REMOTE_PUSH" ] && CONFIG_REMOTE_PUSH=git@github.com:genivigo/server-config-backup.git

# The second URL is intended to be a fork of the go-commands repo
# It's not that important but you can read more at the main repo:
# https://github.com/gocd/go-command-repo
[ -z "$COMMANDS_REMOTE" ] && COMMANDS_REMOTE=http://github.com/genivigo/go-command-repo.git

# Normalize directory - make sure we start in "this" directory
D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

# ---------------------------------------------------------------------------
# Function: Misc helpers
# ---------------------------------------------------------------------------
prompt_with_default() {
   echo "Default is: $1"
   echo "(Hit return to keep default value, or type none to disable)"
   read -p "$2: " value
   value=${value:-$1}
   echo "$value"
}

fail() { echo "Something went wrong - check script" 1>&2 ; echo msg: "$@" 1>&2 ; exit 1 ; }

# ---------------------------------------------------------------------------
# Function: Account creation app needs "gouser" user.  
# This is kind of unique for GENIVI setup and can be skipped by others.
# ---------------------------------------------------------------------------
setup_account_creation_application() {
   echo 'Creating gouser for account-creation application'
   mkdir /home/gouser
   mkdir "$GO_HOME_DIR"
   mkdir -p "$GO_HOME_DIR" && echo make dir Go home dir ok
   chown -R go "$GO_HOME_DIR"
   adduser gouser go -h "$GO_HOME_DIR" -u 1501

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
restore_cruise_config_from_backup() {
   if [ "$CONFIG_REMOTE_FIRST_PULL" != "none" ] ; then
      echo "Getting initial pipeline setup from git repo"
      cd "$CRUISE_CONFIG_DIR" || fail "config dir still not available?"
      chown -R go "$CRUISE_CONFIG_DIR/"
      ls -alR "$CRUISE_CONFIG_DIR/"
      su go -c whoami
      su go -c "git init ."
      su go -c "git remote add first_pull $CONFIG_REMOTE_FIRST_PULL" || fail Adding backup git remote
      su go -c "git fetch first_pull" || fail git fetch
      su go -c "git reset first_pull/master --hard" || fail git restore backup

      # Is there a password file defined in config file?
      # If so we reset it to a known location and start using that instead, less complicated that way.
      if fgrep -q '<passwordFile path=' cruise-config.xml ; then

         echo "WARNING:  Resetting password file location to $PASSWORD_FILE"
         sed -i "s@passwordFile path=\".*\"\$@passwordFile path=\"$PASSWORD_FILE\"@" cruise-config.xml

         # Need to also store a password file assuming there was one.
         echo
         echo "Copying password file template"
         echo
         echo "WARNING: If users were defined in restored cruise-config.xml, they must also exist in password file.  In particular the administrator(s), or you will not be able to log in as admin"
         echo

         PDIR="$(dirname "$PASSWORD_FILE")"
         mkdir -p "$PDIR"
         chown go "$PDIR"
         cp "$MYDIR/password_file_template" "$PASSWORD_FILE" || fail "Copying password file template"
         chown go:go $PASSWORD_FILE
         chmod 600 $PASSWORD_FILE
      fi

#      # Replace the actually used config (in /etc/go) with the one taken from backup
#      su go -c "cp $CRUISE_CONFIG_DIR/cruise-config.xml /etc/go/"
      cd -
   else
      echo "git pull URL for initial pipeline config was not configured -- skipping"
   fi
}

# ----------------------------------------------------------------
# Function: Configure a backup git repo to backup config file changes to
# git (recommended)
# ----------------------------------------------------------------
configure_cruise_config_backup() {
  password_file="$1"

   if [ "$CONFIG_REMOTE_PUSH" != "none" ] ; then

      cd "$CRUISE_CONFIG_DIR" || fail "config.git dir still not available?"
      su go -c "git remote add backup $CONFIG_REMOTE_PUSH" || fail Adding backup git remote
      su go -c "git config push.default simple" || fail git config push
      echo "NOTE:  Setting password file location to $password_file"
      sed -i "s@<passwordFile path=\".*\$@<passwordFile path=\"$password_file\"/>@" cruise-config.xml
      cd -

      # Set up cron job for hourly backups
      echo "Adding hourly crontab job to push config changes"
      echo "0 * * * * $CRONSCRIPTS/go-config-cronjob" >> "$CRONTAB"
      install -m 755 ./go-config-cronjob $CRONSCRIPTS/go-config-cronjob || fail "Copying config cronscript"

      # Set up SSH key
      if [ -f $GO_HOME_DIR/.ssh/id_rsa ] ; then
         echo "SSH key exists -- skipping"
      else
         mkdir -p -m 700 "$GO_HOME_DIR/.ssh"  || fail "Creating .ssh dir"
         chown go "$GO_HOME_DIR/.ssh"
         su go -c "ssh-keygen -f $GO_HOME_DIR/.ssh/id_rsa -N \"\"" || fail "Creating ssh keys"
         echo
         echo "Here is the public key for git access -- add it to GitHub or your git server (read WARNING)"
         echo
         echo "*** WARNING ***"
         echo "*** WARNING *** The private key is stored without passphrase -  So unless you can control access individually per repository, make sure to use a separate Git account for this purpose only."
         echo "*** WARNING ***"
         echo
         cat $GO_HOME_DIR/.ssh/id_rsa.pub || fail "cat pub key"

         cp ./ssh_config "$GO_HOME_DIR/.ssh/config"
         chmod 644 "$GO_HOME_DIR/.ssh/config"
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

      # Set up cron job for hourly updates, if command repo changes
      D="$PWD"  # <- got some weird error with pushd/popd... hmm
      cd "$COMMANDS_DIR" || fail "cd commands dir"
      echo "Cloning commands repo from $COMMANDS_REMOTE into $COMMANDS_DIR_NAME"
      git clone $COMMANDS_REMOTE $COMMANDS_DIR_NAME || fail "Can't clone commands repo"
      chown -R go "$COMMANDS_DIR_NAME" || fail "Can't reset owner on commands repo"
      cd "$COMMANDS_DIR_NAME" || fail "cd to commands git dir"
      cd "$D"

      sudo install -m 755 ./go-command-cronjob $CRONSCRIPTS/ || fail "Copying command cronscript"
   else
      echo "git pull URL for commands repo was not configured -- skipping"
   fi
}


# MAIN SCRIPT STARTING -- server

# ---------------------------------------------------------------------------
# Install Java, git and stuff.  N.B.: Java version is coded into helper script.
# ---------------------------------------------------------------------------
#./install-prerequisites.sh

echo TODO INSTALLATIONS ALPINE

# ---------------------------------------------------------------------------
# Install the rpm/deb previously downloaded
# ---------------------------------------------------------------------------
#type=$(./rpm-or-deb.sh)
#case $type in
#   rpm)
#      sudo rpm -iv "$DL_PATH" || fail "RPM install failed"
#      ;;
#   deb)
#      sudo dpkg -i "$DL_PATH" || fail "DEB install failed"
#      ;;
#   *)
#      fail "Unsupported package type - fix script"
#      ;;
#esac

# Optional functions - comment them if you don't need them.
restore_cruise_config_from_backup

# --------------------------------------------------------------------------
# Run server once to go through initialization
# --------------------------------------------------------------------------

#echo
#echo "Starting go-server to make it go through initialization"
#sudo service go-server start >/dev/null 2>&1 &
#
#echo "While we wait, set up the git remote for the pipeline configuration"
#
#exit

exit
prompt_for_git_urls  # <- this user-interactive is useful to do while we wait for the long startup

# Loop until we see the config dir ready
#echo
#echo "Checking for directories $CRUISE_CONFIG_DIR"
#echo "Note: Total waiting time should not be more than 30 seconds or so."
#[ ! -d $CRUISE_CONFIG_DIR ] && echo "still not there... waiting until I see it"
#while [ ! -d $CRUISE_CONFIG_DIR ] ; do
#   echo -n "."
#   sleep 1
#done
#sleep 10

#echo "OK init is done.  Stopping go-server."
#sudo service go-server stop

# This seems like it's not being created by itself?
su go -c "mkdir -m 755 -p $COMMANDS_DIR"

# FIXME: This does not actually set up the application currently
# it only creates the user and home dir...
setup_account_creation_application # <- optional

configure_cruise_config_backup "$PASSWORD_FILE"
configure_commands_repo

cd $MYDIR
echo
echo 'Copying password file template'

PDIR="$(dirname "$PASSWORD_FILE")"
mkdir -p "$PDIR"
chown go "$PDIR"
cp "$MYDIR/password_file_template" "$PASSWORD_FILE" || fail "Copying password file template"
chown go:go $PASSWORD_FILE
chmod 600 $PASSWORD_FILE

echo 'WARNING: If users are defined in cruise-config.xml, they must also exist in password file.  In particular the administrator(s), or you will not be able to log in as admin'
cp password_file_template $PASSWORD_FILE || fail "Copying password file template"

echo
echo "Try starting with"
echo "sudo service go-server start"
echo "otherwise with:"
echo "sudo -u go /etc/init.d/go-server start"

