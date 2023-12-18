#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

# Plex Port 32400
#wget https://downloads.plex.tv/plex-media-server-new/1.32.7.7621-871adbd44/debian/plexmediaserver_1.32.7.7621-871adbd44_amd64.deb
#sudo dpkg -i plexmediaserver_1.32.7.7621-871adbd44_amd64.deb

curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

# Entfernen von Carriage-Return-Zeichen am Ende der Datei
sudo dos2unix /etc/apt/sources.list.d/plexmediaserver.list

sudo apt update
sudo apt install plexmediaserver -y

sudo mkdir -p /opt/plexmedia/{movies,series}
sudo chown -R plex: /opt/plexmedia

sudo systemctl start plexmediaserver.service
sudo systemctl enable plexmediaserver.service
