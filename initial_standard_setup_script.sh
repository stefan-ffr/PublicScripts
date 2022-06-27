#!/bin/bash
IPADDR=$(hostname -I | awk '{print $1}')
#Basic URL to the Webserver which serving the required files
WEBSTOREURL=
MANAGING_USER=
#Key to write the IP of this Host into the serverlist.txt
PROVISIONKEY=
#NAS
NAS=

rm /root/.ssh/authorized_keys2
apt-get update
apt-get upgrade -y
apt-get autoremove -y
apt-get install sudo curl git gnupg2 wget qemu-guest-agent cloud-init -y
useradd -m $MANAGING_USER
mkdir /home/$MANAGING_USER/.ssh
usermod -aG sudo $MANAGING_USER
wget $WEBSTOREURL/$MANAGING_USER/authorized_keys -O /home/$MANAGING_USER/.ssh/authorized_keys
wget $WEBSTOREURL/$MANAGING_USER/servermanager-sudo -O /etc/sudoers.d/servermanager-sudo
wget $WEBSTOREURL/$MANAGING_USER/servermanagerprovision -O $PROVISIONKEY
chmod 600 $PROVISIONKEY
ssh -i $PROVISIONKEY $MANAGING_USER@$NAS "/bin/echo -e $IPADDR >> /volume2/IT/Skripte/Adminscripts/automatic-scripts/serverlist.txt"
rm $PROVISIONKEY
