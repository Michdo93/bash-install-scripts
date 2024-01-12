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

run_command "mkdir -p $config_dir" "$sudo_available"

# Überprüfen, ob Docker Compose bereits installiert ist
if is_docker_compose_installed; then
    echo "Docker Compose ist bereits installiert."
else
    # Installieren von Docker Compose
    sudo_available=$(check_sudo)
    run_command "curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose" "$sudo_available"
    run_command "chmod +x /usr/local/bin/docker-compose" "$sudo_available"
fi

# Überprüfen, ob fail2ban bereits installiert ist
if docker ps -a --format '{{.Names}}' | grep -q "^fail2ban$"; then
    echo "fail2ban ist bereits installiert."
else
    # Docker Compose-Datei erstellen
    compose_file="$config_dir/fail2ban.yml"
    cat > "$compose_file" <<EOL
version: "2.1"
services:
  fail2ban:
    image: lscr.io/linuxserver/fail2ban:latest
    container_name: fail2ban
    cap_add:
      - NET_ADMIN
      - NET_RAW
    network_mode: host
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - VERBOSITY=-vv #optional
    volumes:
      - /path/to/appdata/config:/config
      - /var/log:/var/log:ro
      - /path/to/airsonic/log:/remotelogs/airsonic:ro #optional
      - /path/to/apache2/log:/remotelogs/apache2:ro #optional
      - /path/to/authelia/log:/remotelogs/authelia:ro #optional
      - /path/to/emby/log:/remotelogs/emby:ro #optional
      - /path/to/filebrowser/log:/remotelogs/filebrowser:ro #optional
      - /path/to/homeassistant/log:/remotelogs/homeassistant:ro #optional
      - /path/to/lighttpd/log:/remotelogs/lighttpd:ro #optional
      - /path/to/nextcloud/log:/remotelogs/nextcloud:ro #optional
      - /path/to/nginx/log:/remotelogs/nginx:ro #optional
      - /path/to/nzbget/log:/remotelogs/nzbget:ro #optional
      - /path/to/overseerr/log:/remotelogs/overseerr:ro #optional
      - /path/to/prowlarr/log:/remotelogs/prowlarr:ro #optional
      - /path/to/radarr/log:/remotelogs/radarr:ro #optional
      - /path/to/sabnzbd/log:/remotelogs/sabnzbd:ro #optional
      - /path/to/sonarr/log:/remotelogs/sonarr:ro #optional
      - /path/to/unificontroller/log:/remotelogs/unificontroller:ro #optional
      - /path/to/vaultwarden/log:/remotelogs/vaultwarden:ro #optional
    restart: unless-stopped
EOL

    echo "fail2ban Docker Compose-Datei erstellt."
fi

exec_command="docker-compose -f $compose_file up -d --remove-orphans"
stop_command="docker-compose -f $compose_file down"

# Service-Datei erstellen
service_file="/etc/systemd/system/fail2ban.service"
cat > "$service_file" <<EOL
[Unit]
Description=Fail2Ban
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
sudo systemctl enable fail2ban.service
sudo systemctl start fail2ban.service
