#!/bin/bash
#
# LAMP Stack Installation Script
# Installs Linux, Apache, MariaDB (MySQL), and PHP with phpMyAdmin
# Suitable for Ubuntu/Debian-based systems
#

# Prompt user to enter their network interface name
# Common examples: eth0, ens33, enp0s3
# This is used to display the server's IP address at the end
read -p "Enter the network interface name (e.g., eth0): " network_interface

# Extract the IPv4 address from the specified network interface
# Uses 'ip' command to get interface info, then filters with awk and cut
ip_address=$(ip -o -4 addr show $network_interface | awk '{print $4}' | cut -d'/' -f1)

# Prompt for MySQL root password (input is hidden for security)
# This password will be used for database administration
read -s -p "Enter MySQL root password: " -s mysql_root_password
echo

# Update the system package list to get latest package information
sudo apt update

# Install Apache2 web server
# Apache will serve web pages and handle HTTP requests
sudo apt install -y apache2

# Pre-configure MariaDB installation with the root password
# debconf-set-selections allows unattended installation with preset answers
# This avoids interactive prompts during MariaDB installation
sudo debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password password $mysql_root_password"
sudo debconf-set-selections <<< "mariadb-server-10.5 mysql-server/root_password_again password $mysql_root_password"

# Install MariaDB database server (MySQL-compatible)
sudo apt install -y mariadb-server

# Install PHP and required modules
# - php: Core PHP interpreter
# - libapache2-mod-php: Apache module to process PHP files
# - php-mysql: PHP extension to connect to MySQL/MariaDB databases
sudo apt install -y php libapache2-mod-php php-mysql

# Enable the PHP module in Apache
# a2enmod enables Apache modules
sudo a2enmod php

# Restart Apache to apply the PHP module changes
sudo systemctl restart apache2

# Configure firewall to allow HTTP and HTTPS traffic
# "Apache Full" profile allows both port 80 (HTTP) and 443 (HTTPS)
sudo ufw allow in "Apache Full"

# Install phpMyAdmin - web-based database management tool
# Provides a user-friendly interface to manage MySQL/MariaDB databases
sudo apt install -y phpmyadmin

# Link phpMyAdmin configuration to Apache configuration directory
# This makes phpMyAdmin accessible through the web server
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf

# Enable the phpMyAdmin configuration in Apache
sudo a2enconf phpmyadmin

# Reload Apache to apply phpMyAdmin configuration
sudo systemctl reload apache2

# Grant root user full privileges for phpMyAdmin access
# First command: Grant all privileges to root user from localhost
mysql -u root -p$mysql_root_password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$mysql_root_password';"

# Second command: Apply privilege changes immediately
mysql -u root -p$mysql_root_password -e "FLUSH PRIVILEGES;"

# Display success message with access URLs
echo "LAMP stack with MariaDB and phpMyAdmin is installed. You can access phpMyAdmin at http://$ip_address/phpmyadmin"
echo "You can access your web server at http://$ip_address/"

# Clean up unnecessary packages to free disk space
# autoremove: Remove packages that were installed as dependencies but are no longer needed
sudo apt autoremove -y

# autoclean: Remove downloaded package files from the cache
sudo apt autoclean -y
