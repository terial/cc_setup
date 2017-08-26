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

# Start installation of Samba
echo "Starting installation of Samba"
sudo apt-get install -y samba samba-common-bin

# Append /etc/samba/smb.conf to configure shares
# may need additional changes to cmb.conf per https://raspberrypihq.com/how-to-share-a-folder-with-a-windows-computer-from-a-raspberry-pi/
#Share for /boot and /opt/log
cat >> /etc/samba/smb.conf <<EOF
[Boot]
Comment = Boot
Path = /boot/
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0777
directory mask = 0777
Public = no
Guest ok = no

[Companion Computer Logs]
Comment = Compantion Computer Logs
Path = /opt/log/
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0777
directory mask = 0777
Public = no
Guest ok = no
EOF

# Set permissions for shared directories
chown -R $INSTALL_USER /opt/log/dataflash # Allows users to delete dataflash logs
#chown -R $INSTALL_USER /boot # Allows users to configure without removing SD card

# Create user for Samba
smbpasswd -a $INSTALL_USER

# Restart Samba
/etc/init.d/samba restart

# Samba installation finished
echo "Samba installed and running!"
