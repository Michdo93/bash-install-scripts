#!/bin/bash

# Verzeichnis für Docker-Konfigurationen
config_dir="/opt/docker/configs"
container_dir="/opt/docker/containers"

# Funktion, um zu prüfen, ob Docker installiert ist
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0  # Docker ist installiert
    else
        return 1  # Docker ist nicht installiert
    fi
}

# Funktion, um zu prüfen, ob Docker Compose installiert ist
is_docker_compose_installed() {
    if command -v docker-compose &> /dev/null; then
        return 0  # Docker Compose ist installiert
    else
        return 1  # Docker Compose ist nicht installiert
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
run_command "mkdir -p $container_dir" "$sudo_available"

# Überprüfen, ob Docker Compose bereits installiert ist
if is_docker_compose_installed; then
    echo "Docker Compose ist bereits installiert."
else
    # Installieren von Docker Compose
    sudo_available=$(check_sudo)
    run_command "curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" "$sudo_available"
    run_command "chmod +x /usr/local/bin/docker-compose" "$sudo_available"
fi

# Docker Compose-Datei erstellen, wenn sie nicht existiert
compose_file="$config_dir/lazylibrarian.yml"
if [ ! -f "$compose_file" ]; then
    # Einen verfügbaren Port finden
    available_port=$(find_next_port 5299)

    # Compose-Datei erstellen
    cat > "$compose_file" <<EOL
---
version: "2.1"
services:
  lazylibrarian:
    image: lscr.io/linuxserver/lazylibrarian:latest
    container_name: lazylibrarian
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DOCKER_MODS=linuxserver/mods:universal-calibre|linuxserver/mods:lazylibrarian-ffmpeg #optional
    volumes:
      - $container_dir/lazylibrarian/config:/config
      - /path/to/downloads:/downloads
      - /path/to/books:/books #optional
    ports:
      - "$available_port:5299"
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
service_file="/etc/systemd/system/lazylibrarian.service"
cat > "$service_file" <<EOL
[Unit]
Description=LazyLibrarian
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
sudo systemctl enable lazylibrarian.service
sudo systemctl start lazylibrarian.service

echo "LazyLibrarian wurde installiert und gestartet."
