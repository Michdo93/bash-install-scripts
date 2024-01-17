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

# Überprüfen, ob phpMyAdmin bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^phpmyadmin$"; then
    echo "phpMyAdmin ist bereits installiert."
else
    # phpMyAdmin Docker Compose-Datei erstellen
    compose_file="$config_dir/phpmyadmin.yml"
    if [ ! -f "$compose_file" ]; then
        # Einen verfügbaren Port finden
        available_port=$(find_next_port 80)

        # Compose-Datei erstellen
        cat > "$compose_file" <<EOL
---
services:
  phpmyadmin:
    image: lscr.io/linuxserver/phpmyadmin:latest
    container_name: phpmyadmin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - PMA_ARBITRARY=1
      - PMA_ABSOLUTE_URI=https://phpmyadmin.example.com
    ports:
      - "$available_port:80"
    restart: unless-stopped
EOL

        echo "phpMyAdmin Docker Compose-Datei erstellt."
    else
        echo "Die phpMyAdmin Docker Compose-Datei existiert bereits."
    fi

    # Container nach dem Systemstart ausführen
    sudo systemctl enable docker.service
    sudo systemctl start docker.service

    exec_command="docker-compose -f $compose_file up -d --remove-orphans"
    stop_command="docker-compose -f $compose_file down"

    # Service-Datei erstellen
    service_file="/etc/systemd/system/phpmyadmin-setup.service"
    cat > "$service_file" <<EOL
[Unit]
Description=phpMyAdmin Setup
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
    sudo systemctl enable phpmyadmin-setup.service
    sudo systemctl start phpmyadmin-setup.service
fi
