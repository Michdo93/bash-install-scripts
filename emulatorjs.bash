#!/bin/bash

# Funktion, um zu prüfen, ob Docker installiert ist
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0  # Docker ist installiert
    else
        return 1  # Docker ist nicht installiert
    fi
}

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    if command -v sudo &> /dev/null; then
        echo "sudo"
    else
        echo ""
    fi
}

# Funktion zum Ausführen von Befehlen mit oder ohne sudo
run_command() {
    local cmd="$1"
    local sudo_available="$2"

    if [ -n "$sudo_available" ]; then
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# Überprüfen, ob Docker bereits installiert ist
if is_docker_installed; then
    echo "Docker ist bereits installiert."
else
    # Aktualisieren und Upgraden
    sudo_available=$(check_sudo)
    run_command "apt update" "$sudo_available"
    run_command "apt upgrade -y" "$sudo_available"

    # Installieren von Paketen
    run_command "apt install curl git wget net-tools -y" "$sudo_available"

    # Add Docker's official GPG key:
    run_command "apt update" "$sudo_available"
    run_command "apt install ca-certificates curl gnupg -y" "$sudo_available"
    run_command "install -m 0755 -d /etc/apt/keyrings" "$sudo_available"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    run_command "chmod a+r /etc/apt/keyrings/docker.gpg" "$sudo_available"

    # Add the repository to Apt sources:
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      run_command "tee /etc/apt/sources.list.d/docker.list > /dev/null" "$sudo_available"
    run_command "apt update" "$sudo_available"

    run_command "apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y" "$sudo_available"
fi

run_command "groupadd docker" "$sudo_available"
run_command "usermod -aG docker $USER" "$sudo_available"

# Fehlende Teile des Skripts
run_command "systemctl start docker.service" "$sudo_available"
run_command "systemctl enable docker.service" "$sudo_available"
run_command "systemctl start containerd.service" "$sudo_available"
run_command "systemctl enable containerd.service" "$sudo_available"

# Warten, bis Docker-Dienste vollständig initialisiert sind
while ! docker info &>/dev/null; do
    sleep 1
done

# Docker-Befehl für Portainer ausführen
run_command "docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:latest" "$sudo_available"

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

