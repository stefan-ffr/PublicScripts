#!/bin/bash
#
# Syncthing Installation Script
# Installs and configures Syncthing for continuous file synchronization
# Suitable for Ubuntu/Debian-based systems
#

# Update the package list to ensure we have the latest package information
sudo apt update

# Upgrade all installed packages to their latest versions
sudo apt upgrade

# Install required dependencies for adding the Syncthing repository
# - gnupg2: GNU Privacy Guard for verifying package signatures
# - curl: Command-line tool for downloading files
# - apt-transport-https: Allows apt to retrieve packages over HTTPS
sudo apt install gnupg2 curl apt-transport-https -y

# Add the official Syncthing repository to the system's package sources
# This ensures we get the latest stable version of Syncthing
echo "deb https://apt.syncthing.net/ syncthing release" > /etc/apt/sources.list.d/syncthing.list

# Download and add the Syncthing release key for package verification
# This ensures the packages are authentic and haven't been tampered with
curl -s https://syncthing.net/release-key.txt | apt-key add -

# Update package list again to include packages from the newly added Syncthing repository
sudo apt update

# Install Syncthing
sudo apt install syncthing -y

# Create the systemd service file for Syncthing
# touch creates an empty file if it doesn't exist
touch /etc/systemd/system/syncthing@.service

# Write the systemd service configuration
# This configures Syncthing to run as a system service
# Key settings:
# - %I and %i: Placeholder for the username (allows per-user instances)
# - -no-browser: Don't automatically open web browser on start
# - -gui-address="0.0.0.0:8384": Listen on all interfaces on port 8384
# - -no-restart: Let systemd handle restarts
# - Restart=on-failure: Automatically restart if the service fails
echo "[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -gui-address=\"0.0.0.0:8384\" -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/syncthing@.service

# Reload systemd to recognize the new service file
# This makes systemd aware of the newly created service
sudo systemctl daemon-reload

# Start Syncthing service for the root user
# Format: syncthing@username
# Change "root" to another username if you want to run it as a different user
sudo systemctl start syncthing@root
