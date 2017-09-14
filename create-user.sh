#!/bin/bash
# ---------------------------------------------------------------------------
# Function: Create user
# ---------------------------------------------------------------------------

# Once I found that go-server installer created the go user but go-agent 
# installer did not?

# Now used by docker/agent/Dockerfile

[ $(id -u) -eq 0 ] || { echo "Please make sure you run as root to create users" ; exit 1 ; }

create_user() {
  [ -n "$1" ] || { echo "Usage: create_user <username>" ; return 1 ; }

  id "$1" >/dev/null 2>&1
  if [ $? != 0 ] ; then
     groupadd "$1" --gid 1500
     useradd "$1" -g "$1" --uid 1500 -d "$GO_HOME_DIR"
  else
     echo "User $1 exists -- skipping"
  fi
}

