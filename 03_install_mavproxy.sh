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
. $SETUP_DIR/config.env

# Start installation of MAVlink
echo "Starting installation for MAVLink"

# Install required packages and librarios
#sudo apt-get update \ disabled, updated in previous script
sudo apt-get install -y \
	screen \
	python-wxgtk2.8 \
	python-matplotlib \
	python-opencv \
	python-pip \
	python-numpy \
	python-dev \
	libxml2-dev \
	libxslt-dev \
pip install future
pip install pymavlink
pip install mavproxy

# MAVProxy installed!
echo "MAVProxy Installed!"

# General MAVProxy use notes
# http://ardupilot.org/dev/docs/raspberry-pi-via-mavlink.html
#
#
# To test connection
# sudo -s \
# mavproxy.py --master=/dev/ttyS0 --baudrate 921600 --aircraft MyCopter
#
#
# To route MAVProxy out over UDP
# sudo -s \
# mavproxy.py --master=/dev/ttyS0 --baudrate 921600 --out 192.168.XXX.XXX:14550 --aircraft MyCopter
#
#
# To configure MAVProxy t run at start, insert in /etc/rc.local
#(
#date
#echo $PATH
#PATH=$PATH:/bin:/sbin:/usr/bin:/usr/local/bin
#export PATH
#cd /home/pi
#screen -d -m -s /bin/bash mavproxy.py --master=/dev/ttyAMA0 --baudrate 57600 --aircraft MyCopter
#) > /tmp/rc.log 2>&1
#exit 0
