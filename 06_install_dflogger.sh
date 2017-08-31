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

# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi

# Check if mavlink-router directory already exists at $INSTALL_DIR
if [ ! -d $INSTALL_DIR/dflogger ]; then
   echo "No existing dflogger directory"
   mkdir $INSTALL_DIR/dflogger
else
    echo "directory dflogger already exists!"
    echo "cleaning existing dflogger directory!"
    rm -rf $INSTALL_DIR/dflogger
fi

# Clone repository and configure/build/install
cd /home/$INSTALL_USER/GitHub
 rm -rf dronekit-la
git clone --recurse-submodules http://github.com/peterbarker/dronekit-la
cd dronekit-la
make dataflash_logger
cp dataflash_logger $INSTALL_DIR/dflogger/dataflash_logger



