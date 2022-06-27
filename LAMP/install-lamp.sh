#!/bin/bash
MYSQL-FILE=mysql-apt-config_0.8.22-1_all.deb

#################################################################################################################################################################

#Update/Upgrade Server
apt update
apt upgrade

#Install sudo, wget, ufw and apache2
apt install sudo -y
sudo apt install wget -y
sudo apt install apache2 -y
sudo apt install ufw -y

#Define Ports for LAMP
sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw allow 'Apache Full'
sudo ufw status
sudo systemctl status apache2

#Install MySQL from File
wget https://dev.mysql.com/get/$MYSQL-FILE
sudo apt install ./$MYSQL-FILE

#Install MySQL-Server
sudo apt update
sudo apt install mysql-server
sudo service mysql status
sudo mysql_secure_installation
sudo apt -y install lsb-release apt-transport-https ca-certificates
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update
sudo apt install -y php libapache2-mod-php php8.1-mysql php8.1-common php8.1-mysql php8.1-xml php8.1-xmlrpc php8.1-curl php8.1-gd php8.1-imagick php8.1-cli php8.1-dev php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-intl -y
