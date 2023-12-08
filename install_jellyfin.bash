#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

# Jellyfin: Port 8096
sudo apt install apt-transport-https
sudo wget -O /usr/share/keyrings/jellyfin-archive-keyring.gpg https://repo.jellyfin.org/ubuntu/jellyfin-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list

sudo apt update
sudo apt install jellyfin -y

sudo systemctl start jellyfin.service
sudo systemctl enable jellyfin.service