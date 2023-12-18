#!/bin/bash
sudo apt update
sudo apt upgrade -y

sudo apt install curl git wget net-tools -y

# Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo systemctl start containerd.service
sudo systemctl enable containerd.service

# Warten, bis Docker-Dienste vollständig initialisiert sind
while ! docker info &>/dev/null; do
    sleep 1
done

docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:lates

# EmulatorJS
#docker pull lscr.io/linuxserver/emulatorjs:latest 

mkdir -p /home/ubuntu/emulatorjs
sudo chown -R ubuntu:ubuntu /home/ubuntu/emulatorjs

sudo mkdir -p /opt/emulatorjs
sudo chown -R ubuntu:ubuntu /opt/emulatorjs

# Dateinamen definieren
DOCKER_COMPOSE_FILE="/home/ubuntu/emulatorjs/emulatorjs-compose.yml"

# YAML-Code in die Datei schreiben
cat <<EOL > "$DOCKER_COMPOSE_FILE"
version: "2.1"
services:
  emulatorjs:
    image: lscr.io/linuxserver/emulatorjs:latest
    container_name: emulatorjs
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SUBFOLDER=/ #optional
    volumes:
      - /home/ubuntu/emulatorjs/config:/config
      - /opt/emulatorjs/data:/data
    ports:
      - 3000:3000
      - 80:80
      - 4001:4001 #optional
    restart: unless-stopped
EOL

# '/volume1/docker/emulatorjs/config:/config'
# '/volume1/data/retro:/data'

# 3000: Rom/artwork management interface, used to generate/manage config files and download artwork
# 80: Emulation frontend containing static web files used to browse and launch games
# 4001: IPFS peering port, if you want to participate in the P2P network to distribute frontend artwork please forward this to the Internet
# -v /config 	Path to store user profiles
# -v /data 	Path to store roms/artwork

sudo cat <<EOL > "/etc/systemd/system/docker-compose.service"
    [Unit]
    Description=Docker Compose Application Service
    Requires=docker.service
    After=docker.service

    [Service]
    Type=simple
    WorkingDirectory=/home/ubuntu/emulatorjs
    ExecStart=/usr/local/bin/docker-compose up -d
    ExecStop=/usr/local/bin/docker-compose down
    Restart=always

    [Install]
    WantedBy=default.target
EOL

sudo systemctl start docker-compose.service
sudo systemctl enable docker-compose.service

# NAS
sudo apt install nfs-kernel-server -y
sudo systemctl start nfs-kernel-server.service
sudo systemctl enable nfs-kernel-server.service

echo "/opt/emulatorjs *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

sudo systemctl restart nfs-kernel-server.service

sudo apt install samba samba-common-bin -y
sudo systemctl start smbd.service
sudo systemctl enable smbd.service

freigabe_verzeichnis="/opt/emulatorjs"

# Samba-Konfigurationsdatei bearbeiten
echo "[emulatorjs]" | sudo tee -a /etc/samba/smb.conf
echo "   path = $freigabe_verzeichnis" | sudo tee -a /etc/samba/smb.conf
echo "   browseable = yes" | sudo tee -a /etc/samba/smb.conf
echo "   read only = no" | sudo tee -a /etc/samba/smb.conf
echo "   guest ok = yes" | sudo tee -a /etc/samba/smb.conf
echo "   create mask = 0775" | sudo tee -a /etc/samba/smb.conf
echo "   directory mask = 0775" | sudo tee -a /etc/samba/smb.conf

# Samba-Dienst neu starten
sudo systemctl restart smbd.service

