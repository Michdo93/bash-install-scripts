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

# Überprüfen, ob Docker Compose bereits installiert ist
if is_docker_compose_installed; then
    echo "Docker Compose ist bereits installiert."
else
    # Installieren von Docker Compose
    sudo_available=$(check_sudo)
    run_command "curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" "$sudo_available"
    run_command "chmod +x /usr/local/bin/docker-compose" "$sudo_available"
fi

# Überprüfen, ob Snipe-IT bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^snipe-it$"; then
    echo "Snipe-IT ist bereits installiert."
else
    # Snipe-IT Docker Compose-Datei erstellen
    compose_file="$config_dir/snipe-it.yml"
    if [ ! -f "$compose_file" ]; then
        # Compose-Datei erstellen
        cat > "$compose_file" <<EOL
---
services:
  snipe-it:
    image: lscr.io/linuxserver/snipe-it:latest
    container_name: snipe-it
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - APP_URL=http://localhost:8080
      - MYSQL_PORT_3306_TCP_ADDR=
      - MYSQL_PORT_3306_TCP_PORT=
      - MYSQL_DATABASE=
      - MYSQL_USER=
      - MYSQL_PASSWORD=
    volumes:
      - /path/to/data:/config
    ports:
      - 8080:80
    restart: unless-stopped
EOL

        echo "Die Snipe-IT Docker Compose-Datei wurde erstellt. Bitte passen Sie die Datei nach Bedarf an."
    else
        echo "Die Docker Compose-Datei für Snipe-IT existiert bereits: $compose_file"
    fi

    # Docker Compose ausführen
    run_command "docker-compose -f $compose_file up -d" "$sudo_available"
fi
