#!/bin/bash
# (C) 2017 Gunnar Andersson

# What:  It wipes all OLD dirs/files, when a new one appears
# WARNING hacky and probably pretty buggy

user=go
workingdir=/tmp/pipelines
current=/tmp/current
new=/tmp/new

prepare() {
   [ ! -f $current ] && ls >$current
}

# Lines in first file, minus the second
set_intersection() {
   comm --check-order -12 <(sort $1) <(sort $2)
}

fail() {
   echo $@
   exit 1
}

wipe() {
   for f in $@ ; do
      p=$(readlink -f "$f")
      # Some safety...
      echo "$p" | egrep "^/" && fail "BUG: Path should be absolute" 
      echo "$p" | fgrep " " && fail "BUG: No spaces please - aborting" 
      echo "$p" | fgrep ".." && fail "BUG: No .. please - aborting" 
      echo "$f" | egrep "^/$workingdir" && fail "BUG: Got dangerous path outside workingdir" 
      echo "REMOVING $p"
      su $user -c rm -rf "$p"
   done
}

cd "$workingdir"
prepare
rm -f "$new"
ls >"$new" || fail "Can't ls new"
[ -f "$current" ] || fail "current disappeared"
[ -f "$new" ] || fail "No new list? "
[ $(wc -l <"$new") -eq 0 ] && fail "new file is empty - better abort"
cmp $current $new && exit 0  # Don't delete if there is no difference
targets=`set_intersection $current $new`  # A long as there is a diff, intersection will show only the old (shared) dirs
mv $new $current || fail "FATAL can't update current!"
[ -z "$targets" ] && { echo All done ; exit 0 ; }
wipe "$targets"

