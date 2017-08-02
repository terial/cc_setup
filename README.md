Companion Computer Setup for RPI3

#First create a new user and passwork:
sudo adduser <username>
sudo passwd <username>

#Add user to groups
sudo adduser <username> pi adm dialout cdrom sudo audio video plugdev games users netdev input

#Change hostname and expand file system
sudo raspi-config
#option 2 and change to desired hostname
#option 7 and option A1
#Also you can change the GPU memory split or do this later in /boot/config.txt
#Accept changes and when prompted reboot the pi

#Login using the new username and password

#Delete the old user pi and pi's home directory
sudo deluser pi
sudo rm -r /home/pi

#Clone this repository
sudo apt-get update
sudo apt-get install -y git
sudo mkdir ~/GitHub
cd GitHub

```
$ sudo git-clone https://github.com/terial/cc_setup.git
```
