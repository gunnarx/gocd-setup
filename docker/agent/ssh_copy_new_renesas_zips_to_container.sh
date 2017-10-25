#!/bin/sh

# (C) 2017 Gunnar Andersson
# License: Your choice of MPLv2, GPLv2+

usage() {
  echo "Usage: $0 <host> <user> <container> [file.zip...]"
  echo "host = Host IP"
  echo "user = ssh user for logging into host"
  echo "container = Docker container name running go-agent"
  echo "file.zip... = list *all* the files that should be transferred"
  echo
  echo "Make sure to have ssh-agent running or similar to facilitate repeated SSH logins!"
  exit 1
}

fail() {
  echo "Fatal error - aborting" 1>&2
  exit 2
}

[ $# -lt 3 ] && usage

host=$1 ; shift
user=$1 ; shift
cont=$1 ; shift

BIN_LOCATION=/var/go/sgx_bin_gen3
HOST_TMPDIR=/tmp

echocmd() {
  echo "+ $@"
  "$@"
}

echo
echo Copying files into $BIN_LOCATION on docker container $cont, on host $user@$host
echo "WARNING -- dir $BIN_LOCATION will be emptied first!"
echo Hit return to continue
read x

# This bug could be dangerous...
[ -z "$BIN_LOCATION" ] && fail

echo "COPYING TO HOST:"
for f in $@ ; do 
  echocmd scp "$f" "$user@$host:$HOST_TMPDIR"
done

echo "LISTING AGENTS:"
echocmd ssh $user@$host docker ps -a

echo
echo "BEFORE:"
echocmd ssh $user@$host docker exec -i $cont ls -alF "$BIN_LOCATION"

echo
echo REMOVING...
echocmd ssh $user@$host docker exec -i $cont rm -rf "$BIN_LOCATION" \&\& docker exec -i $cont mkdir -p "$BIN_LOCATION" \&\& docker exec -i $cont chown go "$BIN_LOCATION"

echo
echo "NOW: (Dir should now be empty)"
echocmd ssh $user@$host docker exec -i $cont ls -alF "$BIN_LOCATION"

echo
echo "COPYING:"
for f in $@ ; do 
  ff=$(basename "$f")
  echocmd ssh $user@$host tar -C "$HOST_TMPDIR" -cf - "$ff"  \| docker exec -i $cont tar xvf - -C "$BIN_LOCATION"
  echocmd ssh $user@$host docker exec -i $cont chown -R go "$BIN_LOCATION"
done

echo
echo AFTER:
echocmd ssh $user@$host docker exec -i $cont ls -alF "$BIN_LOCATION"

