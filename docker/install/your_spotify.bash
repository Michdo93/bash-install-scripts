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

# Überprüfen, ob your_spotify bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^your_spotify$"; then
    echo "your_spotify ist bereits installiert."
else
    # Installieren und Starten von your_spotify
    sudo_available=$(check_sudo)
    run_command "docker run -d --name=your_spotify --restart=unless-stopped -e PUID=1000 -e PGID=1000 -e TZ=Etc/UTC -e APP_URL=http://localhost -e SPOTIFY_PUBLIC= -e SPOTIFY_SECRET= -e CORS=http://localhost:80,https://localhost:443 -e MONGO_ENDPOINT=mongodb://mongo:27017/your_spotify -p 80:80 -p 443:443 lscr.io/linuxserver/your_spotify:latest" "$sudo_available"
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
compose_file="$config_dir/your_spotify.yml"
if [ ! -f "$compose_file" ]; then
    # Einen verfügbaren Port finden
    available_port=$(find_next_port 80)

    # Compose-Datei erstellen
    cat > "$compose_file" <<EOL
---
version: "2.1"
services:
  your_spotify:
    image: lscr.io/linuxserver/your_spotify:latest
    container_name: your_spotify
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - APP_URL=http://localhost
      - SPOTIFY_PUBLIC=
      - SPOTIFY_SECRET=
      - CORS=http://localhost:80,https://localhost:443
      - MONGO_ENDPOINT=mongodb://mongo:27017/your_spotify
    ports:
      - "$available_port:80"
      - 443:443
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
service_file="/etc/systemd/system/your_spotify-setup.service"
cat > "$service_file" <<EOL
[Unit]
Description=Your Spotify Setup
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
sudo systemctl enable your_spotify-setup.service
sudo systemctl start your_spotify-setup.service
