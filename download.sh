#!/bin/sh -x

[ "$#" -lt 2 ] &&  { echo "Usage: $0 <"agent" or "server">  <version>" ; exit 1 ; }

# variant is "agent" or "server"
variant="$1"
version="$2"

type=$(./rpm-or-deb.sh)

case $type in
   rpm)
      arch=".noarch"
      dir="rpm"
      ;;
   deb)
     arch=
     dir="deb"
      ;;
   *)
      fail
      ;;
esac

[ -z "$type" ] && fail "Couldn't figure out if rpm or deb is desired."

file=go-${variant}-${version}${arch}.${type}
filehost="http://download.go.cd"
fileurl="$filehost/binaries/${version}/${dir}/${file}"

# The download URL seemed to require an actual web browser as agent
# or something?  The redirect to the file fails otherwise.
# We need the download so here's an agent string...
agent_str="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8)"

curl=$(which curl)
[ -x "$curl" ] || { echo "Can't find curl -- not installed?" ; exit 1 ; }

if [ -f "$file" ] ; then
   echo "** $type file exists, skipping download.  (If you see install problems, try deleting it to trigger a fresh download)" 1>&2
else
   curl -# -C - -A "$agent_str" -L "$fileurl" >$file || fail "download failed, (network connected?)"
fi

# If OK, report file path to caller
[ -f "$PWD/$file" ] && DL_PATH="$PWD/$file"
