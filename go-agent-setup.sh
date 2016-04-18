#!/bin/sh

# (C) 2015 Gunnar Andersson
# License: Your choice of GPLv2, GPLv3 or CC-BY-4.0
# (https://creativecommons.org/licenses/by/4.0/)

# ---------------------------------------------------------------------------
# SETTINGS
# ---------------------------------------------------------------------------
VERSION=16.3.0-3183
GO_HOME_DIR=/var/go

# Normalize directory - make sure we start in "this" directory
D=$(dirname "$0")
cd "$D"
MYDIR="$PWD"

fail() { echo "Something went wrong - check script" 1>&2 ; echo $@ 1>&2 ; exit 1 ; }


# ---------------------------------------------------------------------------
# Function: Configure JAVA_HOME variable
# ---------------------------------------------------------------------------
# This is slightly overcomplicated and can probably be rewritten.  Also this
# might be done correctly by the post-install scripts in the deb/rpm but if it
# fails here is another attempt. Anyway, the point is to figure out JAVA_HOME
# and add it to the config file.

add_java_to_conf() {
   sudo cp /etc/default/go-agent /tmp/newconf.$$ || fail "copying conf"
   sudo chmod 666 /tmp/newconf.$$ || fail "conf?"

   javadir=$(ls /usr/lib/jvm | egrep "java-.*-openjdk-.*$" | head -1)
   java_home=/usr/lib/jvm/$javadir/jre
   [ -d "$java_home" ] || fail "Could not figure out JAVA_HOME directory - please check the script"
   [ -x "$java_home/bin/java" ] || fail "Could not find java executable in JAVA_HOME ($java_home) - please check the script"

   export JAVA_HOME="$java_home"
   cat <<EEE >>/tmp/newconf.$$
   export JAVA_HOME="$java_home"
EEE

   # OK, put it back and just in case, fix up permissions and stuff
   sudo mv /tmp/newconf.$$ /etc/default/go-agent
   sudo chown root:root /etc/default/go-agent
   sudo chmod 644 /etc/default/go-agent
}

# MAIN SCRIPT STARTING -- agent

# ---------------------------------------------------------------------------
# Download and install agent (helper script)
# ---------------------------------------------------------------------------
path=$(./download.sh agent $VERSION)

# ---------------------------------------------------------------------------
# Install Java, git and stuff.  N.B.: Java version is coded into helper script.
# ---------------------------------------------------------------------------
./install-java.sh
./install-prerequisites.sh

[ -f "$path" ] || fail "No go-agent installation archive found"

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

# Most (all?) these dirs are likely created by deb/rpm installation
# but creating them just in case.
echo "Fixing install/log directories to be accessible for go user"
sudo mkdir -m 755 -p /var/{log,lib,run}/go-agent $GO_HOME_DIR || fail "Can't create /var/... directories"
sudo chown -R go:go /var/{log,lib,run}/go-agent $GO_HOME_DIR || fail "Can't chown a directory"

[ -f go-agent.conf ] || fail "Can't find go-agent.conf in this directory - giving up"

echo Copying default conf to /etc/default/go-agent
sudo cp go-agent.conf /etc/default/go-agent

echo Determining JAVA_HOME once again and adding to go-agent conf
add_java_to_conf

# ---------------------------------------------------------------------------
# Install useful packages for agent (needed for yocto build etc.)
# ---------------------------------------------------------------------------
./install_agent_build_prerequisites.sh

echo Go-agent is installed - NOTE: It will contact the go server
echo at the defined address: GO_SERVER is set to:
fgrep GO_SERVER= /etc/default/go-agent

echo
echo Current Status:
service go-agent status
echo "Try starting with"
echo "sudo service go-agent start"
echo "otherwise with:"
echo 'sudo -u go /etc/init.d/go-agent start'

