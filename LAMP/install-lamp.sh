#!/bin/bash

# Prompt for MySQL root password
read -p "Enter MySQL root password: " -s mysql_root_password
echo

# Update the package list
sudo apt update

# Install Apache
sudo apt install -y apache2

# Install MySQL and set the root password
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_root_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_root_password"
sudo apt install -y mariadb-server

# Install PHP and required modules
sudo apt install -y php libapache2-mod-php php-mysql

# Enable the Apache and PHP modules
sudo a2enmod php
sudo systemctl restart apache2

# Open the firewall for Apache
sudo ufw allow in "Apache Full"

# Test the installation
echo "LAMP stack is installed and running. You can access your web server at http://localhost/"

# Clean up
rm -- "$0"

