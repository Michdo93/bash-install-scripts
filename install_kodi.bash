#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

sudo apt install ca-certificates apt-transport-https software-properties-common lsb-release -y
sudo add-apt-repository ppa:team-xbmc/ppa -y

sudo apt update

sudo apt install kodi kodi-bin -y

cat <<EOL > "/etc/systemd/system/kodi.service"
[Unit]
Description = Kodi Media Center
After = remote-fs.target network-online.target
Wants = network-online.target

[Service]
User = $USER
Group = $USER
Type = simple
ExecStart = /usr/bin/kodi-standalone
Restart = on-abort
RestartSec = 5

[Install]
WantedBy = multi-user.target
EOL

sudo systemctl start kodi.service
sudo systemctl enable kodi.service
