sudo apt update
sudo apt upgrade
sudo apt install gnupg2 curl apt-transport-https -y
echo "deb https://apt.syncthing.net/ syncthing release" > /etc/apt/sources.list.d/syncthing.list
curl -s https://syncthing.net/release-key.txt | apt-key add -
sudo apt update
sudo apt install syncthing -y
touch /etc/systemd/system/syncthing@.service
echo "[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -gui-address="0.0.0.0:8384" -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/syncthing@.service
sudo systemctl daemon-reload
sudo systemctl start syncthing@root
