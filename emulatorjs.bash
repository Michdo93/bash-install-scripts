#!/bin/bash

# Überprüfen, ob der Benutzer Root ist
if [ "$(id -u)" -ne 0 ]; then
    echo "Bitte als Root ausführen (mit sudo)." >&2
    exit 1
fi

# Fehlerbehandlung aktivieren
set -e

# Funktion, um zu prüfen, ob Docker installiert ist
is_docker_installed() {
    command -v docker &> /dev/null
}

# Funktion, um zu prüfen, ob sudo verfügbar ist
check_sudo() {
    command -v sudo &> /dev/null && echo "sudo" || true
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

# Überprüfen, ob Docker-Dienste gestartet sind
while ! systemctl is-active --quiet docker.service && ! systemctl is-active --quiet containerd.service; do
    sleep 1
done

# Überprüfen, ob Docker Compose installiert ist
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose ist nicht installiert. Bitte installieren Sie es zuerst." >&2
    exit 1
fi

# Docker-Container für Portainer und EmulatorJS starten
if docker ps -a | grep -q "portainer" || docker ps -a | grep -q "emulatorjs"; then
    echo "Portainer oder EmulatorJS Container sind bereits vorhanden. Skript wird beendet." >&2
    exit 1
fi

# EmulatorJS
#docker pull lscr.io/linuxserver/emulatorjs:latest 

mkdir -p /home/$USER/emulatorjs
run_command "chown -R $USER:$USER /home/$USER/emulatorjs" "$sudo_available"

run_command "mkdir -p /opt/emulatorjs" "$sudo_available"
run_command "chown -R $USER:$USER /opt/emulatorjs" "$sudo_available"

# Dateinamen definieren
DOCKER_COMPOSE_FILE="/home/$USER/emulatorjs/emulatorjs-compose.yml"

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
      - /home/$USER/emulatorjs/config:/config
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

run_command "cat <<EOL > "/etc/systemd/system/docker-compose.service"
    [Unit]
    Description=Docker Compose Application Service
    Requires=docker.service
    After=docker.service

    [Service]
    Type=simple
    WorkingDirectory=/home/$USER/emulatorjs
    ExecStart=/usr/local/bin/docker-compose up -d
    ExecStop=/usr/local/bin/docker-compose down
    Restart=always

    [Install]
    WantedBy=default.target
EOL" "$sudo_available"

run_command "systemctl start docker-compose.service" "$sudo_available"
run_command "systemctl enable docker-compose.service" "$sudo_available"

# NAS
run_command "apt install nfs-kernel-server -y" "$sudo_available"
run_command "systemctl start nfs-kernel-server.service" "$sudo_available"
run_command "systemctl enable nfs-kernel-server.service" "$sudo_available"

echo "/opt/emulatorjs *(rw,sync,no_subtree_check)" | run_command "tee -a /etc/exports" "$sudo_available"

run_command "systemctl restart nfs-kernel-server.service" "$sudo_available"

run_command "apt install samba samba-common-bin -y" "$sudo_available"
run_command "systemctl start smbd.service" "$sudo_available"
run_command "systemctl enable smbd.service" "$sudo_available"

freigabe_verzeichnis="/opt/emulatorjs"

# Samba-Konfigurationsdatei bearbeiten
echo "[emulatorjs]" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   path = $freigabe_verzeichnis" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   browseable = yes" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   read only = no" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   guest ok = yes" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   create mask = 0775" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"
echo "   directory mask = 0775" | run_command "tee -a /etc/samba/smb.conf" "$sudo_available"

# Samba-Dienst neu starten
run_command "systemctl restart smbd.service" "$sudo_available"
