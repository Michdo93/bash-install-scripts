#!/bin/bash

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

# Plex Port 32400

curl https://downloads.plex.tv/plex-keys/PlexSign.key | run_command "apt-key add -" "$sudo_available"
echo deb https://downloads.plex.tv/repo/deb public main | run_command "tee /etc/apt/sources.list.d/plexmediaserver.list" "$sudo_available"

run_command "apt update" "$sudo_available"
run_command "apt install plexmediaserver -y" "$sudo_available"

run_command "mkdir -p /opt/plexmedia/{movies,series}" "$sudo_available"
run_command "chown -R plex: /opt/plexmedia" "$sudo_available"

run_command "systemctl start plexmediaserver.service" "$sudo_available"
run_command "systemctl enable plexmediaserver.service" "$sudo_available"
