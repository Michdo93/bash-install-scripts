#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"
container_dir="/opt/docker/containers"

# Compose-Datei
compose_file="$config_dir/webcord.yml"

# Service-Datei
service_file="/etc/systemd/system/webcord-setup.service"

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

# Überprüfen, ob Portainer bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^portainer$"; then
    echo "Portainer ist bereits installiert."
else
    # Installieren und Starten von Portainer
    sudo_available=$(check_sudo)
    run_command "docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:latest" "$sudo_available"
fi

# Prüfen, ob nmap installiert ist, andernfalls installieren
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
