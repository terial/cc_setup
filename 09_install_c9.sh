#!/bin/bash
#

# Check if running as root
if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

# Get confige stuff
. config.env

# update
apt-get update

# get a version of NodeJS, version 10.28 based off write-up at
# https://medium.com/@chintanp/using-cloud9-3-0-ide-on-raspberry-pi-954cf2d6ab8e
# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi
# get NodeJS, extract, install
cd /home/$INSTALL_USER/GitHub
wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-arm-pi.tar.gz
cd /usr/local
tar -xzf /home/$INSTALL_USER/GitHub/node-v0.10.28-linux-arm-pi.tar.gz —-strip=1
export NODE_PATH=”/usr/local/lib/node_modules”

# check install
CHECK_INSTALL=node --version
echo "$CHECK_INSTALL"

# git clone cloud9 
cd /home/$INSTALL_USER/GitHub
git clone git://github.com/c9/core.git c9sdk
cd c9sdk
scripts/install-sdk.sh