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

# Überprüfen, ob steamos bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^steamos$"; then
    echo "steamos ist bereits installiert."
else
    # steamos Docker Compose-Datei erstellen
    compose_file="$config_dir/steamos.yml"
    if [ ! -f "$compose_file" ]; then
        # Compose-Datei erstellen
        cat > "$compose_file" <<EOL
---
services:
  steamos:
    image: lscr.io/linuxserver/steamos:latest
    container_name: steamos
    hostname: hostname #optional
    cap_add:
      - NET_ADMIN
    security_opt:
      - seccomp:unconfined
      - apparmor:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DRINODE=/dev/dri/renderD128
      - HOST_IP=192.168.100.10 #optional
      - STARTUP=KDE #optional
      - RESOLUTION=1920x1080 #optional
    volumes:
      - /path/to/config:/config
      - /dev/input:/dev/input #optional
      - /run/udev/data:/run/udev/data #optional
    ports:
      - 3000:3000
      - 3001:3001
      - 27031-27036:27031-27036/udp #optional
      - 27031-27036:27031-27036 #optional
      - 47984-47990:47984-47990 #optional
      - 48010-48010:48010-48010 #optional
      - 47998-48000:47998-48000/udp #optional
    devices:
      - /dev/dri:/dev/dri
    shm_size: "1gb"
    restart: unless-stopped
EOL

        echo "Die steamos Docker Compose-Datei wurde erstellt. Bitte passen Sie die Datei nach Bedarf an."
    else
        echo "Die Docker Compose-Datei für steamos existiert bereits: $compose_file"
    fi

    # Docker Compose ausführen
    run_command "docker-compose -f $compose_file up -d" "$sudo_available"
fi
