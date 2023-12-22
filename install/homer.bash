#!/bin/bash

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
        sudo "$cmd"
    else
        "$cmd"
    fi
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools -y" "$sudo_available"

# Überprüfen, ob Docker bereits installiert ist
if is_docker_installed; then
    echo "Docker ist bereits installiert."
else
    # Installiere Docker
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

    run_command "groupadd docker" "$sudo_available"
    run_command "usermod -aG docker $USER" "$sudo_available"

    run_command "systemctl start docker.service" "$sudo_available"
    run_command "systemctl enable docker.service" "$sudo_available"
    run_command "systemctl start containerd.service" "$sudo_available"
    run_command "systemctl enable containerd.service" "$sudo_available"    
fi

# Überprüfen, ob Docker Compose bereits installiert ist
if is_docker_compose_installed; then
    echo "Docker Compose ist bereits installiert."
else
    # Installiere Docker Compose
    run_command "curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" "$sudo_available"
    run_command "chmod +x /usr/local/bin/docker-compose" "$sudo_available"
fi

# Warten, bis Docker-Dienste vollständig initialisiert sind
while ! docker info &>/dev/null; do
    sleep 1
done

# Docker-Befehl für Portainer ausführen
run_command "docker run -d -p 9000:9000 -p 8000:8000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer:latest" "$sudo_available"

# Wechsle zum Verzeichnis, in dem du Docker Compose-Konfiguration speichern möchtest
cd /opt/docker-compose

# Erstelle Docker Compose-Konfigurationsdatei (docker-compose.yml)
cat <<EOL > docker-compose.yml
version: '3.8'

services:
  homer:
    image: b4bz/homer
    restart: always
    ports:
      - "8080:8080"
    volumes:
      - /opt/homer/config:/homer/config
    environment:
      - PUID=1000
      - PGID=1000
EOL

# Starte Homer mit Docker Compose
run_command "docker-compose up -d" "$sudo_available"
