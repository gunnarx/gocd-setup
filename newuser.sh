#!/bin/sh
# Encode a password using SHA1, then base64 as used by Go password file
# (unless you're using LDAP instead)

[ -z "$1" ] && {
   echo "Usage: $0 <username>"
   echo "Then enter password on standard-in and hit return"
   exit 1
}

read x
p=$(/bin/echo -n "$x" | sha1sum | awk '{print $1'} | xxd -r -p | base64)
echo "$1:$p"
