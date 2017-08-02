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

# Disable built in bluetooth and enabl UART on /dev/tty/AMA0
systemctl disable hciuart
cat >> /boot/config.txt <<EOF
# Disable bluetooth and enable /dev/ttyAMA0 on UART
dtoverlay=pi3-disable-bt

# Enable UART
enable_uart=1
EOF

# Update packages
sudo apt-get update

# Install required packages and librarios
. $SETUP_DIR/02_install_libraries.sh

# Install mavlink-router
. $SETUP_DIR/03_install_mavlinkrouter.sh

# Install Samba
. $SETUP_DIR/04_install_samba.sh
