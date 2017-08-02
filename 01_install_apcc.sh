#!/bin/bash
# Library and package installation script for RPI3 companion computer setup
# for ardupilot. This script is pieced together from the multiple sources and
# is the work of the respective authors.

# Check if running as root
if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

set -e
set -x

# Set location of installation scripts
SETUP_DIR=$(pwd)

# Get current user and directory of scripts
read -p "Enter the working username: " INSTALL_USER
read -p "Enter the root directory for packages(/opt): " INSTALL_DIR
echo "Current user is $INSTALL_USER"
echo "Running installation scripts from $INSTALL_DIR..."

# Create config.env
cat > config.env <<EOF
# Configuration settings for companion computer installation
# DO NOT ALTER this file
export SETUP_DIR=$SETUP_DIR
export INSTALL_USER=$INSTALL_USER
export INSTALL_DIR=$INSTALL_DIR
EOF

# Update packages
sudo apt-get update

# Install required packages and librarios
. $SETUP_DIR/02_install_libraries.sh

# Install mavlink-router
. $SETUP_DIR/03_install_mavlinkrouter.sh

# Install  cmavnode
#. $SETUP_DIR/04_install_cmavnode.sh

# Install mavproxy
#. $SETUP_DIR/03_install_mavproxy.sh

# Install dataflash logger
# Install dataflash logger
#. $SETUP_DIR/04_install_dflogger.sh
	
# Install wifibroadcast
#. $SETUP_DIR/06_install_wifibroadcast.sh

#. $SETUP_DIR/07_install_video.sh
	




