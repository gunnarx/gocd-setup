#!/bin/sh
# Encode a password using SHA1, then base64 as used by Go password file
# (unless you're using LDAP instead)

echo 'Enter pass, end with return'
read x
p=$(/bin/echo -n "$x" | sha1sum | awk '{print $1'} | xxd -r -p | base64)
echo "$p"

