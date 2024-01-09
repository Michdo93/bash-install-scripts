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
        sudo $cmd
    else
        $cmd
    fi
}

# Aktualisieren und Upgraden
sudo_available=$(check_sudo)
run_command "apt update" "$sudo_available"
run_command "apt upgrade -y" "$sudo_available"

# Installieren von Paketen
run_command "apt install curl git wget net-tools apt-transport-https -y" "$sudo_available"

# Jellyfin installieren
JELLYFIN_KEYRING="/usr/share/keyrings/jellyfin-archive-keyring.gpg"
JELLYFIN_REPO="https://repo.jellyfin.org/ubuntu"
JELLYFIN_LIST="/etc/apt/sources.list.d/jellyfin.list"

run_command "wget -O $JELLYFIN_KEYRING $JELLYFIN_REPO/jellyfin-archive-keyring.gpg" "$sudo_available"
echo "deb [signed-by=$JELLYFIN_KEYRING] $JELLYFIN_REPO $(lsb_release -cs) main" | run_command "tee $JELLYFIN_LIST" "$sudo_available"

run_command "apt update" "$sudo_available"
run_command "apt install jellyfin -y" "$sudo_available"

# Jellyfin-Dienst starten und aktivieren
run_command "systemctl start jellyfin.service" "$sudo_available"
run_command "systemctl enable jellyfin.service" "$sudo_available"
