#!/bin/bash

## Delete - delete a user account without a trace...
#	    Not for use with Max OS X

homedir="/home"
pwfile="/etc/passwd"
newpwfile="etc/passwd.new"
suspend="echo suspending "
locker="/etc/passwd.lock"
shadow="/etc/shadow"
newshadow="/etc/shadow.new"

if [ -z $1 ]; then
	echo "Usage: $0 account" >&2; exit 1
elif ["$(whoami)" != "root" ]; then
	echo "Error: you must be 'root' to run this command.">&2; exit 1
fi


