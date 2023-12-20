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

# Jellyfin: Port 8096
sudo apt install apt-transport-https
sudo wget -O /usr/share/keyrings/jellyfin-archive-keyring.gpg https://repo.jellyfin.org/ubuntu/jellyfin-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list

sudo apt update
sudo apt install jellyfin -y

sudo systemctl start jellyfin.service
sudo systemctl enable jellyfin.service
