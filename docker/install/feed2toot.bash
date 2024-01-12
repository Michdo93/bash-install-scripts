#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"

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
        sudo $cmd
    else
        $cmd
    fi
}

# Überprüfen, ob Docker bereits installiert ist
if is_docker_installed; then
    echo "Docker ist bereits installiert."
else
    # Installieren von Docker
    sudo_available=$(check_sudo)
    run_command "apt update" "$sudo_available"
    run_command "apt upgrade -y" "$sudo_available"
    run_command "apt install curl git wget net-tools ca-certificates gnupg -y" "$sudo_available"
    run_command "install -m 0755 -d /etc/apt/keyrings" "$sudo_available"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    run_command "chmod a+r /etc/apt/keyrings/docker.gpg" "$sudo_available"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | run_command "tee /etc/apt/sources.list.d/docker.list > /dev/null" "$sudo_available"
    run_command "apt update" "$sudo_available"
    run_command "apt install docker-ce docker-ce-cli containerd.io -y" "$sudo_available"
fi

run_command "mkdir -p $config_dir" "$sudo_available"

# Docker Compose-Datei erstellen
compose_file="$config_dir/feed2toot.yml"
cat > "$compose_file" <<EOL
version: "2.1"
services:
  feed2toot:
    image: lscr.io/linuxserver/feed2toot:latest
    container_name: feed2toot
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - FEED_LIMIT=5 #optional
    volumes:
      - /path/to/feed2toot/config:/config
    restart: unless-stopped
EOL

echo "Docker Compose-Datei für feed2toot erstellt."

exec_command="docker-compose -f $compose_file up -d --remove-orphans"
stop_command="docker-compose -f $compose_file down"

# Service-Datei erstellen
service_file="/etc/systemd/system/feed2toot.service"
cat > "$service_file" <<EOL
[Unit]
Description=Feed2Toot
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
sudo systemctl enable feed2toot.service
sudo systemctl start feed2toot.service
