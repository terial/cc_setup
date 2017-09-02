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

# Define the user and directory for installation
INSTALL_USER=admin
INSTALL_DIR=/opt

# Create config.env
cat > config.env <<EOF
# Configuration settings for companion computer installation
# DO NOT ALTER this file
export SETUP_DIR=$SETUP_DIR
export INSTALL_USER=$INSTALL_USER
export INSTALL_DIR=$INSTALL_DIR
EOF

# The following lines have been commented, use modified config.txt instead
# Disable built in bluetooth and enabl UART on /dev/tty/AMA0
#systemctl disable hciuart
# Check if bluetooth is disabled, if not append /boot to disable
#if grep -q dtoverlay=pi3-disable-bt "/boot/config.txt"; then
#   echo "bluetooth already disabled"
#   else
#   cat >> /boot/config.txt <<EOF

## Disable bluetooth and enable /dev/ttyAMA0 on UART
#dtoverlay=pi3-disable-bt
#EOF
#   echo "bluetooth set to disabled in /boot/config.txt"
#fi

# Check if UART is enabled in /boot/config.txt
#if grep -q enable_uart=1 "/boot/config.txt"; then
#   echo "UART is already enabled"
#   else
#   cat >> /boot/config.txt <<EOF

# Enable UART on /dev/tty/AMA0
#enable_uart=1
#EOF
#   echo "UART enabled on /dev/ttyAMA0"
#fi

# Copy modified config.txt to /boot
cp /boot/config.txt /boot/config.txt.bak
rm -rf /boot/config.txt
cp $SETUP_DIR/config.txt /boot/config.txt

# Copy login script
# http://daroude.at/uncategorized/lets-change-the-motd-of-our-raspberry-pi/
cp $SETUP_DIR/motd.sh /etc/profile.d/motd.sh
chmod 755 /etc/profile.d/motd.sh

# Update packages
#sudo apt-get update

# Make sure install shell scripts are executable
chmod 755 *.sh

# Install required packages and librarios
. $SETUP_DIR/02_install_libraries.sh

# Install MAVProxy
. $SETUP_DIR/03_install_mavproxy.sh

# Install mavlink-router
. $SETUP_DIR/04_install_mavlinkrouter.sh

# Install cmavnode
. $SETUP_DIR/05_install_cmavnode.sh

# Install dflogger
. $SETUP_DIR/06_install_dflogger.sh

# Install Samba
. $SETUP_DIR/07_install_samba.sh

# Install video packages
. $SETUP_DIR/08_install_video.sh

# Install wifibroadcast
. $SETUP_DIR/09_install_wifib.sh

# Install libgphoto2
#. $SETUP_DIR/10_install_libgphoto2.sh

# Install cloud9 SDK
#. $SETUP_DIR/11_install_c9.sh

