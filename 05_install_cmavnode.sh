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

# Get required packages
apt-get install -y libboost-all-dev cmake libconfig++-dev libreadline-dev

# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi

# Check if cmavnode directory already exists at $INSTALL_DIR
if [ ! -d $INSTALL_DIR/cmavnode ]; then
   echo "No existing cmavnode directory"
else
    echo "directory cmavnode already exists!"
    echo "cleaning existing cmavnode directory!"
    rm -rf $INSTALL_DIR/cmavnode
fi

# Clone repository and configure/build/install
cd /home/$INSTALL_USER/GitHub
 rm -rf cmavnode
git clone https://github.com/MonashUAS/cmavnode.git
cd cmavnode
git submodule update --init 
mkdir build && cd build
cmake ..
make
#sudo make install

# Copy cmavnode, config file sample and start script to $INSTALL_DIR/cmavnode
cp /home/$INSTALL_USER/GitHub/cmavnode/build/cmavnode $INSTALL_DIR/cmavnode/cmavnode
cp cmavnode.txt




