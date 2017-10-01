#!/bin/sh

# Helper script to remove old pipeline working directories from agent disk.
# I'm not sure if this is overly complicated or not...

D="/home/go/go-agent-pipelines"

# Remove N at a time, 
# (and this will also leave <= N remaining if it runs multiple times)
#
n_remove=4
n_min=2

# List dirs, from newest to oldest
# but not special dirs starting with: __
ls_filtered() {
   # Listing in modification -time order
   # There are no dirs with spaces here normaly but if they are here, make sure
   # to remove them so we won't have strange resulting bugs
   ls -t | grep -v __ | grep -v " "
   # FIXME: This will also do files, if there are files here (there shouldn't be)
}

cd "$D" || { echo "Can't find dir $D" ; exit 2; }

# List dirs, from newest to oldest, check if enough
count=$(ls_filtered | wc -l)
if [ $count -lt $(($n_remove + $n_min)) ] ; then
   # Not enough, do nothing
   echo "Not enough dirs. Stopping."
   exit 0
fi

# Get the oldest of the bunch
candidates=$(ls_filtered | tail -$n_remove)

# Put them in separate dir to make a fast & almost atomic operation
mkdir -p __remove
mv $candidates __remove/ || true
rm -rf __remove

