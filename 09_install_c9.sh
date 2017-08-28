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

# update
apt-get update

# get a version of NodeJS, version 10.28 based off write-up at
# https://medium.com/@chintanp/using-cloud9-3-0-ide-on-raspberry-pi-954cf2d6ab8e
# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi
# get NodeJS, extract, install
cd /home/$INSTALL_USER/GitHub
wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-arm-pi.tar.gz
cd /usr/local
tar -xzf /home/$INSTALL_USER/GitHub/node-v0.10.28-linux-arm-pi.tar.gz —-strip=1
export NODE_PATH=”/usr/local/lib/node_modules”

# check install
CHECK_INSTALL=node --version
echo "$CHECK_INSTALL"

# git clone cloud9 
cd /home/$INSTALL_USER/GitHub
git clone git://github.com/c9/core.git c9sdk
cd c9sdk
scripts/install-sdk.sh

cp -r /home/$INSTALL_USER/GitHub/c9sdk $INSTALL_DIR/c9sdk

# Create startup script
cat > $INSTALL_DIR/c9sdk/start_c9sdk.sh << \EOF
#!/bin/bash
#

set -e
set -x

DIR_C9SDK=/opt/c9sdk

# Get mavlink-router.txt from /boot and conver to MAVLINK_ROUTER_DIR/mavlink-router.conf
DETECT_CONF=`ls /boot | grep -c c9sdk.txt`
if [ "$DETECT_CONF" == "0" ]; then
echo "No configuration file found for Cloud9 SDK!"
exit 1
else
echo "Getting configuration file.."
dos2unix -n /boot/c9sdk.txt $DIR_C9SDK/c9sdk.conf
fi

# Get configuration
. $DIR_C9SDK/c9sdk.conf

# Start Cloud 9 SDK
EXEC_CMD=. $DIR_C9SDK/server.js -w $WORKSPACE -p $PORT -l $IP -a $USER:$PASSWD > /opt/log/services/start_c9sdk.log 2>&1
EOF

# change permissions to startc9sdk.sh
chmod +x $INSTALL_DIR/c9sdk/start_c9sdk.sh

# Create systemd unit file
cat > /etc/systemd/system/cloud9.service << \EOF
[Unit]
Description=Cloud9 Development Environment
After=network.target

[Service]
Type=simple
ExecStart=/opt/c9sdk/start_c9sdk.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
Alias=cloud9.service
EOF

systemctl daemon-reload
systemctl start cloud9.service
systemctl status cloud9.service -l
