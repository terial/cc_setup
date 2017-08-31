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

# Get packages
apt-get install -y libjsoncpp0

# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi

# Check if dflogger directory already exists at $INSTALL_DIR
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


# Copy preconfigured dflogger to INSTALL_DIR/dflogger/
cp $SETUP_DIR/dflogger.txt /boot/dflogger.txt 

# Create dflogger start script
cat > $INSTALL_DIR/dflogger/start_dflogger.sh << \EOF
#!/bin/bash
#

# dflogger
DFLOGGER_DIR=/opt/dflogger
DFLOGGER_LOG=/opt/log/services

# Get dflogger.txt from /boot and conver to DFLOGGER_DIR/dflogger.conf
DETECT_CONF=`ls /boot | grep -c dflogger.txt`
if [ "$DETECT_CONF" == "0" ]; then
echo "No configuration file found for dfloggerr!"
exit 1
else
echo "Getting configuration file.."
dos2unix -n /boot/dflogger.txt $DFLOGGER_DIR/dflogger.conf
fi

# Start dataflash_logger
$DFLOGGER_DIR/dataflash_logger -d -c $DFLOGGER_DIR/dflogger.conf > $DFLOGGER_LOG/start_dflogger.log 2>&1
EOF

# add execute permissions to start_dflogger.sh
chmod +x $INSTALL_DIR/dflogger/start_dflogger.sh

# Create directory for  dflogger logs
   if [ ! -d /opt/log ]; then
   echo "No existing log directory"
   mkdir /opt/log
   else
    echo "log directory already exists!"
   fi

# Create systemd unit file
cat > /etc/systemd/system/dflogger.service << \EOF
[Unit]
Description=Data Flash Logger

[Service]
Type=simple
ExecStart=/opt/dflogger/start_dflogger.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
Alias=dflogger.service
EOF

# Create symlink and reload systemctl and start mavink-router
systemctl daemon-reload
systemctl start dflogger.service
systemctl status dflogger.service -l
