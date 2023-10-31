#!/bin/bash

# Prompt for MySQL root password
read -p "Enter MySQL root password: " -s mysql_root_password
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

# Test the installation
echo "LAMP stack with MariaDB and phpMyAdmin is installed. You can access phpMyAdmin at http://localhost/phpmyadmin"
echo "You can access your web server at http://localhost/"

# Clean up
sudo apt autoremove -y
sudo apt autoclean -y
