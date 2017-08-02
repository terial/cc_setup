#!/bin/bash
# Library and package installation script for RPI3 companion computer setup
# for ardupilot. This script is pieced together from the multiple sources and
# is the work of the respective authors.

# Check if running as root
if [ $(id -u) -ne 0 ]; then
   echo >&2 "Must be run as root"
   exit 1
fi

#
set -e
set -x

# Check config.env
. config.env

# Update packages
apt-get update

# Remove modem manager if installed
echo "Removing modem manager..."
apt-get purge -y modemmanager

# Install_required libraries and packages
echo "Installing required libraries and packages, this may take a while..."
apt-get install -y \
	autoconf \
	avahi-daemon \
	strace \
	ltrace \
	tcpdump \
	lsof \
	mlocate \
	v4l-utils \
	usbutils \
	tree \
	wireless-tools \
	cmake \
	libavcodec-dev \
	libswscale-dev \
	libv4l-dev \
	libboost-dev \
	libboost-thread-dev \
	libboost-program-options-dev \
	libgtk2.0-dev \
	libpcap0.8-dev \
	libconfig-dev \
	libconfig++-dev \
	libreadline-dev \
	libpoppler-private-dev \
	libjpeg8-dev \
	libxvidcore-dev \
	libx264-dev \
	indent \
	libfreetype6-dev \
	ttf-dejavu-core \
	build-essential \
	libjsoncpp-dev \
	libjsoncpp0 \
	python-dev \
	python-numpy \
	python3-numpy \
	python-pip \
	python-opencv \
	dh-autoreconf \
	screen \
	python2.7-dev \
	python3-dev \
	libatlas-base-dev \
	gfortran \
	python-wxgtk2.8 \
	python-matplotlib \
	python-opencv \
	python-pip \
	python-numpy \
	python-dev \
	libxml2-dev \
	libxslt-dev

#Install packages using pip
pip install future

# Remove unused packages
echo "Removing unused packages..."
apt-get autoremove -y

# Clear cache
echo "Clearing cache..."
apt-get clean

# Finished!
echo "Required libraries and packages installed!"
