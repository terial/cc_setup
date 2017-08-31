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
mkdir $INSTALL_DIR/cmavnode
cp /home/$INSTALL_USER/GitHub/cmavnode/build/cmavnode $INSTALL_DIR/cmavnode/cmavnode

cat > $INSTALL_DIR/cmavnode/cmavnode.conf.sample << \EOF
#[aseriallink]
#    type=serial
#    port=/dev/ttyUSB0
#    baud=57600

[audplink]
    type=udp
    targetip=127.0.0.1
    targetport=14559
    localport=14550
    sim_enable=true
    sim_packet_loss=25
    packet_drop_enable=true

[audplink2]
    type=udp
    targetip=127.0.0.1
    targetport=14555
    localport=14556
EOF

# Copy preconfigured cmavnode.txt to /boot/cmavnode.txt
cp $SETUP_DIR/cmavnode.txt /boot/cmavnode.txt 

# Create cmavnode start script
cat > $INSTALL_DIR/cmavnode/start_cmavnode.sh << \EOF
#!/bin/bash
#

# cmavnode
CMAVNODE_DIR=/opt/cmavnode
CMAVNODE_LOG=/opt/log/services

# Get cmavnode.txt from /boot and conver to CMAVNODE_DIR/cmavnode.conf
DETECT_CONF=`ls /boot | grep -c cmavnode.txt`
if [ "$DETECT_CONF" == "0" ]; then
echo "No configuration file found for mavlink-router!"
exit 1
else
echo "Getting configuration file.."
dos2unix -n /boot/cmavnode.txt $CMAVNODE_DIR/cmavnode.conf
fi

# Start Mavlink-router
$CMAVNODE_DIR/cmavnode -i -f $CMAVNODE_DIR/cmavnode.conf > $CMAVNODE_LOG/start_cmavnode.log 2>&1
EOF

# add execute permissions to start_cmavnode.sh
chmod +x $INSTALL_DIR/$CMAVNODE_DIR/start_cmavnode.sh

# Create directory for mavlink-router dataflash logs
   if [ ! -d /opt/log ]; then
   echo "No existing log directory"
   mkdir /opt/log
   else
   echo "/opt/log already exists!"
   fi

# Create systemd unit file
cat > /etc/systemd/system/cmavnoder.service << \EOF
[Unit]
Description=CMAVNode

[Service]
Type=simple
ExecStart=/opt/cmavnode/start_cmavnode.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
Alias=cmavnode.service
EOF

 Create symlink and reload systemctl and start mavink-router
systemctl daemon-reload
systemctl start cmavnode.service
systemctl status cmavnode.service -l

