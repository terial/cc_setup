#!/bin/bash
#

# Check if running as root
if [ $(id -u) -ne 0 ]; then
   echo >&2 "Installation must be run as root"
   exit 1
fi

# Output
set -e
set -x

# Get confige stuff
. $SETUP_DIR/config.env 

# Install directory for gphoto2
#DIR_INSTALL_WIFIBROADCAST=$INSTALL_DIR/gphoto2

# Install required packaged
# https://github.com/gphoto/libgphoto2/blob/master/INSTALL
# https://github.com/gphoto/gphoto2/blob/master/README.md
apt-get install -y /
libexif-dev /
libjpeg-dev /
cdk-devel /
libusb-1.0-0-dev /
gtk-doc-tools /
gettext

#
