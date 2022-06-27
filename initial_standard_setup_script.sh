#!/bin/bash
IPADDR=$(hostname -I | awk '{print $1}')
#Basic URL to the Webserver which serving the required files
WEBSTOREURL=
MANAGING_USER=
#Key to write the IP of this Host into the serverlist.txt
PROVISIONKEY=
#NAS
NAS=

##########################################################################################################################################

#Remove authorized_keys2
rm /root/.ssh/authorized_keys2

#Update Server
apt-get update
apt-get upgrade -y
apt-get autoremove -y

#Install Utility software
apt-get install sudo curl git gnupg2 wget qemu-guest-agent cloud-init -y

#Create Managing User and add it to sudo group
useradd -m $MANAGING_USER
mkdir /home/$MANAGING_USER/.ssh
usermod -aG sudo $MANAGING_USER

#Get the essential Files for the specified User and adjust Permissions
wget $WEBSTOREURL/$MANAGING_USER/authorized_keys -O /home/$MANAGING_USER/.ssh/authorized_keys
wget $WEBSTOREURL/$MANAGING_USER/servermanager-sudo -O /etc/sudoers.d/servermanager-sudo
wget $WEBSTOREURL/$MANAGING_USER/servermanagerprovision -O $PROVISIONKEY
chmod 600 $PROVISIONKEY

#Write the IP of this Host to the serverlist.txt
ssh -i $PROVISIONKEY $MANAGING_USER@$NAS "/bin/echo -e $IPADDR >> /volume2/IT/Skripte/Adminscripts/automatic-scripts/serverlist.txt"

#Remove Provision Key
rm $PROVISIONKEY
