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

# Start installation of Samba
echo "Starting installation of Samba"
sudo apt-get install -y samba samba-common-bin

# Append /etc/samba/smb.conf to configure shares
#Share for /boot and /opt/log
chmod 755 -R /opt/log
cat >> /etc/samba/smb.conf <<EOF
[Boot]
Comment = Boot
Path = /boot/
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0775
directory mask = 0775
Public = no
Guest ok = no

[Companion Computer Logs]
Comment = Compantion Computer Logs
Path = /opt/log/
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0775
directory mask = 0775
Public = no
Guest ok = no
EOF

# Create user for Samba
read -p "Enter a username for Samba:" USERNAME_SAMBA
smbpasswd -a $USERNAME_SAMBA

# Restart Samba
/etc/init.d/samba restart
