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
. config.env 

# Install directory for wifibroadcast
DIR_INSTALL_WIFIBROADCAST=$INSTALL_DIR/wifibroadcast

# Get updated and install packages
echo "Updating repository and installing required packages..."
apt-get install -y libpcap0.8-dev # For wifibroadcast core 
apt-get install -y wiringpi # For wifibroadcast core
apt-get install -y libjpeg8-dev indent libfreetype6-dev ttf-dejavu-core # Needed DejaVu fonts, and the jpeg and freetype libraries for OpenVG
apt-get install -y libsdl1.2-dev # For WifiBroadcast_rc
#apt-get install -y libsdl2-dev # For WifiBroadcast_rc
apt-get install -y dos2unix # convert text files from /boot from dos format to unix
apt-get install -y socat

# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi

# Build and Install OpenVG for wifibroadcast_osd
echo "Cloning OpenVG repository and build,make,install..."
cd /home/$INSTALL_USER/GitHub
 rm -rf openvg # remove existing openvg repository if it exists
git clone https://github.com/ajstarks/openvg.git # OpendVG for raspberry pi
cd openvg
make all
make library
make install

# Clone repository
echo "Cloning wifibroadcast repository and build,make,install..."
cd /home/$INSTALL_USER/GitHub
 rm -rf cc_wifib # remove existing cc_wifib repository if it exists
git clone https://github.com/terial/cc_wifib.git

# Copy configuration text files to /boot
cp /home/$INSTALL_USER/GitHub/cc_wifib/config/apconfig.txt /boot/apconfig.txt
cp /home/$INSTALL_USER/GitHub/cc_wifib/config/joyconfig.txt /boot/joyconfig.txt
cp /home/$INSTALL_USER/GitHub/cc_wifib/config/osdconfig.txt /boot/osdconfig.txt
cp /home/$INSTALL_USER/GitHub/cc_wifib/config/wifibroadcast.txt /boot/wifibroadcast.txt
cp /home/$INSTALL_USER/GitHub/cc_wifib/config/wifibroadcast_bitrates.txt /boot/wifibroadcast_bitrates.txt

# Copy wifibroadcast files to DIR_INSTALL_WIFIBROADCAST
 rm -rf $DIR_INSTALL_WIFIBROADCAST # remove existing wifibroadcast if it exists
mkdir $DIR_INSTALL_WIFIBROADCAST
mkdir $DIR_INSTALL_WIFIBROADCAST/wifibroadcast
cp -a /home/$INSTALL_USER/GitHub/cc_wifib/wifibroadcast/. $DIR_INSTALL_WIFIBROADCAST/wifibroadcast
mkdir $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_misc
cp -a /home/$INSTALL_USER/GitHub/cc_wifib/wifibroadcast_misc/. $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_misc
mkdir $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_osd
cp -a /home/$INSTALL_USER/GitHub/cc_wifib/wifibroadcast_osd/. $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_osd
mkdir $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_rc
cp -a /home/$INSTALL_USER/GitHub/cc_wifib/wifibroadcast_rc/. $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_rc
mkdir $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_status
cp -a /home/$INSTALL_USER/GitHub/cc_wifib/wifibroadcast_status/. $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_status

# Using dos2unix, copy the configuration files from /boot and rename as needed
# using flag -n will always write to a new file.
dos2unix -n /boot/osdconfig.txt $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_osd/osdconfig.h
dos2unix -n /boot/joyconfig.txt $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_rc/rctx.h > /dev/null 2>&1
dos2unix -n /boot/apconfig.txt /tmp/apconfig.txt # unused until ap is setup

# Build wifibroadcast
cd $DIR_INSTALL_WIFIBROADCAST/wifibroadcast
make all
cd $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_osd
make all
cd $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_rc
chmod 755 build.sh
./build.sh
cd $DIR_INSTALL_WIFIBROADCAST/wifibroadcast_status
make all
