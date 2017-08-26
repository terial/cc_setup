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

# Check if GitHub folder already exists
if [ ! -d /home/$INSTALL_USER/GitHub ]; then
    mkdir /home/$INSTALL_USER/GitHub
else
    echo "$INSTALL_USER/GitHub already exists!"
fi

# Clone repository and configure/build/install
cd /home/$INSTALL_USER/GitHub
 rm -rf mavlink-router
git clone https://github.com/01org/mavlink-router.git
cd mavlink-router
git submodule update --init --recursive
./autogen.sh
./configure CFLAGS='-g -O2' --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib64 --prefix=/usr --disable-systemd
# Check if mavlink-router directory already exists at $INSTALL_DIR
if [ ! -d $INSTALL_DIR/mavlink-router ]; then
   echo "No existing mavlink-router directory"
else
    echo "directory mavlink-router already exists!"
    echo "cleaning existing mavlink-router directory!"
    rm -rf $INSTALL_DIR/mavlink-router
fi

make DESTDIR=$INSTALL_DIR/mavlink-router/ install

# Create a template config based of mavlink-router sample
cat > $INSTALL_DIR/mavlink-router/mavlink-router.conf.sample <<EOF
# mavlink-router configuration file is composed of sections,
# each section has some keys and values. They
# are case insensitive, so `Key=Value` is the same as `key=value`.
#
# [This-is-a-section name-of-section]
# ThisIsAKey=ThisIsAValuye
#
# Following specifications of expected sessions and key/values.
#
# Section [General]: This section doesn't have a name.
#
# Keys:
#   TcpServerPort
#       A numeric value defining in which port mavlink-router will
#       listen for TCP connections. A zero value disables TCP listening.
#       Default: 5760
#
#   ReportStats
#       Boolean value <true> or <false> case insensitive, or <0> or <1>
#       defining if traffic statistics should be reported.
#       Default: false
#
#   MavlinkDialect
#       One of <auto>, <common> or <ardupilotmega>. Defines which MAVLink
#       dialect is being used by flight stack, so mavlink-router can log
#       appropiately. If <auto>, mavlink-router will try to decide based
#       on heartbeat received from flight stack.
#       Default: auto
#
#   Log
#       Path to directory where to store flightstack log.
#       No default value. If absent, no flightstack log will be stored.
#
#   DebugLogLevel
#       One of <error>, <warning>, <info> or <debug>. Which debug log
#       level is being used by mavlink-router, with <debug> being the
#       most verbose.
#       Default:<info>
#
# Section [UartEndpoint]: This section must have a name
#
# Keys:
#   Device
#       Path to UART device, like `/dev/ttyS0`
#       No default value. Must be defined.
#
#   Baud
#       Numeric value stating baudrate of UART device
#       Default: 115200
#
#   FlowControl
#       Boolean value <true> or <false> case insensitive, or <0> or <1>
#       defining if flow control should be enabled
#       Default: false
#
#
# Section [UdpEndpoint]: This section must have a name
#
# Keys:
#   Address
#       If on `Normal` mode, IP to which mavlink-router will
#       route messages to (and from). If on `Eavesdropping` mode,
#       IP of interface to which mavlink-router will listen for
#       incoming packets. In this case, `0.0.0.0` means that
#       mavlink-router will listen on all interfaces.
#       No dafault value. Must be defined.
#
#   Mode
#       One of <normal> or <eavesdropping>. See `Address` for more
#       information.
#       No default value. Must be defined
#
#   Port
#       Numeric value defining in which port mavlink-router will send
#       packets (or listen for them).
#       Default value: Increasing value, starting from 14550, when
#       mode is `Normal`. Must be defined if on `Eavesdropping` mode.
#
# Section [TcpEndpoint]: This section must have a name
#
# Keys:
#   Address:
#       IP to which mavlink-router will connect to.
#       No default value. Must be defined.
#
#   Port:
#       Numeric value with port to which mavlink-router will connect to.
#       No dafault value. Must be defined.
#
#   RetryTimeout:
#       Numeric value defining how many seconds mavlink-router should wait
#       to reconnect to IP in case of disconnection. A value of 0 disables
#       reconnection.
#       Default value: 5
#
# Following, an example of configuration file:
[General]
#Mavlink-router serves on this TCP port
TcpServerPort=5790
ReportStats=false
#Which mavlink dialect is being used. Can be `common`[default] or `ardupilotmega`
MavlinkDialect=ardupilotmega

[UdpEndpoint alfa]
Mode = Eavesdropping
Address = 0.0.0.0
Port = 10000

[UartEndpoint bravo]
Device = /dev/tty0
Baud = 52000

[UdpEndpoint charlie]
Mode = Normal
Address = 127.0.0.1
Port = 11000

#Mavlink-router will connect to this TCP address
[TcpEndpoint delta]
Address = 127.0.0.1
Port = 25790
RetryTimeout=10
EOF

# Copy preconfigured mavlink-router.conf to INSTALL_DIR/mavink-router/
cp $SETUP_DIR/mavlink-router.conf /boot/mavlink-router.txt 

# Create mavlink-router start script
cat > $INSTALL_DIR/mavlink-router/mavlink-router.sh <<EOF
#!/bin/bash
#

# Mavlink-router
MAVLINK_ROUTER_DIR=/opt/mavlink-router
MAVLINK_ROUTER_EXEC=/opt/mavlink-router/usr/bin
MAVLINK_ROUTER_CONF=/opt/mavlink-router
MAVLINK_ROUTER_LOG=/opt/log/services

# Get mavlink-router.txt from /boot and conver to MAVLINK_ROUTER_DIR/mavlink-router.conf
DETECT_CONF=`ls /boot | grep -c mavlink-router.txt`
if [ "$DETECT_CONF" == "0" ]; then
echo "No configuration file found for mavlink-router!"
exit 1
else
echo "Getting configuration file.."
dos2unix -n /boot/mavlink-router.txt $MAVLINK_ROUTER_CONF/mavlink-router.conf
fi

# Start Mavlink-router
$MAVLINK_ROUTER_EXEC/mavlink-routerd -c $MAVLINK_ROUTER_CONF/mavlink-router.conf > $MAVLINK_ROUTER_LOG/start_mavlink-router.log 2>&1
EOF

# Create directory for mavlink-router dataflash logs
if [ ! -d /opt/log ]; then
   echo "No existing log directory"
else
    echo "log directory already exists!"
    echo "cleaning existing log directory!"
    rm -rf /opt/log
fi

# and set permissions to allow r+w
mkdir /opt/log
mkdir /opt/log/dataflash
mkdir /opt/log/services
chown -R $INSTALL_USER /opt/log

# Create systemd unit file
cat > /etc/systemd/system/mavlink-router.service <<EOF
[Unit]
Description=MAVLink Router

[Service]
Type=simple
ExecStart=/opt/mavlink-router/start_mavlink-router.sh
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
Alias=mavlink-router.service
EOF

# Create symlink and reload systemctl and start mavink-router
systemctl daemon-reload
systemctl start mavlink-router.service
systemctl status mavlink-router.service -l
