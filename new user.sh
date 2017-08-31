#!/bin/bash
#

# Check if running as root
if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

read -p "Enter new user name.." USER
adduser $USER
adduser $USER groups
adduser $USER pi
adduser $USER dialout
adduser $USER adm
adduser $USER cdrom
adduser $USER sudo
adduser $USER audio
adduser $USER video
adduser $USER plugdev
adduser $USER games
adduser $USER users
adduser $USER netdev
adduser $USER input

echo "New user added.."
