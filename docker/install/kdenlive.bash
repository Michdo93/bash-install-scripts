#!/bin/bash

# Konfiguration
config_dir="/opt/docker/kdenlive"
compose_file="$config_dir/docker-compose.yml"
service_file="/etc/systemd/system/kdenlive.service"

# Überprüfen, ob Docker installiert ist
if ! command -v docker &> /dev/null; then
    echo "Docker ist nicht installiert. Bitte installiere Docker und führe das Skript erneut aus."
    exit 1
fi

# Überprüfen, ob Docker Compose installiert ist
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose ist nicht installiert. Bitte installiere Docker Compose und führe das Skript erneut aus."
    exit 1
fi

# Docker Compose-Datei erstellen
cat > "$compose_file" <<EOL
version: "2.1"
services:
  kdenlive:
    image: lscr.io/linuxserver/kdenlive:latest
    container_name: kdenlive
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SUBFOLDER=/ #optional
    volumes:
      - $config_dir/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    devices:
      - /dev/dri:/dev/dri #optional
    shm_size: "1gb" #optional
    restart: unless-stopped
EOL

# Service-Datei erstellen
cat > "$service_file" <<EOL
[Unit]
Description=Kdenlive
After=docker.service
Requires=docker.service

[Service]
User=$USER
Group=$USER
WorkingDirectory=$config_dir
ExecStart=$(command -v docker-compose) -f $compose_file up -d --remove-orphans
ExecStop=$(command -v docker-compose) -f $compose_file down

[Install]
WantedBy=multi-user.target
EOL

# Berechtigungen für Konfigurationsverzeichnis erstellen
mkdir -p "$config_dir/config"
sudo chown -R $USER:$USER "$config_dir"

# systemd aktualisieren und Service registrieren
sudo systemctl daemon-reload
sudo systemctl enable kdenlive.service
sudo systemctl start kdenlive.service

echo "Kdenlive wurde installiert und gestartet."
