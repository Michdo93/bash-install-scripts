#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"
container_dir="/opt/docker/containers"

# Überprüfen, ob nmap installiert ist, andernfalls installieren
if ! command -v nmap &> /dev/null; then
    sudo apt update
    sudo apt install nmap -y
fi

# Funktion zum Überprüfen der Portverfügbarkeit
check_port() {
    local port="$1"
    nmap -p "$port" 127.0.0.1 | grep -qE "open|closed"
}

# Funktion zum Suchen des nächsten verfügbaren Ports
find_next_port() {
    local base_port="$1"
    local port="$base_port"

    while check_port "$port"; do
        ((port++))
    done

    echo "$port"
}

# Docker Compose-Datei erstellen, wenn sie nicht existiert
compose_file="$config_dir/webcord.yml"
if [ ! -f "$compose_file" ]; then
    # Einen verfügbaren Port finden
    available_port=$(find_next_port 3000)

    # Compose-Datei erstellen
    cat > "$compose_file" <<EOL
---
version: '3.1'
services:
  webcord:
    image: lscr.io/linuxserver/webcord:latest
    container_name: webcord
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - $container_dir/webcord/config:/config
    ports:
      - "$available_port:3000"
      - 3001:3001
    shm_size: "1gb"
    restart: unless-stopped
EOL

    echo "Docker Compose-Datei erstellt."
else
    echo "Die Docker Compose-Datei existiert bereits."
fi

# Container nach dem Systemstart ausführen
sudo systemctl enable docker.service
sudo systemctl start docker.service

exec_command="docker-compose -f $compose_file up -d --remove-orphans"
stop_command="docker-compose -f $compose_file down"

# Service-Datei erstellen
service_file="/etc/systemd/system/webcord-setup.service"
cat > "$service_file" <<EOL
[Unit]
Description=Webcord
After=docker.service
Requires=docker.service

[Service]
User=$USER
Group=$USER
WorkingDirectory=$config_dir
ExecStart=$exec_command
ExecStop=$stop_command

[Install]
WantedBy=multi-user.target
EOL

# systemd aktualisieren und Service registrieren
sudo systemctl daemon-reload
sudo systemctl enable webcord-setup.service
sudo systemctl start webcord-setup.service
