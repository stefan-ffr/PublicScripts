#!/bin/bash

# Prompt for the network interface name
read -p "Enter the network interface name (e.g., eth0): " network_interface

# Get the IP address of the specified network interface
ip_address=$(ip -o -4 addr show $network_interface | awk '{print $4}' | cut -d'/' -f1)

# Prompt for MySQL root password
read -s -p "Enter MySQL root password: " -s mysql_root_password
echo

# Update the package list
sudo apt update

# Install Apache
sudo apt install -y apache2

# Install MariaDB and set the root password
sudo debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password $mysql_root_password"
sudo debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password $mysql_root_password"
sudo apt install -y mariadb-server

# Install PHP and required modules
sudo apt install -y php libapache2-mod-php php-mysql

# Enable the Apache and PHP modules
sudo a2enmod php
sudo systemctl restart apache2

# Open the firewall for Apache
sudo ufw allow in "Apache Full"

# Install phpMyAdmin
sudo apt install -y phpmyadmin

# Configure Apache to work with phpMyAdmin
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin
sudo systemctl reload apache2

# Allow root user access from phpMyAdmin
mysql -u root -p$mysql_root_password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mysql_root_password';"
mysql -u root -p$mysql_root_password -e "FLUSH PRIVILEGES;"

# Test the installation
echo "LAMP stack with MariaDB and phpMyAdmin is installed. You can access phpMyAdmin at http://$ip_address/phpmyadmin"
echo "You can access your web server at http://$ip_address/"

# Clean up
sudo apt autoremove -y
sudo apt autoclean -y
